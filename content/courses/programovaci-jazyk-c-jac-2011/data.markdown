---
title: ÚINF/JAC1a - Programovanie v jazyku C
date: 2019-07-30T10:32:23+01:00
---
(:toc:)
## Cvičenie 1 (20. 9. 2011)
[Popis cvičenia 1](Skola.ProgramovanieVJazykuC2011Cvicenie1 )

## Cvičenie 2 (27. 9. 2011)
Nekonalo sa (konferencia ITAT)

## Cvičenie 3 (4. 10. 2011)

## Cvičenie 4 (11. 10. 2011)
Majme daný zjednodušený súbor typu `/etc/passwd` z Linuxu, v ktorom sú uvádzané údaje o používateľoch systému. Súbor nech vyzerá nasledovne:
```
root:x:0:0
novotnyr:x:127:127
www-data:x:5:5
```
Na každém riadku sú štyri hodnoty oddelené dvojbodkami:
* login používateľa (maximálne 32 znakov)
* indikátor uloženia hesla v externom súbore `/etc/shadow`. Vždy má hodnotu `x`.
* ID používateľa (UID), jednoznačné vzhľadom na celý súbor. Prirodzené číslo.
* ID skupiny používateľa (GID). Prirodzené číslo.

Vytvorte program, ktorý načíta súbor do pamäte a zaveďte nasledovné funkcie:
* vyhľadanie používateľa podľa UID
* výpis používateľa
* výpis celej databázy.

Databáza nech je realizovaná pomocou `struct`ov a alokovaná staticky v poli 255 položiek.


## Cvičenie 5 (18. 10. 2011)
Upravte predošlú úlohu tak, aby bola databáza alokovaná dynamicky podľa počtu záznamov v súbore. Pre jednoduchosť predpokladajte upravený súbor `passwd` tak, že počet záznamov je uvedený na prvom riadku.
```
2
root:x:0:0
novotnyr:x:127:127
```
Dopracujte vyhľadávanie používateľa podľa loginu. Vytvorte funkciu pre túto funkcionalitu; nájdeného používateľa nevracajte, ale vypíšte na konzolu.

