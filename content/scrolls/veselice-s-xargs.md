---
title: "Veselice s `xargs`"
date: 2019-01-13T10:20:04+01:00
---

Každý druhý článok o `xargs` sa začína v duchu _„... jedným z najpodceňovanejších príkazov Unixu je...”_. Tento nebude iný.

Mnohokrát sa stáva, že výstupom programu je niekoľko slov oddelených bielym miestom (napr. slová na samostatných riadkoch), ktoré chceme postupne jeden za druhým spracovávať a posielať ako parameter do iného programu. Niečo v duchu:

	pre každé slovo R
		spracuj R

Priamo `for` cyklus! V shellscriptingu je však `for` prekérny: vyžaduje totiž podivnú viacriadkovú syntax... a komu sa chce kvôli jednoduchým jednorazovým veciam zakladať skripty, písať shebangy, `chmod`ovať a patlať sa s editorom.

Túto rolu vie mnohokrát zastúpiť `xargs`.

O `xargs`
=========
Stručne povedané:

> `xargs` zostavuje zo štandardného vstupu príkazový riadok
>  a vykonáva ho.

A povedané ešte inak: ak máte na štandardnom vstupe slová oddelené bielym miestom, a v inom príkaze ich potrebujete nasekať do parametrov, `xargs` vás zachráni. A naozaj nemusíte `for`ovať.

Ukážková úloha: hromadné sťahovanie súborov
===========================================

Prestavme si, že chceme hromadne sťahovať súbory, pričom ich adresy máme v súbore `url.txt`:

```
https://google.com
http://altavista.digital.com
http://askjeeves.com
```

Pre každú adresu chceme zavolať `wget`, ktorý stiahne obsah do aktuálneho adresára. (Ako pekne to zodpovedá našej filozofii zhora! URL je slovo, stiahnutie súboru je operácia.)

`xargs`, ktorý použijeme, potrebuje dve veci:

* **čo má vykonať,**  teda príkaz, ktorý sa má spustiť. 
* **s čím má pracovať**, teda dáta, nad ktorými sa vykoná príkaz.

Dáta pošleme do `xargs` cez štandardný vstup a príkaz použijeme ako argument `xargs`:

```shell
< url.txt xargs -n 1 wget
```

`xargs` má parameter `-n 1`, ktorý hovorí, že pre každé (jedno) slovo zo štandardného vstupu sa má spustiť `wget` a toto slovo sa použije ako jeho parameter.

Keďže máme tri adresy (tri slová oddelené bielym miestom), `xargs` ich bude načítavať po jednom a pre každé z nich spustí `wget`. V skratke, `wget` sa spustí trikrát:

```shell
wget https://google.com
wget http://altavista.digital.com
http://askjeeves.com
```

Ukážková úloha: spracovanie používateľov systému
================================================

`xargs` možno využiť aj pri spracovaní textu. Vypíšme zoznam všetkých používateľov v systéme na jeden riadok!

```shell
cut -d : -f 1 /etc/passwd | xargs
```

Zoznam používateľov je uložený ako prvá položka záznamu v `/etc/passwd`. Použitím príkazu `cut` sme na každý riadok vypísali len používateľa.

Ak výstup pošleme na štandardný vstup príkazu `xargs`, pre každého používateľa, ktorý je považovaný za slov, sa vykoná príkaz. Aký je to však príkaz? Ak v `xargs` neuvedieme nič, použije sa implicitne `echo`.

V tomto prípade sme neuviedli prepínač `-n 1`, to znamená, že všetci používatelia, teda všetky slová sa vezmú naraz a akoby “prilepia” na koniec príkazového riadku. 

Zoberme teda zoznam používateľov:

```
root
johnpaul
willgates
```

`xargs` vezme všetky tri slová a použije ich *naraz* ako argument pre `xargs` a v skutočnosti sa vykoná:

```shell
xargs echo root johnpaul willgates
```

Keďže na vstupe boli tri slová (traja používatelia, na troch riadkoch), príkaz `xargs` zavolá `echo` s troma argumentami.

Limity operačného systému
-------------------------

`xargs` použije zo štandardného vstupu toľko slov, koľko sa zmestí na príkazový riadok. Operačný systém totiž obvykle kladie limity na maximálnu dĺžku riadku, ktorý sa dá vykonať. V súčasných systémoch to už nie je až také kritické (napr. náš debianovský server podporuje na príkazovom riadku vyše 2 miliónov znakov!) Ak by aj napriek tomu k niečomu takému došlo, `xargs` sa s tým vie vysporiadať, pretože vstupné slová primerane rozdelí do kratších skupín a príkaz zopakuje viackrát.

Ukážková úloha: rátanie riadkov
===============================

`xargs` sa dá použiť aj pri spracovaní ciest k súborom. Vypíšme počty riadkov textových súborov v aktuálnom adresári a podadresároch!

Všetky texťáky nájdeme poľahky cez `find`:

```shell
find . -name '*.txt'
```

Dáta tvoria riadky s cestami k súborom, a príkazom na rátanie bude `wc -l`.

Pozor, slová nie sú riadky!
---------------------------

Ale pozor, v tomto prípade nemôžeme v `xargs` použiť `-n 1`! Ak by súbor obsahoval medzeru (napr. `diplomova praca.txt`), `xargs` by  zavolal príkaz dvakrát: raz pre slovo `diplomova` a druhýkrat pre `praca.txt`, čo určite nie je to, čo očakávame.

`xargs` pre rátanie riadkov
---------------------------

Namiesto toho vie `xargs` rátať aj riadky:

```shell
find . -name '*.txt' | xargs -I {} wc -l {}
```

