---
title: Dobré ráno s jazykom Java 
date: 2006-09-20T00:00:00+01:00
course: UINF/PAZ1c
year: 2006/2007
---

## O projekte

Majú o vás záujem IT firmy? Zmeškali ste jarné popoludnie s jazykom Java? V rámci predmetu UINF/PAZ1c (2+2) môžete získať (bez nároku na kredity ;-)) teoretické i praktické skúsenosti s jedným z najhorúcejších programovacích jazykov súčasnosti. 

Stretnutia budú prebiehať každý týždeň v dvoch podobách: 90 minút (štvrtok o 9.00 v posluchárni P12) budé koncipovaných ako prednáška. Ďalších 90 minút bude venovaných praktickým skúsenostiam v počítačovom laboratóriu (časy sa upresnia).

Na rozdiel od [Popoludní s jazykom Java](Java.PopoludnieSJazykomJava ) budú tieto stretnutia zamerané viac na idey a princípy objektovo orientovaného programovania a ich aplikovanie v programovacom jazyku Java.

## Oznamy
* Nezabudnite si čo najskôr vybrať/dohodnúť projekt!

## Otázky?
Príde Bruce Eckel? Bude sa podávať káva? Dostanem zadarmo zápočet?
E-mail: http://ics.upjs.sk/~novotnyr/img/email.gif

## Konvencia o zasielaní domácich úloh
Domáce úlohy je potrebné zasielať skomprimované v archíve ZIP, RAR, alebo TAR.GZ. Archív musí mať názov typu `novotny3.zip`, kde namiesto `novotny` uveďte vlastné priezvisko a namiesto 3 poradové číslo semestra.

## Návrhy na projekty
Predbežný návrh projektov. Podmienky sa môžu a budú meniť! Ak niečo nie je jasné, konzultujte. Ak je niečo príliš náročné/ľahké, tiež konzultujte.

