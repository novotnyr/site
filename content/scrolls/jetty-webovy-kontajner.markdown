---
title: Jetty – webový kontajner 
date: 2007-09-03T00:00:00+01:00
---
# O Jetty
Jetty je servletový a JSP kontajner, ktorý sa vyznačuje malou veľkosťou a subjektívne väčšou svižnosťou oproti klasickým kontajnerom (napr. Tomcat-u).

Posledná verzia 6.1 spĺňa všetky najnovšie štandardy špecifikácie Servlet/JSP (teda Servlet 2.5 a JSP 2.1)

# Kde stiahnuť
Jetty si možno stiahnuť napr. z [CodeHaus](http://dist.codehaus.org/jetty/jetty-6.1.5/ )u, veľkosť ZIP archívu v prípade verzie 6.1 je cca 23 MB.

Rozbalený ZIP archív (66 MB) však môžeme bez problémov osekať o nepoužívané komponenty. V prípade jednoduchého testovania webaplikácií sa môžeme zbaviť súčastí ako asynchrónne IO a pod. 

V podstate bez problémov sa môžeme zbaviť adresárov ako:

* `contrib` -- obsahuje zdrojové kódy pre komponenty tretích strán)
* `examples` -- príklady webaplikácií
* `extras` -- zdrojové kódy pre integráciu Jetty a ostatných aplikačných rámcov
* `javadoc` -- JavaDoc API pre zdrojové kódy Jetty
* `modules` -- zdrojové kódy pre jednotlivé moduly Jetty
* `patches` -- opravné súbory pre zdrojové kódy Jetty
* `project-website` -- zdrojové kódy pre webovú stránku Jetty
* podadresáre z `webapps` -- ukážkové testovacie príklady 
* konfiguračné súbory a adresáre `test-jndi.xml`, `test-annotations.xml` `test.xml` a nim prislúchajúce `.d` adresáre

Tým sa veľkosť Jetty zminimalizuje na prijateľných 15 MB.

# Konfigurácia webovej aplikácie
Konfigurácia prebieha pomocou XML súborov v adresári `contexts`. Každej nasadenej aplikácii zodpovedá jeden XML súbor. Príkladom minimalistického konfiguračného súboru je:
```xml
<?xml version="1.0"  encoding="ISO-8859-1"?>
<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">

<Configure class="org.mortbay.jetty.webapp.WebAppContext">
  <Set name="contextPath">/libris</Set>
  <Set name="resourceBase">c:/Projects/libris/web</Set>
</Configure> 
```
* `contextPath` špecifikuje koncovku v URL webovej aplikácie. V príklade bude aplikácia typicky nasadená na adresu napr. `http://localhost:8080/libris`
* `resourceBase` odkazuje na adresár webovej aplikácie (ide o adresár obsahujúci `WEB-INF`)

# Služba a jej popis
Jetty podporuje na Windowse spúšťanie kontajnera ako windowsovsej služby. V adresári `bin` sa nachádza Jetty-Service.exe. Pomocou neho môžeme však spustiť kontajner aj priamo v konzole. Tento `exe` obaľovač java tried má navyše výhodu v tom, že dokáže detekovať padnuté inštancie a v prípade potreby kontajner reštartovať. To sa týka aj prípadu, keď v JVM nastane nedostatok pamäti (výnimka `java.lang.OutOfMemoryError`).

# Autoreload - automatické načítavanie webovej aplikácie
V servletovom kontajneri [`touch`](http://tomcat.apache.org | Tomcat]] možno využívať možnosť automatického načítania webovej aplikácie po zmene niektorej z tried (typicky po rekompilácii). Analogickú funkcionalitu je možné dosiahnuť aj v Jetty. Znovunačítanie sa uskutoční v momente, keď bol aktualizovaný konfiguračný súbor XML v adresári `contexts`. Jedna z možností je využitie klasického unixovského príkazu [[http://www.helge.mynetcologne.de/touch/program/touch0.1/touch.exe ), ktorý zmení 
dátum a čas daného súboru. Po kompilácii triedy stačí `touch`núť daný súbor a prebehne autoreload.

# Typické problémy
Typickým problémom so štartom Jetty je prípad, keď už na danom porte počúva nejaká aplikácia. (štandardným portom je 8080). To sa prejavuje chybovou hláškou
```
INFO:  Opened C:\java\jetty\logs\2007_09_03.request.log
WARN:  failed SelectChannelConnector@0.0.0.0:8080
 java.net.BindException: Address already in use: bind
     at sun.nio.ch.Net.bind(Native Method)
     at sun.nio.ch.ServerSocketChannelImpl.bind(Unknown Source)
     at sun.nio.ch.ServerSocketAdaptor.bind(Unknown Source)
```
Riešením je zastaviť aplikáciu, ktorá na danom porte počúva, alebo upraviť port. 

Zmeniť port možno v súbore `etc/jetty.xml`, kde v 
```
<Call name="addConnector">
  <Arg>
    <New class="org.mortbay.jetty.nio.SelectChannelConnector">
      <Set name="port"><SystemProperty name="jetty.port" 
                       default="8080"/>
      </Set> 
```
upravíme atribút `default`.

# Maven a Jetty
Pre Jetty existuje plugin do buildovacieho systému [Maven](http://maven.apache.org ), kde v najjednoduchšom prípade stačí spustiť `mvn jetty:run`, ktorý stiahne z úložiska minimalistickú verziu Jetty a spustí ju nad projektom.

Bližšie informácie možno nájsť na [stránkach pluginu](http://docs.codehaus.org/display/JETTY/Maven+Jetty+Plugin ).

# Programové spustenie Jetty
Jetty je možné pohodlne naštartovať aj v rámci webovej aplikácie. Prepokladajme, že máme servlet:
```java
public class HelloServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req,
                       HttpServletResponse resp)
      throws ServletException, IOException 
  {
    System.out.println("Hello world.");     
  }

}
```
Jetty, v ktorej beží jeden jednoduchý servlet (ktorý nepotrebuje celú webovú aplikáciu, ani konfigurovanie cez `web.xml`), naštartujeme:

```java
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.mortbay.jetty.Server;
import org.mortbay.jetty.servlet.ServletHandler;

public class ClassicServer {
  public static void main(String[] args) throws Exception {
    Server server = new Server(8080);
    ServletHandler servletHandler = new ServletHandler();
    servletHandler.addServletWithMapping(HelloServlet.class,
                                         "/hello");
    
    server.addHandler(servletHandler);
    
    server.start();
    server.join();  
  }
}
```

Po spustení aplikácie a navštívení adresy http://localhost:8080/hello uvidíme výpis:
```
2007-11-14 15:14:10.168::INFO:  Logging to STDERR via org.mortbay.log.StdErrLog
2007-11-14 15:14:10.356::INFO:  jetty-6.1.5
2007-11-14 15:14:10.575::INFO:  Started SocketConnector@0.0.0.0:8080
Hello world.
```

Táto konfigurácia je minimalistická a servlety napríklad nemajú k dispozícii všetky vymoženosti regulárnej webaplikácie. Prístup ku inštancii `ServletContext`u nie je možný (vráti sa `null`), rovnako nie je podporované vytváranie sessionov.
