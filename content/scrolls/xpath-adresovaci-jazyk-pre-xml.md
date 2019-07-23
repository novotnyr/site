---
title: XPath - adresovací jazyk pre XML
date: 2007-10-02T10:56:16+01:00
---
# Úvod
XPath je programovací jazyk určený na adresáciu jednotlivých prvkov XML súboru. Umožňuje pomocou jednoduchej syntaxe riešiť problémy typu "chcem všetky `title ` elementy", chcem všetky elementy `author`, ktoré sa nachádzajú pod elementom `book` s atribútom `id` rovným `12`", chcem všetkých vnukov koreňového elementu, a pod.

Jeho syntax je inšpirovaná syntaxou používanou v súborových systémoch - jednotlivé prvky XML stromu sú oddeľované lomkami. Je možné sa dopytovať na elementy v štruktúre, podstrome, prípadne v atribútoch.

Príklady dopytov v jazyku XPath sú napr.:

* `//title`

* `//book[@id=12]//author`
* `/books/book[author="Eco"]/author/firstName`

Treba podotknúť, že jazyk umožňuje len adresovať existujúce prvky v danom dokumente XML. Nie je v jeho silách vytvárať v dopytoch nové elementy, či modifikovať existujúce. (To je doménou komplexnejších jazykov ako XQuery alebo XSLT).

