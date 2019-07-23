---
title: Transformácie XML súborov v Jave pomocou TraX 
date: 2007-09-30T11:54:31+01:00
---

Úvod
====

Do práce s XML v Jave väčšinou spadá jedna z nasledovných operácií:

* práca s jednotlivými uzlami - teda elementmi, atribútmi, textom atď pomocou niektorého z mnohých dostupných API (či už DOM, SAX, StAX)
* adresovanie uzlov pomocou dopytovacieho jazyka XPath
* transformácia XML pomocou niektorého z transformačných jazykov.

V tomto článku sa budeme venovať tretiemu bodu. Transformácia XML stromu je proces, ktorý na základe vstupného XML a nejakých pravidiel vráti prepracované výstupné XML. Štandardným jazykom na transformáciu je jazyk XSL Transformations alebo XSLT.

Už od JDK 1.4 je k dispozícii balíček `java.xml.transform` s triedami podporujúcim transformácie. 

Základným nástrojom na vykonávanie transformácií je trieda `Transformer` a jej metóda `transform()` s dvoma parametrami: zdrojom `Source` a cieľom `Result`. Zdroj môže byť takpovediac ľubovoľný: zdrojom môže byť DOM strom (`DOMSource`), postupnosť SAX udalostí `SAXSource`, či vstupný prúd údajov (`StreamSource`). Rovnako je k dispozícii viacero cieľov: `DOMResult` (výstupom je DOM strom), `SAXResult` (postupnosť udalostí SAX), či `StreamResult` pre zápis do prúdov.

Postup je nasledovný:
1.  získame inštanciu továrne `TransformerFactory` cez `TransformerFactory.newInstance()`
1.  z nej získame novú inštanciu `Transformer`a pomocou metódy `newTransformer()`
1.  na inštancii transformera voláme príslušné metódy
Príklad kódu, ktorý vezme vstupný reťazec s XML a v transformácii nespraví nič:
```java
public static void main(String[] args) {
  try {
    String xml = "<document><text>Hello</text></document>";

    TransformerFactory transformerFactory 
      = TransformerFactory.newInstance();
    Transformer serializer = transformerFactory.newTransformer();

    // zdrojom je prúd dát zo Stringu
    Source source = new StreamSource(new StringReader(xml));
    // cieľom je prúd dát do konzoly
    Result result = new StreamResult(System.out));

    serializer.transform(source, result);
  } catch (TransformerConfigurationException e) {
    e.printStackTrace();
  } catch (TransformerFactoryConfigurationError e) {
    e.printStackTrace();
  } catch (TransformerException e) {
    e.printStackTrace();
  }
}
```
Je dôležité vedieť, že inštanciu `TransformerFactory` môžeme znovupoužiť na vytvorenie viacerých transformátorov. Rovnako jednu inštanciu transformátora môžeme znovupoužiť na viacero transformácií. Dôležité je vedieť, že obe triedy **nie sú** *thread-safe*, teda stavané na prácu s viacerými vláknami. To sa prejaví najčastejšie v servletoch. Je nebezpečné mať servlet
```java
// Tento servlet je NEKOREKTNÝ. Nastanú chyby pri práci s viacerými vláknami.
public class TransformerServlet extends HttpServlet {
  @Override
  public void init() throws ServletException {
    try {
      transformer = TransformerFactory.newInstance().newTransformer();
    } catch (Exception e) {
      throw new ServletException("Nemôžem vytvoriť transformátor.");
    }
  }

  @Override
  protected void doGet(HttpServletRequest req, 
                       HttpServletResponse resp)
    throws ServletException, IOException 
  {
    //tu pracujeme s transformerom
  }

  private Transformer transformer;

}
```
Pokojne sa môže stať, že viacero požiadaviek pracuje súčasne nad inštanciou transformátora, z čoho môžu vyplynúť ťažko odladiteľné chyby.

Transformátor je v podstate viacúčelová trieda, ktorú môžeme používať aj na prevod medzi XML reprezentáciami. V uvedenom príklade sme previedli reťazcovú reprezentáciu na reťazcovú. Ak by sme ako zdroj použili `DOMSource`, dosiahli by sme prevod DOM stromu do textu.

