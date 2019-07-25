---
title: Ako nakonfigurovať Jetty v Java kóde
date: 2009-03-21T10:49:10+01:00
description: Servletový kontajner Jetty umožňuje veľmi jednoduché embeddovanie, čiže použitie v rámci iných aplikácií. To sa prejavuje aj v jeho jednoduchej konfigurácii pomocou Java kódu, čo v mnohých jednoduchých prípadoch uľahčuje spúšťanie a ladenie webových aplikácií. V článku si ukážeme základné triedy a mechanizmy, pomocou ktorých je to možné dosiahnuť.
---
# Poznámka k aktuálnosti
Nasledovné údaje sú platné pre Jetty verzie 6 a 7. Existuje verzia pre [Jetty 9](http://ics.upjs.sk/~novotnyr/blog/1162/ako-nakonfigurovat-jetty-v-java-kode ) s mnohými zmenami!

# Úvod
Servletový kontajner Jetty má oproti ostatným riešeniam výhodu v ľahkom *embeddovaní*, čiže použití ako súčasti inej aplikácie. To zároveň znamená, že ho možno veľmi jednoducho nakonfigurovať v Java kóde a spúšťať priamo z našich aplikácií.

To sa mi napríklad osvedčilo pri demonštrovaní a školení rôznych webových frameworkov, kde nie je nutné predstavovať a vysvetľovať nasadzovanie webových aplikácií hneď na začiatku práce s nimi.

## Ako použiť Jetty v našej aplikácii

V jednoduchých prípadoch stačí z celej inštalácie použiť tri archívy:

* `jetty-*.jar` -- obsahuje jadro Jetty
* `jetty-util-*.jar` -- obsahuje ďalšie nutné knižnice jadra Jetty
* `servlet-api-*.jar` -- knižnica s rozhraniami [API servletov](http://java.sun.com/products/servlet/2.5/docs/servlet-2_5-mr2/index.html )

Jetty umožňuje implementovať triedy obsluhujúce HTTP požiadavky klienta viacerými spôsobmi. Od primitívneho handlera až po plne funkčnú webovú aplikáciu konfigurovanú podľa špecifikácie.

# Implementácia tried pomocou handlera
Najprimitívnejším spôsobom ako rýchlo postaviť obslužnú triedu je použitie *handlera*. Handler je konceptuálne veľmi podobný servletom. Nerozlišuje však HTTP príkazy, poskytuje jedinú univerzálnu metódu `handle()`, nie je možné špecifikovať mapovanie URL adries (handler vybavuje ľubovoľnú adresu). Výhoda oproti iným postupom spočíva v tom, že server je možné nakonfigurovať menším počtom riadkov.
```java
public class HelloWorldHandler extends AbstractHandler {
  @Override
  public void handle(String target, HttpServletRequest request,
                 HttpServletResponse response, int dispatch) 
  throws IOException, ServletException 
  {
    System.out.println(target);
    // odpoveď musíme flushnúť, inak ju bude Jetty 
    // bude považovať za nevybavenú a vráti 404
    response.flushBuffer();
  }
}
```
Nevýhoda je nutnosť *flush*-núť odpoveď. V parametri `target` dostaneme príponu URL adresy za názvom servera - čiže ak navštívime adresu `http://localhost:8080/service/data`, v `target`e bude `/service/data`.

Celý server následne naštartujeme troma riadkami. Špecifikujeme port, nastavíme serveru implicitný handler a spustíme ho.
```java
public static void main(String[] args) throws Exception {
  Server server = new Server(8080);
  server.setHandler(new HelloWorldHandler());
  server.start();
}
```
Existuje možnosť používať viacero handlerov naraz, pričom pridať do servera ich môžeme použitím metódy `addHandler()`. Požiadavka na server potom bude obslúžená všetkými handlermi.

# Implementácia tried pomocou jedného servletu
Ďalšou možnosťou je použitie plnoprávneho servletu.
```java
public class DateServlet extends HttpServlet {
  protected void doGet(HttpServletRequest req, 
                       HttpServletResponse resp)
      throws ServletException, IOException {
    
    PrintWriter writer = resp.getWriter();
    // vypíšeme aktuálny dátum a čas
    writer.println(new Date());
  }
}
```
Nasadenie servletov pre jednoduché prípady je možné urobiť pomocou preddefinovaného handlera podporujúceho servlety, čiže triedy `ServletHandler`.
```java
Server server = new Server(8080);

ServletHandler handler = new ServletHandler();
handler.addServletWithMapping(DateServlet.class, "/");
server.setHandler(handler);

server.start();
```
V metóde `addServletWithMapping` špecifikujeme triedu servletu (o vytvorenie inštancie sa postará servlet) a navyše sme povinní uviesť aj koncovku URL adresy, ktorú bude obsluhovať tento servlet. 

Toto primitívne použitie servletového handlera však nedáva k dispozícii [`ServletContext`u](http://java.sun.com/j2ee/1.4/docs/api/javax/servlet/ServletContext.html ) ani sessiony. (Pokus o vytvorenie session zlyhá.)

## Mapovanie URL adries na servlety
Mapovanie je realizované podľa špecifikácie servletov a implementované v triede [PathMap](http://jetty.mortbay.org/apidocs/org/mortbay/jetty/servlet/PathMap.html ). Pravidlá pre vyhodnocovanie sú nasledovné:

* presná zhoda. Sufix `/books` má zhodu s adresou ``http://localhost:8080/books``, ale už nie s `http://localhost:8080/books/orders`.
* hľadanie najdlhšieho sufixu. Špecifikácia sa musí končiť hviezdičkou. Sufix `/books/*` má zhodu s `http://localhost:8080/books/` aj s `http://localhost:8080/books/orders`
* hľadanie najdlhšieho prefixu. Špecifikácia musí začínať hviezdičkou.
Sufix `*.do` má zhodu s `http://localhost:8080/books.do` aj s `http://localhost:8080/books/orders.do`
* štandardné správanie. V tomto prípade má `/` zhodu s ľubovoľnou adresou.

# Implementácia pomocou `ServletHolder`a
V predošlom prípade sme nemali možnosť nijak konfigurovať servlet v takom rozmedzí, ako to poskytuje `web.xml`. `ServletHandler` umožňuje len pridať servlet a namapovať ho na URL. Pokročilú konfiguráciu možno riešiť cez `ServletHolder`, ktorým obalíme inštanciu servletu, a pridáme ho do `Server`a.
```java
ServletHandler handler = new ServletHandler();

ServletHolder springServletHolder 
  = new ServletHolder(DispatcherServlet.class);
// ekvivalentné nastaveniu init-param vo web.xml
springServletHolder.setInitParameter(
  "contextConfigLocation", "classpath:spring-mvc.xml");
// Ekvivalent init-on startup. Číslo špecifikuje poradie.
springServletHolder.setInitOrder(0);

handler.addServlet(springServletHolder, "*.do");

server.setHandler(new handler);
server.start();
```
Podobne ako v predošlých prípadoch nemáme k dispozícii `ServletContext` ani sessiony.

# Implementácia pomocou `Context`u
Ak v našej aplikácii potrebujeme podporu sessionov, môžeme použiť triedu `Context` ako náhradu `ServletHandler`a. Popri tom umožňuje nastaviť tzv. *context path*, teda prefix pre URL adresy, od ktorého sa budú odvíjať URL cesty namapované pre servlety. `Context` navyše dáva servletom k dispozícii inštanciu `ServletContextu`, čo v predošlých prípadoch nebolo možné.
```java
Server server = new Server(8080);
// vytvoríme nový kontext s podporou sessions a namapujeme ho na adresy začínajúce sa na /books
Context context = new Context(server, "/books", Context.SESSIONS);
ServletHolder servletHolder 
  = new ServletHolder(DispatcherServlet.class);
servletHolder.setInitParameter("contextConfigLocation", 
                               "classpath:spring-mvc.xml");
// load-on-startup
servletHolder.setInitOrder(1);
context.addServlet(servletHolder, "*.do");

server.start();
```
V tejto konfigurácii bude `DispatcherServlet` obsluhovať adresy s prefixom `http://.../books` a so sufixom `.do`.
## Nastavenie adresára so statickými stránkami
Bežná webová aplikácia spĺňajúca štandardy musí dodržiavať [predpísanú adresárovú štruktúru](http://ics.upjs.sk/~novotnyr/js/web-tomcat/web-tomcat.html#d0e55 ). Základom je koreňový adresár webovej aplikácie, v ktorom sú statické stránky (ich URL je tvorená kontextovou cestou a názvom súboru) a podadresár `WEB-INF` (obsahujúci triedy a knižnice). 

Niektoré servlety vyžadujú korektné fungovanie tejto vlastnosti - príkladom je servlet v Spring MVC, ktorý používa koreňový adresár na vyhľadávanie JSP stránok. 

Na tejto vlastnosti tiež závisí správne fungovanie metódy [getResource()](http://java.sun.com/javaee/5/docs/api/javax/servlet/ServletContext.html#getResource(java.lang.String) ) zo špecifikácie servletov.

Povoliť toto správanie v rámci `Contextu` je ľahké: na kontexte nastavíme túto cestu pomocou `setResourceBase()`. Použiť možno buď absolútnu cestu alebo relatívnu cestu vzhľadom k aktuálnemu adresáru.
```java
context.setResourceBase("web");
```
Ak máme **resource base** nastavenú na `D:/books/web` a **context path** nastavená v kontexte je `/books`, potom vyžiadanie `getResource("/index.html") vráti obsah stránky v adresári `D:/books/web/index.html`.

## Štandardný `DefaultServlet` pre výpis adresárov a statické súbory.
Veľmi často chceme, aby Jetty dokázala vypisovať obsahy adresárov a obsluhovať požiadavky na statické súbory v koreňovom adresári aplikácie. Na tento účel je k dispozícii [`DefaultServlet`](http://jetty.mortbay.org/apidocs/org/mortbay/jetty/servlet/DefaultServlet.html ), ktorý toto všetko umožňuje.

# Implementácia s použitím `WebAppContext`u
Ďalším „levelom" je použitie `WebAppContextu`, ktorý rozširuje klasický `Context` o možnosť konfigurovať webaplikáciu zo štandardného súboru `web.xml` (v adresári `WEB-INF`). Samozrejmosťou je zapnutie sessionov, prístup ku `ServletContext`u a navyše podpora autentifikácie.

Klasický príklad, v ktorom definujeme jeden servlet a namapujeme ho na koreňovú URL kontextu:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE web-app 
   PUBLIC "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN" 
   "http://java.sun.com/dtd/web-app_2_3.dtd">
   
<web-app>

  <servlet>
    <servlet-name>TestServlet</servlet-name>
    <servlet-class>sk.jetty.TestServlet</servlet-class>
  </servlet>
  
  <servlet-mapping>
    <servlet-name>TestServlet</servlet-name>
    <url-pattern>/</url-pattern>
  </servlet-mapping>
</web-app>
```
Ak ho uložíme do súboru `D:/AIS/jetty-test/web/WEB-INF/web.xml`, potom konfigurácia v kóde je nasledovná:
```java
Server server = new Server(8080);
// prvý parameter udáva cestu k adresáru s WEB-INF
// druhý parameter udáva context path
WebAppContext context 
  = new WebAppContext("D:/AIS/jetty-test/web", "/date");
server.addHandler(context);
server.start();
```
Servlet potom počúva na adrese `http://localhost:8080/date`.

Prvý parameter v konštruktore môže byť cesta alebo URL k adresáru s WEB-INF alebo k WAR súboru.

# Automatická aktualizácia kontextov
Z Tomcatu je známa možnosť automaticky znovunačítať kontext v prípade, že sa zmení niektorá z tried webaplikácie. V prastarých servletových kontajneroch bolo totiž nutné po každej zmene (kompilácii tried, zmenách nastavení) reštartnúť celý server, čo bolo pomerne nepohodlné.

Jetty umožňuje znovunačítavanie svojským spôsobom, ktorý je síce menej pohodlný ako v prípade Tomcatu, ale stále je to lepšie ako nič. Filozofia je jednoduchá: v Jetty sa sleduje súbor popisovača nasadenia a v prípade, že sa zmení jeho dátum a čas, kontext sa zahodí a nasadí nanovo.

Popisovač nasadenia v Jetty v podstate kopíruje Java syntax, ale zapisuje ju pomocou XML súboru.
```xml
<?xml version="1.0"  encoding="ISO-8859-1"?>
<!DOCTYPE Configure 
  PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" 
  "http://jetty.mortbay.org/configure.dtd">

<Configure class="org.mortbay.jetty.handler.ContextHandler">
  <Set name="contextPath">/books</Set>
  <Set name="resourceBase">d:/projects/books/web</Set>
</Configure>
```
Všimnite si, že nastavujeme **context path** aj **resource base** podobným spôsobom, ako sme to robili v kóde. Rovnako si všimnime, že tento XML súbor nakonfiguruje nový `ContextHandler`.

Súbor môžeme uložiť do adresára `D:/projects/books`. Samotné znovunačítavanie sa deje pomocou triedy `ContextDeployer`. Jeho API je však pomerne ťažkopádne.

Najprv vytvoríme deployer, a nastavíme mu adresár, v ktorom sa majú vyhľadávať zmeny v popisovačoch nastavení (adresár môže obsahovať viac popisovačov pre viacero kontextov). Ďalej nastavíme interval kontroly zmien.

Následne potrebujeme vytvoriť zoznam kontextových handlerov (`ContextHandlerCollection`) a podhodiť ho deployeru. Deployer po uplynutí intervalu prejde popisovače v adresári a na základe nich vytvorí nové kontexty, zahodí už neaktuálne alebo aktualizuje tie, ktoré sa zmenili.

Ten istý zoznam handlerov potrebujeme nastaviť inštancii `Server`a, čím asociujeme kontexty so serverom.

Inak povedané, server si pamätá zoznam handlerov a deployer tento zoznam v pravidelných intervaloch aktualizuje.
```java
Server server = new Server(8080);
// zoznam handlerov
ContextHandlerCollection contexts = new ContextHandlerCollection();
// vytvoríme deployer
ContextDeployer deployer = new ContextDeployer();
// nastavíme zoznam, ktorý má deployer aktualizovať
deployer.setContexts(contexts);
// nastavíme adresár s XML súbormi
deployer.setConfigurationDir("D:/projects/books");
// interval kontroly
deployer.setScanInterval(1);

// zoznam handlerov priradíme serveru
server.addHandler(deployer.getContexts());
// deployer podhodíme pod server, aby sa spúšťal zároveň s ním
server.addLifeCycle(deployer);

server.start();
```

# Porovnanie prístupov
| Prístup          | Výhody                                                       | Nevýhody                       |
| ---------------- | ------------------------------------------------------------ | ------------------------------ |
| handler          | najjednoduchší prístup                                       | mimo špecifikácie servletov    |
|                  |                                                              | len primitívne veci            |
|                  |                                                              | žiadne mapovanie na URL adresy |
| `ServletHandler` | podporuje servlety                                           | žiadne sessiony                |
|                  |                                                              | žiaden `ServletContext`        |
|                  |                                                              | žiadna konfigurácia parametrov |
| `ServletHolder`  | obalením servletu a pridaním do Servlet Handlera umožňuje konfigurovať servlet | žiadne sessiony                |
|                  |                                                              | žiaden `ServletContext`        |
| `Context`        | základná verzia kontextu pre webovú aplikáciu                |                                |
|                  | umožňuje podrobnejšie mapovanie URL na servlety              |                                |
| `WebAppContext`  | ako `Context`, možnosť konfigurovať z XML                    |                                |

Odkazy
======

* [Embedding Jetty](http://docs.codehaus.org/display/JETTY/Embedding+Jetty ) - stránka v Jetty Wiki s ďalšími príkladmi
