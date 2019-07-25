---
title: HSQLDB - embedded databáza
date: 2007-09-04T09:15:49+01:00
---
# Úvod
*hsqldb* je ľahká 100% Java databáza, ktorú môžete bez problémov zahrnúť, či *embeddnúť* do svojho projektu.
Vlastnosti:

* malá veľkosť – základný JAR má 700kB
* podpora značnej časti SQL štandardu
    * primárne a cudzie kľúče
    * joiny 
    * vnorené SELECTy

V prípade jednoduchých Java projektov je jej použitie jednoduchšie ako inštalácia a konfigurácia najčastejšie používanej databázy MySQL. Nevyžaduje sa totiž žiadna inštalácia ani konfigurácia schém alebo užívateľských práv.
...

# Inštalácia a spustenie
ZIP súbor si možno stiahnuť zo [SourceForge.net](http://sourceforge.net/project/showfiles.php?group_id=23316 ). Najdôležitejším súborom je `hsqldb.jar` z podadresára `lib`, ktorý si môžeme skopírovať do projektu. 

HSQLDB podporuje viacero režimov behu:

* databáza embeddnutá priamo v programe – výhodou je rýchlejšia komunikácia s programom, nevýhodou je nemožnosť sa pripojiť na ňu zvonku (napr. na sledovanie zmien SQL nástrojmi)
* databáza bežiaca ako server
* databáza bežiaca ako HTTP server
* databáza bežiaca ako servlet v servletovom kontajneri.

Venujme sa druhej možnosti.
Predpokladajme, že `hsqldb.jar` sa nachádza v adresári `lib` nášho projektu a že v analogickom podadresári `db` sa budú nachádzať súbory databázy.

Príkaz na spustenie potom bude
```
java -cp lib/hsqldb.jar org.hsqldb.Server -database.0 db/databaza -dbname.0 databaza
```
Parameter `-database.0` špecifikuje konfiguráciu prvej (= nultej) databázy nachádzajúcej sa v `db/databaza`. Meno databázy (ktoré sa prejaví v URL adrese na pripojenie) je špecifikované parametrom `-dbname.0`, v tomto prípade je ním `databaza`.

Po spustení sa naštartuje databáza v konzole:
```
[Server@1d99a4d]: [Thread[main,5,main]]: checkRunning(false) entered
[Server@1d99a4d]: [Thread[main,5,main]]: checkRunning(false) exited
[Server@1d99a4d]: Startup sequence initiated from main() method
[Server@1d99a4d]: Loaded properties from [c:\Projects\hsqldb-samples\server
.properties]
[Server@1d99a4d]: Initiating startup sequence...
[Server@1d99a4d]: Server socket opened successfully in 16 ms.
[Server@1d99a4d]: Database [index=0, id=0, db=file:db/databaza, alias=databaza] opened sucessfully in 328 ms.
[Server@1d99a4d]: Startup sequence completed in 344 ms.
[Server@1d99a4d]: 2007-09-04 08:33:35.937 HSQLDB server 1.8.0 is online
[Server@1d99a4d]: To close normally, connect and execute SHUTDOWN SQL
[Server@1d99a4d]: From command line, use [Ctrl]+[C] to abort abruptly
```
# Pripojenie sa k databáze
Pripojenie k databáze sa riadi klasickým postupom JDBC.

* názov JDBC ovládača je `org.hsqldb.jdbcDriver` (nachádza sa v `hsqldb.jar`.
* parametre pripojenia k databáze bežiacej ako server sú:
    * **URL** – `jdbc:hsqldb:hsql://localhost/databaza`
    * **login** – `sa`
    * **heslo** – prázdne (prázdny reťazec)

# Odpojenie sa od databázy.
Databáza v konzole beží do chvíle, kým nie je „odstrelená". To však nie je práve ideálny spôsob. Slušné odpojenie prebieha vykonaním SQL príkazu `SHUTDOWN` v ľubovoľnom z pripojení v programe.

# Bežiaca databáza
Bežiaca databáza vytvorí v adresári, ktorý bol špecifikovaný pri štarte, štyri súbory. 
## `.script`
Významným je súbor `databaza.script`, do ktorého sa zapisujú všetky dopyty, ktoré viedli k počiatočnému stavu databázy pred spustením. Tento súbor je tvorený čistým textom, ktorý je možné v prípade zastavenej databázy ľubovoľne upravovať.
## `.log`
Súbor `databaza.log` obsahuje všetky aktualizačné dopyty, ktoré sa vykonali od spustenia databázy. V prípade násilného ukončenia databázy slúži na obnovu dát. Rovnako ako `.script` je tvorený čistým textom.

# Spravovanie databázy
HSQLDB poskytuje aj jednoduchého grafického klienta na spravovanie databázy (prezeranie tabuliek, odosielanie dopytov). Spustiť ho možno pomocou
```
java -cp lib/hsqldb.jar org.hsqldb.util.DatabaseManagerSwing
```

# Rozdiely v SQL syntaxi
V porovnaní s MySQL podporuje HSQLDB v podstate identickú funkcionalitu s istými syntaktickými rozdielmi.
## INSERT INTO
Príkaz `INSERT INTO` nepodporuje vloženie viacerých riadkov naraz. Každý riadok je potrebné vložiť pomocou samostatného príkazu
## Automatická inkrementácia primárneho kľúča
Autoinkrementačné stĺpce sú riešené pomocou dátového typu `IDENTITY`.
```
CREATE TABLE student(
  ID IDENTITY, 
  MENO VARCHAR(255) NOT NULL, 
...)
```
`IDENTITY` stĺpec je automaticky primárnym kľúčom. Vloženie `NULL` hodnoty do tohto stĺpca znamená pridelenie automatickej hodnoty v primárnom kľúči danému riadku.

# HSQLDB a Spring
HSQLDB dáva k dispozícii implementáciu rozhrania `javax.sql.DataSource`, čiže je ju možné priamočiaro nadeklarovať v popisovači aplikačného kontextu Springu:
```xml
<bean id="dataSource" class="org.hsqldb.jdbc.jdbcDataSource">
  <property name="user" value="sa" />
  <property name="password" value="" />
  <property name="database" value="jdbc:hsqldb:hsql://localhost/databaza" />
</bean>
```
V prípade, že používame embedded databázu priamo v rámci daného procesu, je možné využiť [bean z projektu Spring Modules](https://springmodules.dev.java.net/source/browse/springmodules/sandbox/src/org/springmodules/db/hsqldb/ServerBean.java?rev=1.1&view=markup ), ktorý zabezpečí korektný štart a ukončenie databázy pri štarte a skončení kontajnera Springu.