Vypracovaním projektu by ste mali preukázať znalosti základných princípov a myšlienok OOP a schopnosť vytvárať programy a nástroje v programovacom jazyku Java. Na projekte môžu spolupracovať maximálne dvaja riešitelia. Každý riešiteľ je však povinný preukázať schopnosť porozumieť svojmu vlastnému projektu a byť schopný v ňom na požiadanie vykonať drobné zmeny. (V preklade: výhovorky ako „ja neviem, čo to robí, lebo to programoval ten druhý" neplatia). 

Užívateľské rozhranie je typicky realizované cez konzolu (keďže grafickému rozhraniu sme sa nevenovali). Samostatné naštudovanie tvorby grafického rozhrania môže byť ohodnotené dodatočnými bodmi.

Každý projekt by mal obsahovať minimálne 5 tried (testovacie triedy sa nezapočítavajú) a aspoň jeden príklad na použitie dedičnosti.

### Zoznam projektov
* Bankomat je referenčným projektom. Na základe tohto projektu môže byť odvodených viacero analogických projektov (obchod, kvetinárstvo, pohrebný ústav...). %red% Bankomat je už zadaný.
* Evidencia diplomových prác.
* Grafové algoritmy. Trieda pre graf a rôzne typy grafov (ohodnotený graf, orientovaný graf...). Načítavanie grafových štruktúr zo súboru. Objektovo orientovaná implementácia grafových algoritmy pre hľadanie najkratšej cesty.
* Primitívny textový editor pre konzolu. Textový editor, ktorý pracuje na princípe príkazov v duchu editora vi. 
* [Jukebox](http://ics.upjs.sk/~novotnyr/home/programovanie/java/jukebox/jukebox.zip ) je zverejnený ako vzorový projekt. (Predbežná verzia)

### Zadané projekty
* Exportér databázy. Export dátovej štruktúry a dát v podobe SQL skriptu z databázy MySQL. (Pruzinsky, Skvarkovsky)
* Kalkulačka pre matfyzákov (vymyslel M. Varchula). Podpora štandardných operácií, plus netypických úkonov (matice, determinanty). (Varchula, Vozarikova)
* Bankomat. Informačný systém, ktorý reprezentuje bankomat. Bankomat má dve časti: klientskú a administrátorskú. Klientská časť bankomatu umožňuje operácie, ktoré je možné vidieť v typickom bankomate slovenskej banky. Administrátorská časť umožňuje „vkladať" do bankomatu peniaze, sledovať operácie a pod. (Kal, Nagy)
* Viacužívateľský diár. Evidencia dôležitých termínov pre používateľa. Možnosť prihlásenia viacerých používateľov s nezávislou evidenciou pripomienok. Upozornenie na nadchádzajúce termíny po prihlásení. (Frývaldsky, Kopčák)
* Výherný hrací automat. (Horváth, Demčišáková)
* Knižnica (Diheneščíková, Fedorová)
* Spracovanie konfiguračných súborov. Trieda umožňujúca načítavanie konfiguračných súborov vo formáte Windows initialization files a vo formáte XML. (vyžaduje naštudovanie úvodu do XML, možné úľavy v ostatných hľadiskách požiadaviek) (Simal, Palusakova)
* Encyklopédia dostupná z príkazového riadku. Inšpiráciou nech je [nástroj Ox](http://www.xml.com/pub/a/2004/01/28/ox.html ). Pridávanie článkov, podpora wikipedie, podpora centrálneho servera... (Kováčová, Salaková)
* Požičovňa CD (Lazár)
* Elektronická nástenka. Výveska oznamov s podporou viacerých užívateľov a oprávnení. Odosielanie príspevkov, prezeranie najnovších, reakcia na príspevok. (Drvenica, Cienka)
* Cestovná kancelária (Komjatiová+)

## Realizovaný program
### 21. 9. 2006 
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-1.ppt )) Formality a byrokracie. Historický úvod. Deklarácia a definovanie premenných. Podmienky a cykly (for, while). Polia.
### 22. 9. 2006 
Úlohy, ktoré je potrebné zaslať mailom do 28. 9. 2006, 23.59
1. Vyskúšajte si program Hello World.
1. Dané sú dve polia a = (a'_1_', a'_2_', a'_3_', a'_4_'), b = (b'_1_', b'_2_', b'_3_', b'_4_'). Vypíšte ich súčet po prvkoch, teda prvky poľa c = (a'_1_' + b'_1_', a'_2_' + b'_2_', a'_3_' + b'_3_', a'_4_' + b'_4_').
1. Vypíšte prvky poľa d = (a'_4_' + b'_4_', a'_3_' + b'_3_', a'_2_' + b'_2_', a'_1_' + b'_1_').
1. Daný je reťazec *s*. Vypíšte ho odzadu (použite cyklus).
1. Vypíšte parametre programu, ktoré boli špecifikované pri jeho spustení.

Úlohy, ktoré je potrebné vyskúšať
1. Stiahnite a nainštalujte JDK, nastavte systémové premenné PATH, JAVA_HOME, CLASSPATH
1. Oboznámte sa s dokumentáciou JavaDoc.

### 5. 10. 2006 
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-2.ppt )) Triedy, inštancie, objekty. Inštančné premenné, metódy (s parametrom, návratovými hodnotami). Vytváranie inštancií.

### 22. 9. 2006 [praktické cvičenie]
Úlohy, ktoré je potrebné zaslať mailom do 12. 10. 2006, 23.59

Sada 1:

1. Vytvorte triedu `Clovek` s inštančnými premennými meno, priezvisko a vek. 
1. Vytvorte metódy na získanie priezviska (ako Stringu) a získanie iniciál (ako Stringu, pozor, metóda nemá robiť výpis!).
1. Vytvorte triedu `ClovekTester`, pomocou ktorej budete testovať triedu `Clovek`. V nej vytvorte 5 objektov typu `Clovek`.
1. Vytvorte pole prvkov typu `Clovek` dĺžky 5 a vložte doňho zmienených päť inštancií.
1. Vypočítajte priemerný vek `Clovek`-ov. Výpočet uskutočnite v metóde `main` triedy `ClovekTester`.

Sada 2:

1. Vytvorte triedu `KomplexneCislo` s inštačnými premennými reprezentujúcimi reálnu a imaginárnu zložku
1. Vytvorte metódu na získanie absolútnej hodnoty komplexného čísla. Absolútnu hodnotu komplexného čísla získate ako odmocninu súčtu mocnín jednotlivých zložiek. Odmocninu v Jave reprezentuje metóda `Math.sqrt()` s hlavičkou `double sqrt(double)`. (`double` je nadtyp typu `float`, teda do `double` možno priradiť `float`, nie však naopak.)
1. Vytvorte metódu na pripočítanie komplexného čísla s hlavičkou `void pripocitaj(float re, float im)`
1. Vytvorte metódu na pripočítanie komplexného čísla s hlavičkou `void pripocitaj(KomplexneCislo k)`
1. Vytvorte triedu `KomplexneCisloTester`, pomocou ktorej budete testovat triedu `KomplexneCislo`. V nej vytvorte 4 objekty komplexných čísel.
1. Vytvorte pole prvkov typu `KomplexneCislo` a vložte doň zmienené 4 inštancie.
1. Vypočítajte aritmetický priemer z absolútnych hodnôt komplexných čísiel v zmienenom poli.

Občania, ktorí riešili jednu sadu, môžu vyriešiť druhú sadu za polovičný počet bodov.

### 12. 10. 2006 
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-3.ppt )) Gettery, settery, úplné zapúzdrenie. Referencie a ako funguje halda. 

### 13. 10. 2006 [praktické cvičenie]
1. Simulácia spojového zoznamu. Vytvorte triedu Pes, ktorá reprezentuje psa s menom a odkazom na rodiča (odkaz na rodiča je realizovaný inštančnou premennou `private Pes rodič`. Máme dané pole reťazcov obsahujúce mená psov. Vytvorte toľko inštancií, koľko je prvkov v tomto poli reťazcov tak, aby pes s menom v *i*-tom prvku bol rodičom psa v (*i-1*)-vom prvku. Vypíšte postupnosť predkov prvého psa v poradí na konzolu.
1. Navrhnite dve triedy: `Surovina` a `Guláš`. Surovina reprezentuje prísadu do guláša, ktorá má názov a cenu. `Guláš` obsahuje inštančnú premennú typu pole surovín. 
    1. Naprogramujte metódu `void pridajSurovinu(Surovina surovina)`, ktorou prihodíte do guláša novú surovinu.
    1. Naprogramujte pre `Guláš` metódu `Surovina[] getSuroviny()`, ktorá vráti suroviny vyskytujúce sa v guláši. 
    1. Naprogramujte metódu `int dajCenu()`, ktorá vráti celkový súčet cien surovín v guláši.

### 19. 10. 2006 [teoretické cvičenie]
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-4.ppt )) Balíčky, importy. Dátové štruktúry: polia, zoznamy, množiny, mapy

### 19. 10. 2006 [praktické cvičenie]
Úlohy, ktoré je potrebné zaslať mailom do 26. 10. 2006, 23.59. 

Úlohy z piatku možno vyriešiť za polovičný počet bodov.

1. Práca so súbormi - vstup a výstup. Triedy `java.io.FileReader` (čítanie súboru po znakoch), `java.io.FileWriter` (zápis do súboru po znakoch), `java.io.BufferedReader` (čítanie zo súboru po riadkoch), `java.io.PrintWriter` (zápis do súboru po riadkoch)). 
1. Vytvorte triedu `Sťahovač` s dvoma inštančnými premennými: jedna reprezentuje vstupnú URL (použite triedu `java.net.URL`), druhá cestu k výstupnému súboru. Vytvorte metódu stiahni s hlavičkou `void stiahni() throws Exception`, ktorá stiahne z danej URL textový dokument a uloží ho do textového súboru s názvom. Ku inštančným premenným vygenerujte gettery a settery. Na stiahnutie dokumentu použite InputStream a metódu `openStream()` triedy `URL`.

### 20. 10. 2006 [praktické cvičenie]
Úlohy, ktoré je potrebné zaslať mailom do 26. 10. 2006, 23.59. 

Úlohy zo štvrtka možno vyriešiť za polovičný počet bodov.

Parodujeme databázu.

1. Vytvorte triedu `Študent` reprezentujúcu študenta s identifikačným číslom, menom a priezviskom (nezabudnite na gettery a settery). Vytvorte druhú triedu AkademickýInformačnýSystém, ktorého úlohou bude spravovať študentov. AIS v sebe obsahuje zoznam študentov ako inštančnú premennú. Navrhnite a implementujte metódy pre AIS:

    1. pridanie študenta do informačného systému 
    1. odobratie študenta z informačného systému na základe identifikačného čísla
    1. vyhľadanie študenta podľa identifikačného čísla (v parametri metódy je identifikačné číslo, návratovou hodnotou je študent)
    1. vyhľadanie študenta podľa priezviska (v parametri metódy je reťazec, návratovou hodnotou je zoznam študentov, ktorých priezvisko obsahuje tento reťazec. Použite metódu `String.indexOf`)
    1. získanie dvojíc <identifikačné číslo, priezvisko + meno> (návratovou hodnotou je mapa). 

