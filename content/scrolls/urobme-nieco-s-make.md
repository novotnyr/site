---
title: "Urobme niečo s `make`"
date: 2019-01-04T14:57:45+01:00
---

O `make` a `makefile` súboroch
===

`make` zjednoduší zostavovanie súborov - teda kompilovanie, konverzie, či akékoľvek iné hromadné spracovanie súborov. Zostaviť binárku zo zdrojáku v Céčku? Vytvoriť PDF súbor v diplomovej práce v LaTeXu? Previesť markdownovské zdrojové súbory do HTML? To všetko `make` zvládne bez problémov.

A keďže už od nepamäti je súčasťou každého Linuxu, či dokonca MacOS, oplatí sa ho spoznať!

Jednoduché recepty, najmä pre céčkarov
======================================

Recept: overenie, že `make` funguje
-----------------------------------

`make`  je naozaj všade! Z terminálu, resp. konzoly spustime:

```shell
whitehall:tmp$ make
make: *** No targets specified and no makefile found.  Stop.
```

Program nemá žiadne špeciálne inštrukcie, preto skončí s chybovou hláškou.

Overme si verziu `make` v operačnom systéme:

```shell
whitehall:tmp$ make -v
GNU Make 3.81
Copyright (C) 2006  Free Software Foundation, Inc.
This is free software; see the source for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

This program built for i386-apple-darwin11.3.0
```

V ukážke vidíme **GNU Make** spustený na *MacOS Mojave*. Ide o najrozšírenejší variant, i keď to nie je najnovšia verzia. V každom prípade, je to rozumný štandard!

Recept: zostavenie jedného `c` súboru
---

Vytvorme si primitívny program v jazyku C, `hello.c`:

```c
#include<stdio.h>

int main(void) {
  printf("Hello World!");
  return 0;
}
```

Build (zostavenie) spustíme nasledovne:

```shell
make hello
```

Na výstupe uvidíme priebeh zostavenia:

```makefile
cc     hello.c   -o hello
```

V aktuálnom adresári vznikne binárka `hello`, ktorú môžeme rovno spustiť.

```shell
./hello
```

`make` má totiž zabudovanú podporu pre jazyk C. Po spustení `make hello` sa vyhľadá v aktuálnom adresári súbor `hello.c`, a skompiluje sa presne tak, ako keby sme vykonali `cc hello.c -o hello`. Príkaz `cc` je na tradičnom linuxovom systéme stotožnený s niektorý, kompilátorom jazyka C, napr. s `gcc`.

### Pozorovanie: ak sa zdrojáky nezmenili, build sa nevykoná

Opakované spustenie `make` šetrí čas. Ak `make` zistí, že zdrojový súbor nebol zmenený, kompiláciu nebude zbytočne opakovať a vypíše len:

```
`hello` is up to date
```

Recept: prispôsobenie parametrov buildu pre jazyk C
---

Ak chceme použiť vlastné nastavenia pre build, založme si konfiguračný súbor `makefile`. Uveďme doňho nastavenia pre kompilátor C:

```makefile
CFLAGS = -Wall -Wextra -ansi -pedantic -Werror
```

V súbore `makefile` môžeme deklarovať vlastné premenné. V tomto prípade nastavíme zabudovanú premennú `CFLAGS`, ktorou sa riadia parametre kompilátora jazyka C.
Ak spustíme `make hello` znovu, uvidíme jej použitie:

```shell
whitehall$ make hello
cc -Wall -Wextra -ansi -pedantic -Werror    hello.c   -o hello
```

Recept: vlastný kompilátor pre C
---

Ak chceme použiť konkrétny kompilátor jazyka C pre build, nastavme premennú `CC`:

```
CC = gcc
```

Spustíme ho:

```shell
whitehall$ make hello
gcc -Wall -Wextra -ansi -pedantic -Werror    hello.c   -o hello
```

Recept: vlastný cieľ pre mazanie
---

`make` podporuje aj vlastné ciele (**targets**), teda vlastné postupnosti príkazov, ktoré sa majú vykonať. Folklórom je vymazanie binárok, teda príkaz v duchu:

```
rm ./hello
```

V `makefile` si môžeme zaviesť vlastný cieľ `clean` a následne ho zavolať:

```
clean:
	rm ./hello
```

