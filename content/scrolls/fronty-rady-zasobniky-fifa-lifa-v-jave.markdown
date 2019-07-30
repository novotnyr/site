---
title: Fronty, rady, zásobníky, fifá, lifá... v Jave
wpid: 395
date: 2012-06-29T22:10:01+01:00
tags: 
- dátové štruktúry
- front 
- Java 
- rad 
- zásobník
categories:
- Java
- programovanie
---

Zásobníky a rady nie sú práve najčastejšie používanou dátovou štruktúrou Java aplikácií, ale z času na čas dôjde na i na ne. Ako ich elegantne a ľahko použiť bez toho, aby sme zabili kopu času ich reimplementáciou? <!--more-->

Rekapitulácia
==============
Zrekapitulujme si terminológiu:

* **zásobník** a.k.a. _stack_ a.k.a. _LIFO_ je nafukovací zoznam, kde elementy možno vkladať a vyberať len z jedného konca (vrcholu zásobníka). Krásny príklad je hŕba tanierov: tanier možno položiť len na iný tanier. Ak chceme vybrať tanier zo spodku zásobníka, musíme vybrať najprv všetky taniere nad ním. Je to teda filozofia „posledný dnu, prvý von”´, čiže zmienené _last in-first out_.
* **rad** a.k.a. _front_ (a. k. a. nespisovne fronta) a.k.a. _FIFO_ je zoznam, kde prvky pcháme na jeden koniec a vyberáme z opačného konca. Príklad: front na mäso. Prichádzajúci sa radia na koniec frontu a odchádzajú z jeho začiatku: v opačnom prípade nastane hádka, krik a ruvačka. FIFO analogicky vychádza z _first in-first out_, čiže kto prv príde, ten prv odchádza s mäsom.

Implementácie v Jave
====================
Neopovážte sa implementovať rad a zásobník po svojom! (Pokiaľ fakt neviete, čo robíte.) 

K dispozícii je totiž pestrá paleta tried pre obe situácie.

