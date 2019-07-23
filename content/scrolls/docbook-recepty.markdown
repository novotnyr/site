---
title: DocBook – receptár tipov a trikov
date: 2011-03-21T00:00:00+01:00
---



# Ako editovať DocBook?

[XMLMind XML Editor](http://www.xmlmind.com/xmleditor/) podporuje tvorbu dokumentov vo formáte DocBook (a tiež DITA či XHTML) vo WYSIWYG podobe. Pre nekomerčné použitie je zadarmo, i keď oproti profesionálnej verzii neobsahuje zabudované nástroje pre transformácie dokumentov.

# Odkiaľ získať XSLT šablóny?
Najlepšie [z projektových stránok](http://sourceforge.net/projects/docbook/files/docbook-xsl/) na SourceForge.

Šablóny stiahnite a rozbaľte do vhodného adresára (napr. `C:\Programs\docbook-xslt`).

# Ako rozbehať transformácie s `xsltproc`?
Knižnica `xmlib` je pôvodne knižnica pre spracovanie XML určená pôvodne pre prostredie GNOME. Binárky sú k dispozícii pre rozličné platformy. Skompilované knižnice pre Windows sú k dispozícii na serveri [Zlatkovic.com](http://www.zlatkovic.com/libxml.en.html).

XSLT transformácie potrebujú minimálne nasledovné knižnice:
* zlib-1.2.5.win32.zip
* iconv-1.9.2.win32.zip
* libxslt-1.1.26.win32.zip 
* libxml2-2.7.7.win32.zip 

Všetky knižnice stiahnime a rozbaľme do vhodného adresára (napr. `C:\Programs\libxml`, pričom ich treba zhromaždiť v jedinom adresári:
* iconv.dll
* libexslt.dll
* libxml2.dll
* libxslt.dll
* zlib1.dll
* iconv.exe
* minigzip.exe
* xmlcatalog.exe
* xmllint.exe
* xsltproc.exe 

Adresár s rozbalenými súbormi je vhodné pridať do premennej prostredia `PATH`.

## Vykonanie transformácie
Transformácie možno spustiť pomocou `xsltproc`:
```
xsltproc c:\Programs\docbook-xslt\xhtml\docbook.xsl refprirucka.xml > test.xml
```

# Ako rozbehať transformácie v Jave?
V JDK 1.6.0_24 sa nachádza zabudovaný transformátor Apache Xalan vo verzii 2.6.0. Táto verzia je zastaralá a spôsobuje záludné chyby. Namiesto toho silne odporúčame stiahnuť Xalan v poslednej verzii (2.7.1).
## Stiahnuť Xalan 2.7.1
Z projektových stránok stiahnite `xalan-j_2_7_1-bin-2jars.zip`. 

## Použitie z príkazového riadku
```
java -jar xalan.jar -IN c:\Users\novotnyr\Documents\refprirucka.xml -XSL c:\Programs\docbook\xhtml\docbook.xsl -OUT c:\Users\novotnyr\Documents\refprirucka.html
```

## Použitie z Java projektu
Vytvorte nový Java projekt a do §§build path§§ pridajte `xalan.jar` a `serializer.jar`.

Kód pre transformáciu vyzerá nasledovne:
```java
import java.io.File;
import java.io.FileReader;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;


public class Transformator {
  public static void main(String[] args) throws Exception {
    StreamSource sablona = new StreamSource(new File("c:/Programs/docbook/html/docbook.xsl"));
				
    StreamSource vstup = new StreamSource(new File("c:/Users/rn/Documents/refprirucka.xml"));
    StreamResult vystup = new StreamResult(new File("C:/Users/rn/Documents/refprirucka.html"));

    Transformer transformer = TransformerFactory.newInstance().newTransformer(sablona);

    transformer.transform(vstup, vystup);
  }
}
```

# `<foreignphrase>` je obalený medzerami!
Vypnite `INDENT` v XSLT transformátore. Ak máte
```java
transformer.setOutputProperty(OutputKeys.INDENT, "yes");
```
rozbije vám to výstup.