Pozor, v prezentácii je preklep. Na pridanie prvku slúži v HashMap metóda `put` a nie `add`!

### 26. 10. 2006 [teoretické cvičenie]
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-5.ppt )) Výnimky

### 26. 10. 2006 [praktické cvičenie]
1. Vytvorte triedu Elektromer, ktorý meria kumulatívne nameranú spotrebu v kWh od jeho posledného vymazania. Elektromer nech má tieto metódy
* `void reset()`, ktorá vymaže spotrebu (nastaví ju na nulu)
* `int zistiStav()` fungujúcu nasledovne: vráti aktuálny stav elektromera a hneď na to pripočíta k aktuálnej celkovej spotrebe náhodne 1-8 kWh. Problémom elektromera je, že v štvrtine prípadov namiesto vrátenia aktuálneho stavu len vyhodí výnimku (definujte vlastnú výnimku ZléMeranieException).
  Naimplementujte obe metódy, vytvorte triedu `ElektromerTester` a otestujte obe metódy. V `ElektromerTester`i obaľte potrebné veci do try-catch bloku.
1. V cykle skúste zavolať zo dvadsaťkrát metódu `zistiStav()` a pozorujte, ako vyhadzujú výnimky
1. Vylepšite `ElektromerTester` tak, aby namerané hodnoty zapisoval do textového súboru až do chvíle, kým elektromer nevyhodí výnimku. Dbajte na to, aby sa súbor korektne uzavrel vo `finally` bloku.
1. Vytvorte triedu `Elektraren` s metódou `void meraj(int početElektromerov, int početMeraní)`. Metóda vyrobí `početElektromerov` inštancií elektromerov, na ktorých postupne spustí merania `početMeraní`-krát. (Kolovým spôsobom, kde v každom kole sa vypíše postupne stav každého elektromera). Vypisujte jednotlivé merania pre každý elektromer na štandardný výstup. V prípade, že niektorý elektromer vyhodí chybu, zabezpečte, aby sa vypísala chybová hláška a program pokračoval v zistení stavu nasledovného elektromera.

### 27. 10. 2006 [praktické cvičenie]
1. Vytvorte triedu `Spevak`, ktorý má meno a priezvisko (a gettery a settery). Spevák má jedinú metódu: `void spievaj()`. Spevák je však často indisponovaný a preto sa mu každé druhé spievanie nepodarí. Nepodarenie spievania implementujte pomocou vyhodenia vlastnej výnimky `NemôžemSpievaťException`.
Naimplementujte metódu, vytvorte triedu `SpevakTester` a otestujte ju. V `SpevakTester`i obaľte potrebné veci do try-catch bloku.
1. V cykle skúste zavolať zo dvadsaťkrát metódu `spievaj()` a pozorujte, ako vyhadzujú výnimky
1. Vylepšite `SpevakTester` tak, aby v prípade úspešného spievania vložil do textového súboru reťazec `OK` a v prípade neúspešného spievania reťazec `BUUUU`. Dbajte na to, aby sa súbor korektne uzavrel vo `finally` bloku. (Zrejme budete musieť použiť try-catch blok vnorený v inom try-catch bloku).

### 2. 11. 2006 [teoretické cvičenie]
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-6.ppt )). Metódy `toString()`, `equals()`, `hashCode()`. Preťažené (overloaded) metódy. Konštruktory. Statické metódy.

### 2. 11. 2006 [praktické cvičenie]
1. Vytvorte triedu `Databaza` s metódou dvoma konštruktormi: 
    1. `Databaza(String súbor)` 
    1. `Databaza(File súbor)`

    Konštruktory špecifikujú cestu k súboru, s ktorým sa bude pracovať.
