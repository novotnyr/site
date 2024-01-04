---
title: Kotlin - lambdy, anonymné funkcie, rozširujúce funkcie a lambdy s prijímačom
date: 2024-01-04T22:00:36+01:00
---
Toto je funkcia:
```kotlin
fun double(n: Int): Int {
    return n * 2
}
```
Funkciu môžeme priradiť do premennej:
```kotlin
fun double(n: Int): Int {
    return n * 2
}

fun main() {
    val f = ::double
    println(f(2))

```
Syntax `::` používa _method references_, teda odkazy na funkcie, či metódy.
## Anonymné funkcie
Funkcia môže byť anonymná.
```kotlin
val double = fun (n: Int): Int {
	return n * 2
}
println(double(2))
```
Ako vidno, medzi `fun` a zoznamom argumentov nie je meno. Môžeme ju potom priradiť do premennej `double` a volať naďalej.
Ak sme zvedaví, tak dátový typ premennej (!) `double` je:
```kotlin
(Int) -> Int
```
Berieme jeden `Int`ídžer a vraciame tiež `Int`ídžer.
## Anonymné funkcie ako parametre
Funkcie sú v Kotline bežnými občanmi. Môžeme ich odovzdávať ako parametre:
```kotlin
val double = fun (n: Int): Int {
	return n * 2
}
val doubles = listOf(1, 2, 3).map(double)
println(doubles)
```
Funkcia `map` na zozname `List` berie ako parameter funkciu, ktorá sa spustí na každom prvku zoznamu.
## Lambdy
Anonymné funkcie sa volajú **lambdy**. Keďže v Kotline sa používajú kade-tade, existuje skrátený zápis:
```
val double = { n: Int -> n * 2 }
```
Premenná `double` obsahuje anonymnú funkciu, po novom **lambda výraz**, ktorý má
- jeden celočíselný parameter
- vracia celé číslo.
  Na rozdiel od anonymnej funkcie sa návratový typ automaticky zistí pomocou *odvodzovania typov* (_type inference_), lebo intídžer krát dva je intídžer.
  Zároveň nepoužívame `return`.

Lambdu používame rovnako ako anonymné funkcie:
```kotlin
val doubles = listOf(1, 2, 3).map(double)
```
## Lambdy ako parametre
Funkcia môže brať lambdu ako parameter. Obvykle predstavuje nejaký „kus kódu“, čo sa môže dynamicky vykonať.

Funkcia `map` zoberie po jednom prvky zoznamu a na každom z nich „vykoná kus kódu“. Tento kus kódu je reprezentovaný lambdou.

Na zozname čísiel preto berie ako parameter funkciu `(Int) -> Int`, čiže z intídžrov do intídžrov. Naša premenná `double` predstavuje „kus kódu“, ktorá zdvojnásobí ľuboľný vstup a teda ju môžeme použiť na každý prvok zoznamu.
## Lambdy ako koncové parametre
Ak má funkcia posledný parameter typu lambda, máme skrátený zápis:
```kotlin
val doubles = listOf(1, 2, 3).map { n: Int -> n * 2 }
```
Oficiálne sa to volá **trailing lambda** (_koncová lambda_).
Toto v skutočnosti pripomína funkcie, až na šípku:
```kotlin
val doubles = listOf(1, 2, 3).map { n: Int -> 
	n * 2 
}
```
Odvodzovanie typov je zázračné — niekedy vie uhádnuť dátový typ parametra `n`.
```kotlin
val doubles = listOf(1, 2, 3).map { n ->  n * 2 }
```
Keďže máme zoznam `Int`-egerov, lambda vykonaná na každom prvku musí byť `Int` a teda ho nemusíme uviesť ako dátový typ premennej `n`.
Ak má lambda jediný parameter, je to ešte kratšie:
```kotlin
val doubles = listOf(1, 2, 3).map { it * 2 }
```
Zjaví sa automatická premenná `it` („to“) s automaticky odvodeným dátovým typom - napríklad `Int`.
## Lambda a viacero riadkov
Lambda môže mať viacero riadkov:
```kotlin
val doubles = listOf(1, 2, 3).map { 
	println("Calculating double of $it")
	it * 2
}
```
Výsledkom lambdy je posledný výraz, teda dvojnásobok premennej `it`.

Zátvorky `{` ... `}` sa podobajú na blok kódu. Toto nám dáva nové možnosti!
## Ľubovoľné bloky
Aha, kód:
```kotlin
repeat(5) {
	println(it)
}
```
To, čo vyzerá podozrivo ako `while(true) {... }` je bežné použitie lambdy a parametrov.
Ale je to bežná funkcia! Tento `repeat` má dva parametre:
```kotlin
public fun repeat(times: Int, action: (Int) -> Unit)
```
1. počet opakovaní `times`
2. a lambdu z `Int` do „ničoho“ (`Unit`), lebo nepotrebujeme z nej vracať žiadnu hodnotu.

To by sme mohli celé napísať komplikovane napríklad takto:

```kotlin 
val printToConsole = { n: Int -> println(n) }
repeat(5, printToConsole)
```

Ale načo, keď máme koncové lambdy?

