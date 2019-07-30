---
title: Softvérový projekt (UINF/PRJ1a) – 2010
date: 2010-02-22T18:04:46+01:00
year: 2009/2010
course: UINF/PRJ1a
---

# Harmonogram
* pondelok, 11.40, P3
* streda, 8.00, P7

# Kalendár prednášok zabezpečovaných RWE

## Agile/Scrum (R. Šoffa)
- Dátum:  22.2.2010
- [Prezentácia PPT](RWEScrum.ppt )

## Projektový manažment (J. Vojtko)
- Dátum: 8.3.2010
- [Prezentácia PDF](Uvod do projektoveho manazmentu.pdf )

## JavaServer Faces (R. Šoffa)
- Dátum: 29.3.2010

## Testovanie (J. Vojtko)
- Dátum: 12.4.2010

# Zoznam projektov

* [Prekladový kľúč](http://s.ics.upjs.sk/~greslik/wiki/pmwiki.php?n=Informatika.Softv%C3%A9rov%C3%BDProjektPrekladov%C3%BDK%C4%BE%C3%BA%C4%8D )
	* http://repo.ics.upjs.sk/svn/sw-projekty-2010/kluc/
* [ITAT - účastníci konferencie](http://s.ics.upjs.sk/~sinal/wiki/ )
	* http://repo.ics.upjs.sk/svn/sw-projekty-2010/itat/
* [Elektronické študijné materiály](http://s.ics.upjs.sk/~gamcik/wiki/pmwiki.php )
* [Multimed](http://s.ics.upjs.sk/~gamcik/wiki/pmwiki.php)
	* http://repo.ics.upjs.sk/svn/sw-projekty-2010/multimed/
* [Online Poker](http://s.ics.upjs.sk/~piatnicova/wiki/pmwiki.php)
	* http://repo.ics.upjs.sk/svn/sw-projekty-2010/poker/

# Cvičenie 1 (15. 2. 2010)
Dohovor a organizačné pokyny

# Cvičenie 2 (17. 2. 2010)
* Výber projektov
* Projektová dokumentácia, inštalácia PmWiki

Úloha: nainštalovať a otestovať PmWiki. Vytvoriť projektovú stránku, a zaslať mailom meno projektu, odkaz na projektovú stránku a zoznam jeho riešiteľov.

Nastavenie kódovania: do `local/config.php` uviesť 
```
$Charset="windows-1250";
```

Nastavenie hesla: do `local/config.php` uviesť 
```
$DefaultPasswords['admin'] = crypt('heslo');
$DefaultPasswords['edit'] = crypt('heslo');
```
# Cvičenie 2 (22. 2. 2010)
Projektový manažment (prednáška, realizuje Mgr. Šoffa [RWE]).

# Cvičenie 3 (2. 2. 2010)
Používateľské požiadavky. Zber používateľských požiadaviek.

# Cvičenie 6 (8. 3. 2010)
Projektový manažment (prednáška, realizuje Ing. Vojtko [RWE]).

# Cvičenie 7 (10. 3. 2010)
Úložiská zdrojových kódov - CVS, SVN.

[Prezentácia PDF](svn-zdielanie-suborov-v-time.pdf)

# Cvičenie ? (22. 3. 2010)
Use-cases

[Prezentácia PDF](use-cases.pdf)

# Požiadavky na hodnotenie
Dokument obsahujúci:

* názov projektu, riešitelia
* používateľské požiadavky
* prehľad existujúcich riešení. Diskusia k minimálne dvom existujúcim riešeniam. Porovnanie vlastností, komentár k absentujúcim vlastnostiam, zdôvodnenie, prečo nemožno použiť existujúce riešenie.
* use-case (používateľské scenáre). Minimálne 5 úplných scenárov. Jeden sumárny UC diagram. Minimálne 3 diagramy názorne popisujúce jednotlivé UC (zvoľte typ diagramu podľa uváženia)
* výber technológií. Prehľad a zdôvodnenie možných technológií, výber jednej z nich.
* návrh modulov a popis ich funkcionality a prepojenia. Ak používate OOP jazyk, modulu zodpovedá sada tried. V opačnom prípade je modul sada funkcií. Moduly znázornite vo vhodnom diagrame (napr. diagrame tried)
* návrh databázovej štruktúry + entitno-relačný diagram.

Dokument bude prezentovaný jednotlivými tímami v posledný týždeň semestra (prezentácia rádovo 20 minút).
