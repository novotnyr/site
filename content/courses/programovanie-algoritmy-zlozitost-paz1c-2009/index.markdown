---
title: Programovanie, algoritmy, zložitosť 2009
year: 2009/2010
date: 2009-09-23T12:56:00+01:00
course: UINF/PAZ1c
---

# Oznamy
* Vo štvrtok je 5. 11. 2009 je prvý test!
* Podmienky na zápočet sú uvedené v prvej prezentácii.
* Každý študent je povinný byť na práve jednom praktickom cvičení a na teoretickom cvičení

# Úvod a podmienky na zápočet
* teoretické cvičenie - streda, 18.05, P11
* cvičenie pri počítačoch
* streda, 10.45, P3
* streda, 12.35, P3
* podmienky na zápočet
* účasť na praktických cvičeniach (30%)
* záverečný projekt (40%) - nutná podmienka
* dva testy: jeden v polovici semestra, druhý na konci (30%)
* jedna možnosť opravy jedného testu

# Teoretické cvičenia
## Cvičenie 1 (23. 9. 2009)
Reprezentácia dát. Stringy nie sú vhodný dátový typ. Ďalšie nápady na reprezentáciu. Triedy ako štruktúrované typy. Filozofia objektov. Inštančné premenné.

[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-1.pdf )

## Cvičenie 2 (30. 9. 2009)
Metódy. Polia vs zoznamy. Primitívne a objektové typy. Autoboxing. Kompozícia tried. Privátne inštančné premenné. Gettre a settre.
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-2.pdf )

## Cvičenie 3 (8. 10. 2009)
*Samostatné čítanie:* preťažené metódy, konštruktory a preťažené konštruktory
Zapúzdrenie. Príklad s rodným číslom. Najprv kontrakt, potomm implementácia. Príklad návrhu kávového automatu a implementácia.

- [Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-3.pdf )
- [Kávomat verzia 1.0](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/automat-1.0-2009-08-08.zip )

- [Kávomat verzia 2.0](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/automat-2.0-2009-08-08.zip )

## Cvičenie 4 (14. 10. 2009)
Iterácia príkladu - write tests first, ukážka vhodnej reprezentácie, tabuľka namiesto podmienok. Dedičnosť, polymorfizmus.

[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-4.pdf )

## Cvičenie 5 (21. 10. 2009)
Liskovovej substitučný princíp. 
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-5.pdf )

Referencie. Ako prebieha vytváranie objektu na halde.
[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-referencie.pdf )

## Cvičenie 6 (21. 10. 2009)
Interfejsy. Programovanie vzhľadom k interfejsom, nie k implementáciám. Kontrapríklady dedičnosti. Rady pre používanie dedičnosti.

[Prezentácia PDF](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/paz1c-6.pdf )

%red% [Ukážka písomky z minulého roka](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2008/pisomka.doc  )

## Cvičenie 8 (18. 11. 2009)
Swing

[Swing](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/swing.pdf  )

## Cvičenie 9 (25. 11. 2009)
Swing 2 - layout managery, ukážka modelov

[Swing](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/swing2.pdf  )

## Cvičenie 11 (10. 12. 2009)
Swing a vlákna

[Swing](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/threads-swing-2009.pdf )

## Cvičenie 12 (17. 12. 2009)
Prístup k SQL databázam s použitím Spring-JDBC.

[Prezentácia PDF. V PDF sú priložené zdrojové kódy.](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/java-spring-jdbc.pdf )


# Praktické cvičenia
## Cvičenie 1 (29. 9. 2008)
???

## Cvičenie 2 (1. 10. 2009)
Naprogramujte simulátor Turingovho stroja

## Cvičenie 3 (8. 10. 2009)
### Skupina Mesto
Vytvorte triedu `Mesto`, ktorá sa pomocou konštruktora dokáže načítať zo súboru. Na načítanie zrecyklujte kód z prvého cvičenia.