Možnosti jazyka XPath je možné preskúmať buď v peknom českom [tutoriále na Zvon.org](http://www.zvon.org/xxl/XPathTutorial/General_cze/examples.html) alebo priamym štúdium [špecifikácie](http://www.w3.org/TR/xpath).

XPath existuje v dvoch verziách - jednoduchšej a staršej verzii 1.0, ku ktorej existuje množstvo implementácií v rôznych programovacích jazykoch, a novšej značne prepracovanej verzii 2.0.

# XPath a Java - dodávateľské implementácie
## Apache Xalan
Špecifikácia XPath 1.0 má v Jave viacero rôznych implementácii. Tradične sa využíval napr. projekt [Apache Xalan](http://xml.apache.org/xalan-j/ ). 

Stiahneme `xalan-j_2_7_0-bin-2jars.tar.gz` a do projektu pridáme `xalan.jar`. Použitie XPath v základnej verzii je potom priamočiare:
```java
import javax.xml.transform.TransformerException;

import org.apache.xpath.XPathAPI;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

...

NodeList nodeList = XPathAPI.selectNodeList(document, "id('Gn1')");
for (int i = 0; i < nodeList.getLength(); i++) {
  Node node = nodeList.item(i);
  System.out.println(node);
}
```

Jadrom je trieda `org.apache.xpath.XPathAPI`, ktorá obsahuje metódy na vrátenie zoznamu uzlov (NodeList) alebo iterátora (NodeIterator).

Pre väčšiu efektivitu je možné použiť triedu `CachedXPathAPI`. Statické metódy triedy `XPathAPI` totiž s každým volaním vytvárajú nový model pre vstupný dokument. Naopak, trieda `CachedXPathAPI` môže medzi volaniami využívať stále rovnaký dokumentový model.

### Xalan a Java 1.4
V rámci Javy 1.4 je automaticky dodávaná staršia verzia Xalana (vo verzii 1.4.2_15 je k dispozícii Xalan 2.4.1). Vyššie uvedený postup bude fungovať aj bez stiahnutia Xalanovských knižníc. Napriek tomu sa však odporúča stiahnuť novšiu verziu Xalana zo stránok Apachu, predíde sa tým problémom s prípadnými staršími neopravenými chybami.


## Saxon
Saxon je alternatívna implementácia XML parsera, a vyhodnocovača jazykov XPath, XSLT a XQuery. Softvér je možné stiahnuť zo stránok [SourceForge](http://sourceforge.net/project/showfiles.php?group_id=29872 ). Do `CLASSPATH` si stačí pridať `saxon8.jar`.

Programový prístup k XPath je o niečo iný než v prípade Xercesu.
```java
import java.io.FileReader;
import java.util.List;

import javax.xml.transform.sax.SAXSource;

import net.sf.saxon.om.NodeInfo;
import net.sf.saxon.sxpath.XPathEvaluator;
import net.sf.saxon.sxpath.XPathExpression;

import org.xml.sax.InputSource;

...
//vybudujeme dokumentový model
InputSource inputSource = new InputSource(new FileReader("d:/gnsample.xml"));
SAXSource saxSource = new SAXSource(inputSource);
        
XPathEvaluator xPathEvaluator = new XPathEvaluator();
XPathExpression xPathExpression = xPathEvaluator.createExpression("id('Gn1')");
List result = xPathExpression.evaluate(saxSource);
for (int i = 0; i < result.size(); i++) {
  NodeInfo node = (NodeInfo) result.get(i);
  System.out.println(node.getStringValue());
}
```

Základnými triedami sú `XPathEvaluator`, pomocou ktorého vytvoríme „skompilovanú" formu výrazu v jazyku XPath (metódou `createExpression()`). Na objekte `XPathExpression` potom pomocou metódy `evaluate()` získame výsledok dopytu XPath. V našom príklade je výsledkom množina uzlov (`NodeInfo`), ktorú vypíšeme.

Od Javy 5 je podpora pre XPath dodávaná priamo v rámci JRE.

### Saxon a Java 1.4
Uvedený postup bude fungovať aj v prípade Javy 1.4 ako alternatíva Xalana.

# XPath a Java - prístup pomocou rozhrania JAXP
Vyššie uvedené prístupy majú jednu nevýhodu - prístup k XPath sa líši od dodávateľa k dodávateľovi. Túto nevýhodu má za cieľ odstrániť špecifikácia [JAXP](http://java.sun.com/webservices/jaxp/index.jsp ) (Java API for XML Processing), ktorá má „umožniť aplikáciam spracovávať a transformovať dokumenty XML nezávisle od konkrétnej implementácie XML spracovávateľa".

V Jave 1.4 je možné dodatočne [stiahnuť JAXP vo verzii 1.3](https://jaxp.dev.java.net/servlets/ProjectDocumentList?folderID=4584&expandFolder=4584&folderID=0 ). V Jave 5 je už JAXP priamo k dispozícii.

Dopytovanie XPath v rámci JAXP je nasledovné:
```java
import java.io.File;
import java.io.IOException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;


public class XPathApiUsage {
  public static void main(String[] args) {
    try {
      //vybudujeme dokument DOM
      DocumentBuilder documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
      Document document = documentBuilder.parse(new File("D:/gnsample.xml"));

      //vytvorime novu instanciu tovarne na XPathy
      XPathFactory xPathFactory = XPathFactory.newInstance();
      //vytvorime novy XPath
      XPath xPath = xPathFactory.newXPath();
      
      NodeList nodeList = (NodeList) xPath.evaluate("id('Gn1')", document, XPathConstants.NODESET);
      for (int i = 0; i < nodeList.getLength(); i++) {
        Node node = nodeList.item(i);
        System.out.println(node);
      }
      
    } catch (ParserConfigurationException e) {
      System.err.println("Cannot configure parser:");
      e.printStackTrace(System.err);
    } catch (IOException e) {
      System.err.println("Cannot load document:");
      e.printStackTrace(System.err);
    } catch (SAXException e) {
      System.err.println("Cannot parse document:");
      e.printStackTrace(System.err);
    } catch (XPathExpressionException e) {
      System.err.println("Cannot execute XPath");
      e.printStackTrace(System.err);
    }
  }
}
```

Dôležitými triedami sú:
* `javax.xml.xpath.XPath` predstavuje objekt pre dopyt jazyka `XPath`.
* `javax.xml.xpath.XPathFactory` je továreň pre objekty `XPath`. Táto abstraktná trieda si automaticky v systéme nájde svoju konkrétnu implementáciu (v závislosti od dodávateľa) a vráti ju. Pomocou metódy `newXPath()` vrátime nový objekt `XPath`.

Objekty `XPath` možno používať dvojako. Prvým spôsobom je priame zavolanie metódy `evaluate()`, ktorej dodáme dopyt v XPathe a dokument, na ktorom sa bude `XPath` vyhodnocovať. Tretím parametrom je dátový typ, ktorý sa má vrátiť (pripomeňme, že XPath rozoznáva 4 dátové typy: množinu uzlov, reťazce, čísla a booleovské hodnoty). Možné hodnoty sú definované v `javax.xml.xpath.XPathConstants`. (Tretí parameter je možné vynechať, vtedy sa očakáva vrátenie reťazca).
```java 
NodeList nodeList = (NodeList) xPath.evaluate("id('Gn1')", document, XPathConstants.NODESET);
for (int i = 0; i < nodeList.getLength(); i++) {
  Node node = nodeList.item(i);
  System.out.println(node);
}
```
Príklad dopytu vracajúceho číslo:
```java
double result = (Double) xPath.evaluate("count(//verse)", document, XPathConstants.NUMBER);
```

Alternatívnym spôsobom použitia objektu `XPath` vhodným pre prípady, keď dopyt voláme viackrát, je použitie metódy `compile()`. Pomocou nej získame predspracovanú a skompilovanú formu dopytu, ktorú reprezentuje objekt `javax.xml.xpath.XPathExpression`. Ten má analogickú metódu `evaluate()`, ktorej môžeme dodať vstupný dokument. `XPathExpression` urýchľuje vyhodnocovanie výrazu, pretože samotné spracovanie, syntaktická kontrola a podobne sa udejú len raz (na rozdiel od priameho volania metód na objektoch `XPath`, ktoré výraz kompilujú s každým volaním nanovo).

```java
XPathExpression xPathExpression = xPath.compile("count(id('Gn1'))");
double result = (Double) xPathExpression.evaluate(document, XPathConstants.NUMBER);
```

## Výmena implementácie JAXP
Vymieňať implementácie JAXP možno jednoducho pomocou systémovej premennej. Štandardne sa ako implementácia `XPathFactory` používa trieda z vnútorností Javy:
```java
XPathFactory xPathFactory = XPathFactory.newInstance();
System.out.println(xPathFactory.getClass());
```
Výpis by mal byť
```
class com.sun.org.apache.xpath.internal.jaxp.XPathFactoryImpl
```
Ak chceme pre XPath používať Saxon, pridáme do `CLASSPATH` knižnice `saxon8.jar`, `saxon8-dom.jar` a `saxon8-xpath.jar`. Použitie saxonovskej implementácie docielime riadkom
```java
System.setProperty(XPathFactory.DEFAULT_PROPERTY_NAME + ":" + XPathFactory.DEFAULT_OBJECT_MODEL_URI, "net.sf.saxon.xpath.XPathFactoryImpl");
```
alebo nastavením systémovej premennej pri spustení:
```
java -Djavax.xml.xpath.XPathFactory:http://java.sun.com/jaxp/xpath/dom=net.sf.saxon.xpath.XPathFactoryImpl
```
alebo vytvorením súboru `jaxp.properties` v podadresári `lib` v adresári, kde je nainštalovaná aktuálne používaná Java:
(:code:)
javax.xml.xpath.XPathFactory\:http\://java.sun.com/jaxp/xpath/dom = net.sf.saxon.xpath.XPathFactoryImpl
(:codeend:)


# Odkazy
* [XML Path Language 1.0](http://www.w3.org/TR/xpath ) - špecifikácia na W3C
* [Tutoriál k XPath](http://www.zvon.org/xxl/XPathTutorial/General_cze/examples.html ) na Zvon.org (v češtine)
* [The Java XPath API](http://www.ibm.com/developerworks/library/x-javaxpathapi.html ) - článok na IBM.com

