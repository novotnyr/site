---
title: CLASSPATH - nočná mora? 
date: 2007-09-04T08:20:57+01:00
---
# Úvod
Asi každý pisateľ kódu v Jave sa stretol s výnimkou `ClassNotFoundException`, ktorá indikuje chybový stav, keď Java Virtual Machine nebola schopná nájsť binárny kód pre danú triedu (teda súbor `.class`). Táto výnimka je veľmi „obľúbená" hlavne v prípade, keď nie je k dispozícii žiadne integrované vývojové prostredie (IDE) a sme obmedzení len na prácu s príkazovým riadkom.

Vyhľadávanie `.class` súborov môže spôsobiť veľký hlavybôľ, ale pri prečítaní [správnej dokumentácie](http://java.sun.com/j2se/1.3/docs/tooldocs/findingclasses.html ) sa ukáže, že sa riadi pevne danými pravidlami. Problémom je ale niekoľko faktorov – predovšetkým adresárová štruktúra, štruktúra balíčkov, premenná CLASSPATH a parameter `-cp` pre `java.exe`, ktoré treba vhodne zladiť.

# Príklady
Vo všetkých príkladoch budeme predpokladať, že máme pevný adresár pre „projekt", povedzme `C:\Projects\javacp`, v ktorom budeme uchovávať zdrojové kódy.

## Jednoduchá trieda, žiadne balíčky
Predpokladajme, že máme jednoduchú triedu `HelloWorld`, ktorá sa nenachádza v žiadnom balíčku.
```java
public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello World!");
  }
}
```
Trieda `HelloWorld` sa podľa konvencií musí nachádzať v súbore `HelloWorld.java` a keďže neprislúcha žiadnemu balíčku, bude uložený priamo v projektovom adresári – teda v `C:\Projects\javacp\HelloWorld.java`.

Súbor môžeme jednoducho skompilovať
```
javac HelloWorld.java
```
čím vznikne `C:\Projects\javacp\HelloWorld.class`. Tento súbor spustíme zavolaním `java.exe`, teda
```
java HelloWorld
```
Program by mal podľa očakávaní vypísať 
```
Hello World!
```
Z nejakého dôvodu sa však môže stať, že zažijeme typickú výnimku:
```
Exception in thread "main" java.lang.NoClassDefFoundError: HelloWorld
```
Zákernosťou môže byť to, že na našom počítači program môže ísť, ale v analogickom adresári na počítači suseda získame výnimku. Základným riešením ťažkého kalibru pre tento príklad je použitie „tajného parametra"
```
java -cp . HelloWorld
```
Ten prikáže virtuálnemu stroju, aby triedy pre program vyhľadával len a výhradne v aktuálnom adresári (teda v `C:\Projects\javacp`.)

## Jednoduchá trieda v balíčku
Presťahujme teraz triedu `HelloWorld` do balíčka `sk.java`. To vyžaduje dva kroky:

* dodanie riadku `package sk.java` do úvodu zdrojovej triedy

```java
package sk.java;

public class HelloWorld {
  public static void main(String[] args) {
    System.out.println("Hello World!");
  }
}
```

* založenie dodatočných adresárov zodpovedajúcich hierarchii balíčkov. Každému balíčku musí prislúchať jeden adresár v súborovom systéme. Vytvorme teda adresárovú štruktúru `C:\Projects\javacp\sk\java`.

```shell
c:\projects\javacp>md sk\java
```

Pre istotu vymažme starý skompilovaný súbor (aby sme predišli zmäteniu):
```
rm HelloWorld.class
```
a presuňme do balíčka zdrojový súbor:
```
C:\projects\javacp>move HelloWorld.java C:\projects\javacp\sk\java\HelloWorld.java
```
Presuňme sa teraz na spodok hierarchie
```
C:\projects\javacp>cd C:\projects\javacp\sk\java
```
a spusťme kompilátor
```
javac HelloWorld.java
```
Po skompilovaní skúsme spustiť program `HelloWorld` tak, ako v predošlom prípade
```
java -cp . HelloWorld
```
Žiaľ, teraz sa skoro určite dožijeme výnimky:
```
C:\projects\javacp\sk\java>java -cp . HelloWorld
Exception in thread "main" java.lang.NoClassDefFoundError: HelloWorld (wrong name: sk/java/HelloWorld)
  at java.lang.ClassLoader.defineClass1(Native Method)
```
V tomto prípade `java` oznamuje, že sa snažíme spustiť `HelloWorld` s nesprávnou špecifikáciou balíčka. Triedy, ktoré sa nachádzajú v balíčku sa musia volať úplným menom a navyše zo správneho adresára.

`HelloWorld` teda spustíme z adresára `C:\Projects\javacp` príkazom
```
C:\Projects\javacp>java -cp . sk.java.HelloWorld
```
Pri spustení sa začne vyhľadávať trieda počnúc aktuálnym adresárom. Keďže sa nachádza v balíčkoch, prejde sa adresárová štruktúra a trieda sa hľadá v súbore `sk/java/HelloWorld`.

# Premenná prostredia `CLASSPATH`
Premenná prostredia `CLASSPATH` umožňuje nahradiť neustále zapisovanie parametra `-cp`. Ak nastavíme `CLASSPATH` na `.`, môžeme parameter `-cp` vynechať.
`CLASSPATH` nastavíme dočasne pomocou
```
SET CLASSPATH=.
```
Zjednodušené spúšťanie je potom cez 
```
java sk.java.HelloWorld
```
Dosť často sa však stáva, že premenná `CLASSPATH` je už definovaná a nachádzajú sa v nej už nejaké adresáre, prípadne JAR súbory. Vypísať `CLASSPATH` môžeme jednoducho
```
SET CLASSPATH
```
Dodať ďalšie položky do existujúceho `CLASSPATH` môžeme pomocou
```
SET CLASSPATH=%CLASSPATH%;.;
```
## Problém `CLASSPATH` a `-cp`
Značná väčšina problémov spočíva v nepochopení spolupráce `CLASSPATH` a parametra `-cp`.

### Pravidlá pre vyhľadávanie tried

1.  Ak nie je definovaný ani `CLASSPATH`, ani parameter `-cp`, trieda sa hľadá v aktuálnom adresári, prípadne v adresároch pod aktuálnym adresárom v prípade tried v balíčkoch
1.  Ak je definovaný `CLASSPATH`, predošlé pravidlo sa ignoruje. Triedy sa hľadajú v adresároch/JARoch špecifikovaných v tejto systémovej premennej.
1.  Ak je špecifikovaný parameter `-cp`, predošlé pravidlá sa ignorujú (premenná `CLASSPATH` sa teda ignoruje). Triedy sa hľadajú v adresároch/JARoch špecifikovaných v tomto parametri.

Špeciálne treba upozorniť na nasledovné chovanie:

* ak nie je definovaný `CLASSPATH`, ani `-cp`, triedy sa hľadajú v aktuálnom adresári
* ak je definovaný buď `CLASSPATH` alebo `-cp` a chceme, aby sa triedy hľadali v aktuálnom adresári, musíme tento adresár v `CLASSPATH`/`-cp` explicitne uviesť (pomocou bodky).

# Ďalšie príklady
## JAR súbory
Na JAR súbory sa možno pozerať ako na celú adresárovú/balíčkovú štruktúru zbalenú v jednom súbore s daným menom. JAR súbor možno pridať do `CLASSPATH`/`-cp` podobne ako akýkoľvek iný adresár.

Ak napr. máme JAR súbor `C:\projects\javacp\log4j.jar` a potrebujeme z neho využívať triedu `org.apache.log4j.Logger`, pridáme ho do `CLASSPATH` cez
```
SET CLASSPATH=%CLASSPATH%;C:\projects\javacp\log4j.jar
```
a prípadne do `-cp` cez
```
java -cp C:\projects\javacp\log4j.jar nazovABalicekTriedy
```

Ak by náš `HelloWorld` využíval knižnicu log4j a chceli by sme ho spustiť, príkaz by vyzeral:
```
C:\projects\javacp>java -cp .;log4j.jar sk.java.HelloWorld
```
Všimnite si, že aktuálny adresár je uvedený explicitne, z neho sa bude odvíjať vyhľadávanie triedy `HelloWorld`. JAR súbor `log4j.jar` sa bude tiež vyhľadávať v aktuálnom adresári.

# Spustiteľné JAR súbory
JAR súbory je možné pripraviť na "priame" spustenie. Takéto priamo spustiteľné súbory je možné naštartovať cez
```
java -jar názovSúboru.jar
```
V tom prípade sa ignorujú všetky body v pravidlách pre vyhľadávanie tried a všetky triedy sa vyhľadávajú len v danom JAR súbore.

# Príklad zo života
Majme triedu `sk.java.MatrixSolver`, ktorá využíva JAR súbor `commons-math-1.1.jar`. Adresárová štruktúra vyzerá:
```
|--bin
|--|--sk
|--|--|--java
|--|--|--|--MatrixSolver.class
|--src
|--|--sk
|--|--|--java
|--|--|--|--MatrixSolver.java
|--commons-logging.jar (JAR pre výpočet matíc)
|--javacp.jar (triedy projektu zabalené do spustiteľného JARu)
```
Program môžeme spustiť napr.
```
java -cp bin;commons-math-1.1.jar sk.java.MatrixSolver
```

V `javacp.jar` sa nachádza automaticky spustiteľná verzia programu. Lenže tá je závislá na `commons-math-1.1.jar`. Bez závislostí by sme ju spustili klasicky cez `-jar` parameter:
```
java -jar javacp.jar
```
Ale ako bolo povedané vyššie, `-jar` parameter ignoruje všetky predošlé body vyhľadávania a teda aj `commons-math-1.1.jar`. Nepomôže ani explicitné určenie:
```
c:\Projects\javacp>java -cp commons-math-1.1.jar -jar javacp.jar
Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/commons/math/linear/RealMatrix
```
V tomto prípade je možné vyriešiť problém pridaním oboch JARov do `CLASSPATH` a spustením hlavnej triedy:
```
c:\Projects\javacp>java -cp commons-math-1.1.jar;javacp.jar sk.java.MatrixSolver
```

# Sumár a morálne ponaučenie
* pokiaľ nepoužívate JARy a dodržiavate adresárovú štruktúru, použite parameter `-cp` a v ňom uveďte všetky adresáre/JAR súbory, ktoré používate a nezabudnite na aktuálny adresár (bodku).
* ak je to možné, uveďte do `CLASSPATH` položku pre aktuálny adresár, pomôže to v prípade jednoduchých projektov
* pri spúšťaní triedy musíte uviesť jej úplné meno a spúšťať ju treba z adresára, ktorý sa nachádza nad adresárovou štruktúrou, ktorá zodpovedá balíčkom. Spustenie triedy, ktorá je v balíčku z adresára, v ktorom sa nachádza `.class` súbor vo väčšine prípadov nepomôže.
* platí pravidlo:
    * `CLASSPATH` ignoruje aktuálny adresár, pokiaľ ho nemá špecifikovaný explicitne
    * `-cp` ignoruje `CLASSPATH` a aktuálny adresár, pokiaľ ho nemá špecifikovaný explicitne
    * parameter `-jar` ignoruje predošlé pravidl

# Referencie
* [Referenčná príručka o algoritme vyhľadávania tried v JDK](http://java.sun.com/j2se/1.3/docs/tooldocs/findingclasses.html ) (Sun)
* [JAR file revealed](http://www.ibm.com/developerworks/library/j-jar/ ) - popis niektorých často opomínaných vlastností JAR súborov


