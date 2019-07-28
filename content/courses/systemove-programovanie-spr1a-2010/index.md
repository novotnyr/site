---
title: Systémové programovanie 2010
date: 2010-12-14T02:20:34+01:00
course: UINF/SPR1a
year: 2010/2011
---

# Prednášky
## Prvá prednáška
[Powershell](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr01.pdf )

## Druhá prednáška
[Powershell](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr02.pdf )
## Tretia prednáška (5. 10. 2010)
[Powershell](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr03.pdf )

## Štvrtá prednáška (12. 10. 2010)
[Úvod do C#](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr04.pdf )

## Piata prednáška (19. 10. 2010)
[Windows Messages ako spôsob výmeny správ](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr05.pdf )

## Šiesta prednáška (26. 10. 2010)
[Mechanizmy inter-process communication (IPC) vo Windowse](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr06.pdf )

## Siedma prednáška (2. 11. 2010)
* [Vývoj vlastných cmdletov v C#](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr07.pdf )

* [ukážka zdrojového kódu z prednášky](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/DictionarySnapIn.zip )

## Prednáška č. 8 (9. 11. 2010)
[Úvod do jazyka C](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr08.pdf )

## Prednáška č. 9 (16. 11. 2010)
[Alokácia pamäte - statická a dynamická. Reťazce v C.](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr09.pdf )

## Prednáška č. 10 (23. 11. 2010)
[Ekvivalencia pointerov a polí. Operátory & a *. Odovzdávanie parametrov hodnotou a odkazom.](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr10.pdf )

## Prednáška č. 11 (30. 11. 2010)
[Oblasť platnosti premenných, structy, pointery na structy](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr11.pdf )

## Prednáška č. 12 (7. 12. 2010)
[Viacrozmerné polia. Pointre na funkcie.](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr12.pdf )

## Prednáška č. 13 (14. 12. 2010)
[Úvod do GUI programovania pomocou Win32 API.](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/spr13.pdf )

# Cvičenia

## PowerShell
[Rozličné úlohy v PowerShelli a ich riešenia](http://ics.upjs.sk/~novotnyr/home/skola/systemove_programovanie/2010/powershell-cvicenia.pdf )

## Windowsové služby
Vytvorte windowsovskú službu, ktorá každé 3 minúty zapíše správu do systémového event logu.

## IPC cez Windows Message
Vytvorte aplikáciu, ktorá po vložení USB kľúča do počítača z neho nakopíruje všetky súbory do špecifikovaného adresára.

## WinAmp
Vytvorte vlastnú GUI aplikáciu, ktorá dokáže ovládať Winamp:
* tlačidlá Play, Next (prípadne Previous, Next, Pause)
* dokáže získať text aktuálne prehrávanej skladby

## Cvičenie 3. 11. 2010
Vytvorte cmdlet, ktorý stiahne z RSS na sme.sk XML dokument a a pošle do rúry všetky tituly (`<title>`) článkov. Skúste pri tom využiť adresovací jazyk XPath.

## Cvičenie 10. 11. 2010
### Nainštalujte NetBeans, plugin C/C++.

### Nainštalujte CygWin s požadovanými balíčkami:

* gcc
* gcc-g++
* make
* gdb

### Vypíšte na konzolu „Ahoj svet.“ 

Použite na to funkciu printf(), resp. puts().

### Vypíšte pomocou `printf()` číslo.

Pozorujte Segmentation Fault.

### Načítajte z konzoly dve čísla a nájdite väčšie z nich a vypíšte ho na konzolu.

Nezabudnime, že `scanf()` berie adresu a pripomeňme si význam ampersandu.

### Z poľa piatich čísiel (zadaného v kóde) nájdite jeho maximum. 

Zatiaľ netreba použiť funkciu.

### Načítajte z konzoly 5 čísiel a nájdite ich maximum.

Použime jeden `scanf()` s piatimi premennými (+ formátovací reťazec). 

Alternatívne možno použiť cyklus.

### Načítajte z príkazového riadku 5 čísiel a nájdite ich maximum.

Použime premenné `argv` a `argc`. Uvedomme si, že polia v C nemajú hornú a dolnú hranicu a na rozdiel od Javy nevieme z premennej typu pole priamo zistiť počet prvkov. Vysvetlime si premennú `argc`.

### Načítajte zo súboru 5 čísiel a nájdite ich maximum.

Objasnime si premennú `FILE *`, a funkciu `fopen()`. Pripomeňme, že treba testovať návratovú hodnotu `fopen()`, pretože v opačnom prípade máme zarobené na problém so `Segmentation Fault`. (Problém sa dá demonštrovať na otvorení neexistujúceho súboru.).

Ďalej demonštrujme potrebu zatvárať súbor cez `fclose()`.

Objasnime funkciu `fscanf(`).

### Vytvorte funkciu, ktorá zráta maximum v poli čísiel.

Opäť pripomeňme, že polia nemajú hornú hranicu a teda je potrebné vytvoriť dvojparametrovú funkciu (druhý parameter je počet prvkov v poli).

### Vytvorte program, ktorý dostane z príkazového riadku cestu k súboru, načíta z neho 5 čísiel a vráti ich súčet.

## Cvičenie 17. 11. 2010
Štátny sviatok.

## Cvičenie 24. 11. 2010
Majme subor `cisla.txt`
```
13 17 -5 6 2
6 -1 2 3 4
5 4 2 -1 2
```

### Nájdime maximálne číslo v súbore a vypíšme ho.

#### Vypisme subor bez zmeny na konzolu. 

Pouzime `fgetc()`. Pozor na to, ze tato funkcia vracia `int` a nie `char`!
### Vypisme pocet znakov v subore

### Vypisme pocet nemedzerovych znakov. (Staci test na `' ‘`.)

### Vypisme ocislovane riadky suboru 

Vysvetlime si, ze neexistuje funkcia „nacitaj cely riadok", lebo musime poznat dlzku. Taku funkciu vsak ani netreba.
### Urobme funkciu pre stlpcove sucty. Predstavme si, ze vstup je matica a zratajme sucty v jednotlivych stlpcoch.

### Napiste funkciu, co vracia z daneho pola len parne cisla. 

Treba povedat, ze funkcia nemoze vracat `int[]`, ale len `int *`. 

Treba povedat, ako zabezpecit to, ze v navratovej hodnote bude zaroven aj dlzka pola: my sme to spravili tak, ze funkcia vrati pole, kde v nultom prvku je jeho dlzka. Pozor na chyby „plus minus jedna!"

## Cvičenie 1. 12. 2010.
Urobte prekladovy slovnik. V subore mame data v tvare:
```
hello=ahoj
world=svet
```

Nacitajte data do structu a vyrobte funkcie pre najdenie prekladu vety z `argv`.

### Fáza I – statická alokácia

Vo faze I pouzite len staticku alokaciu, dlzka kluca a prekladu nech je maximalne 30 znakov. Rovnako predpokladajte, ze slovnik ma obmedzeny maximalny pocet slov (napr. 100).

#### Rady

* na porovnanie stringov pouzime `strcmp()`, porovnanie `==` zname z Javy nefunguje!
* na tokenizaciu pouzite `strtok()` (druhe volanie berie NULL)
* do struktury treba stringy kopirovat cez `strcpy()` (nie cez priame priradenie!)

### Faza II: dynamicky struct
Riadok v subore nech ma obmedzenie na dlzku (napr. 255), ale kluc i preklad mozu mat lubovolnu dlzku. Nezabudnite naalokovat buffre!

* Vytvorte jednoduchu verziu dynamickeho zoznamu pracujuceho nad nafukovacim polom (v duchu java.util.ArrayList). Obmedzte sa na zoznam `int`ov. Definujte funkcie:
    * new
    * add
    * get
    * size

## Cvičenie 8. 12. 2010
Dokončite `ArrayList`. Dopracujte metódy:

* remove()
* push()
* pop()
* to_string()

## Cvičenie 15. 12. 2010
Vytvorte funkciu, ktora nacitala riadok lubovolnej dlzky zo suboru,

Pouzite dynamicky nafukovane pole ako buffer.

Pozor na nasledovne situacie:

* ak nastane koniec suboru pred koncom riadku
* na Windowse je koniec riadku reprezentovany cez `\r` a `\n` (dva znaky)
* pozor na uvolnovanie buffera 
* pozor na semantiku prazdneho riadka na konci suboru: ak sme za poslednym `\n`, ale este pred koncom suboru (= buffer je prazdny) vratime `NULL`

# Záverečné zadania

Zadania je potrebné obhájiť osobne, predbežný termín je 20. 1. 2011.

## Zadanie 1 + 2
Vytvorte skript v PowerShelli, ktorý vytvorí sumárnu informáciu o aktuálnom stroji. V sumárnej informácii uveďte nasledovné informácie.

* Názov aktuálneho stroja
* Veľkosť nainštalovanej pamäte RAM
* MAC adresy sieťových adaptérov
* IP adresu v aktuálne pripojenej sieti
* Počet fyzických diskov
* Všetky logické jednotky a ich veľkosti.
* Zoznam používateľov aktuálneho stroja
* Pre každého používateľa veľkosť jeho domovského adresára a cestu k nemu.

V skripte deklarujte vlastnú triedu `LocalStationInfo` s vhodne zvolenými inštančnými premennými.

Vytvorte cmdlet `GetLocalStationInfo`, ktorý prijme z rúry inštanciu LocalStationInfo a do rúry pošle prehľadne naformátované informácie o aktuálnom stroji. Informácia nech je reprezentovaná v používateľsky prítulnom HTML súbore.

Pripravte powershellovský skript, ktorý vezme ako parameter názov súboru. Po spustení skriptu nech sa do zadaného súboru zapíše uvedená HTML správa o aktuálnom stroji.

## Zadanie 3
Vytvorte jednoduchý informačný systém pre správu hudobných albumov. Každý hudobný album má autora (resp. interpreta), vydavateľa, cenu a zoznam skladieb. Každá skladba má názov a dĺžku. 

Systém má spravovať databázu albumov:

* Vyhľadávať v albumoch a pesničkách podreťazce.
* Pridávať skladbu
* Upravovať informácie o skladbe
* Mazať albumy.

Ovládanie systému nech je pomocou prítulne vyzerajúceho menu v textovom režime spôsobom „vyberte nasledovnú operáciu."
