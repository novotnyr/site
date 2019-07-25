---
title: Hessian a vzdialené volanie procedúr 
date: 2007-11-14T00:07:50+01:00
---
# Úvod
[Caucho Hessian](http://hessian.caucho.com) je protokol použiteľný na vzdialené volanie procedúr alebo na implementáciu myšlienky webových služieb. Samotný protokol je binárny a ako transportná vrstva je použitý klasické HTTP.

Paralelne s Hessian-om jestvuje spriatelený protokol Burlap, ktorý namiesto binárnej reprezentácie prenášaných dát používa XML.

Hessian umožňuje zverejniť na vzdialené volanie procedúr ľubovoľný interfejs, za ktorým stojí vhodná implementačná trieda.

# Vzťah s podobnými technológiami

## Hessian vs RMI
* oba používajú binárne protokoly a Java serializáciu
* RMI používa vlastnú sieťovú komunikáciu, Hessian beží nad HTTP (je teda potrebný aspoň minimalistický servletový kontajner (príklad viď nižšie))
* RMI je zabudovaný priamo v JDK
* Pre Hessian existuje interoperabilita: existujú implementácie pre iné programovacie jazyky (Python, C# a pod.), RMI je obmedzené na Javu

## Hessian vs SOAP
* SOAP využíva protokol založený na XML a rovnako serializáciu objektov do XML
* SOAP beží štandardne nad HTTP (je potrebný servletový kontajner) s možnosťou ďalších protokolov
* SOAP umožňuje mnohé vychytralosti (bezpečnosť a autentifikácia, správy s prílohami) a podporuje interoperabilitu medzi mnohými jazykmi
* kvôli tomu však SOAP vyžaduje omnoho komplexnejšiu konfiguráciu a praktická rýchlosť môže byť nižšia

## Hessian vs Spring HTTP Invoker
* oba využívajú HTTP protokol a Java serializáciu
* Spring HTTP Invoker nepodporuje interoperabilitu
* v ostatných aspektoch približne rovnaké

# Jednoduchý príklad
## Server
Vytvorme si interfejs pre službu poskytujúcu aktuálny čas na serveri.
```java
public interface DateService {
    Date getCurrentDate();
}
```
a vytvorme jeho implementáciu
```java
public class DateServiceImpl implements DateService {
 
  public Date getCurrentDate() {
    return new Date();
  }
  
}
```

Ako sme spomenuli, Hessian beží nad protokolom HTTP, presnejšie povedané využíva technológiu servletov. Na tento účel je k dispozícii špeciálny HTTP servlet `com.caucho.hessian.server.HessianServlet`, ktorému poskytneme dva parametre: 

* názov interfejsu s metódami
* názov implementačnej triedy
Tie môžeme nakonfigurovať v rámci inicializačných parametrov servletu vo `web.xml`. V našom prípade však použijeme programovú konfiguráciu v kontajneri Jetty.

Vytvoríme inštanciu `HessianServletu` a nakonfigurujeme ju nasledovne:
```java
HessianServlet hessianServlet = new HessianServlet();
hessianServlet.setHomeAPI(DateService.class);
hessianServlet.setHome(new DateServiceImpl());
```

Následne naštartujeme a nakonfigurujeme Jetty. 
```java
Server server = new Server(8080);
Context context = new Context(server, "/", Context.SESSIONS);
context.addServlet(new ServletHolder(hessianServlet), "/*");
        
server.start();
server.join();
```
`Server` predstavuje hlavnú triedu servera, do ktorej pridáme webový kontext namapovaný na koreňovú adresu (`/`). Do tohto kontextu pridáme jeden už nakonfigurovaný servlet (inštanciu `HessianServletu` obaľuje `ServletHolder`) a namapujeme ju na ľubovoľnú adresu pod webovým kontextom.

Následne server naštartujeme.

## Klient
Klient je o niečo jednoduchší než server. Centrom je továreň `HessianProxyFactory`, ktorú požiadame o vytvorenie inštancie triedy implementujúcej `DateService`. Táto inštancia skrytá za interfejsom bude riešiť všetku špinavú prácu (pripojenie k serveru, serializácia a deserializácia dát a pod.)

Továrni stačí odovzdať URL adresu, na ktorej beží serverovská časť.

```java
String url = "http://localhost:8080/";
	
HessianProxyFactory factory = new HessianProxyFactory();
DateService dateService = (DateService) factory.create(DateService.class, url);
```

Objekt `dateService` je takto pripravený a môžeme na ňom pohodlne volať metódy. 
```java
System.out.println(dateService.getCurrentDate());
```
Všimnime si, že pracujeme so samotným interfejsom, ktorý stiera rozdiely medzi tým, či pracujeme na lokálnej alebo vzdialenej inštancii triedy `DateServiceImpl`. 

# Aké triedy je možné posielať po kábli?
Hessian podporuje všetky základné dátové typy a objekty, ktoré sú serializovateľné a majú viditeľný prázdny konštruktor. Triedy určené na posielanie nie je potrebné nijak špeciálne konfigurovať ani upravovať.
