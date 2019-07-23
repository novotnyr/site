---
title: Xerces – Java XML Parser Primer
date: 2005-02-01T11:03:02+01:00
---

# DOM v Xercesovi

> Na salaši pod Veprom
> TramtáriaDOM
> Budú miestne preteky
> V hode oštiepkom
> — L&S&F -- Majstrovstvá

```java
DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
factory.setValidating(true);
factory.setIgnoringElementContentWhitespace(true);
DocumentBuilder builder = factory.newDocumentBuilder();
// Method input for entering String included
Document doc = builder.parse(filename);
// DOM tree done - getting the root element
 Element root = doc.getDocumentElement();
```

# SAX

## Štartér

```java
import org.xml.sax.XMLReader;
import org.xml.sax.ContentHandler;
import java.io.IOException;
import org.xml.sax.SAXException;

public class SAXParserDemo {

  public void performDemo(String uri) {
    System.out.println("Parsing XML File: " + uri + "\n\n");

    //Create ContentHandler to handle SAX events
    ContentHandler contentHandler = new MyContentHandler();
    System.out.println("+OK: Handler assigned");
    try {
      // Instantiate a parser
      XMLReader parser = XMLReaderFactory.createXMLReader();
      // Alternatively, you can instantiate vendor's implementation directly.
      // Driver can be specified via system property: java -Dorg.xml.sax.driver=gnu.xml.aelfred2.XmlReader
      //XMLReader parser = new org.apache.xerces.parsers.SAXParser();

      // Register the content handler
      parser.setContentHandler(contentHandler);
      // Parse the document
      parser.parse(uri);
      // Serialize result
    } catch (IOException e) {
      System.out.println("Error reading URI: " + e.getMessage());
    } catch (SAXException e) {
      System.out.println("Error in parsing: " + e.getMessage());
      e.printStackTrace(System.out);
    }
  }

  public static void main(String[] args) {
    if (args.length != 1) {
      System.out.println("Usage: java SAXParserDemo [XML URI]");
      System.exit(0);
    }
    String uri = args[0];
    SAXParserDemo parserDemo = new SAXParserDemo();
    parserDemo.performDemo(uri);
  }
}
```

## `ContentHandler`

```java
class MyContentHandler implements ContentHandler {
    private Locator locator;

    public void setDocumentLocator(Locator locator) {
      System.out.println(" * setDocumentLocator( ) called");
      this.locator = locator;
    }

    public void startDocument() throws SAXException {
      System.out.println("Parsing begins...");
    }

    public void endDocument() throws SAXException {
      System.out.println("Parsing ends...");
      System.out.println("------------------");
      System.out.println("Serializing result");
      serializeNode(resultDocument);
    }

    public void processingInstruction(String target, String data)
    throws SAXException {
    }

    public void startPrefixMapping(String prefix, String uri) {
    }

    public void endPrefixMapping(String prefix) {
    }

    public void startElement(String namespaceURI, String localName,
    String rawName, Attributes atts) throws SAXException {
      System.out.println("startElement: " + localName + "\n");
    }

    public void endElement(String namespaceURI, String localName,
    String rawName) throws SAXException {
      System.out.println("endElement: " + localName + "\n");
    }

    public void characters(char[] ch, int start, int end)
    throws SAXException {
      String s = new String(ch, start, end);
      System.out.println("characters: " + s);
    }

    public void ignorableWhitespace(char[] ch, int start, int end)
    throws SAXException {
    }

    public void skippedEntity(String name) throws SAXException {
    }
}
```

Alternatívne je možné triedu ` MyContentHandler`  oddediť od štandardnej implementácie ` DefaultHandler` , ktorej metódy implementujú rozhranie ` ContentHandler`  tak, že nerobia nič.