Predpokladajte, že mesto je rozdelené na sektory (analógia mapy mesta). Zabezpečte, aby bolo možné evidovať adresu obyvateľa (reprezentovanú sektorom) bez toho, aby ste upravili triedu `Clovek`.
Vytvorte metódy, ktoré dokážu

* zistiť pre človeka, v ktorom sektore býva
* pre daný sektor vrátiť zoznam obyvateľov

### Skupina Úľ
Vytvorte triedu `Úľ`, ktorá sa pomocou metódy dokáže načítať zo súboru. Na načítanie zrecyklujte kód z prvého cvičenia.

Predpokladajte, že úľ je rozdelený na komôrky. (V jednej komôrke môže bývať aj viacero včiel, na rozdiel od reality). Zabezpečte, aby bolo možné evidovať umiestnenie včely v komôrke bez toho, aby ste upravili triedu `Včela`.
Vytvorte metódy, ktoré dokážu

* zistiť pre včelu, v ktorej komôrke býva
* pre danú komôrku vrátiť zoznam včiel, ktoré ju obývajú.

## Cvičenie 4 (15. 10. 2009)
### Skupina Mesto
Vytvorte metódu, ktorá presťahuje občana zo sektora do sektora. 

V meste existuje niekoľko policajtov, ktorí zatýkajú nepoctivých občanov. Simulujte prácu policajta v „kolách", teda vypustite policajtov do mesta, tí nech si vyberú náhodného občana a v prípade, že je nepoctivý, nech ho pošlú do väzenia (nachádza sa v sektore 0, 0)

### Skupina Mesto
Neďaleko úľa sa nachádza lúka s kvetmi, ktoré majú danú kapacitu (v dávkach). Simulujte prácu včiel v „kolách", teda vypustite včely (robotnice) z úľa. Každá včela nech si vyberie náhodný kvet, odoberie jednu dávku a vráti sa do jednej z komôrok úľa (nie nutne tej, z ktorej vyletela). V prípade, že je kvet prázdny, nech skúsi ešte dvakrát nájsť iný kvet.

## Cvičenie (5. 11. 2009)
[Písomka](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/pisomka-paz1c-2009.pdf ) (vrátane riešenia).


## Cvičenie (19. 11. 2009)
### Skupina Mesto
Vytvorte okno, v ktorom zobrazíte do mriežky sektory. Na zobrazenie sektora použite `JButton`. Nadpisom gombíka nech je zoznam ľudí, ktorí obývajú daný sektor. Po kliknutí na gombík zobrazte nové okno s komponentom `JList`, ktorý zobrazí zoznam obyvateľov sektora.

### Skupina Úľ
[Projekt Úľ](http://ics.upjs.sk/~novotnyr/home/skola/programovanie_algoritmy_zlozitost/2009/hive.zip )

Vytvorte okno, v ktorom zobrazíte do mriežky komôrky úľa. Na zobrazenie sektora použite `JButton`. Nadpisom gombíka nech je zoznam včiel, ktoré obývajú daný sektor. Po kliknutí na gombík zobrazte nové okno s komponentom `JList`, ktorý zobrazí zoznam včiel v danom sektore.

## Cvičenie (25. 11. 2009)
### Skupina Mesto
V okne s mriežkou sektorov použite `GridLayout`, ktorý sprehľadní rozhadzovanie komponentov. Namiesto gombíkov však použite panel, v ktorom pre každého obyvateľa sektora vykreslite jeden gombík. Po kliknutí na gombík používateľa zobrazte samostatné modálne okno obsahujúce popisné údaje o používateľovi (meno a rodné číslo), spolu s gombíkom OK.

### Skupina Úľ 
V okne s mriežkou komôrok použite `GridLayout`, ktorý sprehľadní rozhadzovanie komponentov. Namiesto gombíkov však použite panel, v ktorom pre každú včelu v komôrke vykreslite jeden gombík. Po kliknutí na gombík používateľa zobrazte samostatné modálne okno obsahujúce popisné údaje o včele (ID a typ), spolu s gombíkom OK.
