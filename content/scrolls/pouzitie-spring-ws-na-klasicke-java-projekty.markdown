---
title: Použitie Spring-WS na klasické Java objekty 
date: 2008-06-24T15:17:23+01:00
description: Spring-WS je aplikačný rámec pre vývoj webových služieb, ktorý otvorene propaguje filozofiu "od WSDL k triedam". Napriek tomu je natoľko flexibilný, že v jednoduchých prípadoch možno rýchlo vyvinúť webovú službu, ktorá vznikla opačným spôsobom. Ukážeme si jednoduchý príklad vybudovania služby, v ktorom sa objekty zasielané v SOAP správach serializujú na XML pomocou knižnice XStream.
---
# Úvod
[dokumentácii](http://static.springframework.org/spring-ws/site/ | *Spring Web Services*]] (Spring-WS) je knižnica pre podporu budovania webových služieb v Jave. Spadá teda do rodiny, v ktorej sú knižnice / aplikačné rámce ako [[http://ws.apache.org/axis2/ | Apache Axis2]], [[http://cxf.apache.org/ | Apache CXF]] alebo [[https://metro.dev.java.net/ | Glassfish Metro]]. Na rozdiel od jej bratrancov je základnou filozofiou „contract-first". Pri budovaní webových služieb sa teda očakáva vybudovanie XML schémy, popisovača WSDL a tried, ktoré vychádzajú práve z týchto jazykovo a platformovo nezávislých súčastí. Iné knižnice poskytujú aj opačný prístup, teda vybudovanie webovej služby na základe Java implementácie, Spring-WS však tento spôsob zámerne neposkytuje. (Argumentáciu možno nájsť v [[http://static.springframework.org/spring-ws/site/reference/html/why-contract-first.html )). Rovnako je tento aplikačný rámec držaný „pri zemi". Množstvo vecí, ktoré iné knižnice riešia automagicky, sa tuto riešia manuálne - čo však v mnohých prípadoch umožňuje mať veci pod kontrolou.

Ukážme si však spôsob, ktorým je možné vybudovať jednoduchú webovú službu práve „ignorovaným" opačným spôsobom. Obetujeme popri tom množstvo z platformových vymožeností webových služieb, ale dosiahneme popri tom fungujúci prototyp.

# Triedy a serializácia do XML pomocou XStream
V našom príklade budeme chcieť vybudovať webovú službu pre rezerváciu lístkov v kine. Klient zašle požiadavku, v ktorej špecifikuje názov filmu, dátum jeho premientania a počet lístkov, ktoré si chce zarezervovať. Príkladom rezervačného lístka bude nasledovná trieda:
```java
package sk.novotnyr.movie;

import java.util.Date;

public class MovieReservation {

  protected String title;
  protected Date date;
  protected int numberOfTickets;

  // gettre a settre
}
```
Trieda nie je ničím mimoriadna, je to klasické POJO. 
## Serializácia do XML
Túto triedu budeme musieť vložiť do SOAP správy ako XML. Existuje množstvo spôsobov, ktorými je možné namapovať triedu v Jave na XML súbor. Jedným z najjednoduchších nástrojov je [XStream](http://xstream.codehaus.org/ ). Príklad na serializáciu triedy do XML je nasledovný:
```java
MovieReservation reservation = new MovieReservation(
  "Godzilla", new Date(), 4);

XStream xStream = new XStream();
String xml = xStream.toXML(reservation);
System.out.println(xml);
```
Výsledkom je nasledovné XML na štandardnom výstupe:
```xml
<sk.novotnyr.movie.MovieReservation>
  <title>Godzilla</title>
  <date>2008-06-24 16:08:18.421 CEST</date>
  <numberOfTickets>4</numberOfTickets>
</sk.novotnyr.movie.MovieReservation>
```
Ak sa nám nepáči úplný názov triedy ako názov elementu, môžeme použiť alias (ten mapuje názov triedy na element a späť):
```java
xStream.alias("movieReservation", MovieReservation.class);
```
Výsledné XML bude nasledovné:
```xml
<movieReservation>
  <title>Godzilla</title>
  <date>2008-06-24 16:08:18.421 CEST</date>
  <numberOfTickets>4</numberOfTickets>
</movieReservation>
```

# Budovanie webovej služby
## Stiahnutie
Na vybudovanie webovej služby použijeme zmienený Spring-WS. Stiahneme si projekt zo stránok a do `CLASSPATH` projektu pridáme príslušné JARy.

* activation.jar
* commons-logging-1.1.1.jar
* log4j-1.2.15.jar
* saaj-api-1.3.jar
* saaj-impl-1.3.jar
* spring-web.jar
* spring-webmvc.jar
* spring-ws-1.5.2.jar
* spring.jar
* stax-api-1.0.1.jar
  Ak budeme používať na serializáciu a deserializáciu XStream, pridáme aj jeho JAR:
  * xstream-1.2.jar
  (Dôležitá poznámka: vyzerá to tak, že Spring-WS vo verzii 1.5.2 nepracuje korektne s XStream 1.2.1 a novšej. Preto použite verziu 1.2.)



## Inštalácia
Webová služba vytvorená pomocou Spring-WS pracuje na princípe webovej aplikácie, v ktorej je nakonfigurovaný špeciálny servlet posielajúci požiadavky jednotlivým koncovým bodom (endpointom). Endpointov môže byť prirodzene viac a každý môže predstavovať samostatnú webovú službu. (Analógiu možno vidieť v návrhovom vzore MVC: jeden servlet posiela požiadavky na viacero kontrolérov).

Konfigurácia Spring-WS preto spočíva v konfigurácii webovej aplikácie, presnejšie springovej webovej aplikácie.

Kostra webovej aplikácie je tvorená predovšetkým súborom `web.xml`
`web.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/j2ee" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://  
         java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
         version="2.4">

<servlet>
  <servlet-name>spring-ws</servlet-name>
    <servlet-class>
org.springframework.ws.transport.http.MessageDispatcherServlet
    </servlet-class>
</servlet>

<servlet-mapping>
  <servlet-name>spring-ws</servlet-name>
  <url-pattern>/ws/*</url-pattern>
</servlet-mapping>

</web-app>
```
Vo `web.xml` nakonfigurujeme servlet `spring-ws` obsluhujúci HTTP požiadavky na webovú službu a namapujeme ho na URL začínajúce na `/ws/`.

Ďalším krokom je konfigurácia aplikačného kontextu Springu (keďže Spring-WS je založený na tomto frameworku). Tá je tvorená súborom `spring-ws-servlet.xml`, ktorý dáme do adresára `WEB-INF`.

V ňom špecifikujeme dve dôležité veci:

* **endpointy**, ktoré budú obsluhovať webové služby. Zatiaľ budeme mať jediný endpoint (jeho kód vytvoríme o chvíľu). Endpoint uvedieme ako springovský bean s identifikátorom a názvom triedy:

```xml
<bean id="movieReservationEndpoint" 
      class="sk.novotnyr.movie.ws.XStreamMovieReservationEndpoint" />
```

* **mapovanie URL adries na endpointy**. Keďže servlet `spring-ws` môže zasielať požiadavky na rôzne endpointy, je dobré špecifikovať presnejšie mapovania. Mapovacích stratégii existuje viac. Použijeme stratégiu, ktorá bude mapovať URL na endpoint podľa nej samej. V našom mapovaní definujeme, že ak niekto navštívi URL `http://localhost:8080/movie/ws/reservation`, použije sa endpoint s identifikátorom `movieReservationResult`.
Táto stratégia je poskytovaná triedou `org.springframework.ws.server.endpoint.mapping.UriEndpointMapping`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"  
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans 
       http://www.springframework.org/schema/beans/spring-beans-2.0.xsd">
 	
<bean id="movieReservationEndpoint" 
      class="sk.novotnyr.movie.ws.XStreamMovieReservationEndpoint" />
 	
<bean id="endpointMapping" class="org.springframework.ws.server.endpoint.mapping
       .UriEndpointMapping">
  <property name="mappings">
    <props>
      <prop key="http://localhost:8080/movie/ws/reservation">
        movieReservationEndpoint</prop>
    </props>
  </property>
</bean>
    
</beans>
```

## Vytvorenie endpointu
Endpoint je trieda, ktorá možno istým spôsobom prirovnať k servletu. Dostane požiadavku, ktorú spracuje a vytvorí odpoveď. Kým v servletoch je požiadavka tvorená dvojicami parameter-odpoveď, v endpointoch sú požiadavky (i odpovede) tvorené XML dátami. Na prácu s XML dátami jestvuje viacero spôsobov.

Jedným z komplexnejších endpointov, od ktorých môžeme zdediť a použiť ich je `AbstractMarshallingPayloadEndpoint`. Ten má dôležitú metódu `Object invokeInternal(Object)`, ktorá dostane na vstup objekt deserializovaný zo XML požiadavky a má vrátiť objekt, ktorý bude následne serializovaný do XML a odoslatý ako odpovď.

Príkladom je:
```java
public class XStreamMovieReservationEndpoint 
   extends AbstractMarshallingPayloadEndpoint 
{
  
  @Override
  protected Object invokeInternal(Object object) throws Exception {

    MovieReservation movieReservationRequest 
      = (MovieReservation) object;
    System.out.println(movieReservationRequest.getTitle());
    System.out.println(movieReservationRequest.getDate());
    System.out.println(movieReservationRequest.getNumberOfTickets());

    return null;
  }
}
```
V príklade sme pretypovali objekt z parametra na požiadavku `MovieReservation` a vypísali ju na konzolu servera. V tomto jednoduchom prípade nevraciame nič - takto implementujeme *one-way messages*, čiže správy bez odpovede.

Ostáva otázka, akým spôsobom sa realizuje prevod objektov na XML a naopak? To je záležitosť tzv. marshallerov (prevodníkov objektov na XML) a unmarshallerov (XML na objekty). V Spring-WS sú k dispozícii hotové marshallery pre typické technológie - napr. pre JAXB, XMLBeans alebo XStream. Práve tento posledný marshaller a unmarshaller použijeme. Stačí ho v konštruktore zaregistrovať s našim endpointom:
```java
public XStreamMovieReservationEndpoint() {
  super();

  XStreamMarshaller marshaller = new XStreamMarshaller();
  setMarshaller(marshaller);
  setUnmarshaller(marshaller);
}
```
Aby sme zachovali požiadavku na aliasy našich tried, môžeme dodať do konštruktora:
```java
marshaller.addAlias("movieReservation",  MovieReservation.class);
```

Po dohotovení endpointu môžeme celú aplikáciu nasadiť do obľúbeného servletového kontajnera pod menom `/movies` a spustiť.

# Klient

Webová služba bola spustená a je čas k nej pristúpiť pomocou klienta.
Na klienta sa používa analogický návrhový vzor ako v prípade prístupu k databáze: tzv. šablónová trieda. V našom prípade:

1.  vytvoríme takúto triedu
1.  nakonfigurujeme marshallery a unmarshallery identickým spôsobom ako na strane servera
1.  vytvoríme objekt pre požiadavku a spracujeme odpoveď

```java
public class XStreamClient {
  
  public static void main(String[] args) throws Exception {
    // vytvoríme marshaller
    XStreamMarshaller marshaller = new XStreamMarshaller();
    marshaller.addAlias("movieReservation", MovieReservation.class);

    // šablóna pre webovú službu    
    WebServiceTemplate webServiceTemplate = new WebServiceTemplate();

    // URI, ktoré budeme volať
    webServiceTemplate.setDefaultUri(
       "http://localhost:8080/movie/ws/reservation");
    
    // priradíme marshallery a unmarshallery
    webServiceTemplate.setMarshaller(marshaller);
    webServiceTemplate.setUnmarshaller(marshaller);

    //vytvoríme objekt požiadavky
    MovieReservation reservation = new MovieReservation(
        "Godzilla", new Date(), 4);
    
    // odošleme ho, výstup ignorujeme, lebo nemáme žiadny
    webServiceTemplate.marshalSendAndReceive(reservation);
  }
}
```
SOAP požiadavka bude vyzerať nasledovne:
```xml
<SOAP-ENV:Envelope 
      xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
<SOAP-ENV:Header/>
<SOAP-ENV:Body>
  <movieReservation>
    <title>Godzilla</title>
    <date>2008-06-24 16:50:58.171 CEST</date>
    <numberOfTickets>4</numberOfTickets>
  </movieReservation>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
```

# Endpoint s metódou, ktorá vracia výsledok
Doteraz nevracal endpoint žiadnu správu ako odpoveď. V praxi je takýto prípad však asi dosť zriedkavý. Aj klient by možno očakával nejakú zmysluplnú odpoveď (možno číslo rezervácie a pod.) v prípade, že sa jeho registrácia podarila.

Upravme teda metódu `invokeInternal()` tak, aby vracala inštanciu našej vlastnej triedy `ReservationConfirmation`:
```java
protected Object invokeInternal(Object object) throws Exception {

  MovieReservation movieReservationRequest 
    = (MovieReservation) object;

  ReservationConfirmation confirmation 
    = new ReservationConfirmation();
  confirmation.setId(new Date().getDate());
  confirmation.setSeatIds(new int[] {1, 2, 3, 4});

  return confirmation;
}
```
Keďže používame novú triedu, je dobré ju zaregistrovať v XStream marshalleri tak, aby sa jej element volal skrátene a nie na základe plného mena triedy:
```java
marshaller.addAlias(
  "reservationConfirmation", ReservationConfirmation.class);
```
Aliasovanie musíme spraviť aj v endpointe, aj v klientovi.

Modifikované volanie v klientovi je potom nasledovné:
```java
ReservationConfirmation confirmation = (ReservationConfirmation) webServiceTemplate.marshalSendAndReceive(reservation);
System.out.println(confirmation);
```
SOAP odpoveď vyzerá nasledovne:
```xml
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">
<SOAP-ENV:Header/>
<SOAP-ENV:Body>
  <reservationConfirmation>
    <id>24</id>
    <seatIds>
      <int>1</int>
      <int>2</int>
      <int>3</int>
      <int>4</int>
    </seatIds>
  </reservationConfirmation>
</SOAP-ENV:Body>
</SOAP-ENV:Envelope>
```

# Logovanie
Pri vývoji je často užitočné sledovať hlášky, ktoré vypisuje aplikačný rámec. Na to môžeme použiť napr. tradičný spôsob cez `log4j`. Stačí uviesť do `CLASSPATH` súbor `log4j.properties`. Dôležité kategórie sú `MessageTracing` v doleuvedenom balíčku:
```
log4j.rootCategory=INFO, stdout
log4j.logger.org.springframework.ws=DEBUG
log4j.logger.org.springframework.ws.client.MessageTracing.sent=TRACE
log4j.logger.org.springframework.ws.client.MessageTracing.received=TRACE

log4j.logger.org.springframework.ws.server.MessageTracing=TRACE

log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%p [%c{3}] %m%n
```
V rámci logovaní je potom možné vidieť kompletné správy, ktoré boli odoslané klientovi.

# Kdepak je mé WSDL? Kdepak je má schéma?
Ako vravieval klasický tvorca v dielni Rudolfa II.: WSDL... není. Tento spôsob je skutočne veľmi jednoduchý a minimalistický. Napr. Axis2 podporuje možnosť nasadiť jednoduchú Java triedu a získať z nej všetko: webovú službu, automaticky generované WSDL spolu so XML schémou a všetko ostatné. Spring-WS vám WSDL nevie vygenerovať, pretože nemá k dispozícii XML schému vstupných a výstupných dát (a to hlavne preto, že štruktúra XML generovaná XStreamom môže byť principiálne ľubovoľná). To je, ako sme spomínali vyššie, v súlade s filozofiou „contract-first". 
