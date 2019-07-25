---
title: Apache Forrest – receptár tipov a trikov
date: 2006-02-02T00:00:00+01:00
---



# Forrest a slovenské fonty

## Problém
[Formatting Objects](http://xml.apache.org/forrest |Apache Forrest]] je nástroj na generovanie projektovej dokumentácie v rôznych formátoch zo vstupných súborov vo formáte (implicitne) DocBook. Najčastejším použitím je výstup vo forme webových stránok alebo PDFka. Príkladom siete vytvorenej Forrestom sú stránky k mojej [[http://s.ics.upjs.sk/~novotnyr/dp |diplomke]]. Jednou záludnosťou pri generovaní PDFiek je notorický problém slovenčiny - diakritika. V štandardnej distribúcii a konfigurácii nepodporuje Forrest pri generovaní PDFiek diakritiku - namiesto nej sa zobrazia mriežky #. Jadro problému spočíva vo [[http://xml.apache.org/fop |FOPe]], čo je nástroj spracovávajúci [[http://www.w3.org/TR/2001/REC-xsl-20011015/ ) (stručne: špecifikácia pre XML dokumenty s jemnými možnosťami pre formátovanie ich vzhľadu). 

## Riešenie (základné r. ťažkého kalibru)
Na vyriešenie problému použijeme podporný balíček pre FOP, ktorého autorom je Jiří Kosek. 

* Stiahneme balíček z z http://www.kosek.cz/sw/fop/fop-cs.zip
* V tomto archíve rozbalíme obsah adresára `conf` na nejaké inteligentné miesto, napr. do ` %FORREST_HOME%/fonts/conf`
* Otvoríme v tomto adresári súbor `userconfig.xml`, použijeme z neho obsah medzi tagmi <fonts>...</fonts>. Nahradíme entitu `&fop.home;` umiestnením súborov z archívu vo formáte URI. Napr. `&fop.home;/conf/cour.xml` prevedieme na tvar `file:///c:/java/apache-forrest-0.5.1/fonts/conf/cour.xml`. Entitu `&fonts.dir;` nahradíme umiestnením fontu v operačnom systéme. Napr. vo Windows nahradíme `&fonts.dir;/cour.ttf` formou `C:/Windows/fonts/cour.ttf`.
* Tento nahradený obsah vložíme do súboru `%FORREST_HOME%/WEB-INF/lib/fop-0.20.5.jar/conf/config.xml` medzi tagy <fonts>...</fonts> (JAR si môžeme predtým odzálohovať...)
* generujeme PDFko klasickým spôsobom

Here endeth the lesson.