Jednotlivé príkazy *musia* začínať jedným znakom tabulátora (teda nie medzerami, ani ničím iným, jedným (!) znakom tabulátora), pretože inak sa bude `make` sťažovať.
Ak chceme vymazať binárku, stačí zavolať:

```
make clean
```

Recept: prerekvizity
---

Prerekvizitou je súbor, ktorý musí existovať -- teda je požiadavkou -- na úspešné vykonanie cieľa. Prerekvizity uvádzame za dvojbodku:

```makefile
CFLAGS = -Wall -Wextra -ansi -pedantic -Werror
CC = gcc

all: hello

clean:
	rm ./hello
```

V tomto prípade sme si vymysleli cieľ `all`, ktorý vyžaduje na svoje úspešné vykonanie existenciu súboru `hello`.

Ak spustíme `make all`, a súbor s binárkou `hello` , ktorá je prerekvizitou tohto cieľa, neexistuje, spustí sa vykonávanie zabudovaného cieľa `hello` , 
teda spustenie kompilátora `gcc`.

Aký je rozdiel medzi `make hello` a `make`? V tomto prípade zdanlivo žiadny, ale o sekundu zistíme, že prináša jednu pohodlnú vec.

Recept: implicitné ciele
---

Cieľ, ktorý je v `makefile` uvedený ako prvý, je **implicitný** (*default target*). Vykoná sa v prípade, keď zavoláme `make` len tak, bez ničoho:

```shell
make
```

Recepty pre iné technológie
===

