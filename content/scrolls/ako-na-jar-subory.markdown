---
title: Ako na JAR súbory?
date: 2007-09-16T15:30:40+01:00
---
# Úvod
JAR súbory plnia úlohu kompaktného úložiska `.class` súborov v Jave. Ich výhodou je šetrenie miestom (`.class` súbory sú zväčša malé a zaberali by tak veľa nadbytočného miesta), ľahké prenášanie a manipulácia.

Z technického hľadiska sú JAR súbory ničím iným, než premenovanými ZIP archívmi (áno, naozaj je to tak!). Možno ich teda vytvoriť pomocou ľubovoľného ZIP nástroja.

Vo vývojovom prostredí Javy sa však nachádza nástroj `jar.exe`, ktorý uľahčuje manipuláciu s JAR súbormi.

# Vytvorenie JAR súboru z príkazového riadku
Predpokladajme, že máme nasledovnú hierarchiu adresárov a súborov:
```
|--bin
|--|--sk
|--|--|--java
|--|--|--|--MatrixSolver.class
|--|--|--|--AdvancedMatrixSolver.class
|--|--|--|--SpringBasedMatrixSolver.class
|--OpustenaTriedaMimoHierarchie.class
|--commons-logging.jar (JAR pre výpočet matíc)
```

## Pridanie jediného súboru do archívu
```
jar -cf javacp.jar OpustenaTriedaMimoHierarchie.class
```
Parametre sú prosté:

* `-c` – vytvoriť nový archív 
* `-f` – nový archív bude mať dané meno (`javacp.jar`)
* `-C` – presuň sa do špecifikovaného adresára (`bin`) 
Treba dať pozor na to dodržiavanie balíčkovej štruktúry. Výsledný archív bude obsahovať na najvyššej úrovni jeden súbor a adresár `META-INF` (o ňom nižšie). Archív bude korektný len vtedy, ak `OpustenaTriedaMimoHierarchie` neprislúcha žiadnemu balíčku (teda nemá vo svojom zdrojovom kóde deklaráciu `package`. V opačnom prípade môžu nastať problémy s `ClassNotFoundException`>

## Pridanie adresárovej/balíčkovej štruktúry do JAR súboru
```
jar -cf javacp.jar -C bin .
```
Parametre sú prosté:

* `-c` – vytvoriť nový archív 
* `-f` – nový archív bude mať dané meno (`javacp.jar`)
* `-C` – presuň sa do špecifikovaného adresára (`bin`) a zahrň do spracovania daný súbor (čiže aktuálny adresár `.`)

Treba upozorniť, že jednoduchý príkaz
```
jar -cf javacp.jar bin
```
by nefungoval, pretože na najvyššej úrovni archívu by bol adresár `bin`, čo by nezodpovedalo správnej hierarchii balíčkov (získali by sme mylnú hierarchiu `bin.sk.java`).

# Pridanie `manifest` súboru.
Každý JAR by mal obsahovať `manifest` súbor, čo je popisovač obsahu archívu (nie je to však povinné). Tento súbor, ak existuje, sa musí nachádzať v adresári `META-INF` pod názvom `MANIFEST.MF` (pozor na veľké písmená!)

`jar.exe` pridá do každého JAR súboru štandardný prázdny manifest, ktorý vyzerá napr. takto:
```
Manifest-Version: 1.0
Created-By: 1.5.0_09 (Sun Microsystems Inc.)
```

Niekedy je vhodné špecifikovať vlastný manifest a to napríklad v prípade, že chceme získať automaticky spustiteľný JAR. Vytvorme prázdny súbor `manifest` a dodajme doňho
```
Main-Class: sk.java.MatrixSolver
```
(pre istotu je treba na koniec súboru vložiť prázdny riadok).

JAR súbor vytvoríme pomocou
```
c:\Projects\javacp>jar cfm javacp.jar manifest -C bin .
```
Parameter `m` vraví, že dodávame vlastný súbor manifestu pod názvom `manifest`. `jar.exe` automaticky zahrnie tento súbor do archívu, ktorý v konečnej podobe bude vyzerať nasledovne:
```
Manifest-Version: 1.0
Created-By: 1.5.0_09 (Sun Microsystems Inc.)
Main-Class: sk.java.MatrixSolver
```

Automaticky spustiteľný súbor JAR môžeme spustiť pomocou parametra `-jar` v `java.exe`.
```
C:\Projects\javacp>java -jar javacp.jar
```

# Automaticky spustiteľné JARy so závislosťami
Často sa stáva, že automaticky spustiteľný JAR súbor vyžaduje na svoje fungovanie závislosti, typicky ďalšie JAR súbory. Napr. trieda `sk.java.MatrixSolver` vyžaduje na svoje fungovanie `commons-math-1.1.jar`. Jednoduché spustenie pomocou parametra `-jar` nebude fungovať, pretože [treba vyriešiť problémy s `CLASSPATH`](http://ics.upjs.sk/~novotnyr/wiki/Java/ClasspathAClassNotFoundException )

Zrejme jediný spôsob, ako vytvoriť automaticky spustiteľný JAR súbor so závislosťami, je definícia závislostí v manifeste.

Príkladom je nasledovný manifest:
```
Main-Class: sk.java.MatrixSolver
Class-Path: commons-math-1.1.jar
```
V ňom uvádzame, že JAR súbor závisí na knižnici `commons-math`. Manifest zabalíme do JAR súboru pomocou predošlého postupu a výsledný JAR spustíme:
```
C:\Projects\javacp>java -jar javacp.jar
```
Vo virtuálnom stroji sa spustí trieda `sk.java.MatrixSolver`. Tá závisí na triedach z `commons-math`. Tie sa začnú vyhľadávať v súbore `commons-math-1.1.jar` (na základe manifestu), ktorý sa musí nachádzať v rovnakom adresári, ako `javacp.jar`.

Takýmto spôsobom je možné pripraviť aplikáciu, ktorú možno u klienta spustiť jednoriadkovým príkazom.