1. Vytvorte metódu `nacitaj()`, ktorá bude vracať zoznam inštancií triedy `Pes`. Zoznam sa vytvorí na základe textového súboru, v ktorom sú po riadkoch postupne uložené mená psov. Metóda načíta zo súboru, ktorého umiestnenie bolo určené v konštruktore, pomocou `BufferedReader`-a skombinovaného s `FileReader`-om. Ošetrite všetky výnimky, ktoré môžu pri práci so súborom nastať - metóda nemá hádzať žiadnu výnimku. Ak v metóde nastane výnimka, vráťte prázdny zoznam (nie `null`!) Nezabudnite ošetriť zatváranie súboru.
1. Oboznámte sa s návrhovým vzorom Jedináčik/Singleton.

### 3. 11. 2006 [praktické cvičenie]
Majme danú triedu `FilterPárnychČísíel`. Tá slúži na načítavanie zoznamu čísiel buď z klávesnice alebo zo súboru a jeho výpis na štandardný výstup. Aby to však nebolo také jednoduché, trieda pri vypisovaní ignoruje párne čísla.

1. Vytvorte dva konštruktory: jeden bez parametrov a jeden s reťazcovým parametrom určujúcim cestu k súboru, z ktorého sa bude načítavať.
1. Vytvorte metódu `nacitaj()`, ktorá bude načítavať zo súboru, resp. zo štandardného vstupu čísla a na štandardný výstup bude vypisovať len nepárne čísla. To, či sa budú údaje načítavať so súboru alebo z konzoly závisí od toho, ktorý konštruktor použil používateľ na vytvorenie inštancie. (Ak používateľ použil konštruktor bez parametrov, budú sa čísla načítavať zo štandardného vstupu. Ak použil konštruktor s parametrom, bude sa načítavať zo zadaného súboru.).

Na načítavanie použite triedu `java.util.Scanner`. Príklad použitia je v dokumentácii JavaDoc. (Nápomoc: použite vhodný cyklus. Metóda `Scanner.hasNextInt()` vracia `true`, ak je zo súboru možné načítať ďalšie celé číslo, metóda `Scanner.nextInt()` ho načíta.)

### 9. 11. 2006 [teoretické cvičenie]
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-7.ppt )). Dedičnosť a polymorfizmus. Preťažovanie metód.

### 9. 11. 2006 [praktické cvičenie]
Načítavanie údajov z klávesnice a súboru pomocou triedy `java.util.Scanner`. Pripojenie k databázam cez JDBC.

### 10. 11. 2006 [praktické cvičenie]
Domácu úlohu je potrebné zaslať do 1. 12. 2006

Majme danú triedu `GeometrickýÚtvar` a z nej odvodené dve podtriedy: `Štvorec` a `Kružnicu`. Každý geometrický útvar si dokáže zrátať svoje ťažisko. V rovine je daných niekoľko geometrických útvarov. Nájdite dva najvzdialenejšie útvary, pričom uvažujte vzdialenosť ich ťažísk.

Súradnice útvarov sú zadané po riadkoch v textovom súbore. Kružnica je zadaná v tvare
```
3.0 2.5 9.0 1
```
(stred má súradnice [3.0, 2.5], polomer kružnice je 9. 1 indikuje, že útvar je kružnica)

Štvorec je zadaný v tvare
```
2.3 1.7 4.0 0
```
(ľavý dolný roh štvorca má súradnice [2.3, 1.7], dĺžka strany štvorca je 4, 0 indikuje, že útvar je štvorec)

Fotografie tabule: [1](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/foto/100_1609.JPG )
[2](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/foto/100_1610.JPG )

### 16. 11. 2006 [teoretické cvičenie]
Rektorské voľno

### 16. 11. 2006 [praktické cvičenie]
Rektorské voľno

### 17. 11. 2006 [praktické cvičenie]
Deň boja za slobodu a demokraciu

### 23. 11. 2006 [teoretické cvičenie]

([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-8.ppt )). Abstraktné triedy. Dedičnosť -  prekrývanie metód (override) a inštančných premenných. Modifikátory viditeľnosti (private, protected).

### 23. 11. 2006 [praktické cvičenie]
Zadanie je identické so zadaním z 10. 11. 2006. Zadanie je nutné poslať do 7. 12. 2006

### 24. 11. 2006 [praktické cvičenie]
Dokončenie úlohy z predošlého cvičenia.

### 30. 11. 2006 [teoretické cvičenie]
Nekonalo sa.

### 30. 11. 2006 [praktické cvičenie]
Nekonalo sa.

### 1. 12. 2006 [praktické cvičenie]