## Konfigurácia transformácie
Transformáciu si môžeme do istej miery prispôsobiť. 
```java
Transformer t = transformerFactory.newTransformer();
// vynecháme XML prológ
t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
// zapneme odsadenie textu
t.setOutputProperty(OutputKeys.INDENT, "yes");

t.transform(source, result);
```
Metódou `setOutputProperty()` vieme nastaviť vlastnosti pre výstup. Štandardne sú k dispozícii vlastnosti zo [špecifikácie XSLT](http://java.sun.com/j2se/1.4.2/docs/api/javax/xml/transform/OutputKeys.html ). V podobe konštánt sú uvedené v triede `OutputKeys`.

## Transformácie podľa XSLT šablóny
Dosiaľ sme vykonávali len transformácie, ktoré dáta zo vstupu bez zmeny poslali na výstup. Ak chceme vykonávať skutočné transformácie, ktoré dáta zo vstupu pozmenia, použijeme na to pravidlá reprezentované XSLT šablónou. Nasledovná šablóna vyberie zo vstupného XML dokumentu obsah elementu `text`, ktorý sa nachádza v koreňovom elemente `document`:
```xml
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <xsl:value-of select="/document/text" />
  </xsl:template>
</xsl:stylesheet>
```
Výsledkom transformácie na hore uvedený vstupný dokument má byť 
(:code:)
Hello
(:codeend:)
Metóda `newTransformer()` v továrni na transformátory môže brať parameter typu `Source`, ktorý obsahuje zdroj transformačnej šablóny.
```java
Source xslt = new StreamSource(new File("template.xslt"));

// vytvoríme transformátor riadiaci sa šablónou XSLT
Transformer serializer 
  = transformerFactory.newTransformer(xslt);

// zdrojom je prúd dát zo Stringu
Source source = new StreamSource(new StringReader(xml));
// cieľom je prúd dát do konzoly
Result result = new StreamResult(System.out));

serializer.transform(source, result);
```
## Predpripravené transformácie
Ak sme si istí, že XSLT šablóna je nemenná, môžeme urýchliť proces transformácie tým, že ju predkompilujeme. Skompilovaná XSLT šablóna je reprezentovaná inštanciou triedy `Templates`.
```java
Source xslt = new StreamSource(new File("template.xslt"));

TransformerFactory transformerFactory 
  = TransformerFactory.newInstance();
// vytvoríme skompilovanú šablónu
Templates templates = transformerFactory.newTemplates(xslt);
// zo šablóny vieme získať transformátor
Transformer t = templates.newTransformer();
t.transform(source, result);
```
Inštancia `Templates` je znovupoužiteľná a je navyše **thread-safe**. Na tejto inštancii potom môžeme doladiť výstup pomocou `setOutputProperty()`, ktorý sa potom aplikuje na transformátory získané pomocou nej.

# Časté chyby
Metóda `newTransformer()` nesmie podľa dokumentácie nikdy vrátiť `null`.
```java
TransformerFactory tfactory = TransformerFactory.newInstance();
Transformer transformer = tfactory.newTransformer(xslSource);
```
Xalan 2.7.1 má však chybu XALANJ-1549, kde pri použití neexistujúceho súboru XSLT šablóny vypíše chybu do `System.err` a vráti `null`ovú hodnotu transformera.

Odporúčaným riešením je registrácia inštancie `ErrorListenera` na transformačnej factory. Inštancia prevezme výnimku z parametra a vyhodí ju klasickým spôsobom:
```java
TransformerFactory tfactory = TransformerFactory.newInstance();
// due to XALANJ-1549
tfactory.setErrorListener(new ErrorListener() {
@Override
public void fatalError(TransformerException exception)
    throws TransformerException {
  throw new TransformationException(exception);
}

@Override
public void warning(TransformerException exception)
    throws TransformerException {
}

@Override
public void error(TransformerException exception)
    throws TransformerException {
}
});
```


# Referencie
* Balíček [`javax.xml.transform`](http://java.sun.com/j2se/1.4.2/docs/api/javax/xml/transform/package-summary.html )
* Špecifikácia [XSLT 1.0](http://www.w3.org/TR/xslt )
* Tutoriál ku XSLT na [zvon.org](http://www.zvon.org/xxl/XSLTreference/Output/ )

