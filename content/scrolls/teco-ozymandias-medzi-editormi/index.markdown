---
title: "Elder Scrolls: TECO – Ozymandias medzi editormi"
date: 2019-08-07T10:40:37+01:00
---

> Som Ozymandias, všetkých kráľov kráľ.
>
> Hľaď, mocný, zúfaj, vidiac moje dielo!
>
> — Percy Bysshe Shelley: Ozymandias (1818)

![](civ1.jpg)

WTF TECO
========

TECO (tíkou, vzor Daewoo Tico) je azda najstarší ehm textový ehm editor. 

Klasika od roku 1962.

> Šialenstvo TECO: chvíľka pohodlnosti; útrapy do konca života.
>
> — Wiki [C2](http://wiki.c2.com/?TecoEditor)

Pozitívne vlastnosti:

- stručné príkazy reprezentované jedným písmenom!
- podpora skriptov, ktoré možno verzovať v Gite!
- podpora pre makrá, veď ide o turingovsky úplný jazyk

Veď ktorý editor vám vypíše čísla od 1 po 5 takto:

```
5<%0$Q0=>$$
```

Prelúdium: odkiaľ zohnať?
=========================

TECO nie je mŕtve. Práve naopak, toto je žralok ríše editorov, dokonalý a nezničiteľný!

Binárky
-------

Portál [Almy.us](http://almy.us/teco.html) poskytuje binárky pre všetky bežné platformy. Ale nie všade je k dispozícii *video mód* pre bežných smrteľníkov.

## Ako zbuildovať?

Na druhej strane, GitHub repo [blakemcbride/TECOC](https://github.com/blakemcbride/TECOC/) má céčkové zdrojáky, ktoré sa dajú zbuildovať nielen na Linuxe, ale aj na súčasnom MacOS Mojave.

```
git clone https://github.com/blakemcbride/TECOC.git
cd TECOC/src
make -f makefile.osx
```

Prvé dejstvo — základné operácie
================================

GUI
---

TECO nemá GUI. (Ale je tu video mód. Pre krehké srdcia. Viď kapitola na konci.)

Teda, spustenie `teco` spôsobí nasledovný vrchol GUI:

```plain
*
```

Jedna hviezdička, teda prompt, je celé GUI.

TECO je totiž znakovo orientovaný editor. Celý textový súbor považuje za obrovský reťazec (znakov), ktoré sú indexované (od nuly). V tomto reťazci máme **kurzor**, ktorý ukazuje na konkrétny znak, a vďaka pestrej palete **príkazov** môžeme po súbore skackať a meniť, pridávať, či mazať jednotlivé znaky.

Akurát trochu terminológie:

- **pointer** je kurzor. Ale: pointer ukazuje *medzi znaky*. Pointer na pozícii `1` hovorí, že „naľavo od pointeru je 1 znak“, teda pointer stojí medzi prvým a druhým znakom buffera.
- **súbor** zodpovedá obrovskej páske, kde na políčkach sú znaky. (Turingov stroj, *anyone*?). Začiatok súboru má index 0.
- **riadky** sú *sociálny konštrukt*, teda falat buffera medzi dvoma znakmi konca riadku. TECO považuje za koniec riadku dvojicu znakov CR-LF (bez ohľadu na platformu).

Načítanie a výpis súboru v bufferi
------------------------

Na hrajkanie si urobme cvičný súbor `ozymandias.txt`, zo shellu:

```shell
printf "Som Ozymandias, vsetkych kralov kral.\nHlad, mocny, zufaj, vidiac moje dielo\041\n --Percy Bysshe Shelley: Ozymandias (1818)\n" > ozymandias.txt
```

Bežné TECO neberie parametre z príkazového riadka. (Príkazový riadok nebol vynájdený.)

Na načítanie súboru použijeme dva **príkazy**:

- `EB` otvorí súbor na čítanie a zápis. (Analógia `fopen()`)
- `Y` načíta obsah súboru do buffera. (Analógia `fgets()`). Konkrétne načíta prvú stránku, ale o tom viac v bonuse.

Príkazy sú ultrakrátke, jedno, maximálne dve písmená.

Na vykonanie príkazu sa nepoužíva *Enter* (Enter nebol vynájdený), ale **dvakrát Escape**.

Ukážkový *session*, kde `*` je prompt a `$` reprezentuje stlačenie `Esc`:

```
*EBozymandias.txt$$
*Y$$
```

Súbor sa otvoril a načítal! Po otvorení súboru je pointer na začiatku buffera, na indexe 0.

`HT` — výpis obsahu buffera
--------------------------

Výpis celého buffera získame príkazom `HT`:

```plain
HT$$
```

Celý session vyzerá nasledovne:

```
*HT$$
Som Ozymandias, vsetkych kralov kral.
Hlad, mocny, zufaj, vidiac moje dielo!
 --Percy Bysshe Shelley: Ozymandias (1818)
*
```

TECO vypísalo obsah celého buffera.

Mnemotechnika kríva, ale neskôr si povieme, že v skutočnosti sme práve použili dva (!) príkazy. Ale detaily neskôr.

Please no more. Is kruel joke.
------------------------------

Z `teco` sa vylieza dvojitým `Ctrl+C`. `Ctrl+C`.

`.=` – zistenie aktuálnej polohy
------------------------------

Ak chceme zistiť, kde máme pointer, použime príkaz `.=`:

```plain
.=$$
```

Celý session vyzerá:

```plain
*.=$$
0
```

Tento príkaz vypíše index, na ktorom sa práve nachádza pointer.

Mnemotechnika kríva ešte viac, ale v tomto prípade ide o použitie príkazu s parametrom. Ale detaily neskôr.

`T` — typeout – výpis riadka
------------------

Jednopísmenný príkaz `T` vypisuje text od pointeru do konca riadku (teda po najbližší `CR`-`LF`).

```plain
T$$
```

Celý session vrátane dekorácie:

```plain
*T$$
Som Ozymandias, vsetkych kralov kral.
```

Keďže pointer je na začiatku buffera (a na začiatku prvého riadku), samotný `T` vypíše prvý riadok.

`T` je štandardný debugovací nástroj. Kto je stratený, nech si `T`-čkne.

Hodí sa aj kombo na výpis celého riadka, bez ohľadu na polohu pointra:

```plain
0TT
```

O kombách neskôr, zatiaľ to použime ako zaklínadlo! 

`C` — character move – pohyb po znakoch
----------------------

Príkaz `C` hýbe pointerom po ~~páske~~ ~~bufferi~~ súbore. Ak chceme pointer posunúť o jeden znak doprava:

```plain
C
```

Zrazu máme kurzor medzi indexami 0 a 1, inak povedané, v ukážke medzi písmenami `S` a `o`:

```plain
S|om Ozymandias, vsetkych kralov kral.
```

To si môžeme overiť:

- `.=` vráti `1`
- `T` vráti `om Ozymandias, vsetkych kralov kral.`, pretože vypisujeme od pointra (index 1) do konca riadka.

### Parametre príkazu

TECO má minimalistické názvy príkazov,  ale ako vraví Ján Pavol II, nebojme sa. Ide o úplne normálne funkcie, dokonca s parametrami!

* Parametre pred názvom berú polohu, alebo rozsah polohy, na ktorú sa príkaz použije.
* Parametre za názvom sú reťazce. Napríklad vkladaný text, hľadaný text, nahrádzaný text. (Okrem registrov, tam je to naopak.)

### Parametre `C`

Príkaz `C` berie počet znakov, o ktoré sa máme pohnúť doprava. Napr. `1C` posunie pointer o jeden znak doprava. Posun a výpis, aha:

```plain
*1C$$
*T$$
om Ozymandias, vsetkych kralov kral.
```

Posúvať sa môžeme aj doľava, cez záporné indexy! `-1C` posunie pointer o mínus jeden znak doprava. Teda o jeden znak doľava.

```plain
*-1C$$
*T$$
Som Ozymandias, vsetkych kralov kral.
```

Plus jedna a mínus jedna sú zabudované. `C` znamená automaticky `1C` a `-C` znamená `-1C`.

`J` — jump – skok na index
-------------------

`J` ako **jump** skočí na konkrétny index. 

### Skok na začiatok

Napríklad skok pointrom na začiatok buffera?

```plain
0J
```

Skok počiatkový je taký bežný, že má skratku:

```plain
J
```

Skok pred tretí znak?

```plain
3J
```

### Skok na koniec

Skok na koniec buffera vyriešime kúzlom:

```plain
ZJ
```

#### `Z` — index konca buffera

Príkaz `Z` vracia index konca buffera. A samozrejme, výsledok použime ako parameter pre *jump*! Normálny zápis v normálnom jazyku by vyzeral:

```plain
jump(endOfBufferIndex())
```

Ale normálne jazyky neboli vynájdené!

### Konce riadkov sú dva riadky!

Pozor na to, že konce riadkov sú dva znaky: `CR` a `LF`! Index konca bufferu tak môže byť väčšie číslo než je dĺžka súboru v Linuxe!

Funkcie pre indexy
------------------

TECO má tri základné funkcie pre vyhodnotenie indexov:

- `Z`: vráti index konca buffera (obvykle súboru). Mnemotechnicky: `Z` je posledné písmeno abecedy a posledný index súboru!
- `0`: vráti index začiatku buffera (wow!)
- `B`: vráti index začiatku buffera. Mnemotechnicky: `B` ako *begin*.
- `.` : bodka vráti index pointra. Tu už vidno, že `.=` je príkaz `=`  s parametrom „aktuálny index pointra“.

## `L` — line move – posun po riadkoch

Posun zo začiatku na ďalší riadok?

```plain
L
```

Ak sme na začiatku buffera, posunieme sa o riadok ďalej a pointer sa posunie *za* prvý `CR-LF`.

Overme si to výpisom:

```plain
T
```

Uvidíme výpis od aktuálneho pointera do konca riadku, teda `Hlad, mocny, zufaj, vidiac moje dielo!`.

### Posun o viacero riadkov

Posúvať sa môžeme dopredu i dozadu. Napríklad posun o dva riadky dopredu:

```plain
2L
```

## `I` – insert – vkladanie textu

Príkaz `I` (**insert**) vkladá text pod pointer.

Berie jeden parameter a to *text*, čo sa má vložiť. Tento parameter však nejde *pred* príkaz (nie je to poloha), ale *za* príkaz.

Ak sa nachádzame na začiatku buffera a chceme vložiť dekoračnú čiaru, použime:

-  `I` s parametrom `--------------------`, 
- následne odENTERujeme 
- a následne ukončíme príkaz cez `Esc`, `Esc`, 

Vložíme na začiatok buffera nový riadok:

```plain
I--------------------<enter>$$
```

Súbor si vypíšme klasickým `HT`.

Celý *session* vyzerá potom nasledovne:

```
*I--------------
$$
*HT$$
--------------
Som Ozymandias, vsetkych kralov kral.
Hlad, mocny, zufaj, vidiac moje dielo!
 --Percy Bysshe Shelley: Ozymandias (1818)
 *
```

`K` — kill – mazanie textu
-------------------

Príkaz `K` (**kill**) maže riadok od pointera po najbližší koniec riadka (vrátane). Ak chceme zmazať prvý riadok:

```plain
J$$
K$$
HT
```

- `J` presunieme sa na začiatok buffera
- `K` vymaže od začiatku buffera po najbližší `CR`-`LF` (vrátane)
- a overíme si výpisom.

Príkaz berie aj parametre. Ak chceme vymazať od pointra, dva riadky, stačí `2K`.

### Hardcore Combo

Príkazy môžeme aj spájať do kombinácii. Napríklad `JKHT`. Podrobnosti nižšie.

`D` – delete – mazanie znakov
--------------------

Ak chceme mazať znaky, `D` maže jeden znak napravo od pointera.

Prvý znak buffera von!

```plain
J$$
D
```

`D` berie parametre, takže `3D` nie je trojrozmerné TECO, ale mazanie troch znakov napravo od pointera.

Mínusové argumenty mažú naľavo! `-5D` zmaže päť znakov naľavo od pointra.

Hardcore Combo
--------------

`JD` nie je *Jack Daniels*, ale kombo na mazanie prvého znaku buffera.

Intermezzo
==========

V tomto stave je súbor zrejme rozdrbaný tak, že je najlepšie skončiť a začať nanovo. 

Teda

```plain
Ctrl-C
Ctrl-C
teco
EBozymandias.txt$$
Y$$
HT$$
```

Druhé dejstvo – kombá
=====================

TECO je v skutočnosti arkádovka: vľavo pisár, vpravo súbor, a kombá nakladajú do súboru, čo sa zmestí.

Príkazy môžu rovno nasledovať za sebou a ukončia sa **Esc/Esc**.

Dajme si prípravu, kde sekerou rozporcujeme Shelleyho jambický pentameter na päť riadkov a jeden prázdny na konci:

```plain
Som Ozymandias, 
vsetkych kralov kral.
Hlad, mocny, 
zufaj, 
vidiac moje dielo!

```

Pre Linux/Mac to vyzerá:

```
0000000   123 157 155 040 117 172 171 155 141 156 144 151 141 163 054 040
           S   o   m       O   z   y   m   a   n   d   i   a   s   ,
0000020   012 166 163 145 164 153 171 143 150 040 153 162 141 154 157 166
          \n   v   s   e   t   k   y   c   h       k   r   a   l   o   v
0000040   040 153 162 141 154 056 012 110 154 141 144 054 040 155 157 143
               k   r   a   l   .  \n   H   l   a   d   ,       m   o   c
0000060   156 171 054 040 012 172 165 146 141 152 054 040 012 166 151 144
           n   y   ,      \n   z   u   f   a   j   ,      \n   v   i   d
0000100   151 141 143 040 155 157 152 145 040 144 151 145 154 157 041 012
           i   a   c       m   o   j   e       d   i   e   l   o   !  \n
0000120
```

Pre TECO to však vyzerá s CR-LF:

```
Som Ozymandias,<CR><LF>
vsetkych kralov kral.<CR><LF>
Hlad, mocny,<CR><LF>
zufaj,<CR><LF>
vidiac moje dielo!<CR><LF>
```

A teraz kombo tajm!

Mazanie posledného riadku
-------------------------

```plain
ZJ-LK$$
```

* `ZJ` nás hodí na koniec buffera:
  *  `J` skáče, 
  * `Z` je parameter skoku zvaný „na koniec buffera“. Kurzor sa ocitne na úplnom konci, za posledným prázdnym riadkom.
* `-L` nás posunie o riadok vyššie, teda pred `vidiac moje dielo!`.
* `K` maže celý aktuálny riadok.

Poďme hrať TECO golf! Ušetrime jeden znak:

```plain
ZJ-K$$
```

- `ZJ` nás hodí na koniec buffera: `J` skáče, `Z` je parameter skoku zvaný „na koniec buffera“
- `-K` maže celý predošlý riadok. `K` killuje, mínus hovorí „jeden riadok naľavo“.

Vtip do prestávky
-----------------

> Zistilo sa, že postupnosť príkazov v editore TECO sa podobá viac šumu v prenosovej linke než čitateľnému textu [4]. Jedna z tých zábavnejších kratochvíľ, ktoré môžete zažiť s TECOm, je zadávanie svojho mena do príkazového riadku a hádanie, čo sa stane. 
>
> — [Praví programátori nepoužívajú Pascal](http://ics.upjs.sk/~novotnyr/blog/1240/pravi-programatori-nepouzivaju-pascal), 1983

Prepisovanie textu
------------------

TECO nepodporuje prepisovanie textu. Ale vieme mazať a vkladať!

Zmeňme `Som` na začiatku buffera na `som`.

```plain
JDIs$$
```

- `J` skáče na začiatok buffera.
- `D` zmaže znak napravo od pointera. Získame `om Ozymandias,`. Pointer stojí medzi začiatkom buffera a `o`.
- `Is` vloží znak `s` (es) napravo od pointera. Získame `som ozymandias`. Kurzor bude medzi `s` a `o`.

## Nejednoznačnosti v kombách

Nejednoznačnosti vieme vyriešiť voľne pohodeným `Esc`. Napríklad `I` (Insert) potrebuje oddeliť vkladaný text od nasledujúcich príkazov.

```plain
ID$-C$$
```

Vložíme `D` a posunieme sa o znak doľava. **Esc** zabráni vloženiu reťazca „dé mínus cé“.

Výpis celého aktuálneho riadku: `T`
-----------------------------------

Niekedy sa pointer ocitne uprostred riadku. Napríklad po poslednom príklade:

```plain
.=$$
```

Výsledok bude 1.

Ak vypíšeme riadok cez `T`, získame text od pointera do konca riadka, takže `om ozymandias`. Kde je `S`?

Kombináciou dvoch príkazov vypíšeme celý aktuálny riadok:

```plain
0TT
```

- `0T` vypíše obsah od začiatku riadku po pointer.
- `T` vypíše od pointra po koniec riadku.

`S` – search – vyhľadávanie 
----------------------------

TECO vie vyhľadávať! `S` berie jeden argument s textom, ktorý sa má hľadať:

```plain
Skral$$
```

TECO nájde reťazec a postaví pointer za hľadaný text. 

Ak sa pozrieme navôkol, kurzor bude za prvým výskytom reťazca `kral`:

```
*T$$
ov kral.
```

`FS` – find / substitute – vyhľadávanie a nahrádzanie
-----------------------------------------------------

`FS` má dva parametre oddelené **Esc**: *čo* hľadať a *čím* nahradiť.

```plain
FSOzymandias$Ozzy$$
```

Po nahradení sa kurzor objaví za nahradeným textom. 

Pozor, hľadá sa od aktuálnej pozície kurzora! Ak sme práve skončili príkaz s vyhľadávaním, radšej skočme na začiatok súboru.

`EX` – ukončenie a zápis zmien
------------------------------

Príkaz `EX` zapíše zmeny a ukončí trápenie.

Tretie dejstvo: programovanie a.k.a. Brainfuck Time
===================================================

V TECO sa dá programovať! TECO je turingovsky úplný jazyk!

`=` – vyhodnocovanie výrazov
----------------------------

Príkaz `=` v skutočnosti vyhodnocuje výrazy!

```plain
2+2*4=$$
```

Výsledok je .. 16! TECO sa netrápi s prioritou operátorov (tie neboli vynájdené). Kto chce, uzátvorkuje si!

A pozor, medzery vo výrazoch sa nesmú používať. (Teda smú, nahrádzajú sa `+`. Bol to vraj vtedy dobrý nápad.)

Funkcie pre polohu
------------------

Doteraz sme videli viacero funkcií, ktoré vracali polohu:

- `0` vráti nultý index.
- `.` vráti index pointera
- `B` (*beginning*) vráti index na začiatku buffera
- `Z` (posledné písmeno abecedy) vráti index konca buffera
- `H` (*wHole*) vráti usporiadanú dvojicu (*0*, *index konca súboru*)

To sa dá kombinovať! A to je dôvod, prečo:

- `.=` vypíše aktuálnu polohu. Aktuálna poloha je vyhodnotená ako výraz.
- `HT` vypíše celý súbor. Usporiadaná dvojica z `H` je použitá ako rozsah pre výpis `T`

Opakovania a cykly
------------------

TECO podporuje opakovania! Chceme vložiť na začiatok buffera dvadsať pomlčiek?

```plain
J$5<I-$>$$
```

- `J` skočí na začiatok buffera
- `5<I-$>`
  - `5` určuje počet iterácií.
  - `<`…`>` obsahujú kód, ktorý sa má vykonať.
    - pomocou `I` vložíme pomlčku `-` a príkaz ukončíme **Esc**
- **Esc Esc** vykoná program.

Masové nahrádzanie
------------------

Opakovanie sa dá použiť pri masovom nahrádzaní! Chceme v celom súbore nahradiť `m` za `n`?

```plain
J<FSm$n$;>$$
```

- `J` skáče na začiatok buffera.
- `<`…`>` obsahuje cyklus. Keďže nemáme počet opakovaní, máme prakticky `while`.
- `FS` nahrádza:
  - `m` je nahrádzaný text
  - `$` je oddeľovač parametra pre `FS`
  - `n` je nahradený text
  - `$` je oddeľovač druhého parametra
- bodkočiarka `;` je `break`. Presnejšie, ukončí cyklus, ak predošlý príkaz zlyhal. V prípade, že sa už nenájde v texte žiadne `m`, príkaz `FS` zlyhá a bodkočiarka vyskočí z cyklu.

---

Q-Registre – premenné
--------------------

TECO nemá premenné. Namiesto toho má **Q-registre**, čo je 36 chlievikov od *á* po *zet*  a od nuly po 9. Každý chlievik **Q-register** môže obsahovať reťazec a nezávisle od toho číslo. 

Prečo `Q`? Lebo toto písmeno ostalo nepoužité.

### `U` – vkladanie čísla do registra

Príkaz `U` vloží číslo do registra. Má dva parametre 1) vkladané číslo a 2) meno registra.

Vložme dvadsať do nultého registra:

```plain
20U0$$
```

### `Q` – výber čísla z registra

`Q` je „funkcia“ pre výber čísla z registra. Ak chceme vypísať obsah, dáme kombo s `=`!

```plain
Q0=$$
```

### `%` – inkrementácia čísla v registri

Ak chceme zvýšiť číslo v registri o 1:

```plain
%0$$
```

Registre pre cyklus `for`
-------------------------

Teraz si môžeme vypísať čísla od 1 po 5!

```plain
5<%0$Q0=>$$
```

- `5` určuje počet opakovaní
- `<`…`>` je kód cyklu
  - `%0` zvýši hodnotu v nultom registri o 1
  - `$` je oddeľovač príkazov v cykle
  - `Q0=` vypíše obsah nultého registra. Presnejšie `Q0` vráti obsah nultého registra a použije ho ako argument pre `=`
- **Esc Esc** ukončí príkaz

Máme už dosť?

Komentáre: Video mód
====================

Niektoré moderné beštie TECO majú video mód. Napríklad verzia z GitHubu vie zapnúť režim nasledovne:

```plain
 ./teco -scroll:5
```

Obrazovka sa rozdelí na dve časti: 

1. spodných 5 riadkov je editor príkazov
2. zvyšok hore zobrazuje text. Pointer je zvýraznený, ale pozor, na obrazovke nevieme vykresliť kurzor medzi znakmi, preto je vždy na znaku napravo od skutočného pointera.

Komentáre: stránkovanie
=======================

TECO v skutočnosti funguje na stránkach (*page*). Očividne to šetrí pamäť. Stránka je kus súboru oddelený znakom `^L `(`FF`, form feed, ASCII 12, resp. HEX 0xC).

Všetky príkazy pre polohu operujú na jednej stránke, a príkaz `P` posúva editor na nasledovnú stránku.

Zaveďte si do textového editora ^L a prekvapte svoj Word!

História
========

Všetci hovoria, že názov je skratka od „Text Editor and COrrector“, ale Dan Murphy vie, že pravda je inde: ide o „Tape Editor and Corrector“.

V roku 1962 bola doba ťažká, pretože v duchu [štyroch Yorkšírčanov](https://www.youtube.com/watch?v=ue7wM0QC5LE) „nemali sme pevné disky, pružné disky, magnetické pásky, ani siete. Nemali sme ani operačný systém. Mali sme len čítačku papierovej pásky, dierkovač a konzolový písací stroj“ (Dan Murphy, [The Beginnings of TECO, 2009](http://tenex.opost.com/anhc-31-4-anec.pdf))

TECO vzniklo ako pomocný nástroj na korektorské zásahy pri kopírovaní a úprave pásky. Všetky hardcore vlastnosti vyplynuli z okolností: pamäte bolo málo (PDP-1 malo ledva 8kB), strojový čas bol obmedzený a legendárne jednopísmenové príkazy boli inšpirované debuggerom [https://www.computerhistory.org/pdp-1/_media/pdf/DEC.pdp_1.1964.102650078.pdf](https://www.computerhistory.org/pdp-1/_media/pdf/DEC.pdp_1.1964.102650078.pdf).

Napriek tomu TECO predbehlo dobu, veď ostatné editory prišli o mnoho rokov neskôr. 

- `ed`, ktorý bol *riadkovo orientovaným* sa zjavil až v roku 1969
- `vi` , *vizuálny editor* dorazil až v roku 1976
- a **EMACS**, skrátene z *Editor Macros* vznikol ako sada makier pre … TECO.

Literatúra
==========

Binárky a zdrojáky
------------------

* [almy.us/teco.us](http://almy.us/teco.html) – zelený web s odkazmi na binárky pre rozličné súčasné platformy.
* GitHub repo [blakemcbride/TECOC](https://github.com/blakemcbride/TECOC): céčkové zdrojáky skompilovateľné aj na platformách 21. storočia. Obsahujú aj videomód!

Dokumentácia
------------

* [Survival TECO](https://sdfeu.org/w/tutorials:survival-teco) – ťaháčik s príkazmi
* [Video TECO User’s Guide](http://www.copters.com/teco.html) – vyčerpávajúci popis príkazov s parametrami
* [TECO Pocket Guide](https://web.archive.org/web/20061020201751/http://www.avanthar.com/~healyzh/teco/TecoPocketGuide.html#NOTATION) – príručka mladého svišťa so sumárom príkazov. Od autorov DEC PDP-11!
* [TECO Editing, A Tutorial Course](http://bitsavers.informatik.uni-stuttgart.de/www.computer.museum.uq.edu.au/pdf/MNT-16%20TECO%20Editing%20-%20A%20Tutorial%20Course%20for%20PDP-10%20and%20PDP-11%20Users.pdf) – sken tutoriálu pre PDP-11, z roku 1978!

Ľudia a zážitky
---------------

- [**TecoEditor**](http://wiki.c2.com/?TecoEditor) na Wiki.C2.com
- Dan Murphy, autor TECO,  a jeho [domovská stránka](http://www.opost.com/dlm/#teco). Dal si PhD z psychológie!
- [*The Beginnings of TECO*](http://tenex.opost.com/anhc-31-4-anec.pdf), spomienky Dana Murphyho na vznik editora
- [*World’s Greatest Pathological Languages: TECO*](https://scienceblogs.com/goodmath/2006/09/22/worlds-greatest-pathological-l-1)



