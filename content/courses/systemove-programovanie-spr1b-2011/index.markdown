---
title: Systémové programovanie (UINF/SPR1b) 2011
date: 2011-02-15T19:59:44+01:00
---
# Sumár

Prednáška: utorok, 8.55, P10

Praktické cvičenie: streda, 15:00, P7

# Prednášky
## 15. 2. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr01.pdf) 

Procesy, fork/exec, ps, kill. Zombie procesy, wait()

## 22. 2. 2011
Bash skripting. Základné princípy, programové štruktúry. Premenné. Expanzia premenných. Spúšťanie procesov.

## 1. 3. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr03.pdf) 

Procesy, fork/exec, ps, kill. Zombie procesy, wait()

## 8. 3. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr04.pdf) 

Atribúty vlákna. Kritické sekcie. Race conditions. Mutexy ako metóda prístupu k zdieľaným dátam. Druhy mutexov v UNIXe. Semafory ako metóda konkurentného prístupu k zdieľaným prostriedkom.

## 15. 3. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr05.pdf) 

Úvod do programovania v GTK. Widgety, signály widgetov. Layout pomocou boxov a tabuliek.

## 22. 3. 2011


## 29. 3. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr07.pdf) 

Vývoj rozhraní v GTK pomocou nástroja Glade. Definícia rozhraní v XML, načítanie v kóde, mapovanie signálov.

## 5. 4. 2011
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/spr08-android.pdf) 

Android: životný cyklus aplikácie, spôsoby ukladania stavu: `saveInstanceState`, bundles, `SharedPreferences`, content resolvers.


# Cvičenia
## 16. 2. 2011
Inštalácia [VirtualBoxu](http://www.virtualbox.org/ ). Inštalácia Debianu. Základné príkazy.

## 22. 2. 2011

## 1. 3. 2011

## 9. 3. 2011
Vytvorte triviálny program, ktorý neustále vypisuje dokola "Ahoj". Pozorujte správanie a procesorovú spotrebu pomocou príkazu `top`.

Dodajte použitie systémového volania `sleep()` a opäť pozorujte spotrebu CPU.

Vytvorte program, ktorý emuluje `top`, teda každé tri sekundy vypľuje na obrazovku päť procesov, ktoré najviac spotrebúvavajú procesorový čas. Aplikácia nech reaguje na signál `SIGUSR1`, pri ktorom zapíše štatistiky o príslušných piatich procesoch do súboru `psdump.txt`

Rady: 

* textové konzoly v Debiane môžete prepínať cez Ctrl-Alt-F1 až Ctrl-Alt-F5.
* vytvorte si makefile s implicitným cieľom `run` na vrchu
* ak používate `signal.h`, nezabudnite deklarovať `#DEFINE _POSIX_C_SOURCE`
pretože inak neuvidíte systémové volania.
* nezabudnite, že obsluha signálu musí byť čo najkratšia! Vo funkcii teda neotvárajte súbory, ani nespúšťajte iné procesy. Použite na to atomický integer v úlohe príznaku.

## 6. 4. 2011
Vytvorte aplikáciu „Debilníček". Definujte udalosť, u ktorej evidujte názov a deadline. Zobrazte udalosti v rámci jednej aktivity a vytvorte druhú aktivitu, ktorou môžete pridať novú udalosť do debilníčka.
Udalosti ukladajte do SQLite databázy.

[ukážkový kód](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/debilnicek-2011-04-06.zip)

# Zdroje
* [Advanced Linux Programming](http://www.advancedlinuxprogramming.com/alp-folder)

# Zadanie
Majme daný súbor http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/rozvrh.xml obsahujúci dáta o rozvrhu hodín. Vytvorte aplikáciu pre platformu Android spĺňajúce nasledovné kritériá:

* hodnotenie E:
    * aplikácia zobrazí rozvrh hodín prehľadným spôsobom. Využiť môžete komponent [ListView](http://developer.android.com/resources/tutorials/views/hello-listview.html).
    * aplikácia na začiatku životného cyklu stiahne dáta zo zadanej URL adresy. Ďalšia aktualizácia dát nech je realizovaná manuálne, z [menu](http://developer.android.com/reference/android/view/Menu.html) pomocou položky §§Aktualizovať dáta§§.
    * aplikácia nech obsahuje možnosť filtrovať položky v rozvrhu len na jeden deň (napr. na pondelok). 
* hodnotenie D
    * aplikácia obsahuje vhodný objektový model pre jednotlivé elementy XML súboru tak, aby v prípade potreby ju bolo možné zmigrovať na iný vstupný formát dát (napr. JSON)
* hodnotenie C
    * aplikácia je schopná automaticky periodicky aktualizovať rozvrh v pevne zvolenom intervale. Inšpirujte sa článkom [Updating the UI from the timer](http://developer.android.com/resources/articles/timed-ui-updates.html)
* hodnotenie B
    * aplikácia automaticky zobrazuje len aktivity pre aktuálny deň, ktorý sa zistí automaticky zo systémového času.
    * výber iného konkrétneho dňa, pre ktorý sa zobrazí rozvrh, je realizovaný pomocou [AlertDialog](http://developer.android.com/guide/topics/ui/dialogs.html#AlertDialog)u.
* hodnotenie A
    * aplikácia umožňuje pridávať vlastné rozvrhové aktivity (napr. semináre), ktoré sú uložené v relačnej databáze. Zobrazovanie vlastných aktivít je automaticky integrované s aktivitami zo súboru XML.

Pomôcť vám môže [kostra projektu vytvorená na cvičení](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/leto/android-xml.zip).

Riešenie je potrebné zaslať mailom do 5. 5. 2011. Projekt nie je potrebné obhájiť osobne, ale vyvarujte sa plagiátorstva. Vzájomná konzultácia projektov je v poriadku, identické zdrojové kódy budú trestané dodatočnými úlohami.

# Zdroje k Androidu
* http://www.minmax.cz/blog/google-android-tutorial
* http://www.abclinuxu.cz/serialy/vyvijime-pro-android
* Hello Android, 3e (Pragmatic, 2010)
* Professional Android 2 Application Development (Wrox, 2010)
* The Busy Coders Guide to Android Development (Commonsware, 2009)