## Budovateľské nadšenie s buildermi
Predstavme si košík na veci. Presnejšie, košík na reťazce, ktoré doň môžeme pridávať.
```kotlin
class Basket {
    private val items = mutableListOf<String>()

    fun add(item: String) {
        items += item
    }
}
```
Môžeme si predstaviť nasledovný pseudojazyk (DSL, _domain specific language_):
```kotlin
basket {
	it.add("Cabbage")
	it.add("Carrot")
}
```
Toto je v skutočnosti skrátený zápis za:
```kotlin
basket { b: Basket -> 
	b.add("Cabbage")
	b.add("Carrot")
}
```
Aby toto fungovalo, zostrojíme funkciu `basket` s koncovou lambdou:
```kotlin
fun basket(build: (Basket) -> Unit) {
    val basket = Basket()
    build(basket)
}
```
Lambda berie košík `Basket` a nevracia nič.
Konkrétny objekt košíka, ktorý sa ocitne ako argument lambdy `builder`, vytvoríme a pošleme pri volaní lambdy do argumentu.

Takto sa môžeme napojiť na odvodzovanie typov: keďže funkcia `basket` vie, že parametrom lambdy je `Basket` a tento parameter je len jeden, môžeme ho použiť v podobe `it`.

## Lambdy s prijímačmi (_Lambdas with Receivers_)
Aha, akú krásnu syntax vieme v Kotline ešte vymyslieť:
```kotlin
basket {
	add("Cabbage")
	add("Milk")
}
```
Čo je `add`? Je to metóda na objekte typu `Basket`.
A kde je ten objekt? Je skrytý pod zamlčaným `this`.
```kotlin
basket {
	this.add("Cabbage")
	this.add("Milk")
}
```

A čo je `this`? Je to prijímač (_receiver_), ktorý vieme uviesť v lambde.

V skratke: toto je ešte kratší zápis ako hrajkanie sa s `it`.

**Lambda s poslucháčom** má extra parameter:
```kotlin
contentBuilder: Basket.() -> Unit
```
`Basket` pred bodkou znamená typ, ktorý sa vo vnútri lambdy zjaví pod premennou `this`.
Čítame to ako „lambda má prijímač typu `Basket`, žiadne parametre a nič nevracia“.
Ako to použijeme?
```kotlin
fun basket(contentBuilder: Basket.() -> Unit) {
    val b = Basket()
    b.contentBuilder()
}
```
Lambdu tuto zavoláme na objekte `basket` akoby išlo o jeho bežnú metódu. Vo vnútri lambdy sa objekt `basket` objaví v premennej `this`. Takto môžeme košík naplniť vo vnútri lambdy `contentBuilder`.

Lebo naozaj: prijímač typu `Basket` (premenná `b`) volá lambdu bez parametrov a bez návratovej hodnoty.

A ešte: _receiver_ je naozaj dodatočný parameter, lebo volanie lambdy môžeme urobiť aj naopak:
```kotlin
contentBuilder(basket)
```
Syntax zrazu začne fungovať!
## Extension Functions - rozširujúce funkcie
Predstavme si ďalší syntaktický cukor:
```
5.times {
	println("Hello")
}
```
Toto je veľmi podobné ako:
```
repeat(5) {
	println("Hello")
}
```
Ibaže číslo je vysunuté pred bodku, čiže to vyzerá ako metóda!
Dokonca na čísle `5`, teda metóda na `Int`egeri. Ale `Int` nemá metódu `times`, tak ako to funguje?
Začnime jednoduchším prípadom:
```kotlin
5.times("Hello")
```
V Kotline môžeme vytvárať funkcie, ktoré budia dojem, že ide o dodávanie metód triedam. A na to naozaj slúžia!
Vytvorme funkciu:
```kotlin
fun Int.times(s: String) {
    TODO("Not yet implemented")
}
```
Pred názvom funkcie a pred bodkou je `Int`, čo je akýsi dodatočný parameter funkcie reprezentujúci objekt, na ktorom môžeme volať metódu `times`.
Takáto funkcia sa volá *extension function* (rozširujúca funkcia).
Pozor, toto nie je lambda s prijímačom (_lambda with receiver_)! Je to normálna, slušná, pomenovaná funkcia.
Keďže hodnota `5` je typu `Int`, môžeme na nej volať metódu `times`. Funkcia `times` je verejná a patrí do nejakého balíčka. Ak by sme ju chceli použiť v inom balíčku, musíme ju _importnúť_, aby sme jasne povedali, odkiaľ takéto „náhodné“ dodatočné metódy na „náhodných“ triedach pochádzajú a nedošlo k nečakaným prekvapeniam.
## Rozšírenia a lambdy
Extension Functions (rozširujúce funkcie) a lambdy môžeme kombinovať!
```kotlin
fun Int.times(iteration: (Int) -> Unit) {
    for (i in 1..this) {
        iteration(i)
    }
}
```
Funkcia `times` prijme lambdu, ktorá síce nevracia nič, ale zato má jeden celočíselný parameter (reprezentujúci „poradové číslo kola“, ktoré sa práve vykonáva).
Teraz už môžeme volať:
```kotlin
5.times {
	println("$it: Hello")
}
```
## Naspäť ku košíku!
Ak chceme mať peknú syntax:
```kotlin
basket {
	item("Milk")
	item("Sugar")
}
```
Stačí dodať rozširujúcu funkciu:
```kotlin
fun Basket.item(item: String) = add(item)
```
Toto prakticky slúži ako _alias_ metódy `add` na triede `Basket`. Alias sa však správa úplne rovnako ako pôvodná metóda a môžeme ho použiť pri volaní na _prijímači_ vo vnútri lambdy, ktorú volá funkcia `basket`.