---
title: Bedáky nad JAXB - pluginy 
date: 2008-09-10T22:41:41+01:00
---
V jednom z projektov používame JAXB, čo je nástroj na mapovanie XML schémy na Java triedy. Jedného pekného rána sme dostali nápad použiť plugin [FluentAPI](https://jaxb2-commons.dev.java.net/fluent-api/ ), ktorý vie dodať triedam vygenerovaným zo schémy metódy `with...`. Potom vieme používať
```java
USAddress address = new USAddress()
			.withName(name)
			.withStreet(street)
			.withCity(city)
			.withState(state)
			.withZip(new BigDecimal(zip));
```
Stiahli sme teda JAR súbor, a do antovského `build.xml` dodali:
```xml
<taskdef name="xjc" classname="com.sun.tools.xjc.XJCTask">
  <classpath>
    <pathelement path="C:/java/jaxb/lib/jaxb-xjc.jar" />
    <pathelement path="C:/java/jaxb/lib/jaxb-fluent-api-2.1.3.jar" />      
  </classpath>
</taskdef>

<target name="generate-classes">
  <xjc extension="true" destdir="src">
    <schema  dir="src" includes="*.xsd"/>
    <binding dir="src" includes="*.xjb"/>
    <arg value="-Xfluent-api" />
  </xjc>
</target>
```
Spustenie Antu na Sun JDK 1.6 u6 však vyvolalo záplavu výnimiek
```
java.util.ServiceConfigurationError: com.sun.tools.xjc.Plugin: 
Provider org.jvnet.jaxb2_commons.tools.xjc.plugin.fluent_api.XjcFluentApiPlugin could not be instantiated: java.lang.ClassCastException
...
Caused by: java.lang.ClassCastException
  at java.lang.Class.cast(Class.java:2990)
  at java.util.ServiceLoader$LazyIterator.next(ServiceLoader.java:345)
```
Filozofia pluginov v JAXB spočíva v použití filozofie [ServiceLoader](http://java.sun.com/javase/6/docs/api/java/util/ServiceLoader.html )a. Prehľadávajú sa súbory `META-INF/services/com.sun.tools.xjc.Plugin`, v ktorých sa hľadajú názvy tried dediacich od triedy `com.sun.tools.xjc.Plugin`. V prípade FluentApi je v súbore jediný riadok
```
org.jvnet.jaxb2_commons.tools.xjc.plugin.fluent_api.XjcFluentApiPlugin
```
Čas venovaný ladeniu ukázal, že trieda pluginu sa síce nájde, ale nemôže byť pretypovaná na príslušnú nadradenú triedu `Plugin`. Ďalší čas venovaný gúgleniu ukázal, že tento problém nie je výnimočná situácia. Na [fórach Sunu](http://forums.java.net/jive/thread.jspa?messageID=265198 ) je možné vidieť niekoľko bedákov k tejto téme.

Kde je problém? Ukázalo sa, že v pribalení JAXB do runtime JDK 6. V prvých vydaniach JDK 1.6 (do updatu 3) je k dispozícii špecifikácia JAXB 2.0 vrátane jej implementácie. Lenže JAXB sa vyvíja a následne vyšla aktualizovaná špecifikácia JAXB 2.1 spolu s novou implementáciou (v súčasnosti 2.1.7).

Kohsuke Kawaguchi, autor sunovskej implementácie, pri vydaní verzie 2.1 [oznámil](http://weblogs.java.net/blog/kohsuke/archive/2006/12/jaxb_21_release.html ), že migrácia je jednoduchá. Stačí použiť *endorsed* mechanizmus na prekrývanie API v JRE. V tomto prípade treba dať `jaxb-api.jar` (obsahujúci API pre JAXB 2.1) do adresára `lib/endorsed` v JRE. Týmto spôsobom sa potlačí JAXB API 2.0.

Lenže *endorsed* mechanizmus nie je ktovie čo. Modifikácia JRE ako súčasť nasadenia aplikácie sa mnohým ľuďom nepáči. Kohsuke sa teda rozhodol situáciu napraviť pomocou brutálneho classloader vúdú. V [V druhom rozširujúcom poste](http://weblogs.java.net/blog/kohsuke/archive/2007/02/running_jaxbws.html | prvom blogposte]] predviedol fintu, ktorá odstránila nutnosť používať *endorsed* mechanizmus. [[http://weblogs.java.net/blog/kohsuke/archive/2007/02/howitworks_runn.html ) nakreslil úžasný obrázok demonštrujúci štyri (!) classloadery, ktoré spolupracujú na tom, aby sa potlačilo načítavanie JAXB 2.0 API z bootstrap classloadera.

Chvíľu bolo všetko v poriadku.

Následne vyšla JDK 6.0 u4, v ktorej aktualizovali zabudovaný JAXB na verziu 2.1 a dodali novú verziu implementácie. Rama Pulavarthi [na svojom blogu](http://weblogs.java.net/blog/ramapulavarthi/archive/2008/01/jaxws_21_and_ja.html ) zakončil oznámenie radostným *life is better. isn't it?*.

Zjavne nie. Pretože používateľom nefunguje už ani *endorsed* mechanizmus ani Kohsukeho voodoo. Problém s pretypovaním spočíva v tom, že nadradená trieda pluginu sa znovu načítava iným classloaderom než triedy pluginov. Na fóre Sunu však [ktosi](http://forums.java.net/jive/message.jspa?messageID=267755#267755 ) zistil, že pluginy začnú fungovať správne, ak majú názov balíčka začínajúci sa na `com.sun.tools.xjc` (tieto triedy sa zaradia do rovnakého balíčka ako nadradená trieda pluginu.)

Naše riešenie bolo potom nasledovné: stiahli sme zdrojáky pluginu FluentAPI, triedy presunuli do balíčka `com.sun.tools.xjc.plugin.fluent_api`, v súbore `META-INF/services/com.sun.tools.xjc.Plugin` zmenili názov balíčka a prekompilovali plugin projektu.

Zrazu všetko tak funguje ako má. 

Otázka je, kde je problém: či v *endorsed* mechanizme alebo v snahe vyriešiť classloaderovské peklo v dobrej viere iným classloaderovským peklom. Alebo či má zmysel pridávať k JRE špecifické veci ako JAXB. 

Sunovská Java sa už raz s bundlovaním popálila (za čias Javy 1.4 pribalili k JRE beta verziu Xalana). A toto vyzerá byť analogický problém.

Ak si chcete stiahnuť nami prebudovaný plugin FluentAPI, ktorý funguje s JAXB 2.1.7 a má upravený názov balíčka, použite [odkaz](Attach:jaxb-fluent-api-2.1.7-patched.jar ).
