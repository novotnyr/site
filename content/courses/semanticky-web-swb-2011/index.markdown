---
title: Sémantický web (UINF/SWB) – 2010–2014
date: 2010-02-22T18:04:46+01:00
year: [ "2010/2011", "2011/2012" , "2012/2013", "2013/2014" ]  
course: UINF/SWB
---
# Základné informácie
*Kód predmetu:* ÚINF/SWB/10

*Počet kreditov:* 4

*Vyučujúci:* 

- RNDr. Peter Gurský, PhD
- RNDr. Róbert Novotný

*Rozvrh*:

- utorok, 9:50 -- 12:25, P/7

# Realizované cvičenia

## Sémantický web a motivácia, oblasti, problémy, vízie. 
- Prezentácia: [The Semantic Web Vision](http://www.ics.forth.gr/isl/swprimer/presentations/Chapter1.ppt) zo SWP.

## Štruktúrované webové dokumenty a XML
* Prezentácia [Structured Web Documents in XML](http://www.ics.forth.gr/isl/swprimer/presentations/Chapter2.ppt ) zo SWP
* Článok *XML a menné priestory*
* Článok *Transformácie XML*
* Článok *XPath*

### Nástroje

* [Online XSL Tools](http://www.purplegene.com/static/transform.html)
* [XPath Testbed](http://www.whitebeam.org/library/guide/TechNotes/xpathtestbed.rhtm )
* [FirePath](https://addons.mozilla.org/en-US/firefox/addon/firepath/ ) -- rozšírenie pre Firefox. Vyžaduje nainštalovaný FireBug.
* [XSLTCake](http://www.xsltcake.com/ ) -- online nástroj pre testovanie XSLT.
* [XSLTTest](http://xslttest.appspot.com/ ) -- ďalší online nástroj pre testovanie XSLT

### Vzorové XML zo slajdov
```xml
<library location="Bremen">
	<author name="Henry Wise">
		<book title="Artificial Intelligence"/>
		<book title="Modern Web Services"/>
		<book title="Theory of Computation"/>
	</author>
	<author name="William Smart">
		<book title="Artificial Intelligence"/>
	</author>
	<author name="Cynthia Singleton">
		<book title="The Semantic Web"/>
		<book title="Browser Technology Revised"/>
	</author>
</library>
```

### Vzorová XSLT šablóna
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" indent="yes"/>
    <xsl:template match="/author">
        <html>
            <head>
                <title>An author</title>
            </head>
            <body bgcolor="white">
                <b>
                    <xsl:value-of select="name"/>
                </b>
                <br />
                <xsl:value-of select="affiliation"/>
                <br />
                <i>
                    <xsl:value-of select="email"/>
                </i>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
```


## Popisovanie webových zdrojov pomocou RDF
- Prezentácia [Describing Web Resources in RDF](http://www.ics.forth.gr/isl/swprimer/presentations/Chapter3.ppt ) zo SWP

## Jazyk ontológií webu: OWL
- Prezentácia [Web Ontology Language: OWL](http://www.ics.forth.gr/isl/swprimer/presentations/Chapter4.ppt ) zo SWP


## SPARQL

## Modelovanie, Description Logics. 
* Potreba formálnej logiky v konceptuálnom modelovaní
    * [The Need for a Logic in Conceptual Modeling](http://www.inf.unibz.it/~franconi/dl/course/slides/modelling/modelling.pdf)
    * [prezentácia v slovenčine](deskripcna-logika1.pdf ) (pokrýva slajdy 1--41)
* Motivácie z objektovo-orientovaného programovania, deskripčná logika FL-
    * [prezentácia v slovenčine](deskripcna-logika2.pdf ) 
* Deskripčná logika ALC
    * [prezentácia v slovenčine](deskripcna-logika3.pdf ) 

## Protege
* [stránka Juraja Bobáka](http://s.ics.upjs.sk/~bobco/?podsekcia=semantic)
* [španielsky videotutoriál](http://www.youtube.com/watch?v=g6MxiUxlrL0&feature=related)
* [Protege OWL tutoriál](http://owl.cs.manchester.ac.uk/tutorials/protegeowltutorial/ )
* plug-in [OntoViz](http://protegewiki.stanford.edu/wiki/OntoViz#Installation)
* projekt [Vysielanie](http://s.ics.upjs.sk/~bobco/protege/vysielanie.zip) z cvičenia
* [GraphViz](http://www.graphviz.org/Download_windows.php)
* plug-in Jambalaya pre vizualizáciu rámcov v ontológiách
    * [download](http://sourceforge.net/projects/chiselgroup/)
    * [Getting Started](http://www.thechiselgroup.org/jambalaya_getting-started)

## Jena
- [prezentácia Maroš Dzuriš](semanticky-web-dzuris-jena.pdf)

## Sesame
*  [Sesame](http://www.openrdf.org/)
*  [Manuál](http://www.openrdf.org/doc/sesame2/users/ )


# Pokrytie obsahu
* Sémantický web a motivácia, problémy, vízie.
* XML, syntax, rozličné programové modely (DOM, SAX, StAX), menné priestory v XML, adresovací jazyk XPath, dopytovací jazyk XQuery. Ukážky programovania v Jave.
* RDF, RDFS
* OWL
* dopytovacie jazyky: SPARQL
* softvérové nástroje: Jena, Sesame, Protege
* základy deskriptívnej logiky
* odvodzovanie v deskripčnej logike

# Odkazy
* [Technologie sémantizace webu (NSWI140)](http://www.ksi.mff.cuni.cz/~vojtas/vyuka/NSWI140TechnologieSemantizaceWebu/1011/NSWI140.html ) -- predmet na MFF UK Praha
* Grigoris Antoniou and Frank van Harmelen: Semantic Web Primer, Second Edition. MIT Press, 2008. ISBN: 978-0-262-01242-3 
    * [odkaz dostupný zo 158.197.*.*](http://ics.upjs.sk/~novotnyr/home/skola/semanticky-web/)
    * [anglické slajdy k SWP](http://www.ics.forth.gr/isl/swprimer/presentation.htm)
* [Description Logics Tutorial](http://www.inf.unibz.it/~franconi/dl/course/ ). Enrico Franconi, Free University of Bozen-Bolzano.
* [Semantic Web](http://www.dcs.bbk.ac.uk/~michael/sw/sw.html ). Birkbeck University of London.


## Náhodné odkazy
* http://www2.fiit.stuba.sk/~kapustik/ZS/Clanky0607/petras/index.html
* http://www2.fiit.stuba.sk/~kapustik/ZS/Clanky0910/csoka/index.html
* http://www2.fiit.stuba.sk/~kapustik/ZS/Clanky0607/klempa/index.html
* http://www2.fiit.stuba.sk/~kapustik/ZS/Clanky0809/fris/index.html
* Vojtěch Svátek: Ontologie a WWW. DATAKON 2002. Dostupné na iternete: http://nb.vse.cz/~svatek/onto-www.pdf
* De Bruin, J.: Using Ontologies : Enabling Knowledge Sharing and Reuse on the Semantic Web.
* DERI Technical Report DERI-TR-2003-10-29. Október 2003. Dostupné na internete: http://www.deri.at/publications/techpapers/documents/DERI-TR-2003-10-29.pdf
* Noy, N., Hafner, C.: The State of the Art in Ontology Design : A Survey and Comparative Review. AI Magazine, American Association for Artificial Intelligence, 2003 
* DERI Insbruck: Technical Papers. Dostupné na internete: http://www.deri.at/publications/techpapers/
* http://www.cs.man.ac.uk/~horrocks/ISWC2003/Tutorial/introduction.ppt
* http://www.hitka.sk/diplomovka/index.php
* http://www.dcs.elf.stuba.sk/~kapustik/ZS/Clanky0405/matusik/reprezentSW.htm
* http://nlp.fi.muni.cz/projekty/owl/
* [Topic Maps vs RDF](http://www.ontopia.net/topicmaps/materials/tmrdf.html)