Prepínač `-I` (veľké I) zapne postupné spracovanie riadkov namiesto slov zo štandardného vstupu. Výraz `{}` je špeciálne označenie “premennej”, v ktorej sa postupne objavia jednotlivé riadky s názvami súborov. Túto premennú môžeme použiť na vhodnom mieste ako argument príkazu, ktorý sa spracováva. To je užitočné v prípade, keď spracovávaná položka sa má v príkaze použiť inak ako posledný argument.

### Porovnanie s `find`/`exec`

Rovnaký výsledok dosiahneme aj klasickým zápisom `find` a jeho prepínača `-exec`:

```shell
find -name '*.txt' -exec wc -l {} \;
```

Príkaz nájde všetky súbory s príponou `.txt` a pre každý z nich vykoná počítanie slov. Dokonca aj vidno, že zápis pre “aktuálny súbor” je rovnaký — pomocou `{}`.

Rozdiel je v rýchlosti a robustnosti. Kombinácia `find` a `xargs` je omnoho rýchlejšia, ale môže mať problémy pri ošetrovaní mimoriadne neštandardných či zákerných názvov súborov.

### Rátanie riadkov bezpečným spôsobom: nulové znaky

Ak máme k dispozícii GNU prostredie (na Linuxe) alebo MacOS, môžeme použiť pri spracovávaní súborov mechanizmus, ktorý ošetrí aj veľmi neštandardné názvy súborov:

```shell
find . -name '*.txt' -print0 | xargs -0 wc -l
```

V tomto prípade `find` bude vypisovať na štandardný výstup jednotlivé súbory oddelené znakom `NUL` (teda znakom s ASCII hodnotou 0). Dosiahneme to parametrom `-print0`.

Príkazu `xargs` potom môžeme povedať, že položky v štandardnom vstupe sú oddelené tým istým znakom , stačí použiť parameter `-0`.

Ukážková úloha: vytváranie súborov
==================================

Vytvorme si naraz 10 súborov `kapitola1.txt`, `kapitola2.txt` … `kapitola10.txt`! 

Toto je obvykle situácia pre cyklus `for`, ale ten sa v shelli zapisuje mimoriadne nepríjemne. Namiesto toho si nechajme vygenerovať 10 čísiel pomocou príkazu `seq` a použime ich ako premennú v `xargs`:

```shell
seq 10 | xargs -I{} touch kapitola{}.txt
```

Príkaz `seq` nageneruje na každý riadok jedno číslo, a kombinácia `-I` bude brať jednotlivé riadky a zároveň poslúži na vyformátovanie názvu súboru.

Ak by sme chceli súbory `Kapitola 1.txt`, `Kapitola 2.txt` atď. (s medzerami), použijeme klasické zásady o úvodzovkovaní zo shellu.

```
seq 10 | xargs -I {} touch 'Kapitola {}.txt'
```

Iné zvyklosti pri premennnej
----------------------------

V niektorých skriptoch sa namiesto pseudopremennej `{}` používa iný, kratší symbol, a to percento `%`. Skracuje to zápis:

```shell
seq 10 | xargs -I% touch kapitola%.txt
```

Ďalšie triky
============

Trasovanie príkazov
-------------------

Prepínač `-t` zapne trasovanie príkazov, teda výpis úplneho príkazu, ktorý `xargs` spustí.

Potvrdenie príkazu
------------------

Prepínač `-p` sa pri každom spustení príkazu vyvolaného `xargs` spýta používateľa na potvrdenie:

```shell
whitehall$ ls -1 *.txt | xargs -I % -p rm %
rm 1.txt?...y
rm 2.txt?...n
rm 3.txt?...y
```

Pre každý súbor musí používateľ zadať `y` a potvrdiť vymazanie súboru.

Prevod riadkov na slová
-----------------------

Desať čísiel vieme preklopiť zo samostatných riadkov na jeden riadok, kde budú čísla oddelené medzerami:

```shell
whitehall$ seq 10 | xargs
1 2 3 4 5 6 7 8 9 10
```

Viac príkazov a viac pseudopremenných
-------------------------------------

Ak potrebujeme vykonať nad položkou viacero príkazov, môžeme vyvolať v príkaze `xargs` celý shell, ktorému posunieme príkazy v reťazci za prepínačom `-c`:

```
ls *.txt | xargs -I{} sh -c 'echo {}; <{} wc -l'
```

V tomto príklade nad každým textovým súborom vykonáme dva podpríkazy: 

- vypíšeme jeho názov cez `echo`
- spočítame jeho riadky cez `wc`, do ktorého presmerujeme obsah aktuálneho súboru v pseudopremennej `{}`.

Oba príkazy vykonáme v shelli, a odovzdáme ich do shellu cez `-c`.

Ako vidno, pseudopremennú `{}` môžeme použiť aj viackrát: v tomto prípade raz na výpis a druhýkrát na presmerovanie vstupu.

Funky veci
==========

A ako bonus, matematika:

Vypíšte maticu 3 x 3 s prvkami od 1 po 9
----------------------------------------

Stačí použiť fintu s dávkovaním parametrom po _n_-ticiach:

```
seq 9 | xargs -n 3 
```

Výsledkom je

```
1 2 3
4 5 6
7 8 9
```

### Vypíšte jednotkovú maticu 3 x 3

```
yes | head -n 9 | xargs -n 3 | tr y 1
```

Príkaz `yes` generuje `y` donekonečna, ale nám stačí odseknúť `head`om prvých 9 hodnôt (3 x 3), ktoré pošleme posekať do `xargs` a na záver nahradíme znaky `y` jednotkami. (Samozrejme, predpokladá to existenciu príkazu `yes`, ktorý nie je posixový.)



### 