Ukážme si zostavenie, kompiláciu, či konverziu pre iné technológie, presnejšie pre prevod zdrojových súborov z formátu [Markdown](https://daringfireball.net/projects/markdown/) pomocou nástroja [Pandoc](https://pandoc.org/). 
Založme si cvičný súbor `hello.markdown` s nasledovným jednoduchým obsahom:

```markdown
Hello World
===========
Toto je ukážkový súbor!
```

Recept: ručný prevod z Markdown do HTML
---

Ak by sme nepotrebovali `make`, súbor prevedieme na HTML jednoducho:

```
pandoc hello.markdown --output hello.html
```

Recept: vlastný prevod jedného súboru
---

Ak využijeme `make`, zavedieme pravidlo:

```makefile
hello.html: hello.markdown
	pandoc hello.markdown --output hello.html
```

Cieľ `hello.html` zodpovedá súboru, ktorý sa má vyprodukovať v prípade, že 

1. existuje **prerekvizita** zodpovedajúca súboru `hello.markdown` ,
2. súbor prerekvizity `hello.markdown` sa zmenil.
   Vyskúšajme zostaviť cieľ:

```
make hello.html
```

`make` vykoná požadovaný prevod a v adresári vznikne `hello.html`.

Recept: opakovaný prevod
---

`make` sleduje zmeny na prerekvizitách. Ak sa prerekvizita nezmenila, pravidlo sa nevykoná, čím sa šetrí čas! Vyskúšajme jeden cieľ spustiť viackrát:

```
make hello.html
```

Po druhom spustení uvidíme oznam, že cieľ nie je potrebné vykonať, lebo jeho prerekvizita sa nezmenila.

```
make: `hello.html' is up to date.
```

Recept: všeobecné pravidlá pre prevody súborov (*pattern rules*) 
---

Ak by sme mali v adresári viacero zdrojových súborov vo formáte Markdown určených na prevod do HTML, každý jeden súbor by musel mať samostatné pravidlo. To by nebola ktovieaká zábava. Našťastie, `make` podporuje *vzorové pravidlá* (**pattern rules**) pre súbory, ktorých názvy zodpovedajú príslušnému vzoru:

```
%.html: %.markdown
```

V pravidle máme pravidlo, ktoré hovorí, že cieľ (súbor) s príponou `.html` má za prerekvizitu príslušný zdrojový súbor s príponou `.markdown`.
Znak `%` reprezentuje zástupný znak (*wildcard*) pre neprázdny reťazec.
Aký bude konkrétny návod pre zostavenie súboru?

```
%.html: %.markdown
	pandoc $< --output $@
```

V definícii používame dve **automatické premenné** (*automatic variables*):

* `$@`: názov cieľa, vrátane prípony. 
* `$<` : názov prvej prerekvizity. Inými slovami, obvykle predstavuje názov prvého súboru, vďaka ktorému sa zvolilo toto pravidlo. 
  Ak vykonáme `make hello.html`, v premennej `$@`  sa ocitne `hello.html` a v premennej `$<` bude `hello.markdown`.

Recept: falošné ciele (*phony targets*)
---

[Pravidlo č. 2](http://make.mad-scientist.net/papers/rules-of-makefiles/#rule2) tvorby `makefile`-ov hovorí, že názov cieľa predstavuje názov súboru, ktorý sa aktualizuje / zostaví / konvertuje, ak sa cieľ vykoná.

Ale čo taký `make clean`? Žiaden súbor `clean` predsa neexistuje!

Ciele, ktoré nezodpovedajú súborom, sú *falošné* (**phony target**). Ak by totiž existoval v adresári súbor `clean`, mazanie súborov by sa nekonalo, prípadne by sa diali ďalšie podivnosti.
Falošný cieľ označíme nasledovne:

```
.PHONY: clean
```

Zápis je vtipný, pretože vytvoríme špeciálne pravidlo s cieľom  `.PHONY` , ktorého prerekvizitou je falošný cieľ.

Rekapitulácia: jednoduchý `makefile`
---

Nasledovný `makefile` dokáže:

* zostaviť HTML súbor zo zdrojového Markdownu pomocou `make hello.html`,
* vymazať všetky prevedené súbory pomocou `make clean`,
* vyhlásiť `clean` za falošný cieľ,
* použiť `all` ako falošný cieľ, ktorý síce neurobí nič, ale vykoná sa v prípade, ak neuvedieme žiaden cieľ`.

```makefile
%.html: %.markdown
	pandoc $< --output $@

all:
.PHONY: all

clean:
	rm *.html
.PHONY: clean
```

Recepty pre hromadné spracovanie súborov
===

Vytvorme si ešte jeden súbor vo formáte Markdown, `intro.markdown`:

```
Úvod
=============
Toto je úvod!
```

Recept: premenné
---

`make` podporuje premenné, ktoré sprehľadňujú zápis. Vytvorme si premennú `MARKDOWN`, ktorá obsahuje zoznam dvoch súborov. 

```
MARKDOWN = intro.markdown hello.markdown
```

Premennú následne môžeme použiť na viacerých miestach:

* pri prerekvizitách
* v príkazoch samotného receptu.
  V ukážke vidíme priradenie i čítanie z premennej pomocou `$(MARKDOWN)`, čo je zápis podobný shellu.

```makefile
MARKDOWN = intro.markdown hello.markdown
all.markdown: $(MARKDOWN)
	cat $(MARKDOWN) > all.markdown
```

Zároveň vidíme, že definujeme cieľ `all.markdown`, ktorý má prerekvizitu získanú z premennej.
Vo vykonaní cieľa pomocou `cat` zoberieme obsahy oboch súborov z premennej a zapíšeme ich do súboru.
Môžeme tak vykonať príkaz, ktorým sa obsahy oboch súborov konkatenujú do jedného veľkého súboru.

```shell
make all.markdown
```

Recept: dynamické zoznamy súborov pomocou funkcie `wildcard`
---

Ak by sme mali príliš veľa zdrojových súborov, môžeme využiť zabudovanú funkciu `wildcard`:

```
MARKDOWN = $(wildcard *.markdown)
```

Do premennej `MARKDOWN` vložíme výsledok volania funkcie `wildcard`, ktorá vyhľadá všetky súbory s príponou `.markdown` a zostaví z nich zoznam.
V premennej `MARKDOWN` sa v našom prípade objavia dva súbory: `intro.markdown` a `hello.markdown`.

```
MARKDOWN = $(wildcard *.markdown)
all.markdown: $(MARKDOWN)
	cat $(MARKDOWN) > all.markdown
```

Recept: hromadné zostavenie súborov
---

Predstavme si teraz, že chceme jedným cieľom zostaviť všetky markdownové súbory do HTML!
Zatiaľ máme pravidlo, ktorým prevedieme jeden Markdown na jeden HTML súbor:

```
%.html: %.markdown
	pandoc $< --output $@
```

Zároveň vieme získať zoznam všetkých markdownových súborov:

```
MARKDOWN = $(wildcard *.markdown)
```

Ako však prevedieme všetky markdowny na všetky HTML súbory?
Mohli by sme si urobiť cieľ  `html`

```
.PHONY: html
html: intro.html hello.html
```

Ak zavoláme `make html` , `make` zistí, že sú potrebné dve prerekvizity v podobe dvoch HTML súborov. Ak tieto súbory nejestvujú alebo nie sú aktuálne, pokúsi sa ich zostaviť.
Na vytvorenie HTML súboru máme vzorové pravidlo (*pattern rule*) , ktoré zavolá nástroj `pandoc`. Toto pravidlo sa zavolá pre každý markdownový súbor zvlášť.

```shell
whitehall$ make html
pandoc intro.markdown --output intro.html
pandoc hello.markdown --output hello.html
```

Vidíme, že vieme zavolať cieľ, ktorým naraz vybudujeme všetky HTML súbory!

Recept: hromadné zostavenie dynamických súborov
---

Ak chceme naraz zostaviť všetky HTML súbory, máme na to cieľ `html` s pevným zoznamom prerekvizít:

```
html: intro.html hello.html
```

Čo ak chceme dynamický zoznam prerekvizít? Chceli by sme zoznam všetkých HTML súborov v adresári, a to dosiahneme na dva kroky:

1. Pomocou funkcie `wildcard` vieme získať zoznam všetkých markdownových súborov. 

```
MARKDOWN = $(wildcard *.markdown)
```

1. Keďže každému `.markdown` prislúcha presne 1 HTML súbor, stačí zmeniť prípony každého súboru v zozname a máme to!
   Na zmenu prípony použijeme nasledovný zápis

```
HTML = $(MARKDOWN:.markdown=.html)
```

Zápis jemne pripomína expanziu premenných v shelli, ale poďme si ho rozobrať:

* v premennej `MARKDOWN` 
  * za dvojbodkou uvedieme príponu, ktorú nahrádzame (`.markdown`) 
  * za “rovná sa” uvedieme reťazec, ktorým nahrádzame (`.html`)
    Ak je v premennej `MARKDOWN` zoznam dvoch súborov:

```
MARKDOWN = intro.markdown hello.markdown
```

po nahradení bude v premennej HTML obsah:

```
HTML = intro.html hello.html
```

Prehľadnejší  `makefile` môže vyzerať nasledovne:

```
MARKDOWN = $(wildcard *.markdown)
HTML = $(MARKDOWN:.markdown=.html)

%.html: %.markdown
	pandoc $< --output $@

html: $(HTML)
.PHONY: html
```

Rekapitulácia: `makefile`
---

Nasledovný súbor dokáže:

* `make intro.html`: vybudovať jeden HTML súbor
* `make html` alebo len `make`: vybudovať všetky HTML súbory. Keďže cieľ `html` je prvý nevzorový cieľ, použije sa v prípade, že zavoláme `make` bez uvedenia cieľa.
* `make all.markdown`: vybudovať súbor obsahujúci všetky markdownové súbory
* `make clean`: odstráni všetky HTML súbory a odstráni generovaný súbor `all.markdown`

```
MARKDOWN = $(wildcard *.markdown)
HTML = $(MARKDOWN:.markdown=.html)

%.html: %.markdown
	pandoc $< --output $@

html: $(HTML)
.PHONY: html

all.markdown: $(MARKDOWN)
	cat $(MARKDOWN) > all.markdown

clean:
	rm *.html
	rm all.markdown
.PHONY: clean
```

Keďže ciele `clean` a `html` nezodpovedajú súborom, označíme ich ako /phony/. Každá deklarácia cieľa  `.PHONY` pridá danú prerekvizitu do zoznamu falošných cieľov.

Sumár základov
===

`make` dokáže jednoduchým spôsobom zostavovať súbory. Stačí však dodržať niekoľko základných pravidiel:

* **Príkazy musia začínať TABulátorom**: v opačnom prípade uvidíme hlášku:

```
makefile:2: *** missing separator.  Stop.
```

* **Cieľ = súbor**. Názov cieľa reprezentuje súbor, ktorý sa má vytvoriť. Príkazy cieľa musia vytvoriť, či aktualizovať príslušnú súbor, pretože inak si koledujeme o problémy.
* **Falošné ciele sú `.PHONY`**. Ak cieľ nezodpovedá súboru, musíme ho vyhlásiť za prerekvizitu cieľa `.PHONY`
* **Prerekvizity sú ciele**. Každá prerekvizita cieľa reprezentuje súbor. Cieľ sa vykoná, ak niektorá z prerekvizít zmenila či vznikla.