* Prepracujte triedu `GeometrickýÚtvar` tak, aby bola abstraktnou triedou, pričom metóda na nájdenie ťažiska má byť tiež abstraktná
* Prepracujte `GeometrickýÚtvar` tak, aby umožňoval priraďovať geometrickým útvarom ich názvy. Inak povedané, každý útvar môže mať popisný reťazec
* Vytvorte triedu `FarebnýKruh`, ktorá umožňuje pridať kruhom farbu. (Farbu reprezentujte ako reťazec).

### 7. 12. 2006 [teoretické cvičenie]
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-9.ppt )). Pretypovanie smerom nahor a nadol. Dedenie konštruktorov. Interface-y.

### 7. 12. 2006 [praktické cvičenie]

* Vypíšte zoznam regulárnych súborov v danom adresári. Využite metódu `java.io.File#list(FileFilter)`. Zostrojte tri triedy implementujúce rozhranie `java.io.FileFilter` - filter, ktorý akceptuje všetky súbory; filter, ktorý neakceptuje žiadne súbory a filter, ktorý akceptuje len regulárne súbory.
* Vytvorte triedu `Študent` reprezentujúcu študenta s menom. V triede vytvorte jednoparametrový konštruktor umožňujúci uviesť pri vytváraní inštancie meno študenta. 
* Zabezpečte, aby trieda `Študent` implementovala rozhranie `Comparable` takto: študent je menší ako iný študent, ak jeho meno je v lexikografickom usporiadaní menšie ako meno iného študenta (použite metódu `String#compareTo()`).
* Zotrieďte zoznam študentov pomocou `Collections.sort()`
* Prepracujte triedu `Študent` tak, že odstráňte implementovanie rozhrania `Comparable`. Dodajte inštančné premenné pre priezvisko a študijný priemer. Zostrojte tri triedy implementujúce rozhranie `Comparator`, ktoré budú umožňovať porovnanie dvoch študentov postupne podľa mena (`StudentNameComparator`), priezviska (`StudentSurnameComparator`) a priemeru (`StudentAverageComparator`). Zotrieďte zoznam študentov pomocou dvojparametrovej metódy `Collections.sort()`

### 8. 12. 2006 [praktické cvičenie]

* Vytvorte triedu `Študent` reprezentujúcu študenta s menom, priezviskom a študijným priemerom. V triede vytvorte vhodný počet konštruktorov uľahčujúcich vytváranie inštancií.
* Dodajte inštančné premenné pre priezvisko a študijný priemer. Zostrojte dve triedy implementujúce rozhranie `Comparator`, ktoré budú umožňovať porovnanie dvoch študentov postupne podľa priezviska (`StudentSurnameComparator`) a priemeru (`StudentAverageComparator`). Zotrieďte zoznam študentov pomocou dvojparametrovej metódy `Collections.sort()`

----

## Rozširujúce a doplňujúce štúdium

[Hodnotenie](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/hodnotenie-rsi.xls )

### 23. 9. 2006 
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-1.ppt )) Formality a byrokracie. Historický úvod. Deklarácia a definovanie premenných. Podmienky a cykly (for, while). Polia.

Úlohy, ktoré je potrebné zaslať mailom do 6. 10. 2006, 23.59

1. Daný je reťazec *s*. Vypíšte ho odzadu (použite cyklus).
1. Dané sú dve polia a = (a'_1_', a'_2_', a'_3_', a'_4_'), b = (b'_1_', b'_2_', b'_3_', b'_4_'). Nadeklarujte pole c, ktorého prvky sú tvorené súčtom prvkov z polí *a*, *b*, teda prvky poľa c = (a'_1_' + b'_1_', a'_2_' + b'_2_', a'_3_' + b'_3_', a'_4_' + b'_4_').
1. Nadeklarujte nové pole e, ktorého prvky sú tvorené nepárnymi prvkami z poľa *a* a párnymi prvkami poľa *b*, teda e = (a'_1_', b'_2_', a'_3_', b'_4_'). Použite cyklus.

### 14. 10. 2006 
([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/paz1c-2.ppt )) Triedy, inštancie, objekty. Inštančné premenné, metódy (s parametrom, návratovými hodnotami). Vytváranie inštancií.

