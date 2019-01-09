---
title: "Tri veci pri práci s adresármi v termináli, ktoré robíte zle"
date: 2019-01-08T07:44:08+01:00
---

Trojica `ls`, `find` a `grep` sa v linuxovom termináli používa každý deň. Nie vždy sú však pohodlné, veď poniektoré nástroje majú azda aj 50 rokov. Ukážme si moderné alternatívy pre nové milénium!

- [`exa`](https://the.exa.website/) namiesto `ls`
- [`fd`](https://github.com/sharkdp/fd) namiesto `find`
- [`ag`](https://github.com/ggreer/the_silver_searcher) namiesto `find` / `grep`

Všetky nástroje fungujú krížom cez linuxové distribúcie i na MacOS.

`exa` - výpis adresára pre moderných ľudí
=========================================

```
brew install exa
```

![Príkaz `exa`](/assets/tri-veci-pri-praci-s-adresarmi-ktore-robite-zle-exa-fd-ag/exa.png)

Príkaz `exa` je ako `ls`, ibaže je

- farebný
- podporuje dynamické šírky okna
- podporuje Git
- a milión serepetičiek

V jednoduchých prípadoch sa `exa` tvári ako `ls`:

```
> exa
1.txt  2.txt  3.txt  4.txt  5.txt  6.txt  7.txt  8.txt  9.txt  10.txt
```

Okrem toho podporuje klasické kombinácie z `ls`:

- `-l` (alebo `—long`) zapne stĺpcový dlhý výpis
- `-a` (alebo `-all`) vypíše všetky -- aj skryté súbory

```
> exa -la
drwxr-xr-x  - novotnyr  7 Jan 16:17 .git
.rw-r--r-- 11 novotnyr  7 Jan 17:17 1.txt
.rw-r--r--  0 novotnyr  7 Jan 16:15 2.txt
.rw-r--r--  0 novotnyr  7 Jan 16:15 3.txt
.rw-r--r-- 32 novotnyr  7 Jan 17:17 4.txt
```

Okrem toho podporuje `exa` aj špeci stĺpček pre `git`:

```
> exa -l --git
.rw-r--r-- 11 novotnyr  7 Jan 17:17 -M 1.txt
.rw-r--r--  0 novotnyr  7 Jan 16:15 -- 2.txt
.rw-r--r--  0 novotnyr  7 Jan 16:15 -- 3.txt
.rw-r--r-- 32 novotnyr  7 Jan 17:17 -M 4.txt
```

Vidíme, že súbory `1.txt` a `4.txt` sú zmodifikované, ale nekomitnuté.

### Stromy

`exa` podporuje aj stromový výpis:

```
> exa --tree
.
├── 1.txt
├── 2.txt
├── 3.txt
├── 4.txt
└── children
   ├── one.txt
   └── two.twt
```

### Ďalšie vlastnosti

K dispozícíi sú estetické vlastnosti:

* výpis skupiny používateľa (*group*) cez `-g`
* výpis estetickej hlavičky stĺpcov cez`-h`
* ISO formát pre modifikáciu súboru (*mtime*) cez `—time-style`

```
> exa -lag --git -h --time-style=full-iso
Permissions Size User     Group Date Modified                       Git Name
drwxr-xr-x     - novotnyr wheel 2019-01-07 16:17:31.996454614 +0100  -- .git
.rw-r--r--    11 novotnyr wheel 2019-01-07 17:17:25.458001899 +0100  -M 1.txt
.rw-r--r--     0 novotnyr wheel 2019-01-07 16:15:36.535003675 +0100  -- 2.txt
.rw-r--r--     0 novotnyr wheel 2019-01-07 16:15:36.536635284 +0100  -- 3.txt
.rw-r--r--    32 novotnyr wheel 2019-01-07 17:17:34.563047197 +0100  -M 4.txt
drwxr-xr-x     - novotnyr wheel 2019-01-07 17:27:39.019907496 +0100  -N children
```

Okrem toho môžeme filtrovať a triediť podľa ľubovoľnej vlastnosti súboru (napr. podľa prípony), či prezerať skryté atribúty súborov (*xattr*).

`fd` - vyhľadávanie súborov pre 21. storočie
============================================

```
brew install fd
```

[`fd`](https://github.com/sharkdp/fd) je `find`, ale

* dáva o 50% menej úderov klávesov pri bežných operáciách!
* až 9krát vyššia rýchlosť vyhľadávnia
* až 256 krát viac fareb!
* Git je automaticky podporovaný
* “nájdi a vykonaj” má civilizovaný zápis

![Príkaz `fd`](/assets/tri-veci-pri-praci-s-adresarmi-ktore-robite-zle-exa-fd-ag/fd.png)

`fd` pre všetko
---------------

Jednoduchý `fd` vypíše celý podstrom adresárov a súborov:

```
> fd
1.txt
2.txt
3.txt
4.txt
children
children/one.txt
children/two.txt
children/1.txt
children/2.txt
```

`fd` a vyhľadávanie
-------------------

fd` automaticky hľadá podľa regulárneho výrazu:

```
> fd 1.txt
1.txt
children/1.txt
```

Ba dokonca podľa poriadného regulárneho výrazu:

```
> fd '^[12]'
1.txt
2.txt
children/1.txt
children/2.txt
```

Vyhľadávanie:

- automaticky rešpektuje záznamy v `.gitignore` (ak nie je vypnuté cez `-I`)
- automaticky ignoruje skryté súbory (ale možno vypnúť cez `-H`),
- vyhľadávanie inteligentne zapne podporu pre veľké/malé písmená!

Obľúbené parametre sú:

* `-e` hľadá podľa prípony. Napr. `fd -e txt` nájde všetky texťáky!
* `-t` pre múdre vyhľadávanie adresárov (`d`), riadnych súborov (`f`), ale aj symlinkov (`l), či spustiteľných súborov (`x`)

`fd` a spracovanie súborov
--------------------------

`find`/`exec` a `find` / `xargs` sú zbytočné! 

Spočítanie riadkov vo všetkých texťákoch je jednoduché:

```
fd -e txt -x wc -l
```

`fd` automaticky spustí `wc` pre každý nájdený súbor. Cestu pre každý súbor použije ako argument spúšťaného príkazu. Mňam!

Spracovávanie beží automaticky na viacerých vláknach, presne ako v `GNU Parallel`!

Prevod súborov na HTML cez `pandoc`?

```
fd -e txt -x pandoc {} -o {.}.html
```

Nájdené súbory sa ocitnú v špeciálnych premenných:

* `{}` je relatívna cesta k nájdenému súboru: `children/2.txt`
* `{.}` je relatívna cesta k súboru, ale bez prípony: `children/2`, čo je skvelé na premenovávanie a konverzie!  

`ag` — hľadanie v súboroch rýchlosťou blesku
============================================

```
brew install the_silver_searcher
```

`ag` vyhľadáva v obsahoch súborov. Oproti `find` / `exec` / `grep` má:

- o 72.5% kratšie zápisy pre bežné operácie!
- rozkošné farby - až 256 farebných kombinácií!
- o mnoho percent rýchlejší a paralelnejší — vyhľadávanie beží na viacerých vláknach!
- podporuje Git!

![Príkaz `ag`](/assets/tri-veci-pri-praci-s-adresarmi-ktore-robite-zle-exa-fd-ag/ag.png)

```
> ag hello
4.txt
1:Chapter 4: Hello World Revisited

1.txt
1:Hello World

hello.markdown
3:    echo hello-world
```

`ag` hľadal a našiel tri výskyty reťazca `hello` a všetky farebne zvýraznil! Vyhľadávanie automaticky zapína, či vypína VEĽKÉ a malé písmená a podporuje regulárne výrazy:

Hľadanie na začiatku riadku?

```
ag '^hello'
```

Vyhľadávať sa dá aj v konkrétnom adresári:

```
ag hello ./children
```

Podpora existuje aj pre vyhľadávanie súborov, ktoré obsahujú reťazec a namiesto zvýrazneného obsahu stačí vypísať ich názvy:

```
ag -l hello
```

`ag` podporuje aj vyhľadávanie v sadách súborov! Hľadanie v `markdown`och?

```
ag hello --markdown
```

