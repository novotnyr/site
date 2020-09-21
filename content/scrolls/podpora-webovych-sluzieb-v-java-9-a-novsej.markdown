---
title: Podpora webových služieb SOAP v Java 9 a novšej
date: 2019-10-02T08:42:32+01:00
lastmod: 2020-09-21T20:42:32+01:00
---

Ak chceme v Jave zverejniť webovú službu v protokole SOAP, máme k dispozícii základnú špecifikáciu  [JSR 224: JavaTM API for XML-Based Web Services (JAX-WS) 2.0](http://jcp.org/en/jsr/detail?id=224). Stačí si vybrať jednu zo štyroch knižníc alebo bezpočtu aplikačných serverov, v ktorej službu implementujeme.

Rokmi overená istota, ktorú si ukážeme, je SOAP služba implementovaná v knižnici **Metro**.

Ukážeme si:

1. Vytvorenie serverovskej časti: od kódu ku automaticky generovanému popisu služby cez WSDL.
2. Vytvorenie klientskej časti: vygenerovaním kódu klienta na základe WSDL.

Historické okienko
==================

Knižnica [Metro](https://github.com/eclipse-ee4j/metro-jax-ws) je odpradávna referenčnou implementáciou JAX-WS 2.0/JSR 224. 

Programátorov však viac zasiahli následné zmeny:

- **Java 6 (2006)** pridala podporu pre SOAP do základnej knižnice. Kód Metra bol dodávaný priamo s Javou.
- **Java 9 (sept. 2017)** vyhlásila JAX-WS 2.0 v základnej knižnici za zrelý na odstránenie.
- **Java 11 (sept. 2018)** už JAX-WS 2.0 neobsahuje.

*Metro* prešlo aj politickými zmenami: pôvodne bolo vyvíjané v rámci projektu **Glassfish**, ale na konci októbra 2018 bolo presunuté pod nadáciu Eclipse,

Serverovská časť
================

Server vytvoríme v štyroch krokoch:

1. Pridáme závislosti na knižnici Metro.
2. Vytvoríme triedu so serverovským kódom.
3. Pridáme anotáciu `@WebService`
4. Pripravíme triedu s metódou `main()`, kde spustíme server a publikujeme ho cez HTTP.

Závislosti v Mavene
-------------------

Serverovskú časť vytvoríme s použitím Mavenu, ktorý zavedie všetky nutné knižnice. Do `pom.xml` stačí pridať jedinú závislosť pre Metro.

```xml
<dependency>
    <groupId>com.sun.xml.ws</groupId>
    <artifactId>jaxws-rt</artifactId>
    <version>2.3.3</version>
</dependency>
```

Netreba sa čudovať, hoci názov skupiny (*group id*) je staručký `com.sun.xml.ws`, samotný kód verzie 2.3.3 už pochádza z nadácie Eclipse.

Nastavenie použitia Javy 11
---------------------------
V `pom.xml` nezabudnime zapnúť podporu pre Javu 11:

```xml
<properties>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
</properties>
```

Kód serverovskej časti
----------------------

Serverovská časť je úplne bežná trieda, s úplne bežnými metódami:

```java
package sk.upjs.ics.kopr.soap.server;

import javax.jws.WebService;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebService
public class DefaultTermService {
    private List<Term> terms = new ArrayList<Term>();

    public DefaultTermService() {
        terms.add(new Term(LocalDate.of(2020, 12, 12), "UINF/PAZ1c", 100));
        terms.add(new Term(LocalDate.of(2020, 12, 15), "UINF/PAZ1c", 75));
        terms.add(new Term(LocalDate.of(2021, 1, 5), "UINF/TVY1a", 50));
    }

    public List<Term> getTerms(String courseCode) {
        return terms.stream()
                .filter(term -> term.getCourseCode().equals(courseCode))
                .collect(Collectors.toList());
    }
}
```

Pridanie anotácie `@WebService`
-------------------------------

Ak chceme zverejniť triedu ako SOAPovú webovú službu, dodáme anotáciu `@javax.jws.WebService`.

```
@WebService
public class DefaultTermService {
```

Publikovanie služby
-------------------

Službu vypublikujeme zavolaním statickej metódy `publish` na triede `Endpoint`.

```java
import javax.xml.ws.Endpoint;

public class Server {
    public static void main(String[] args) {
        Endpoint.publish("http://localhost:8888/terms", new DefaultTermService());
    }
}
```

Publikovanie potrebuje dva parametre:

* URL adresu, na ktorej pobeží server. V ukážke máme lokálny server na porte 8888.
* objekt služby s anotáciou `@WebService`, ktorá obslúži požiadavky.

Triedu s metódou `main()` teraz môžeme spustiť, čím naštartujeme interný server nad HTTP. Cez prehliadač môžeme navštíviť adresu http://localhost:8888/terms. Uvidíme informačnú stránku, ktorá obsahuje odkaz na popisovač webovej služby WSDL.

### Chybové hlášky?

Pri spustení možno uvidíme varovanie:

```
WARNING: Illegal reflective access by com.sun.xml.ws.model.Injector (file:/Users/novotnyr/.m2/repository/com/sun/xml/ws/jaxws-rt/2.3.2/jaxws-rt-2.3.2.jar) to method java.lang.ClassLoader.defineClass(java.lang.String,byte[],int,int)
```

Ide o známu [chybu č. 60](https://github.com/eclipse-ee4j/metro-jax-ws/issues/60) v knižnici Metro, ktorú stačí ignorovať.

Klientska časť
==============

Server zverejnil svoju službu na adrese `http://localhost:8888/terms`, a zároveň poskytol aj WSDL. Vďaka tomu vieme automaticky vygenerovať klientsky kód!

Vytvoríme si extra projekt, `metro-java11-client`, v ktorom budeme udržiavať zdrojáky klientskej časti.

Kde je `wsimport`?
------------------

V predošlých verziách Javy existoval nástroj `wsimport`. Ten už v bežnej distribúcii nie je tak ľahko dostupný (zmenil sa na shellskripty).

Namiesto neho použijeme mavenovský plugin.

### Generujeme zdrojáky mavenovským pluginom

Na generovanie použijeme mavenovský plugin `jaxws-maven-plugin`. Do klientskeho `pom.xml` dodáme:

```xml
<plugins>
    <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>jaxws-maven-plugin</artifactId>
        <version>2.6</version>
        <configuration>
            <wsdlUrls>
                <wsdlUrl>http://localhost:8888/terms?wsdl</wsdlUrl>
            </wsdlUrls>
        </configuration>
    </plugin>
</plugins>
```

Samozrejme, predpokladáme, že i klientsky projekt obsahuje:

* závislosť na `com.sun.xml.ws:jaxws-rt:2.3.3`
* a je pripravený pre zostavenie nad Javou 11

Nechajme si vygenerovať zdrojové kódy pre klienta:

```
mvn clean jaxws:wsimport compile
```

Plugin vygeneruje niekoľko súborov, ktoré sa ocitnú v adresári `target/generated-sources/wsimport`. Keďže ide o automaticky generované triedy, niektoré názvy môžu byť čudesné (napríklad `DefaultTermServiceService`).

Následne ich priamo skompiluje, čím ich sprístupní v zdrojových kódoch klienta, ktorého ihneď vytvoríme.

### Použitie klienta v kóde

Klienta použijeme jednoducho:

```java
public class Client {
    public static void main(String[] args) {
        DefaultTermServiceService serviceLocator = new DefaultTermServiceService();
        DefaultTermService termService = serviceLocator.getDefaultTermServicePort();
        List<Term> terms = termService.getTerms("UINF/PAZ1c");
        for (Term term : terms) {
            System.out.printf("%s - %d slots left\n", term.getDate(), term.getFreeSlots());
        }
    }
}
```

Klient sa bude pripájať k URL, ktorá sa prevezme z WSDL.

Záver
=====

Takúto podporu webových služieb môžeme považovať za vhodnú pre mnoho jednoduchých prípadov (jednoduchá trieda, málo metód, HTTP binding, vyhovujúci HTTP server, žiadne závislosti). Samozrejme, v komplexnejších prípadoch si asi s touto verziou nevystačíme a budeme potrebovať použiť niektorú z ťažkotonážnejších implementácií, alebo jej zahrnutie do aplikačného servera s Java EE. 

Napriek tomu je však už i takáto jednoduchá podpora minimálne ekvivalentná s použitím technológie RMI.

Ukážkové projekty
=================

* **Serverovský** repozitár [novotnyr/kopr-soap-server-2020](https://github.com/novotnyr/kopr-soap-server-2020) obsahuje SOAP server.
* **Klientsky** repozitár  [novotnyr/kopr-soap-klient-2020](https://github.com/novotnyr/kopr-soap-server-2020) obsahuje podporu pre generovanie kódu klienta s ukážkovým použitím.

