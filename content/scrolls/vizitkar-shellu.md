---
title: Šesťdesiat vizitiek s ťahákmi k shellu
date: 2019-02-03T18:56:29+01:00
---

TLDR; ťaháky k shellu v tvare vizitiek 9x5cm sú zverejnené na [GitHube](https://github.com/novotnyr/shell-handouts).

Počas zimného semestra 2018/2019 bežal na PF UPJŠ kurz *Seminár k operačným systémom*, kde som vyučoval Powershell a Bash. Na začiatku každého shellového stretnutia som rozdal jeden A4kový handout, kde boli uverejnené syntaktické a príkazové nápovedy, ktoré sa mohli hodiť k danej téme.

Obsah z cvičení som následne preklopil z Wordu do LaTeXu a nasekal do formátu vizitiek 9x5cm. Zverejnený je na GitHube, vrátane popisu pokrývaného obsahu (v skratke: syntax shellu, dostupné utility).

Poznámky zo zákopov
===================

Ako štandardný nástroj na buildovanie LaTeXového zdrojáku som použil XeLaTeX. Ten totiž priamo podporuje UTF8 a umožňuje renderovať PDF súbory s použitím natívnych fontov v operačnom systéme (takže dovidenia *Computer Modern*.)

Pri vyrábaní vizitiek boli dva možné smery:

- urobiť na jednu A4ku tabuľku s bunkami 9x5cm a vyplniť obsah. To je pomerne veľký boj, pretože niektoré kombinácie makier jednoducho nejdú k sebe a už vôbec nie, keď majú byť umiestnené v bunke tabuľky. (Za všetko: `verbatim` varianty nejdú dohromady s vlastnými prostrediami)
- urobiť si špeciálny rozmer papiera 9x5cm, vyrenderovať do PDF a následne urobiť *imposition* viacerých stránok. Takto máme stránku, ktorá je stránka (a nie akási zanorená bunka tabuľky).

S použitím balíčka *geometry* sa v LaTeXu dá nastaviť akýkoľvek rozmer stránky, teda aj rozmer klasickej vizitky. 

A imposition? Na MacOS existuje trilión nástrojov na imposition viacerých stránok. Napodiv, väčšina je v Jave z roku 2010, a máloktorý dokáže naukladať stránky na jednu stránku bez zmeny veľkosti. (Druhá množina nástrojov je na Store, za 20 dolárov priemernej ceny…). Klasický scenár hovorí, že chceme naukladať 8 listov A4 na jednu A4, teda ich zmenšiť, pootáčať a správne preusporiadať. Ak však stránka nemá prejsť zmenou veľkosti, často nastal problém.

Nakoniec som urobil *full circle* a pristál v nástroji `pdfjam`, ktorý využíva LaTeXový balíček **pdfpages** a v ňom urobiť na jeden konzolový riadok ľubovoľnú rozumnú transformáciu. (Výsledok je možné vidieť v [`makefile`](https://github.com/novotnyr/shell-handouts/blob/master/latex/makefile)).

Takto je možné vyrobiť dve sady PDFka: jedno s vizitkovými rozmermi stránok a druhé s naukladanými vizitkami na jednej A4 v správnom rozmere.