1. Vytvorte triedu `Clovek` s inštančnými premennými meno, priezvisko a vek. 
1. Vytvorte metódy na získanie priezviska (ako Stringu) a získanie iniciál (ako Stringu, pozor, metóda nemá robiť výpis!).
1. Vytvorte triedu `ClovekTester`, pomocou ktorej budete testovať triedu `Clovek`. V nej vytvorte 5 objektov typu `Clovek`.
1. Vytvorte pole prvkov typu `Clovek` dĺžky 5 a vložte doňho zmienených päť inštancií.
1. Vypočítajte priemerný vek `Clovek`-ov. Výpočet uskutočnite v metóde `main` triedy `ClovekTester`.

### 21. 10. 2006 
Úlohy je potrebné zaslať do 3. novembra 2006, 23.59

([Prezentácia](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/rsi3.ppt )) Gettery a settery. Polia a zoznamy.

1. Vytvorte triedu Študent reprezentujúcu študenta s identifikačným číslom, menom a priezviskom (nezabudnite na gettery a settery). Vytvorte druhú triedu AkademickýInformačnýSystém, ktorého úlohou bude spravovať študentov. AIS v sebe obsahuje zoznam študentov ako inštančnú premennú. Navrhnite a implementujte metódy pre AIS:
    1. pridanie študenta do informačného systému 
    1. odobratie študenta z informačného systému na základe identifikačného čísla
    1. vyhľadanie študenta podľa identifikačného čísla (v parametri metódy je identifikačné číslo, návratovou hodnotou je objekt typu `Študent`)
    1. vyhľadanie študenta podľa priezviska (v parametri metódy je reťazec, návratovou hodnotou je zoznam študentov, ktorých priezvisko je zhodné s týmto reťazcom.)

### 4. 11. 2006 
Úlohy je potrebné zaslať do 3. decembra 2006, 23.59

Vstupno-výstupné operácie. Zápis textu na konzolu. Načítanie dát z konzoly pomocou triedy `java.util.Scanner`. Načítanie dát z textového súboru. Zápis dát do súboru pomocou kombinácie tried `java.io.PrintWriter` a `java.io.FileWriter`. Výnimky.

1. V textovom súbore je daných *n* celých čísiel po riadkoch. Vyrobte triedu `FilterPárnychČísiel`, ktorá spracuje zadaný textový súbor tak, že z neho vyberie len párne čísla a zapíše ich do iného textového súboru. Trieda by mala mať privátne inštančné premenné `vstupnýSúbor` a `výstupnýSúbor` typu `java.io.File`, gettery a settery na ich nastavenie a metódu `void filtruj()`, ktorá vykoná filtráciu.

### 2. 12. 2006
Majme danú triedu `GeometrickýÚtvar` a z nej odvodené dve podtriedy: `Štvorec` a `Kružnicu`. Každý geometrický útvar si dokáže zrátať svoje ťažisko - má metódu `getŤažisko()`. V rovine, ktorá je reprezentovaná zoznamom, je daných niekoľko geometrických útvarov. Nájdite dva najvzdialenejšie útvary, pričom uvažujte vzdialenosť ich ťažísk. Využite dedičnosť a polymorfizmus.

Súradnice útvarov sú zadané po riadkoch v textovom súbore. Kružnica je zadaná v tvare
```
3.0 2.5 9.0 1
```
(stred má súradnice [3.0, 2.5], polomer kružnice je 9. 1 indikuje, že útvar je kružnica)

Štvorec je zadaný v tvare
```
2.3 1.7 4.0 0
```
(ľavý dolný roh štvorca má súradnice [2.3, 1.7], dĺžka strany štvorca je 4, 0 indikuje, že útvar je štvorec)

Fotografie tabule: [1](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/foto/100_1609.JPG )
[2](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/foto/100_1610.JPG )


## Odkazy
* [Článok o Jave na Wikipedii](http://en.wikipedia.org/wiki/Java_programming_language ). Obsahuje filozofický pokec, prehľad verzií a pod. [english]
* [JDK 1.5.0_6 (Win32)](http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jdk-1.5.0_06-oth-JPR&SiteId=JSC&TransactionId=noreg )
* [Thinking in Java, 3rd Edition](http://mindview.net/Books/TIJ/DownloadSites )
* [Java Sborník](http://dione.zcu.cz/java/sbornik/toc.html ) - rýchly náhľad na elementy jazyka Java
* [Interval.cz: Naučte se Javu](http://interval.cz/clanky/naucte-se-javu-uvod/ ) - seriál k Jave