Ďalšie čítanie: [Dynamická alokácia pamäte a pointery](http://ics.upjs.sk/~novotnyr/home/skola/programovaci_jazyk_c/jac1a-pointery.pdf)

# Zadania
Poznámky k zadaniam: zadania realizujte použitím ANSI C podľa normy ANSI C89/90. Kompilácia nech prebehne s parametrami `-ansi -pedantic`. Odporúčaný kompilátor je `gcc`.

Termín na odovzdanie je 6. 2. 2011 do 23:59

## Zadanie 1
Vytvorte modul a používateľské rozhranie pre spracovanie INI súborov podľa konvencie súboru `win.ini`.

Inicializačný súbor predstavuje textový súbor nasledovného typu:
```
; for 16-bit app support
[Mail]
MAPI=1
[MCI Extensions.BAK]
3g2=MPEGVideo
3gp=MPEGVideo
3gp2=MPEGVideo
3gpp=MPEGVideo
[Internet]
UUID=2030258618
```
Riadok predstavuje:
* buď komentár začínajúci bodkočiarkou alebo znakom mreže (#)
Komentár sa vzťahuje k položke na nasledujúcom riadku (t. j. k nasledujúcej sekcii či kľúču).

Príklad:
* nasledovný komentár sa vzťahuje ku kľúču `OS`
```
1.  vybraný operačný systém
OS=Windows
```
* viacriadkový komentár, ktorý sa vzťahuje ku kľúču `OS`
```
1.  vybraný operačný systém
1.  jedna z možností: Windows / Linux / MacOS
OS=Windows
```
* komentár, ktorý sa vzťahuje k sekcii `Windows`
```
1.  Nastavenia Windowsu
[Windows]
BootDrive=C
InstallFolder=Windows
```

    * komentáre začínajú vždy mrežou na začiatku riadku. §§In-line§§ komentáre uprostred riadka nie sú podporované.
* alebo údaj typu §§kľúč§§=§§hodnota§§, kde kľúč je reťazec a hodnota je
    * buď typu reťazec
    * alebo typu integer

Znak `=` je tesne spojený na jednej strane s kľúčom a na druhej strane s hodnotou (okolo znaku `=` nie je žiadne biele miesto).

Názov kľúča nesmie obsahovať medzery, ale hodnota medzery obsahovať môže.

* alebo názov sekcie umiestnený v hranatých zátvorkách.
* alebo prázdny riadok, ktorý je možné pri načítaní ignorovať.

Každá položka začína prvým znakom nového riadku (nie sú pred ňou medzery ani iné znaky bieleho miesta).

Modul nech obsahuje funkcionalitu:
* načítanie INI dát zo súboru
* získanie všetkých kľúčov zo všetkých sekcií: funkcia nech vráti vhodnú štruktúru obsahujúcu všetky kľúče
* získanie kľúčov z danej sekcie: funkcia nech vráti vhodnú štruktúru obsahujúcu všetky kľúče z danej sekcie
* získanie hodnoty pre daný kľúč
    * ako reťazca
    * ako celého čísla (ošetrite chybové stavy)
* pridanie kľúča a hodnoty do danej sekcie spôsobom, kde v prípade existencie daného kľúča sa hodnota prepíše
* pridanie kľúča a hodnoty do danej sekcie spôsobom, kde v prípade existencie daného kľúča nastane chybový stav
* pri pridaní záznamu do neexistujúcej sekcie sa sekcia vytvorí
* odstránenie kľúča a hodnoty z danej sekcie
    * pri odstránení posledného záznamu zo sekcie sa celá sekcia odstráni
* uloženie INI dát do súboru
    * pri ukladaní súboru nie je potrebné dbať na presnú polohu prázdnych riadkov.


Dáta z INI súboru musia byť uložené v pamäti (nepripúšťa sa zmena dát načítaním, prebehnutím a úpravou súboru).

Modul nech je dodaný v podobe samostatného C súboru vrátane hlavičkového súboru obsahujúceho požadované funkcie.

Používateľské rozhranie nech predstavuje jednoduché menu s voľbou položiek menu z klávesnice, kde je možné otestovať nasledovnú funkcionalitu:
* načítanie INI súboru
* pridanie novej položky
* výpis všetkých kľúčov a hodnôt
* výpis kľúčov a hodnôt v danej sekcii
* výpis názvov všetkých sekcií
* odstránenie položky
* zmena hodnoty v danom kľúči.
* uloženie údajov do INI súboru. 
    * Pri ukladaní treba dodržať vzájomný vzťah komentárov a položiek, ku ktorým sa vzťahujú.

Všetky vyššie popísané funkcie musia byť v zadaní implementované -- nepripúšťa sa odovzdanie čiastočne implementovaného zadania.

## Zadanie 2
Vytvorte program spracovávajúci matematické výrazy v infixnej notácii za použitia reverznej poľskej notácie. Použité operátory sú: 
* sčítanie `+`,
* odčítanie `-`, 
* násobenie `*`,
* delenie ` / `
Priorita operátorov je v tradičnom duchu: násobenie a delenie má prednosť pred sčítaním a odčítaním.

Matematický výraz obsahuje prirodzené čísla, zátvorky a operátory. 

Príklady výrazov:
* `(2 + 3) + 5`
* `(2 * 3) / (5 * 25)`

Príklady nekorektných výrazov?
* `2 + 3 + 5` (zlé uzátvorkovanie)
* `2 / 3 # 5` (nepodporovaný operátor

Prevod z infixnej notácie do reverznej poľskej notácie realizujte napr. pomocou §§[shunting yard](http://en.wikipedia.org/wiki/Shunting-yard_algorithm)§§ algoritmu, ktorý využíva zásobník a rad. (Zásobník a rad realizujte ako samostatnú knižnicu v separátnom súbore s hlavičkovým súborom includnutým do hlavného súboru v rovnakom duchu ako sa to realizovalo na cvičeniach. Implementáciu radu a zásobníka zvoľte podľa uváženia.)

Výstupom programu nech je výsledok vyhodnotenia výrazu a zároveň jeho prepis do reverznej poľskej notácie.

Ukážka:
```
/home/novotnyr> ./rpn "1 + 1"
1 1 + = 2
```

Ak výraz obsahuje nekorektné zátvorkovanie, vypíšte chybu "Nekorektné zátvorkovanie" (na overenie použite zásobník a kód z cvičenia, resp. znalosti z PAZ1b).

Ak výraz obsahuje nekorektné znaky, či operátory, vypíšte chybu "Nekorektný znak na pozícii X", kde X je poradie znaku indexované od 1ky.