```java
public class MyContentHandler extends DefaultHandler {

  public void startDocument() throws SAXException {
    System.out.println("Parsing begins...");
  }

  public void endDocument() throws SAXException {
    System.out.println("Parsing ends...");
    System.out.println("------------------");
    System.out.println("Serializing result");
  }

  public void startElement(String namespaceURI, String localName,
      String rawName, Attributes atts) throws SAXException {
    System.out.println("startElement: " + localName);
  }

  public void endElement(String namespaceURI, String localName, String rawName)
      throws SAXException {
    System.out.println("endElement: " + localName);
  }

  public void characters(char[] ch, int start, int end) throws SAXException {
    String s = new String(ch, start, end);
    System.out.println("characters: " + s);
  }
}
```

## Metóda `characters()` .
Typický začiatočnícky používateľ si nevšimne nenápadné upozornenie v dokumentácii metódy `characters()` , ktoré hovorí, že reťazce v XML elemente sa nemusia spracovať v jedinom volaní tejo metódy. Inak povedané, napr. v prípade elementu

```xml
<nazov>Everything is proceeding as I have foreseen.</nazov>
```
sa text `Everything is proceeding as I have foreseen.`	 pri spracovávaní môže rozdeliť do dvoch volaní metódy ` characters()` . V prvom volaní môže prísť napr. text ''Everything is proceeding'' a zvyšok textu dostanete k dispozícii až v ďalšom volaní. Preto je priam nutné zhromažďovať jednotlivé kusy textu v ` StringBuffer` i a následne na vhodnom mieste si z neho skompletizovaný obsah elementu vytiahnuť.

` ContentHandler`  môže vyzerať napr. takto:
```java
public class MyContentHandler extends DefaultHandler {
  private StringBuffer charBuffer = new StringBuffer();

  public void startDocument() throws SAXException {
    System.out.println("Parsing begins...");
  }

  public void endDocument() throws SAXException {
    System.out.println("Parsing ends...");
    System.out.println("------------------");
    System.out.println("Serializing result");
  }

  public void startElement(String namespaceURI, String localName,
      String rawName, Attributes atts) throws SAXException {
    System.out.println("startElement: " + localName);
  }

  public void endElement(String namespaceURI, String localName, String rawName)
      throws SAXException {
    System.out.println("endElement: " + localName);
    
    //element skončil, vypíšeme nazhromaždený text...
    System.out.println(charBuffer);
    //..a keďže text už nepotrebujeme, vymažeme StringBuffer
    charBuffer.setLength(0);
  }

  public void characters(char[] ch, int start, int end) throws SAXException {
    String s = new String(ch, start, end);
    System.out.println("characters: " + s);
    
    charBuffer.append(s);
  }
}
```

# Transformácie XSL

Pozri tiež [článok o Transformáciách pomocou TraX]({{< ref "transformacie-xml-suborov-v-jave-pomocou-trax.markdown" >}}).

http://www-106.ibm.com/developerworks/edu/x-dw-xusax-i.html

# Serializácia XML

## Serializacia XML pomocou pomocnych tried Xalanu

```java
OutputFormat format = new OutputFormat(document);
format.setLineSeparator(LineSeparator.Windows);
format.setIndenting(true);
format.setLineWidth(0);
format.setPreserveSpace(true);

StringWriter out = new StringWriter();
XMLSerializer serializer = new XMLSerializer(out, format);
serializer.asDOMSerializer();
serializer.serialize(document);

return out.toString();
```

# Preliezanie stromu (` NodeIterator` )
```java
Document doc = //...
NodeIterator ni = ((DocumentTraversal) doc).createNodeIterator(doc.getDocumentElement(), NodeFilter.SHOW_ALL, null, false);

Node node;
while((node = ni.nextNode()) != null) {
  System.out.println(node.getNodeName());

  if(node.getAttributes() != null) {
    for(int i = 0; i < node.getAttributes().getLength(); i++) {
      System.out.println("  " + node.getAttributes().item(i));
    }
  }
}
```