Starý dobrý `java.util.Stack`
-----------------------------
Rýchle prehľadanie tried odhalí triedu [`java.util.Stack`](http://docs.oracle.com/javase/6/docs/api/java/util/Stack.html). Táto trieda je s nami od čias Javy 1.0. (Kto neverí, nech pozrie [do praJavadocu](http://www.aquaphoenix.com/ref/jdk1.0.2_api/java.util.Stack.html).) Z dnešného pohľadu je táto trieda, slušne povedané, svojská, ale v tých časoch vývojári azda ani netušili, čo sa z Javy vykľuje. (Našťastie existuje jej krajšia verzia.)

K dispozícii sú predovšetkým klasické metódy:

* `push()` vloží prvok na vrchol zásobníka. Ako bonus vráti aktuálne vložený prvok, čo sa málokedy používa, ale nejaký rozumný dôvod za touto voľbou sa nepochybne nájde.
* `pop()` nie je názov pravoslávneho kňaza, ale metóda, ktorá vráti objekt na vrchole zásobníka a zároveň ho zo zásobníka vyhodí. V prípade prázdneho zásobníka sa metóda správa pozoruhodne: oblaží nás výnimkou [`EmptyStackException`](http://docs.oracle.com/javase/6/docs/api/java/util/EmptyStackException.html). S odstupom času to možno nebola najšťastnejšia voľba -- vyžaduje to totiž `try`-`catch`ovanie, ale v tejto triede s tým veľa neurobíme. Ak vás to otravuje, použite `Deque` (deku ;-)), ale o tom o chvíľu.
* `peek()` je slabšia forma `pop()`a: vráti objekt z vrcholu zásobníka bez toho, aby ho zo zásobníka vyhodila. Platí to isté čo pre predošlú metódu: `peek()`ovanie z prázdneho zásobníka vyhodí [`EmptyStackException`](http://docs.oracle.com/javase/6/docs/api/java/util/EmptyStackException.html).
* `empty()` zistí, či je zásobník prázdny. Ak predošlé metódy hádžu výnimku, znamená to, že korektné používanie zásobníka evokuje pri každom vyberaní nutnosť testovať prázdnosť a až keď sa ukáže, že nejaké dáta v ňom predsa len sú, môžeme korektne `peek()`/`pop()`ovať.
* `search()` vráti pozíciu elementu od vrcholu zásobníka. Ale pozor: pozícia je indexovaná od jednotky (na rozdiel od „tradičného” indexovania od nuly).

		#!java
		Stack<String> zásobník = new Stack<String>();
		zásobník.push("Java");
		int pozícia = zásobník.search("Java");
		System.out.println(pozícia); // 1

Ešte podrobnejší pohľad na `java.util.Stack` ukáže kúzelnú dedičnosť

	public class Stack extends java.util.Vector

Rozhodne to nie je učebnicový príklad dedičnosti: `Vector` je prakticky ekvivalent `ArrayListu` a overenie starých materí _„Je každý zásobník zoznamom založeným na poli?”_ jednoducho nefunguje. Poburovanie však je pomerne zbytočné: je to daň Javy 1.0, kde finty typu `LinkedList` ešte neexistovali.

Tak či onak, `Stack` zdedí všetky `vector`ovské metódy: môžete radostne pridávať doprostred zoznamu, mazať, hľadať, atď... akurát, že nie vždy to má celkom logický zmysel. 

Pri vymýšľaní _Java Collections Framework_ sa síce udiali s touto triedou niektoré pozitívne zmeny, ale veľa sa toho už zachrániť nedalo.

Jeden rozumný bočný efekt `Stack`u spočíva v _thread-safety_ (vláknovej bezpečnosti) triedy. Keďže `Vector` je thread-safe, je takým aj zásobník... i keď i v tomto prípade už existujú oveľa lepšie a efektívnejšie kolekcie.

Vyčkajte chvíľu, rozoberieme si rad a k zásobníku sa ešte vrátime.

Rad `java.util.Queue`
------------------------
V Javách pred verziou 5 by ste márne hľadali triedu pre rad -- neostávalo vám nič iné, než zneužiť na to niektorý z klasických zoznamov. Po upratovaní v Jave päť vznikol interfejs [`java.util.Queue`](http://docs.oracle.com/javase/6/docs/api/java/util/Queue.html) (nemenovaným známym vyslovovaným ako _kveve_, ale neradím vám po ňom opakovať). Ten rozširuje interfejs `java.util.Collection` o 6 metód. V skutočnosti ide o tri páry metód pre štandardné operácie vkladania, vyberania a nakúkania na začiatok radu. (Táto duplicita adresuje `Stack`ovský problém pri manipulácii s prázdnym stackom.) 

Ešte spomeniem drobné terminologické ujasnenie: _hlava_ (_head_) radu je začiatok (z ktorého sa odoberajú prvky) a _chvost_ (_tail_) je koniec, kam sa pridáva.

### Pridávanie
* `add()` pridá prvok na koniec radu a vráti `true` ak sa prvok skutočne pridal. (Táto metóda prakticky prekrýva rodičovskú metódu z `Collection`.)
 Metóda môže vyhodiť `IllegalStateException` v prípade, že pridanie presiahne kapacitné možnosti radu. 
* `offer()` prekvapivo tiež pridáva prvky. Na rozdiel od klasického pridávania však táto metóda nebude vyhadzovať výnimky o nesprávnom stave: ak sa prvok nevie vložiť kvôli kapacitným možnostiam, vráti `false`.

Obe metódy však môžu vyhodiť `NullPointerException` pri pokuse vložiť `null` do radu, ktorý takéto elementy nepodporuje; a tiež môže otrieskať používateľovi o hlavu `IllegalArgumentException`, ak sa element nepodarí vložiť kvôli iným špecifickým obmedzeniam implementácie radu.

### Odoberanie
Opäť máme dvojicu metód:

* `remove()` vyhodí prvok z hlavy radu a vráti ho. Ak je rad prázdny, oblaží nás výnimkou `NoSuchElementException`.
* `poll()` funguje identicky, akurát v prípade prázdneho radu vráti kultúrnejší `null`.

### Nakúkanie
A ešte raz: ak chceme len nazrieť na hlavu radu bez jej vyhadzovania, máme:

* `element()` vráti hlavu radu bez toho, aby ju rušila. Ak je rad prázdny, už viete čo sa stane... `NoSuchElementException`.
* `peek()` je indigová kópia, akurát prázdny rad = vráti `null`.

### Implementácie
Ak nahliadnete [do JavaDoc](http://docs.oracle.com/javase/6/docs/api/java/util/Queue.html)u, odhalíte haldu rozličných implementácií. Do tejto roly možno rovno použiť `java.util.LinkedList` (alias _spojový zoznam_), aj keď sa to zdá možno zvláštne.

Ak chcete poľovo zameraný rad, skúste `java.util.ArrayDeque`. A ak sa vám žiada vláknovo bezpečnej verzie, skúste napríklad `ConcurrentLinkedQueue`.

Bonusom sú implementácie pre zopár úloh konkurentného programovania:

* `ArrayBlockingQueue` resp. `LinkedBlockingQueue` sa dajú použiť na problém producenta a konzumenta
* `PriorityQueue` je zase priamočiara možnosť implementácie prioritných frontov.

 Teraz však...

Naspäť k zásobníkom! (_Back to the stack_)
------------------------------------------
Hore sme si povedali, že `Stack` je nešťastná trieda s neveľkými možnosťami úprav API. V rámci kampane „do Javy 5 s úpravami” sa vymyslel jeden interfejs, ktorým sa mali zabiť dve muchy jednou ranou.

`java.util.Deque` (nečítajte ako dekve, ale ako „dek”) je _double ended queue_, teda, prepytujem, rad o dvoch koncoch. Implementácie tohto interfejsu môžu pridávať a uberať podľa potreby elementy z oboch koncov, čiže sa vedia správať buď ako zásobníky alebo ako rady.

Ekvivalentné metódy vyzerajú nasledovne:

### Vkladanie
*	`push()` je to isté, čo `addFirst()`: vložia element na začiatok deque. Platí to, čo pre pridávanie v klasickej `Queue`. Ak je kapacita presiahnutá, dostanete `IllegalStateException` atď.
*	`offerFirst()` rovnako vkladá element na začiatok, ale bez nechutnej `IllegalStateException` -- namiesto toho vráti v prípade nemožnosti vkladania `false`.

### Vyberanie
*	`pop()` je to isté, čo `removeFirst()`: vrátia a vyhodia element z hlavy/vrchola zásobníka. Pozor na rozdielny typ výnimky: ak je zásobník prázdny, dostanete `NoSuchElementException` (starý `Stack` vracal `EmptyStackException`)
* 	`pollFirst()` analogicky vráti a vyhodí element, akurát bez vyhodenej výnimky. Ak je zásobník prázdny, vráti `null`.

### Nakúkanie
Tu nastáva trošku chaos:

*	`peek()`/`peekFirst()` vráti vrchol zásobníka (= hlavu radu) alebo `null`, ak je kolekcia prázdna. To je rozdiel oproti starému `Stack`u, kde sa vracala výnimka. Ak predsa len chcete odchytávať výnimky, je tu...
*	`getFirst()`, ktorá vráti vrchol zásobníka alebo vyhodí `NoSuchElementException`.

### Sumár zásobníka
Ak sa na to pozrieme ešte raz, vieme si vymyslieť mnemotechnickú pomôcku:

1. v prípade zásobníka pracujeme stále s hlavou _deque_. Hlava = vrchol = prvý prvok.
2. metódy `addFirst()`, `removeFirst()` a `getFirst()` vyhadzujú výnimky
3. metódy `offerFirst()`, `pollFirst()` a `peekFirst()` vracajú `null`, resp. `false`, ak sa operácia nepodarí.

# Implementácie
Mnoho prípadov pokryje implementácia `java.util.LinkedList`. Nepatrným problémom je neexistencia implementácie konkurentného zásobníka, ale v prípade núdze môžete použiť `java.util.concurrent.CopyOnWriteArrayList`.

A ešte raz naspäť k radom!
--------------------------
„Dvojkoncový rad” deque rozširuje interface `Queue` a pridáva aliasy k zdedeným metódam. Zároveň poskytuje metódy na prácu s chvostom, kde platí rovnaká mnemotechnika ako pri radoch:

1. metódy `addLast()`, `removeLast()` a `getLast()` vracajú prvky z chvosta a vyhadzujú výnimky
2. metódy `offerLast()`, `pollLast()` a `peekLast()` vracajú `null`, resp. `false`, ak sa operácia nepodarí.

Aliasy sú nasledovné:

* `add()` je to isté, čo `addLast()` -- je to v súlade s filozofiou kolekcií, že `add()` vždy pridáva na koniec zoznamu (vyhadzujú sa výnimk.y)
* `offer()` = `offerLast()` -- takisto pridávame na koniec zoznamu.
* `remove()` = `removeFirst()` -- v radoch odoberáme zo začiatku / z hlavy (s vyhadzovaním výnimiel)
* `poll()` = `pollFirst()` -- v radoch odoberáme zo začiatku / z hlavy (bez hádzania výnimiek).
* `element()` = `getFirst()` -- nakúkame na hlavu (s hádzaním výnimiek)
* `peek()` = `peekFirst()` -- nakúkame na hlavu (bez výnimkovania)

Implementácie
-------------
* Už spomínaný `java.util.LinkedList` je trieda, ktorá radostne zastúpi úlohu radu i zásobníka: implementuje totiž `Deque`. 
* Ak sa vám nehodia spojové zoznamy, máte k dispozícii `ArrayDeque` založenú na nafukovacom poli. (Podobne ako je `ArrayList` poľovým variantom zoznamu.)

Sumár
=====
Z praktického hľadiska je to jednoduché: vo väčšine prípadov stačí rad vyrobiť cez

	Queue<String> rad = new LinkedList<String>();

a zásobník cez 

	Deque<String> zásobník = new LinkedList<String>();

a to stačí.

Do radu vkladáte cez `offer()`, vyberáte cez `poll()` a nakúkate cez `peek()` a do zásobníka pushujete cez `offerFirst()`, popujete cez `pollFirst()` a nakúkate cez `peekFirst()`.


