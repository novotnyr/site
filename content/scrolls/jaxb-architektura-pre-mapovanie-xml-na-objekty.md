---
title: JAXB - architektúra pre mapovanie XML na objekty
date: 2008-01-27T00:00:00+01:00
---

#  Úvod
> „Technológie jazyka Java a XML možno považovať za ideálne stavebné bloky pre vývoj webových služieb a aplikácií, ktoré ich využívajú. Aplikačné rozhranie **Java Architecture for XML Binding** (JAXB) uľahčuje prácu s XML dokumentami v Java aplikáciách.“

Týmito slovami sumarizuje technológiu JAXB [popisného dokumentu na stránkach Sun-u](http://java.sun.com/developer/technicalArticles/WebServices/jaxb/ ).

JAXB umožňuje mapovanie XML dokumentov na Java objekty a to v oboch smeroch. Samozrejme, že toto mapovanie sa musí riadiť nejakými pravidlami - v tomto prípade [XML schémou](http://www.w3.org/TR/xmlschema-0/ ), ktorá popisuje štruktúru príslušného XML dokumentu.

JAXB je založené na špecifikácii [referenčná implementácia](http://jcp.org/en/jsr/detail?id=222 | JSR-222]], ktorej [[https://jaxb.dev.java.net/ ) sa nachádza na stránkach Java.net. Túto implementáciu budeme používať aj v nasledovných príkladoch. Poznamenajme, že JAXB sa stalo súčasťou Java SE 6.

Zvyčajný postup práce s JAXB spočíva v nasledovných krokoch:

1.  vytvorenie XML schémy a príslušných XML dokumentov, ktoré sú na nej založené
1.  vygenerovanie Java tried na základe tejto schémy. Triedy zodpovedajú jednotlivým elementom XML dokumentu.
1.  deserializácia (''unmarshalling'') - konverzia XML dokumentu do inštancií príslušnej triedy.
1.  serializácia (''marshalling'') - konverzia inštancie do XML reprezentácie

#  JAXB a klasické objekty bez použitia schémy
##  Serializácia
JAXB vo verzii 2.0 vyššie uvedené kroky značne zjednodušuje. Na rozdiel od predošlých verzií je možné serializovať a deserializovať triedy bez vytvorenia XML schémy. Kým predošlý prístup je možné nazvať „zdola nahor" (od schémy cez XML k triedam), nasledovný spôsob je „zhora nadol" (od triedy cez XML a schéme). 

Ukážme si jednoduchý príklad, keď máme existujúcu triedu, ktorú chceme namapovať na XML. 

Majme jednoduchú triedu osoby:
```java
public class Person {
  private String firstName;
  
  private String lastName;
  
  private Date dateOfBirth;
  
  private float weight;

  /* gettre a settre */
}
```

Ak túto triedu chceme serializovať do XML, potrebujeme vykonať nasledovné kroky:

1.  vytvoriť inštanciu triedy `JAXBContext`. Tá udržiava rôzne mapovania XML elementov na triedy a manažuje konkrétne implementácie objektov pre serializáciu, deserializáciu a kontrolu korektnosti serializovaných objektov. V konštruktore potrebujeme uviesť triedy, ktoré budeme serializovať - v našom prípade pôjde o jedinú triedu `Person`.
1.  vytvoriť inštanciu `Marshaller`a, ktorým budeme serializovať objekty osôb
1.  vytvoriť inštanciu osoby.

```java
// vytvoríme kontext JAXB
JAXBContext jaxbContext 
  = JAXBContext.newInstance(Person.class);      

Marshaller marshaller = jaxbContext.createMarshaller();

Person person = new Person();
person.setFirstName("Janko");
person.setLastName("Ždiebik");
person.setDateOfBirth(new Date(1972, 3, 2));
person.setWeight(95);
```

Pred samotným serializovaním daného objektu ho musíme obaliť do inštancie triedy `JAXBElement`, čo je akýsi prostredník medzi Java objektom a jeho XML reprezentáciou. Pri vytváraní tohto prostredníka potrebujeme špecifikovať názov koreňového uzla s dátami serializovaného objektu, dátový typ tohto objektu a samozrejme konkrétnu inštanciu:
```java
JAXBElement<Person> personElement 
  = new JAXBElement<Person>(new QName("person"), 
                                Person.class, 
                                person);
```
Názov koreňového elementu uvedieme pomocou objektu `QName`, bude ním element `<person>`.

Samotnú serializáciu vyvoláme pomocou metódy `marshall` na objekte `Marshaller`a. Uvedieme objekt, ktorý chceme serializovať (teda `personElement`) a výstupný kanál, kam ho serializujeme. Serializovať možno do súboru, na výstup typu `java.io.Writer` a podobne (viď dokumentácia k `Marshaller`u). Nasledovný kód vypíše výsledné XML na štandardný výstup.
```java
marshaller.marshal(personElement, System.out);
```
Vygenerované XML je však bez akéhokoľvek formátovania (všetky biele miesta sú vynechané). Čitateľnosť vygenerovaného XML môžeme zvýšiť zapnutím formátovania v marshalleri. Docieliť to môžeme nastavením príslušnej vlastnosti:
```java
marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
```
Niekedy je vhodné zmeniť štandardné kódovanie používané v XML reprezentácii:
```java
marshaller.setProperty(Marshaller.JAXB_ENCODING, "windows-1250");
```

##  Deserializácia
Deserializácia prebieha podobným spôsobom. Vytvoríme inštanciu kontextu `JAXBContext`, z ktorej získame objekt `Unmarshaller`a:
```java
JAXBContext jaxbContext = JAXBContext.newInstance(Person.class);
Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
```
Na ňom zavoláme metódu `unmarshall()`. Tá vracia `Object` reprezentujúci konkrétnu inštanciu načítanú z XML. Ale aký skutočný typ má daný objekt? To si ukážeme o chvíľu.

Ešte poznamenajme, že deserializácia môže načítavať XML z rôznych zdrojov, my si ukážeme načítavanie z reťazca:
```java
String xmlPerson =
  "<?xml version=\"1.0\" encoding=\"windows-1250\" ?>\n" + 
  "<person>\n" + 
  "    <dateOfBirth>3872-04-02T00:00:00+02:00</dateOfBirth>\n" + 
  "    <firstName>Janko</firstName>\n" + 
  "    <lastName>Ždiebik</lastName>\n" + 
  "    <weight>95.0</weight>\n" + 
  "</person>";
```
Prvá vec, ktorá by nás napadla, by bolo volanie metódy nad `java.io.StringReader`om.
```java
Object o = unmarshaller.unmarshal(new StringReader(xmlPerson));
```
Lenže po spustení takéhoto kódu dostaneme výnimku:
```
javax.xml.bind.UnmarshalException: 
  unexpected element (uri:"", local:"person"). 
  Expected elements are (none).
```
Problém spočíva v tom, že nepoužívame ani XML schému, ani žiadnu inú špeciálnu konfiguráciu mapovaných tried (napr. cez anotácie). JAXB teda nevie presne, na aký dátový typ má daný XML súbor namapovať. To napravíme zavolaním dvojparametrovej metódy `unmarshall`, kde do druhého argumentu dodáme dátový typ. Musíme sa však ešte vysporiadať s jednou nepríjemnosťou: neexistuje metóda so signatúrou `unmarshall(Reader, Class<T>)`, ktorá by umožňovala použiť `StringReader`. To však obídeme metódou `unmarshall(javax.xml.transform.Source, Class<T>)`, kde vytvoríme objekt `Source` nad `StringReader`om.

Zároveň sa tým vyrieši otázka týkajúca sa návratového typu. V prípade serializácie sme museli obaliť inštanciu osoby objektom `JAXBElement`. Podobná zásada platí aj tu. Výsledkom deserializácie bude objekt typu `JAXBElement<Person>`, ktorý bude v sebe obsahovať inštanciu osoby:
```java
Source source = new StreamSource(new StringReader(xmlPerson));
JAXBElement<Person> personElement 
  = unmarshaller.unmarshal(source, Person.class);
//získame osobu a vypíšeme ju
Person person = personElement.getValue();
System.out.println(person);
```

#  JAXB a anotované objekty bez použitia schémy
V predošlej sekcii sme serializovali a deserializovali bežné Java objekty (POJOs). Niekedy je však potrebné proces serializácie a deserializácie viac prispôsobiť svojim potrebám. Na tento účel slúžia anotácie, ktorými vieme podrobne nakonfigurovať príslušnú triedu. 

Základnou anotáciou je `XmlRootElement`. Takto anotovaná trieda bude serializovaná v podobe XML podstromu.
```java
@XmlRootElement
public class Person {
  private String firstName;
  
  private String lastName;
  
  private Date dateOfBirth;
  
  private float weight;

  /* gettre a settre */
}
```
Serializácia takejto triedy sa potom zjednoduší: nemusíme totiž obaľovať inštanciu osôb do `JAXBElement`ov.
```java
JAXBContext jaxbContext = JAXBContext.newInstance(Person.class);
Marshaller marshaller = jaxbContext.createMarshaller();   

Person person = new Person();
person.setFirstName("Janko");
person.setLastName("Ždiebik");
person.setDateOfBirth(new Date(1972, 3, 2));
person.setWeight(95);
            
marshaller.marshal(person, System.out);
```
Rovnako sa zjednoduší aj deserializácia. Nemusíme totiž špecifikovať dátový typ a nemusíme ani vyťahovať osobu z `JAXBElement`u. Musíme len pretypovať výsledný `Object` na `Person`.
```java
JAXBContext jaxbContext = JAXBContext.newInstance(Person.class);
Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();

Reader reader = new StringReader(xmlPerson);
Person person = (Person) unmarshaller.unmarshal(reader);

System.out.println(person);
```

#  Generovanie XML schémy z existujúcich tried
Na generovanie XML schémy z existujúcich tried jestvuje v referenčnej implementácii nástroj `schemagen`. Nájsť ho môžete v adresári `bin` v adresári, kam ste rozbalili JAXB.

Príklad použitia z príkazového riadku je nasledovný:
```
d:\Projects\jaxb>set JAXB_HOME=C:\java\jaxb
d:\Projects\jaxb>%JAXB_HOME\bin\schemagen src\jaxb\Person.java
Note: Writing d:\Projects\jaxb\schema1.xsd
```
Výsledná vygenerovaná schéma zodpovedajúca vyššie uvedenej triede vyzerá nasledovne:
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xs:schema version="1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <xs:element name="person" type="person"/>

  <xs:complexType name="person">
    <xs:sequence>
      <xs:element name="dateOfBirth" type="xs:dateTime" 
                  minOccurs="0"/>
      <xs:element name="firstName" type="xs:string" minOccurs="0"/>
      <xs:element name="lastName" type="xs:string" minOccurs="0"/>
      <xs:element name="weight" type="xs:float"/>
    </xs:sequence>
  </xs:complexType>
</xs:schema>
```
#  Generovanie tried z DTD
Ako experimentálnu alternatívu k XML schéme ponúka referenčná implementácia možnosť vygenerovať triedy zo súboru DTD. Ukážme si to na príklade DTD súboru k popisovaču nasadenia webových aplikácií (súboru `web.xml`). Vygenerujeme triedy, na ktoré namapujeme jednotlivé elementy takéhoto XML súboru:
```
d:\Projects\jaxb>%JAXB_HOME%\bin\xjc -d src -p jaxb.servlet.config 
-dtd http://java.sun.com/dtd/web-app_2_3.dtd
```
Parameter `-d` určuje adresár, do ktorého sa vygenerujú zdrojové kódy tried. Pomocou `-p` nastavíme cieľový balíček (ak tento parameter vynecháme, balíček sa odvodí z URL adresy k DTD súboru). Parameter `-dtd` hovorí, že používame DTD súbor (namiesto štandardnej XML schémy). Posledný parameter udáva cestu k DTD súboru.

Program vygeneruje množstvo súborov:
```
parsing a schema...
compiling a schema...
jaxb\servlet\config\AuthConstraint.java
jaxb\servlet\config\AuthMethod.java
jaxb\servlet\config\ContextParam.java
jaxb\servlet\config\Description.java
...
jaxb\servlet\config\WebApp.java
jaxb\servlet\config\WebResourceCollection.java
jaxb\servlet\config\WebResourceName.java
jaxb\servlet\config\WelcomeFile.java
jaxb\servlet\config\WelcomeFileList.java
```
Proces serializácie a deserializácie je analogický ako v predošlých prípadoch. Rozdiel je však v spôsobe inicializácie kontextu. Namiesto jednej triedy môžeme uviesť názov balíčka, ktorého triedy chceme (de)serializovať.

Následne vytvoríme `Unmarshaller` klasickým spôsobom. Koreňovému elementu XML súboru, ktorým je `<web-app>` zodpovedá trieda `WebApp`, a práve túto triedu budeme potrebovať pri deserializácii XML dokumentu. V príklade deserializujeme dáta z XML súboru na disku.
```java
JAXBContext jaxbContext =   
  JAXBContext.newInstance("jaxb.servlet.config");

Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
File xmlFile = new File("web.xml")
WebApp webApp = (WebApp) unmarshaller.unmarshal(xmlFile);
```
Následne môžeme pracovať s triedami klasickým spôsobom. Napr. deklaráciu nového servletu pridáme do webovej aplikácie nasledovne:
```java
Servlet servlet = new Servlet();
ServletName servletName = new ServletName();
servletName.setvalue("HelloServlet");
servlet.setServletName(servletName);
    
webApp.getServlet().add(servlet);
```
Spätnú serializáciu (v tomto prípade na konzolu) dosiahneme tiež klasickým spôsobom, zavolaním metódy `marshall()` nad objektom typu `WebApp`.
```java
Marshaller marshaller = jaxbContext.createMarshaller();
marshaller.marshal(webApp, System.out);
```

# Odkazy
##  Webové odkazy
* [Referenčná implementácia JAXB](https://jaxb.dev.java.net/ )
* [JavaDoc ](http://java.sun.com/javase/6/docs/api/javax/xml/bind/package-summary.html ) k JAXB
* [Java Architecture for XML Binding](http://java.sun.com/developer/technicalArticles/WebServices/jaxb/ ) - základný článok na java.sun.com
* [Binding between XML Schema and Java Classes ](http://java.sun.com/javaee/5/docs/tutorial/doc/bnazf.html ) - Java EE 5 Tutorial 
* [Improved XML Binding with JAXB 2.0](http://javaboutique.internet.com/tutorials/jaxb/index4.html ) - náhľad na technológiu na Java Boutique
* [A practical guide to JAXB 2.0](http://www.regdeveloper.co.uk/2006/09/22/jaxb2_guide/ ) - tutoriál k práci s JAXB 2.0 v Eclipse
* [Špecifikácia k ''XML Schema''](http://www.w3.org/TR/xmlschema-0/ )
##  Iné podobné projekty
* [Castor](http://www.castor.org ) - mapovanie medzi XML, Java triedami a SQl tabuľkami
* [XStream](http://xstream.codehaus.org/ ) - jednoduchý nástroj na serializáciu objektov do XML a späť


