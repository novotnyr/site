---
title: "Korutiny v Kotline"
date: 2019-07-08T09:09:39+01:00
---

Korutiny v Kotline
==================

V bežnej Jave sa spúšťanie úloh na pozadí (teda paralelný beh úloh) dá dosiahnuť pomocou vlákien (*threads*). Tento mechanizmus však môže byť natoľko komplikovaný, že zaberie pol semestra vysvetľovania. 

Kotlin ponúka alternatívu: **korutiny** / **coroutines**, ktoré majú viacero výhod:

- **elegantný zápis** vďaka kombinácii syntaxe Kotlinu a knižnice pre korutiny
- sú **škálovateľné**: poľahky si môžeme pustiť státisíce korutín
- využívajú **neblokujúcu** filozofiu: keďže sa takmer nikde na nič nečaká, získame nesmierny výkon
- podporujú skladanie korutín cez štruktúrovanú konkurentnosť (**structured concurrency**). To rieši vzťahy medzi vnorenými korutinami.
- adresuje **štandardné prípady** z programovania používateľských rozhraní — napr. komunikáciu medzi úlohou na pozadí a úlohou na popredí.

Korutinu si môžeme predstaviť ako superhrdinskú funkciu / metódu, ktorá sa dokáže spustiť na pozadí, ale inak sa tvári a používa ako bežná funkcia / metóda.

Paralely v iných jazykoch
-------------------------

V iných jazykoch sa na tento účel používajú rozličné zápisy:

- callbacky z JavaScriptu / Node.js, vedúce ku *callback hell*
- promises / future: nahrádzajúce callbacky a poľuďštujúce zápis z JavaScriptu a Javy
- `async` / `await` z C#
- generátory / `yield` z Pythonu

Výhodou korutín v Kotline je zápis programu, ktorý sa (až na drobnosti) programuje ako keby išlo o sekvenčné vykonávanie programu: teda riadok za riadkom pod sebou — bez zanorených callbackov, či všelijakých odbaľovaní / zabaľovaní výsledkov alebo špeciálnych kľúčových slov.

Použitie knižnice korutín v Kotline
===================================

Korutiny síce nie sú súčasťou jazyka, ale dodávajú sa v samostatnej knižnici (od autorov Kotlinu.) Ak ich chceme použiť, dodajme si závislosť:

```groovy
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-core:1.2.2'
```

Zápis korutín
=============

Predstavme si, že chceme na pozadí stiahnuť rozsiahly text z webu. Či už programujeme v Androide alebo v JavaFX alebo nebodaj v Swingu, vieme, že dlhotrvajúce I/O operácie musia ísť na pozadí. To je skvelý kandidát na korutinu!

```kotlin
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.net.URL

fun main() {
    val url = "http://deelay.me/2000/https://www.sav.sk/rss/"

    GlobalScope.launch { 
        val rss = URL(url).readText()
        println(rss)
    }
    /* programová chyba! */
}
```

Korutina potrebuje prinajmenšom tri zložky:

- **scope**: teda rozsah platnosti, v ktorej korutina pobeží. V našom prípade hlúpeho programu použijeme rovnako “inteligentné“ riešenie — globálny scope `GlobalScope` má platnosť celej aplikácie. (Pre reálne aplikácie použijeme iné — jemnejšie — scope, ale pre demo to postačí. V produkcii sa to neodporúča používať!)
- **scope builder**: konkrétny spôsob, ktorým sa zostaví a spustí korutina. Z ponúkanej palety si vyberieme **launch**, určený pre prípady *fire-and-forget*, teda korutiny, od ktorých neočakávame návratové hodnoty.
- **kód korutiny**: samotné príkazy, ktoré sa spustia v rámci korutiny.

Spusťme funkciu `main`! Ale beda, zrejme neuvidíme žiadny vstup!

Korutiny sa tvária ako démonové vlákna
--------------------------------------

Na vlastné oči vidíme, že to nefunguje. Aplikácia totiž skončí skôr ako dobehne sťahovanie súboru! To je nemilé, ale aspoň vidíme, že veci sa dejú na pozadí, hoci — nie vždy musia stihnúť to, čo treba. 

Na pozadí sa korutina spustí v *daemon threade*, teda nečaká sa na jej dobehnutie.

Počkajme na výsledok: `runBlocking`
-----------------------------------

Výhodou korutín je, že nikdy neblokujú a teda nikdy sa na nič nečaká. Na druhej strane, v našom jednoduchom programe vidíme, že čakať jednoducho musíme, inak nikdy neuvidíme výsledok. (To sa týka aj unit testov.) Toto je prekérna situácia, ktorú však vyriešime umnou voľbou **scope buildera**.

```kotlin
import kotlinx.coroutines.runBlocking
import java.net.URL

fun main() {
    runBlocking {
        val url = "http://deelay.me/2000/http://ics.upjs.sk/~novotnyr/home/db.txt"
        val db = URL(url).readText()
        println("${db.length} bytes")
    }
}
```

Kód sme prepísali tak, aby používal builder `runBlocking`. Ten má granulárnejší *scope*: je ním aktuálne vlákno. Ba dokonca, toto aktuálne vlákno vyblokuje (počká), kým kód korutiny nedobehne. 

V našom prípade `runBlocking` vyblokuje hlavné vlákno, kým sa nezíska text z webovej adresy a kým sa nevypíše na konzolu. To je dôsledok vlastnosti tejto sekcie, ktorá spúšťa kód v jedinom vlákne.

Opäť poznamenajme, že pri korutinách sa nikdy nemá čakať či blokovať tak vlákno a `runBlocking` je vhodný jedine pre prípady, keď potrebujeme preklenúť vesmír neblokujúcich korutín s vesmírom starých dobrých pomalých sekvenčných blokujúcich príkazov. Inými slovami, `runBlocking` je pre prípady preklenutia synchrónneho a asynchrónneho kódu — napr. pre `main()` a unit testy.

### Skrátené zápis `runBlocking` pre testy a `main`

V testoch môžeme použiť aj skrátený zápis:

```kotlin
fun main() = runBlocking {
    val url = "http://deelay.me/2000/http://ics.upjs.sk/~novotnyr/home/db.txt"
    val db = URL(url).readText()
    println("${db.length} bytes")
}
```

Paralelné a sekvenčné spúšťanie korutín
=======================================

Kód v korutine sa vykonáva sekvenčne. Ak chceme postupne stiahnuť najprv jeden a potom druhý obsah RSS kanála, stačí zopakovať kód:

```kotlin
fun main() = runBlocking {
    val url = "http://deelay.me/2000/http://ics.upjs.sk/~novotnyr/home/db.txt"
    val db = URL(url).readText()
    println("${db.length} bytes")

    val url2 = "https://www.sav.sk/rss/"
    val rss = URL(url2).readText()
    println("${rss.length} bytes")
}
```

Čo ak chceme paralelný prístup? 

### Paralelný prístup

Paralelný prístup si uľahčíme pomocou mechanizmu **structured concurrency**, teda štruktúrovanej konkurentnosti:

```kotlin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.net.URL

fun main() = runBlocking<Unit> { /* Sémantická chyba! */
    launch(Dispatchers.IO) {
        val url = "http://deelay.me/2000/http://ics.upjs.sk/~novotnyr/home/db.txt"
        val content = URL(url).readText()
        println("${content.length} bytes")
    }

    launch(Dispatchers.IO) {
        val url = "http://deelay.me/2000/http://www.gnu.org/home.en.html"
        val content = URL(url).readText()
        println("${content.length} bytes")
    }
}
```

V kóde použijeme dva vnorené buildery `launch`, ktoré skúsia spustiť paralelné sťahovanie súborov a ich následný výpis. V tomto prípade však použijeme parametrizovaný `launch`, kde uvedieme **dispatcher**, t. j. vlákno, či vlákna, na ktorých sa korutina vykoná. 

#### Dispatchers pre spúšťanie vlákien

Knižnica pre korutiny ponúka viacero preddefinovaných dispatcherov. My sme si vybrali `Dispatchers.IO`, teda dispatcher, ktorý je určený pre spúšťanie úloh s I/O operáciami, čo je presne náš prípad. Sťahovanie súboru z webu totiž premárni množstvo času čakaním na dáta zo servera, než vyťažovaním CPU, na čo je príslušný dispatcher primerane optimalizovaný. (Pre znalcov threadov: dispatcher nie je nič iné, ako *thread pool*).

#### Implicitný a zdedený dispatcher 

Ak by sme neuviedli žiadny dispatcher, použil by sa dispatcher z rodičovskej korutiny (**inherited dispatcher**). A keďže rodičovská korutina beží v rámci `runBlocking`, oba bezparametrové `launch`e by zbehli v jednom vlákne, a to postupne jeden po druhom, teda sekvenčne.

### Návratové hodnoty pre `launch`

*Scope builder* `launch` vracia objekt `Job`, o ktorom si povieme neskôr. Zatiaľ nesmieme zabudnú uviesť korektný návratový typ pre `runBlocking`, aby sa nám nezbláznila kotlinovská inferencia typov.

```kotlin
runBlocking<Unit> { 
...
}
```

### Overenie paralelného prístupu

Ak si chceme overiť, že vnorené korutiny bežia naozaj paralelne, môžeme merať čas behu v sekcii `measureTimeMillis`.

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.net.URL
import kotlin.system.measureTimeMillis

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            launch(Dispatchers.IO) {
                val url = "http://deelay.me/2000/http://ics.upjs.sk/~novotnyr/home/db.txt"
                val content = URL(url).readText()
                println("${content.length} bytes")
            }

            launch(Dispatchers.IO) {
                val url = "http://deelay.me/2000/http://www.gnu.org/home.en.html"
                val content = URL(url).readText()
                println("${content.length} bytes")
            }
        }
    }
    println("$time ms")
}
```

Po spustení uvidíme, že program pobeží zhruba *2 celé niečo* sekúnd, čo bude výkonnostný rozdiel oproti sekvenčným *2 + 2 + niečo* sekundám.

Vďaka štruktúrovanej konkurentnosti vidíme dve vlastnosti:

- kód v korutine vždy beží sekvenčne
- paralelný beh získame pomocou niektorého *scope buildera*, ale musíme myslieť na:
  - buď uvedieme explicitný dispatcher
  - alebo nezabudnime preveriť zdedený dispatcher z nadradenej korutiny. To však môže byť náročné a preto sa odporúča vždy uvádzať explicitný dispatcher.

Funkcie v korutinách
====================

Náš predošlý príklad veselo ťahá dáta v paralelne bežiacich korutinách. Poďme si však trochu upratať repetitívny kód. Vyrobme funkciu `download`, ktorá ťahá dáta a následne ju zavolajme v korutine.

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import java.net.URL
import kotlin.system.measureTimeMillis

fun download(url: String) {
    val content = URL(url).readText()
    println("${content.length} bytes")
}

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            launch(Dispatchers.IO) {
                download("http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt")
            }

            launch(Dispatchers.IO) {
                download("http://deelay.me/5000/http://www.gnu.org/home.en.html")
            }
        }
    }
    println("$time ms")
}

```

Suspendujúce funkcie (suspending functions)
-------------------------------------------

Roman Elizarov, jeden z autorov Kotlinu, [odporúča nasledovnú konvenciu](https://twitter.com/relizarov/status/1088372857766326272): 

> Ak je funkcia pomalá alebo využíva vzdialené volanie, použite *suspending* funkcie.

Naša funkcia na sťahovanie rozhodne využíva vzdialené volanie (a dokonca je pomalá). Čo však je tá *suspending function*? Pozastavujúca sa funkcia?

Naša funkcia na sťahovanie súborov je **blokujúca**, pretože kým neprichádzajú bajty zo servera, bubnuje prstami po stole a **blokuje** vlákno, v ktorom beží, čím zbytočne vyťažuje procesor.

**Suspending Function** je funkcia, ktorá namiesto zbytočného čakania len pozastaví (suspenduje) vykonávanie korutiny, a tým uvoľní vlákno (a vzácne cykly CPU) na užitočné účely. Suspending funkcie teda neblokujú! Ak sa okolitá situácia primerane zmení (napr. prídu bajty zo servera), funkcia sa veselo rozbehne ďalej.

Naša funkcia `download()` je zatiaľ napísaná ako blokujúca, ale vieme ju vylepšiť na neblokujúcu:

1. spustíme ju v inom vlákne, pomocou dispatchera `Dispatchers.IO`
2. vyhlásime ju za suspendujúcu.

## Funkcie spúšťané v explicitnom dispatcheri: sekcia `withContext`

Funkciu môžeme spustiť v explicitnom dispatcheri pomocou bloku `withContext`. 

```kotlin
fun download(url: String) {
    /* Syntaktická chyba */
    withContext(Dispatchers.IO) {
        val content = URL(url).readText()
        println("${content.length} bytes")
    }
}
```

V tomto prípade však uvidíme syntaktickú chybu

> Suspend function 'withContext' should be called only from a coroutine or another suspend function

Táto chyba upozorňuje na dôležitú vlastnosť: **existujúce suspending funkcie môžeme volať len zo suspending funkcie!**

## Deklarácie suspending funkcií

Upravme deklaráciu podľa chybovej hlášky a zároveň upracme v kóde podľa kotlinovských konvencií.

```kotlin
suspend fun download(url: String) = withContext(Dispatchers.IO) {
    val content = URL(url).readText()
    println("${content.length} bytes")
}
```

Naša funkcia je teraz suspending, neblokujúca a dokonca explicitne uvádza dispatcher, na ktorom pobeží.

Použitie suspending funkcie
---------------------------

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.net.URL
import kotlin.system.measureTimeMillis

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            launch {
                download("http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt")
            }

            launch {
                download("http://deelay.me/5000/http://www.gnu.org/home.en.html")
            }
        }
    }
    println("$time ms")
}

suspend fun download(url: String) = withContext(Dispatchers.IO) {
    val content = URL(url).readText()
    println("${content.length} bytes")
}
```

Všimnime si, že `launch` bloky už nemusia uvádzať dispatcher, pretože namiesto zdedeného dispatchera sa použije dispatcher explicitne uvedený v suspending funkcii.

Korutiny s návratovou hodnotou: `async`
=======================================

Naše korutiny získavajú reťazec, ktorý vypisujú na konzolu. Čo ak by sme tento reťazec chceli ďalej spracovávať? Napríklad získať celkovú dĺžku v znakoch? (Áno, je to nezmyselné, ale jednoduché!)

Najprv upravme funkciu `download`:

```kotlin
suspend fun download(url: String): String = withContext(Dispatchers.IO) {
    URL(url).readText()
}
```

Na rozdiel od `launch`, ktorý len odpálime bez toho, aby sme očakávali výsledok, v tomto prípade chceme raz získať návratovú hodnotu. 

**Scope builder** typu `async` vracia hodnotu v podobe objektu `Deferred`, čo je nič iné ako starý známy *promise* (JavaScript) / *future* (Java) / *Deferred* (JQuery), ibaže neblokujúci a efektívny. Ak tento koncept nepoznáme, principiálne ide o objekt, v ktorom sa niekedy v budúcnosti objaví výsledková hodnota. 

S objektom `Deferred` môžeme voľne nakladať a ak chceme počkať na výsledok, použijeme na ňom metódu `await()`, ktorá ho získa neblokujúcim spôsobom.

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.net.URL
import kotlin.system.measureTimeMillis

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            val dbTxt = async {
                download("http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt")
            }

            val homeEnHtml = async {
                download("http://deelay.me/5000/http://www.gnu.org/home.en.html")
            }
            val concatenatedContent = dbTxt.await() + homeEnHtml.await()
            println("Total length: ${concatenatedContent.length}")
        }
    }
    println("$time ms")
}

suspend fun download(url: String): String = withContext(Dispatchers.IO) {
    URL(url).readText()
}
```

Všimnime si, že postupne získame:

- `Deferred` pre budúci obsah prvej adresy `dbTxt`,
- `Deferred` pre budúci obsah druhej adresy `homeEnHtml`.

Tieto dva objekty obsahujú „prísľub“ budúceho obsahu, ktorý sa objaví, keď dolezú dáta z webového servera. Na výsledky počkáme zavolaním metódy `await()`, kde oba reťazce spojíme dohromady a vypočítame jeho veľkosť.

### Await neblokuje!

Metóda `await()` je podobná metóde `get()` na triede `java.util.concurrent.Future`. Na rozdiel od Javy však metóda pri čakaní na výsledok **neblokuje** aktuálne vlákno! Korutina, v ktorej sa funkcia zavolá, sa pozastaví (*suspend*) bez blokovania vlákna a beh bude pokračovať (*resume*) vo chvíli, keď bude k dispozícii výsledok v objekte `Deferred`.

Hromadné sťahovanie
-------------------

Ak poznáme `async`  a trochu funkcionálneho programovania, môžeme sťahovať hromadne ľubovoľný počet súborov!

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.net.URL
import kotlin.system.measureTimeMillis

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            val urls = listOf(
                "http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt",
                "http://deelay.me/5000/http://www.gnu.org/home.en.html"
            )
            urls.map {
                    async {
                        download(it)
                    }
                }
                .awaitAll()
                .sumBy { it.length }
                .also { println(it) }
        }
    }
    println("$time ms")
}

suspend fun download(url: String): String = withContext(Dispatchers.IO) {
    URL(url).readText()
}
```

1. V premennej `urls` vyrobíme zoznam adries na sťahovanie.
2. Každú URL stiahneme v korutine `async` a namapujeme ju na výsledok typu `Deferred`.
3. Funkcia `awaitAll()` je *extension function*, ktorá dokáže počkať (*await*) na dobehnutie všetkých deferredov v kolekcii. Výsledkom je zoznam výsledkov, teda v našom prípade zoznam reťazcov s obsahmi.
4. Pomocou funkcie `sumBy()` spočítame celkovú dĺžku obsahov súborov a vypíšeme ju.

Všetko toto sa deje samozrejme na pozadí, asynchrónne a dobehne to za *päť plus čosi* sekúnd.

# Hromadné sťahovanie vo funkcii: paralelizovateľná dekompozícia

Predstavme si, že si chceme vytvoriť funkciu, ktorá dostane na vstupe niekoľko adries URL, a chceme od nej, aby nám hromadne stiahla obsah a dala ho dohromady.

Skúsime takýto nástrel, ktorý nebude fungovať:

```kotlin
suspend fun downloadAndConcatenate(vararg urls: String) {
    urls.map {
        async {
        		/* Error! Suspension functions can be called only within coroutine body */
            download(it)
        }
    }
    .awaitAll()
    .joinToString()
}
```

Kompilačná chyba jasne hovorí, že chceme použiť *structured concurrency*, ale nesprávnym spôsobom.

> Roman Elizarov v článku [Structured Concurrency](https://medium.com/@elizarov/structured-concurrency-722d765aa952) hovorí, že toto je učebnicový príklad **parallel decomposition**, teda paralelizovateľnej dekompozície úlohy. Tuto rozbijeme úlohu na paralelne bežiace sťahovania súborov, ktoré na konci zlepíme dohromady pomocou metódy `joinToString()`.

Najviac problémov nastáva v chybových stavoch, prípadne pri rušení úloh. O tom si povieme neskôr, ale:

* čo ak sa korutina, z ktorej voláme `downloadAndConcatenate` zruší? Očividne musíme zastaviť čiastkové sťahovania.
* čo ak niektoré z čiastkových sťahovaní zlyhá? V tom prípade chceme zrušiť ostatné sťahovania a vyhlásiť celú operáciu za zlyhanú. (Alebo si definovať vlastnú komplexnú sémantiku, ktorá zlyhaným sťahovaniam priradí konkrétne chybové stavy, ale tie sa budú ťažko lepiť do jedného stringu).

Vykolíkovanie rozsahu platnosti korutiny pre paralelizovateľnú dekompozíciu: `coroutineScope`
---------------------------------------------------------------------------------------------

Na to, aby funkcia `downloadAndConcatenate`, ktorá predstavuje paralelizovateľnú dekompozíciu, fungovala korektne v zmysle *structured concurrency*, potrebujeme použiť ďalší zo dostupných *scope builderov* a to **coroutineScope**.

Táto sekcia:

- skončí, keď dobehnú jej všetky deti. Inými slovami, počká na dobehnutie detí, ale neblokuje!
- ak niektoré z detí zlyhá, celý scope zlyhá tiež, a bežiace deti budú zrušené.

```kotlin
suspend fun downloadAndConcatenate(vararg urls: String) = coroutineScope {
    urls.map {
        async {
            download(it)
        }
    }
    .awaitAll()
    .joinToString()
}
```

Všimnime si, že celú funkciu sme spustili v deklarovanom scope. Deti, reprezentované jednotlivými `async` korutinami, sa budú správať podľa očakávaní.

Funkciu môžeme potom zavolať takto:

```kotlin
fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            val totalContent = downloadAndConcatenate(
                "http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt",
                "http://deelay.me/5000/http://www.gnu.org/home.en.html"
            )
            println("${totalContent.length} bytes")
        }
    }
    println("$time ms")
}
```

### Rozdiel medzi `coroutineScope` a `runBlocking`

Obe sekcie sa správajú rovnako: nedobehnú, kým neskončia ich deti. 

* `runBlocking` pri čakaní na deti **blokuje** vlákno, v ktorom beží.
* `coroutineScope` pri čakaní na deti **neblokuje**.

# Výnimky, chyby a errory

Predstavme si, že chceme stiahnuť nasledovné adresy URL:

```kotlin
val totalContent = downloadAndConcatenate(
    "http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt",
    "http://deelay.me/5000/http://www.gnu.org/home.en.html",
    "http://deelay.me/5000/FAILHOST"
)
```

Je očividné, že tretia adresa neexistuje a teda jej sťahovanie zlyhá.

Ak spustíme aplikáciu, uvidíme nádhernú výnimku:

```text
Exception in thread "main" java.net.UnknownHostException: FAILHOST
	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:184)
	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
	at java.net.Socket.connect(Socket.java:589)
...
```

Čo je ešte dôležitejšie, ostatné dve korutiny a ich metóda `download` sa síce spustia, ale výsledku sa už nedočkáme a celkového súčtu dĺžok tiež nie.

Naša štruktúrovaná konkurentnosť vyzerá nasledovne:

1. `runBlocking` v metóde `main()`
2. `coroutineScope` v metóde `downloadAndConcatenate()`
3. `async` v metóde `downloadAndConcatenate()` pre stiahnutie jednej adresy
4. `withContext` v metóde `download()`

Vďaka nej máme korektné a elegantné spracovanie výnimiek. Konkrétny spôsob záleží od použitého scope buildera:

- `async` sa spolieha na klienta, ktorých ich obslúži v mieste volania metódy  `await()` 
- `launch` považuje výnimky nespracované a prehodí ich do globálnej obsluhy výnimiek.

V príklade sme sa vôbec obsluhe výnimiek nevenovali a preto vidíme správanie **globálnej obsluhy výnimiek** (**global exception handler**), ktorý ich jednoducho vyklopí na chybový výstup `System.err`.

Ak chceme definovať superglobálnu obsluhu, prebijeme nastavenie obsluhy neošetrených výnimiek vo vláknach. Do metódy `main()` uvedieme:

```kotlin
Thread.setDefaultUncaughtExceptionHandler {
		_, e -> println("Unhandled exception: $e")
}
```

## Ošetrenie výnimky na príslušnom mieste

Skúsme ošetriť výnimku v metóde pre hromadné sťahovanie. Obaľme príslušný háklivý kód do `try`/`catch`. 

```kotlin
suspend fun downloadAndConcatenate(vararg urls: String) = coroutineScope {
    try {
        urls.map {
            async {
                download(it)
            }
        }
            .awaitAll()
            .joinToString()
    } catch (e: Exception) {
        /* Chyba: výnimka sa ošetrí dvakrát! */
        println("Failed to download URLs: $e")
        return@coroutineScope ""
    }
}
```

Tento kód povedie k **veľmi** prekvapivej črte: uvidíme dvojité ošetrenie výnimky!

```text
Failed to download URLs: kotlinx.coroutines.JobCancellationException: ScopeCoroutine is cancelling; job="coroutine#1":ScopeCoroutine{Cancelling}@4361bd48

Exception in thread "main" java.net.UnknownHostException: FAILHOST
	at java.net.AbstractPlainSocketImpl.connect(AbstractPlainSocketImpl.java:184)
	at java.net.SocksSocketImpl.connect(SocksSocketImpl.java:392)
	at java.net.Socket.connect(Socket.java:589)
	at java.net.Socket.connect(Socket.java:538)
	at sun.net.NetworkClient.doConnect(NetworkClient.java:180)
	at sun.net.www.http.HttpClient.openServer(HttpClient.java:463)
```

Zrejme by sme očakávali, že keď sa výnimka ošetrí, neuvidíme druhý stack trace, ktorý pochádza z *globálnej obsluhy výnimiek* / *global exception handlera*. Inak povedané, vyzerá to tak, že výnimka sa ošetrí i neošetrí, čo je v rozpore s očakávaniami, ktoré máme na `try`/`catch`.

To však nie je chyba, ale vlastnosť súvisiaca so štruktúrovanou konkurentnosťou. [Dokumentácia](https://kotlinlang.org/docs/reference/coroutines/exception-handling.html#cancellation-and-exceptions) totiž hovorí:

>If a coroutine encounters exception other than `CancellationException`, it cancels its parent with that exception. This behaviour cannot be overridden and is used to provide stable coroutines hierarchies for [structured concurrency](https://github.com/Kotlin/kotlinx.coroutines/blob/master/docs/composing-suspending-functions.md#structured-concurrency-with-async) which do not depend on [CoroutineExceptionHandler](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-exception-handler/index.html) implementation. The original exception is handled by the parent when all its children terminate.

V našom prípade metóda `download()` vyhodila výnimku v rámci sekcie  `async`. Výnimku sme síce odchytili, ale naskočil 

- mechanizmus rušenia (*cancel*) rodiča, ktorým je `coroutineScope`. 
- obsluha pôvodnej výnimky (`UnknownHostException`) rodičom vo chvíi, keď deti dobehnú.
- a navyše, keďže sme v `coroutineScope`, nezabudneme na to, že keď sa zruší rodič, zlyhajú a zrušia sa aj ostatné deti.

### Paralelizovateľná dekompozícia a výnimky

Paralelizovateľná dekompozícia / *parallel decomposition* pomocou `async` naozaj funguje tak, že:

- buď zbehne celá, 
- alebo v niektorom potomkovi nastane výnimka a v tom prípade sa zruší rodič, zrušia všetky deti, a výnimka sa prehodí o úroveň vyššie do korutiny, ktorá paralelizovateľnú dekompozíciu spustila

```kotlin
import kotlinx.coroutines.runBlocking
import kotlin.system.measureTimeMillis

fun main() {
    val time = measureTimeMillis {
        runBlocking<Unit> {
            try {
                val totalContent = downloadAndConcatenate(
                    "http://deelay.me/5000/http://ics.upjs.sk/~novotnyr/home/db.txt",
                    "http://deelay.me/5000/http://www.gnu.org/home.en.html",
                    "http://deelay.me/5000/FAILHOST"
                )
                println("${totalContent.length} bytes")
            } catch (e: Exception) {
                println("Error while calculating bytes: $e")
            }
        }
    }
    println("$time ms")
}
```

### Best Practices / Recepty starých materí pre `async`

#### Async funguje len pre paralelizovateľnú dekompozíciu

Kombinácia `async`/ `await()` navádza na to, že to je mechanizmus `async/await` ukradnutý z C#, a vylepšený o krajšiu syntax. Z toho vyplývajú všetky nejasnosti so spracovaním výnimiek.

Diskutéri v issue [763](https://github.com/Kotlin/kotlinx.coroutines/issues/763) tvrdia, že `async` by sa mal radšej volať **decompose** alebo **fork**, čím by sa vyjasnilo použitie.

#### Sekcia `async` hneď nasledovaná `await()`om je zbytočná

Niekedy sa stane, že uvidíme sekciu `async`, ktorá je hneď nasledovaná `await()`-om.

```kotlin
 val content = async(Dispatchers.IO) { /* kód */ }.await()
```

Toto nie je paralelizovateľná dekompozícia! (Teda je, ale dekomponujeme problém na jeden podproblém.) Namiesto toho stačí prepnúť kontext!

```kotlin
val content = withContext(Dispatchers.IO) { /* kód */ }
```

### `supervisorScope` pre jednosmerné rušenie od rodiča k deťom

V sekcii `coroutineScope` nastáva rušenie / *cancellation* v oboch smeroch: od zlyhaných detí k rodičom a následne od rodiča k ostatným bežiacim deťom. Alternatívou je `supervisorScope`, ktorý deti zruší len vtedy, ak zlyhá sám. Deti sa o svoje rušenie, či obsluhu výnimiek musia postarať samé.

> Podrobnosti uvádza [dokumentácia Kotlinu](https://kotlinlang.org/docs/reference/coroutines/exception-handling.html#supervision-scope).


# Používateľské rozhrania GUI a korutiny

Je čas opustiť hlúpe konzolové hrajkanie sa! Korutiny sú veľmi užitočné pri práci s GUI, pretože uľahčujú typické prípady použitia. 

Typická situácia pre jednovláknové GUI toolkity nastáva, keď chceme vyvolať dlhotrvajúcu akciu a zároveň nechceme, aby aplikácia vytuhla. *Swing* túto situáciu rieši pomocou triedy  `SwingWorker`, a Android zase pomocou `AsyncTask`ov. 

S korutinami je riešenie takýchto situácii omnoho kratšie a prehľadnejšie.

Závislosti a podporované knižnice
---------------------------------

Kotlinovská knižnica pre korutiny rovno podporuje tri najznámejšie GUI toolkity, a ku každému ponúka dodatočnú závislosť, ktorú pridáme do projektu:

- **Swing**: `org.jetbrains.kotlinx:kotlinx-coroutines-swing`
- **Android**: `org.jetbrains.kotlinx:kotlinx-coroutines-android`
- **JavaFX**: `org.jetbrains.kotlinx:kotlinx-coroutines-javafx`

Ukážme si jednoduchý príklad použitia v Swingu. 

Swing a korutiny
----------------

Do projektu si pridajme závislosť:

```gradle
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-swing:1.2.2'
```

Každá z knižníc dá k dispozícii špeciálny typ **dispatchera**: `Dispatchers.Main`, ktorý zabezpečí, že daný kód pobeží v hlavnom vlákne GUI toolkitu. Pre všetky tri GUI toolkity platia dve pravidlá:

1. dlhotrvajúce operácie **nesmú** bežať v hlavnom vlákne.
2. aktualizácie komponentov / widgetov **musia** bežať v hlavnom vlákne.

S použitím špeciálneho dispatchera a vhodného použitia `withContext` sa táto činnosť úplne uľahčí.

Ukážkový formulár
-----------------

Ukážme si jednoduchý formulár s jediným gombíkom, ktorým odpálime dlhotrvajúcu operáciu:

```kotlin

import javafx.application.Application.launch
import kotlinx.coroutines.Dispatchers
import java.awt.event.ActionEvent
import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.SwingUtilities

class PrimeCalculatorForm : JFrame() {
    private val startButton: JButton = JButton("Start")

    init {
        startButton.addActionListener(::onStartButtonClick)
        add(startButton)
    }

    private fun onStartButtonClick(e: ActionEvent) {
        /* dlhotrvajúci výpočet */
    }
}

fun main() {
    SwingUtilities.invokeLater {
        PrimeCalculatorForm().apply {
            defaultCloseOperation = JFrame.EXIT_ON_CLOSE
            setLocationRelativeTo(null)
            pack()
            isVisible = true
        }
    }
}
```

V metóde `onStartButtonClick()` odpálime dlhotrvajúci výpočet, napríklad obľúbený príklad Romana Elizarova, kde rátame veľmi veľké prvočíslo. 

Korutiny a Swing
----------------

Keďže táto operácia musí bežať v samostatnom vlákne, alebo v korutine na pozadí, je to kandidát na použitie scope buildera typu `launch`.

Ak by sme urobili nasledovný kód, nefungovalo by to a skončilo by to na syntaktickej chybe.

```kotlin
private fun onStartButtonClick(e: ActionEvent) {
    launch(Dispatchers.Default) {
        println(BigInteger.probablePrime(4069, Random()))
    }
}
```

V extrémnom prípade sa môže stať, že IntelliJ IDEA importne funkciu, ktorá rozhodne nie je správna:

```kotlin
import javafx.application.Application.launch // WTF?
```

Nezabudnime na zásady používania korutín: potrebujeme poznať *scope*, vybrať si *scope builder* a uviesť kód korutiny. Builder sme si zvolili už predtým: `launch`, kód už máme, ale aký je *scope*?

### Globálny scope `GlobalScope` je považovaný za zlo!

Hlúpe riešenie by nastavilo scope na globálny: `GlobalScope.launch`. Roman Elizarov [však kýve prstom](https://medium.com/@elizarov/the-reason-to-avoid-globalscope-835337445abc#af54) a hovorí, že globálny scope sa takmer nemá používať.

> `GlobalScope.launch` vytvára *globálne* korutiny. Vývojár musí byť zodpovedný za sledovanie ich životného cyklu.

Na rozdiel od konzolových zábaviek, kde sme mohli použiť `runBlocking` ako núdzové riešenie, si tuto musíme zvoliť iný spôsob

Zásady pre scope korutín v GUI
------------------------------

Ak funkcia používa buildery pre korutiny, máme štyri možnosti:

1. ~~použiť globálny scope~~
2. triedu, ktorá obsahuje funkciu, necháme implementovať interfejs `CoroutineScope`, a cez neho poskytneme korutinám príslušný scope. 
3. do triedy, ktorá obsahuje funkciu, zavedieme inštančnú premennú typu `CoroutineScope` reprezentujúcu objekt.
4. do funkcie núdzovo zavedieme parameter typu `CoroutineScope`. To platí pre privátne API, a je to workaround, pretože takto nebudeme vedieť garantovať scope, v ktorom naša funkcia pobeží.

Scope pre okno `JFrame`: `MainScope`
------------------------------------

Zvoľme si druhú možnosť a nechajme naše okno `JFrame` implementovať interfejs `CoroutineScope`. Aký scope však poskytneme korutinám, keď globálny sme si zakázali?

Kotlinovská knižnica pre korutiny poskytuje krásny objekt `MainScope` predstavujúci beh korutín v hlavnom (*main*, EDT) vlákne. 

Interfejs ho vie poskytnúť cez kotlinovskú delegáciu.

```kotlin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope

class PrimeCalculatorForm : JFrame(), CoroutineScope by MainScope() {
```

Delegácia je [odporúčaný postup od Kotlinu 1.1.0](https://www.reddit.com/r/Kotlin/comments/auoyo8/question_about_coroutinescope_example/ehjoxpu/).

Použitie korutiny v metóde
--------------------------

Scope builder `launch` už teraz zafunguje správne, pretože jeho scope bude prebratý z hlavného okna.

```kotlin
private fun onStartButtonClick(e: ActionEvent) {
		launch(Dispatchers.Default) {
				println(BigInteger.probablePrime(4069, Random()))
		}
}
```

Ak si spustíme aplikáciu, môžeme si klikať na tlačidlo **Start** a po dlhej chvíľke uvidíme v konzole výsledky pre prvočísla. Všimnime si, že hlavné vlákno nie je blokované a úlohy bežia na pozadí, pretože inak by sme ani nedokázali kliknúť na tlačidlo a aplikácia by vyzerala zatuhnuto.

Prepínanie vlákien
------------------

Ak chceme aktualizovať komponent hlavného okna, presnejšie nastaviť mu korektný titulok po získané prvočísla, použijeme prepnutie kontextu cez `withContext`:

```kotlin
private fun onStartButtonClick(e: ActionEvent) {
    launch(Dispatchers.Default) {
        val prime = BigInteger.probablePrime(3000, Random())
        withContext(Dispatchers.Main) {
            title = prime.toString()
            println(prime)
        }
    }
}
```

Všimnime si, ako sme jednoducho prepli dispatchera a spustili aktualizáciu na hlavnom vlákne. 

Rušenie korutín z GUI
---------------------

Doteraz sme sa vôbec nebavili o rušení korutín (*cancel*), okrem prípadu, kde korutina vyhodila výnimku. Upravme si naše okno o ďalší gombík, ktorým budeme vedieť pozastaviť výpočet.

```kotlin


import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.awt.FlowLayout
import java.awt.event.ActionEvent
import java.math.BigInteger
import java.util.*
import javax.swing.JButton
import javax.swing.JFrame
import javax.swing.SwingUtilities

class PrimeCalculatorForm : JFrame(), CoroutineScope by MainScope() {
    private val startButton: JButton = JButton("Start")

    private val stopButton: JButton = JButton("Stop")

    init {
        layout = FlowLayout()

        startButton.addActionListener(::onStartButtonClick)
        add(startButton)

        stopButton.addActionListener(::onStopButtonClick)
        add(stopButton)
    }
    private fun onStartButtonClick(e: ActionEvent) {
        /* ... */
    }

    private fun onStopButtonClick(e: ActionEvent) {
        /* ... */
    }
}
```

Máme dva gombíky `JButton`:

* **startButton** s obsluhou v `onStopButtonClick`
* **stopButton** s obsluhou v `onStopButtonClick`

Obe tlačidlá sú uvedené vedľa seba, čo sme dosiahli správcom layoutu (*layout manager*) typu `FlowLayout`.

### Job: úloha

Ak si pamätáme scope builder `async`, hovorili sme, že vracia objekt `Deferred` reprezentujúci výsledok. Builder `launch` sme vyhlásili za čosi, čo nevracia výsledok. Napriek tomu z tohto buildera vieme získať objekt reprezentujúci **job** (úlohu), ktorého základná užitočná vlastnosť je *nechať sa zrušiť* pomocou metódy `cancel()`.

Dajme si do triedy pekný príklad: tlačidlo **Start** vytvorí job a poznačí ho do inštančnej premennej a tlačidlo **Stop** tento job zruší. 

```kotlin
private fun onStartButtonClick(e: ActionEvent) {
    startButton.isEnabled = false
    job = launch(Dispatchers.Default) {
        val prime = BigInteger.probablePrime(4096, Random())
        withContext(Dispatchers.Main) {
            title = prime.toString()
            startButton.isEnabled = true
        }
    }
}

private fun onStopButton(e: ActionEvent) {
    job?.apply {
        cancel()
        startButton.isEnabled = true
        println("Cancelled job")
    }
    job = null
}
```

Vytvorili sme inštančnú premennú typu `job`, ktorý vyhlásime za *nullable*, pretože `null` indikuje stav, keď sa práve nič nedeje, resp. nič nie je spustené.

V metóde pri štarte do nej priradíme výsledok z `launch` sekcie a pri kliknutí na zastavenie jednoducho overíme či `job` nie je `null`, a následne ho zastavíme.

A aby GUI bolo extra vyladené, nezabudneme umne zakazovať a povoľovať štartovacie tlačidlo pomocou `isEnabled`.

Ak aplikáciu spustíme, vidíme korektné správanie. Vždy si vieme spustiť (jeden) *job* na pozadí, a volaním metódy `cancel()` ho zastaviť. Zároveň všetky práce s tlačidlom `startButton` robíme korektne na hlavnom vlákne!

### Upratovanie s použitím suspending funkcie

Samotný kód môžeme ešte upratať. Ak použijeme Elizarovovu konvenciu o hlavičkách funkcií, môžeme dosiahnuť toto:

```kotlin
private fun onStartButtonClick(e: ActionEvent) {
    startButton.isEnabled = false
    job = launch {
        calculatePrime()
    }
}

private suspend fun calculatePrime() = withContext(Dispatchers.Default) {
    val prime = BigInteger.probablePrime(4096, Random())
    withContext(Dispatchers.Main) {
        title = prime.toString()
        startButton.isEnabled = true
    }
}
```

Funkcia `calculatePrime()` je suspending (indikuje dlhý beh), kde uvedieme explicitný *dispatcher*, v ktorom korutina pobeží. Samozrejme, prepnutie dispatchera funguje automaticky.

V metóde `onStartButtonClick()` môžeme spustiť suspending procedúru klasickým spôsobom cez `launch()`.

### Zrušenie jobov so zatvorením okna

Posledná dôležitá vec, ktorú nesmieme zabudnúť vykonať, je zrušiť / cancel všetky joby, ak sa okno zatvorí. Naše okno `PrimeCalculatorForm` má vďaka scopu typu `MainScope` svoj vlastný *job*, ktorého rozsah platnosti zodpovedá životnosti okna. 

Vždy, keď spustíme *job* z obslužnej metódy tlačidla **Start**, spustíme nový *job*, ktorý sa stane potomkom (*child*) *jobu* prináležiacemu oknu.

Táto hierarchia poskytuje výbornú výhodu: ak zrušíme *job* okna, automaticky sa zrušia všetky deti (podobne, ako to robí napríklad korutina bežiaca v sekcii `async`).

Dodajme teda poslucháča na udalosť „zatvára sa okno“ a v ňom jednoducho zrušme celú hierarchiu jobov.

```kotlin
init {
    addWindowListener(object : WindowAdapter() {
        override fun windowClosing(e: WindowEvent?) {
            println("Cancelling job")
            cancel()
        }
    })
```

# Prílepky

Korutiny versus vlákna
----------------------

Korutiny boli navrhnuté ako ľahké vlákna. A naozaj, dá sa použiť skvelé porovnanie:

- **vlákno / thread** ~ korutina
- **blokovanie** ~ suspend
- **paralelizmus** ~ konkurentnosť
- **preemptívny multitasking** ~ kooperatívny multitasking

Keďže sú korutiny nenáročné, môžeme ich spustiť tisícky. Keďže korutiny nikdy neblokujú, ale pozastavujú sa, sú veľmi výkonné. A tretia vlastnosť: kým vlákna môžu bežať paralelne, teda bok po boku naraz (ak máme viac jadier CPU), korutiny sú konkurentné, teda v jednom časovom úseku sa veľmi rýchlo striedajú ich behy. 

Kým vlákna podporujú preemptívny multitasking, teda CPU rozhoduje, kedy ktoré vlákno pobeží, korutiny stavajú na kooperatívnom multitaskingu, kde sa aktívne musia vzdať procesorového času, aby mohli pobežať iné konkurentné korutiny.

Ukážme si, že si ľahko môžeme spustiť desaťtisíc korutín:

```kotlin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    repeat(10_000) {
        launch {
            println(Thread.currentThread().name + " " + it)
        }
    }
}
```

Kooperatívny multitasking
-------------------------

Keďže korutiny fungujú na kooperatívnom multitaskingu, musia definovať v kóde body, kde ich možno suspendovať (pozastaviť) alebo zrušiť (*cancel*).

Predstavme si mimoriadne hlúpy a mimoriadne pomalý algoritmus na triedenie zoznamu, tzv. *bubble sort*.

```kotlin
fun MutableList<Int>.bubbleSort(): List<Int> {
    for (i in 0 until size) {
        for (j in 0 until size) {
            if (this[i] < this[j]) {
                val tmp = this[i]
                this[i] = this[j]
                this[j] = tmp
            }
        }
    }
    return this
}
```

Skúsme si zotriediť zoznam:

```kotlin
fun main(): Unit = runBlocking {
    val job = launch(Dispatchers.Default) {
        val shuffled = (1..30_000).shuffled().toMutableList()
        val bubbleSort = shuffled.bubbleSort()
        println(Thread.currentThread().name + ": " + bubbleSort)
    }
    Thread.sleep(1000)
    println("Cancelling...")
    job.cancel()
    println("Cancelled")
}
```

Hoci sa pokúsime odstreliť job spojený s triedením, nepodarí sa nám to skôr, než funkcia `bubbleSort` dobehne. Bublinové triedenie totiž nekooperuje!

Uvidíme niečo takéto:

```
Cancelling...
Cancelled
DefaultDispatcher-worker-1: [1, ... ]
```

Ak chceme vo funkcii dosiahnuť kooperatívny multitasking, buď:

- **yield**: funkcia naznačí, že suspending funkcia sa vzdáva procesorového času v prospech ďalších výpočtov. Zároveň na tomto mieste môže byť nielen pozastavená, ale i zrušená.
- **isActive**: ak beží funkcia v konkrétnom scope cez `withContext`, môžeme overiť, či je korutina ešte aktívna. Obvyklé použitie je v kombinácii s cyklom  `while`.  Táto vlastnosť je *extension property* na objekte typu `CoroutineScope`.

Keďže naša funkcia nemá nič whileovateľné, použijeme `yield()` a zároveň vyhlásime funkciu za suspending.

```kotlin
suspend fun MutableList<Int>.bubbleSort(): List<Int> {
    for (i in 0 until size) {
        for (j in 0 until size) {
            if (this[i] < this[j]) {
                val tmp = this[i]
                this[i] = this[j]
                this[j] = tmp
            }
            yield()
        }
    }
    return this
}
```

Teraz vidíme, že funkcia sa zruší hneď, ako je to možné, a výpis sa ani nevykoná.

## Čakanie bez blokovania: `delay()`

Doteraz sme na čakanie používali `Thread.sleep()`, ktorý blokuje vlákno, kým neuplynie lehota. V korutinách však existuje neblokujúca verzia, teda suspending funkcia `delay()`:

```kotlin
fun main(): Unit = runBlocking {
    val launch = launch(Dispatchers.Default) {
        val shuffled = (1..30_000).shuffled().toMutableList()
        val bubbleSort = shuffled.bubbleSort()
        println(Thread.currentThread().name + ": " + bubbleSort)
    }
    delay(2000)
    println("Cancelling...")
    launch.cancel()
    println("Cancelled")
}
```

V predošlej verzii sme mali `Thread.sleep()` a *IntelliJ IDEA* nás dokonca upozornila na nevhodný blokujúci kód:

```
Inappropriate blocking method call.
```

# Technická implementácia korutín

Ako sú vlastne korutiny implementované? Ak si vezmeme ľubovoľnú bežnú funkciu, máme na nej dve filozofické operácie:

- *invoke*: spustenie funkcie
- *return*: získanie návratovej  hodnoty.

Korutina poskytuje dve ďalšie operácie:

- *suspend*: pozastaví vykonávanie korutiny
- *resume*: obnoví vykonávanie korutiny

Pri operácii *suspend* sa — voľne povedané — uložia bokom všetky lokálne premenné. O niečo presnejšie, virtuálny stroj vezme celý *stack frame* (teda kontext, resp. stav volania funkcie) a pri suspendovaní ho odloží bokom. Ak sa funkcia obnoví pomocou *resume*, vytiahne sa *stack frame* a vykonávanie pokračuje.

Korutine zodpovedá objekt typu `Continuation`, ktorý má tri vlastnosti:

- metódu `resume()`, ktorá pokračuje vo vykonávaní
- metódu `resumeWithException()`, ktorá obnoví beh s vyvolaním výnimka
- a vlastnosť **kontext** typu `CoroutineContext` reprezentujúcu stav korutiny.

Objekt `Continuation` je takmer vždy za oponou a nepotrebujeme s ním pracovať. Jedinou výnimkou je stav, keď chceme premostiť blokujúce callbackovo orientované API na korutiny.

Suspending funkcie
------------------

Suspending funkcie (“pozastavujúce sa funkcie”) predstavujú mechanizmus, ktorým sa v Kotline dá zapisovať kód korutín. Takáto funkcia sa dá nielen vyvolať a získať jej návratová hodnota, ale aj pozastaviť a obnoviť jej chod.

V Kotline sa funkcie uvádzajú kľúčovým slovom `suspend`.

```kotlin
suspend fun execute() { ... }
```

Kľúčové slovo je jediná vec zo samotného jazyka, ktorá sa venuje korutinám. Všetko ostatné je záležitosťou knižnice.

Pre suspending funkcie platí niekoľko pravidiel:

- funkcia neblokuje!
- suspending funkcia môže volať bežné funkcie alebo iné suspending funkcie
- suspending funkciu môžeme volať len:
  - z inej suspending funkcie
  - zo scope buildera (`launch`, `async` atď).

>  Suspending funkcie sa riadia článkom [What Color is Your Function](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/), podľa ktorého sú to červené funkcie.

Treba dať pozor na to, že suspending funkcia nemusí byť automaticky asynchrónna, teda nemusí bežať na pozadí! To, že funkcii priradíme `suspend`, z nej spraví len kód, ktorý zvláda štyri základné schopnosti korutín! Samotný beh na pozadí je dosiahnutý explicitnou konkurentnosťou, teda použitím vhodného scope buildera alebo kontextu.

## Korutiny a dispatchery

Každá korutina používa **dispatcher**a — niečo ako thread pool —  v ktorom sa spúšťa jej kód. K dispozícii sú nasledovné zabudované dispatchery:

- `Default`: pre bežné operácie na pozadí. V thread poole je k dispozícii toľko threadov, koľko je jadier CPU, ale aspoň 2.
- `IO`: thread pool pre vstupno-výstupné operácie (IO). Obvykle je k dispozícii 64 threadov (alebo toľko threadov, koľko je vlákien, ak je ich viac než 64), ktoré sa však zdieľajú s `Default` poolom.
- `Main`: hlavné vlákno (*main thread*, *event dispatch thread*). Pre tento dispatcher musí byť zavedená podpora konkrétnej knižnice pre konkrétny GUI toolkit. 

 - `Unconfined`: bez thread poolu. Používané pre pokročilé nízkourovňové situácie (napr. emuláciu *event loopu*).

### Prepínanie medzi dispatchermi: `withContext()`

Sekcia `withContext()` prepína vykonávanie kódu medzi dispatchermi. Kotlin optimalizuje “prehodenie vykonávania” tak, aby to bolo rýchle. Prepnutie medzi `Default` a `IO` je dokonca špeciálne optimalizované, keďže oba dispatchery zdieľajú vlákna z thread poolu.

## Prehľad konštrukcií, sekcií a scope builderov

V tejto časti urobíme prehľad často používaných scope builderov. Hoci sa líšia konkrétnym správaním, majú nasledovné spoločné vlastnosti:

- kód v korutine dobehne vtedy, keď dobehnú vnorené korutiny. Jednotlivé buildery sa líšia spôsobom, akým to dosiahnu.
- výnimka v potomkovi zruší (*cancel*) korutinu.
- ak sa zruší (*cancel*) rodič, zrušia sa aj všetci potomkovia

Podrobnosti o builderoch:

- `runBlocking`: vyblokuje aktuálne vlákno a čaká na dobehnutie detí. Používané na premostenie sveta korutín a sveta bez nich, typicky len pre metódu `main()` a unit testy.
- `launch`: korutina typu *fire-and-forget*. Bežné použitie je pre spustenie úloh na pozadí, bez nutnosti získať výsledok. Builder vracia `Job`, ktorým možno korutinu zrušiť. 
  - Tento builder je ideologicky podobný konštrukcii `thread{ … }` , ale namiesto spustenia vlákna len spustí korutinu. 
  - Výnimky hltá, resp. prehadzuje ich na *globálnu obsluhu výnimiek*, ktorá ich vypíše na chybový výstup. Voliteľne je možno zaregistrovať objekt `CoroutineExceptionHandler` v parametri, ale konkrétne pravidlá pre odchytávanie výnimiek sú značne komplexné.
- `async`: pre paralelizovateľnú dekompozíciu, kde sa problém rozbije na paralelne bežiace podúlohy, ktorá sa po dobehnutí zlúčia do jedného výsledku. 
  - Výsledok operácie vráti v podobe objektu `Deferred` (analógia neblokujúcej `Future`, resp. `Promise`).  Na výsledok deferredu možno neblokujúco čakať pomocou metódy `await()`.
  - Objekt `Deferred` je `Job`, takže ho možno zrušiť.
  - Výnimky sa vyhodia po zavolaní `await()`, ale pozor na dvojité ošetrenie výnimky! Vyhodená výnimka sa vždy prehodí o úroveň vyššie, na rodiča, ktorý ju ošetrí ešte raz, resp. prehodí na globálnu obsluhu. To platí aj pre prípady, že výnimku ošetríme v `try`/`catch` v okolí `await()`!

### Prehľad scoping funkcií

Scope funkcie pre korutiny slúžia vymedzenie rozsahu platnosti:

* `coroutineScope`: vymedzuje scope pre vnorené korutiny, napríklad pri paralelizovateľnej dekompozícii pomocou `async`, čo je základ pre *structured concurrency*, teda štruktúrovanú konkurentnosť. 
  * Pri čakaní na dobehnutie detí na rozdiel od `runBlocking` neblokuje vlákno, kým sa tak stane. 
  * Zároveň ak scope spadne na výnimke, alebo je zrušený, zrušia sa aj deti, aj rodič.
* `withContext`: zmení kontext (napr. použitého dispatchera) pre vnorený kód. Použiteľné pre spúšťanie kódu v inom vlákne či dispatcheri.

Kód v korutine je *vždy sekvenčný*, teda čítame ho zhora nadol. Paralelizovateľnosť dosahujeme explicitne, použitím príslušného buildera v kombinácii s vhodným dispatcherom.

### Job a Deferred

`Job` predstavuje výsledok volania scope buildera. Má nasledovné užitočné metódy:

- `join()`: neblokujúco čaká, kým korutina nedobehne
- `cancel()`: zruší korutinu
- `joinAndCancel()`: kombinácia predošlých dvoch: počká na dobehnutie a zruší korutinu.

`Deferred` reprezentuje špecifický *job* s výsledkom, ktorý vracia *scope builder* `async`. Ponúka hlavne metódu:

- `await()`, kde vieme neblokujúco čakať na výsledok asynchrónnej úlohy.

Scoping, globálny scope a štruktúrovaná konkurentnosť
-----------------------------------------------------

Kód v korutine musí bežať v rámci *scope*, teda rozsahu platnosti. Na to máme dve možnosti:

- použiť *globálny scope* (`GlobalScope`)
- využiť štruktúrovanú konkurentnosť (*structured concurrency*) spolu s jasne vymedzeným rozsahom platnosti

### GlobalScope

[Globálny scope](https://kotlin.github.io/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-global-scope/) slúži pre spúšťanie korutín, ktoré majú pracovať počas celej životnosti aplikácie. Pri takýchto korutinách sa neočakáva ich predčasné rušenie. 

Okrem niekoľkých špeciálnych prípadoch sa použitie tohto scope neodporúča práve tak, ako sa neodporúča používanie *globálnych premenných*.  Bežný kód v aplikácii by rozhodne mal využívať niektoré zo scope builderov.

Korutiny spúšťané v tomto scope totiž musí programátor sledovať a v prípade potreby ručne spravovať ich rušenie, joinovanie a ďalšie spravovanie životnosti.

```kotlin
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

fun main() {
    val job = GlobalScope.launch {
        while (isActive) {
            delay(1000)
            println("Reticulating splines...")
        }
    }
    Thread.sleep(3000)
    job.cancel()
}
```

V príklade sme si spustili korutinu v globálnom scope, ktorá čo sekundu vypíše hlášku. V metóde `main()` máme klasický blokujúci kód, ktorý počká tri sekundy a potom `job` odstrelí.

Ak by sme nečakali v `sleep()`, korutina by sa síce rozbehla, ale aplikácia by skončila skôr než nekonečná kontrola pravopisu, a tým ukončila jej beh. (Korutiny sa totiž správajú ako *daemon threads*, démonové vlákna, na ktoré sa nečaká).

Pri sledovaní globálnych korutín musíme dávať pozor na to, že môžeme nechtiac spustiť priveľa korutín alebo môžeme priviesť korutinu v globálnom scope do vytuhnutého stavu. To všetko musíme usledovať zozbieraním referencií na joby / deferredy a následne korektne spracovať.

Štruktúrovaná konkurentnosť
---------------------------

Štruktúrovaná konkurentnosť (*structured concurrency*) dáva jasné pravidlá pre vnorené korutiny:

1. Každá korutina musí bežať v nejakom *scope*. 
2. Korutiny možno vnárať: teda korutina v scope môže spustiť potomkovské (*child*) korutiny.
3. Rodičovská korutina nedobehne, kým nedobehnú potomkovské korutiny. Vďaka tomu nemusíme zbierať referencie na potomkovské joby, `join()` ovať ich, a explicitne očakávať ich ukončenie.
4. Medzi rodičovskou a potomkovskou korutinou existujú jasne definované pravidlá pre chybové situácie, teda rušenie a vyhadzovanie výnimiek.

Scope deklarujeme pomocou niektorého *scope buildera*, ktoré sa líšia konkrétnym mechanizmom v treťom a štvrtom bode.

Coroutine Context a Coroutine Scope
-----------------------------------

Každá korutina so sebou nesie *context*, teda kýbel dát, ktoré majú vplyv na jej beh. Kontext predstavuje objekt typu `CoroutineContext`, čo je *immutable* množina prvkov. Najdôležitejšie sú:

- *job*: používaný pre štruktúrovanú konkurentnosť. Tento job sa stane rodičom pre joby v potomkoch a zároveň ak sa zruší, zrušia sa aj potomkovské joby.
- *dispatcher*: určuje thread-pool, na ktorom sa spustí korutina.
- *názov korutiny*: korutina môže dostať prehľadné meno, čo je užitočné pri ladení.

Každý kontext definuje operátor `plus`, ktorým možno vytvárať immutable kópiu kontextu s novými zmenenými vlastnosťami. Hlúpy príklad vytvorí prázdny kontext s dispatcherom typu IO a vhodným názvom pre korutiny:

```kotlin
val context = EmptyCoroutineContext + Dispatchers.IO + CoroutineName ("test")
println(context)
```

Výsledkom bude:

```
[CoroutineName(test), LimitingDispatcher@27bc2616[dispatcher = DefaultDispatcher]]
```

#### CoroutineScope

Ak si však všimneme šepkára v IntelliJ IDEA, uvidíme:

```kotlin
fun main() = runBlocking<Unit> { /* this: CoroutineScope */
```

Objekt `CoroutineScope` je obal na kontext (doslova interfejs s jediným getterom `CoroutineContext`) a používa sa na získanie efektívneho kontextu používaného v korutine.

Scope buildery totiž zlučujú dva kontexty:

- keďže scope builder je definovaný ako *extension function* na triede `CoroutineScope` , vezme kontext z objektu tejto triedy. (Nezabudnime, že `CoroutineScope` je len obal na scope!)
- a keďže scope builder má parameter typu `CoroutineContext`, vezme sa druhý kontext z tohto parametra. 

Scope builder zlúči oba kontexty pomocou operátora `plus`, pričom kontext z parametra má prednosť.

Výsledný kontext sa stane **rodičovským kontextom** pre novú korutinu. Samotná potomkovská korutina si vytvorí vlastný *job* a zlúči ho s rodičovským kontextom, čím získa vlastný kontext. Okrem toho sa job z rodičovskej korutiny stane rodičom jobu potomka, čím sa bude dať dosiahnuť štruktúrovaná konkurentnosť.

Scope z parametra síce vyzerá ako zbytočná duplicita, ale v skutočnosti slúži ako prostriedok na customizáciu scopu pre potomkov. Môžeme totiž spraviť nasledovné:

```kotlin
fun main() = runBlocking<Unit> {
    launch(Dispatchers.IO + CoroutineName("splines")) {
        delay(1000)
        println("${coroutineContext[CoroutineName]}: Reticulating splines...")
    }
}
```

V príklade zoberieme kontext, pridáme k nemu špeciálny dispatcher a špeciálne pomenovanie a použijeme ho ako rodičovský kontext pre vnútro korutiny. 

Keďže podľa dôležitej konvencie je v rámci korutiny `CoroutineScope ` reprezentovaný ako *receiver* pre kód korutiny, môžeme použiť `this` ako odkaz na scope. 

A keďže `CoroutineScope` je obal na `CoroutineContext` (s getterom, ako sme spomenuli vyššie), vieme pristúpiť k premennej `coroutineContext`.

Vo vnútri korutiny si tak vieme získať napr. názov korutiny pomocou `coroutineContext[CoroutineName]`.

A jedna poznámka: `GlobalScope` nie je zviazaný s rodičovským scopom a funguje nezávisle. Ale keďže `GlobalScope` sa nemá používať, v aplikácii to nie je také dôležité.

## Korutiny a výnimky

Korutiny podporujú elegantnú cestu pre ošetrovanie výnimiek. Dajme si jednoduchý príklad:

```kotlin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main(): Unit = runBlocking<Unit> {
    launch {
        throw IndexOutOfBoundsException() // Will be printed to the console by Thread.defaultUncaughtExceptionHandler
    }
}
```

V sekcii `runBlocking` spustíme korutinu pomocou `launch`… a tá zhorí hneď na štarte. Výsledkom bude krásny *stack trace* na konzole:

```
Exception in thread "main" java.lang.IndexOutOfBoundsException
	at ExceKt$main$1$1.invokeSuspend(Exce.kt:6)
	at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
	at kotlinx.coroutines.DispatchedTask.run(Dispatched.kt:238)
	at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.kt:116)
	at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:80)
	at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:54)
	at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
	at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:36)
	at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
	at ExceKt.main(Exce.kt:4)
	at ExceKt.main(Exce.kt)
```

Výnimka elegantne prebublala cez vnorené korutiny až do globálnej obsluhy výnimiek (*global exception handler*). Okrem toho zrušila korutinu v `launch`, ktorá následne upozornila rodiča `runBlocking`, aby sa zrušil tiež.

Vďaka štruktúrovanej konkurentnosti máme garantované:

- ak padne potomok, automaticky sa zrušia aj ostatní súrodenci v danom *scope*, a zruší sa aj rodič
- ak sa zruší rodič, zrušia sa aj potomkovia.

### Rodič s viacerými potomkami a výnimky

Vytvorme teraz stotisíc korutín, ktoré budú potomkami scopu `runBlocking`. Tieto korutiny však budú chatrné, pretože je 40% šanca, že niektorá z nik z ničoho nič padne.

```kotlin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    repeat(100_000) { 
        launch {
            println(".")
            if (Math.random() < 0.4) {
                throw IllegalStateException()
            }
        }
    }
}
```

Ak spustíme program, uvidíme, že sa vypíše niekoľko bodiek a následne *stack trace*, a program dobehne.

To opäť dokazuje štruktúrovanú konkurentnosť: ak padne niektorý potomok reprezentovaný sekciou `launch`, zruší sa aj rodič, a s ním aj ostatní potomkovia, ktorí ešte nedostali šancu sa spustiť.

### Scope Builders a výnimky

#### Scope Builder `launch` a výnimky

V príklade sme zároveň videli správanie `launch`: výnimky sa zhltnú. Presnejšie, nechajú sa prebublať zložitými pravidlami hierarchie *coroutine exception handlerov* (obsluhy výnimiek v korutinách.) Ak by sme chceli obaliť `launch` do `try`/`catch`, nepomôže to, pretože výnimky z tejto sekcie naozaj neputujú bežnými kanálmi javáckej obsluhy.

Ak v kóde nepoužívame vlastnú obsluhu výnimiek, platia pravidlá:

1. Výnimka `CancellationException` sa ignoruje. Táto výnimka predstavuje indikátor zrušenia korutiny a je ošetrovaná špeciálnym spôsobom.
2. Ak je to iná výnimka, tak:
   1. job v kontexte sa zruší (*cancel*)
   2. vyvolajú sa komplexné pravidlá pre jej obsluhu. Pomocou `ServiceLoadera` sa nájde objekt `CoroutineExceptionHandler` a použije sa. Ak sa nenájde, použije sa `Thread.uncaughtExceptionHandler`.

#### Scope Builder `launch` a Coroutine Exception Handler 

Komplexné pravidlá pre inštalovanie obsluhy výnimiek (*coroutine exception handler*) nie sú veľmi dobre zdokumentované. V júli 2019 sú k dispozícii len komentáre k issue [#1157](https://github.com/Kotlin/kotlinx.coroutines/issues/1157), jde je zhruba povedaných niekoľko zásad:

`CoroutineExceptionHandler` je treba považovať za obsluhu poslednej záchrany, keď už nič nezachytí výnimku. Je to ekvivalent obsluhy výnimiek vo vláknach `Thread.uncaughtExceptionHandler` a na niektorých platformách má špecifickú implementáciu. Na Androide napríklad zhodí appku s *Application Not Responding/ANR* hlásením.

Dôležité je vedieť, že `CoroutineExceptionHandler` funguje len v scope builderi `launch` (a teda inštalovať ho v `async`, či `withContext` nemá žiaden účinok).

Handler môžeme nainštalovať ako parameter kontextu korutiny a platia preňho všetky zásady budovania kontextu. Ak sa `launch` spustí s vlastným handlerom v parametri, použije sa namiesto rodičovského CEH (prepíše sa, keďže parametre kontextu majú prednosť pred rodičovským kontextom.). Inými slovami, ak korutina v launchi padne, buď sa použije zdedený CEH (ak nie je k dispozícii náhrada), alebo CEH, ktorý sa uviedol v parametri.

Ďalšie komplexné pravidlá hovoria:

- nie je vždy pravda, že použije sa handler, ktorý je na najvyššej úrovni
- najväčší zmysel dáva CEH pre korutiny bez rodiča, teda tie, ktoré bežia v globálnom scope. Zodpovedá to filozofii obsluhy poslednej záchrany.
- pri určení konkrétneho CEH, ktorý sa zavolá, sa berú do úvahy viaceré faktory:
  - rodičovský scope a jeho typ
  - rodičovský kontext
  - a to, či rodič zvládne vybaviť výnimku.
- ak použijeme dva zanorené `launch` scope buildery s priradenými CEH handlermi, vnútorný `launch` zistí, že rodič dokáže vybaviť vyhodenú výnimku a preto ju na ňu deleguje bez toho, aby zakomponoval svoj CEH.
- ak prepisujeme existujúci CEH, nesmieme zabudnúť skomponovať zdedený handler s tým, ktorý ideme nainštalovať pre vnorenú korutinu, aby sme zaistili korektné správanie.
- pozor na to, že kontext rodiča nie je nijak ovplyvnený kontextom detí. Kontext je predovšetký nemenný (*immutable*) a jeho dedenie prebieha len od rodiča k potomkom a nie naopak.

#### Obsluha výnimiek v `async`

Scope builder `async` výnimky vyhodí vo chvíli, keď používateľ zavolá `await`. Pozor však na dvojitú obsluhu kvôli dodržiavaniu zásad štruktúrovanej konkurentnosti!

#### Obsluha výnimiek v `runBlocking`

Obľúbený nefunkčný príklad sa pokúsi nainštalovať obsluhu chyby nasledovne:

```kotlin
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    // nefunguje!
    val exceptionHandler = CoroutineExceptionHandler {
        _, t -> println(t)
    }
    repeat(100_000) {
    		// nefunguje!
        launch(exceptionHandler) {
            println(".")
            if (Math.random() < 0.4) {
                throw IllegalStateException()
            }
        }
    }
}
```

Ak zhavaruje korutina v `launch`, podľa pravidiel o štruktúrovanej konkurentnosti zhavaruje aj rodič `runBlocking`, ktorý sa túto výnimku snaží posunúť o úroveň vyššie. Tam však už nič iné nie je a preto sa vyvolá globálna obsluha výnimiek. Náš `exceptionHandler` sa vôbec nepoužije.

Inými slovami, na korutinách spúšťaných vo vnútri `runBlocking` sa neoplatí inštalovať obsluhu výnimiek, pretože to nebude fungovať.

## Prevod z callbackov na korutiny: `suspendCancellableCoroutine`

Pri niektorých historických knižniciach je k dispozícii staré callbackovo orientované API. Klasickým príkladom je klient z knižnice `okhttp`, ktorý vykoná príkaz HTTP asynchrónnym spôsobom a poskytuje dve callbackové metódy:

- `onResponse()`, ak metóda uspeje
- `onFailure()`, ak nastane výnimka.

Takýto kód vieme preklopiť na korutinový prístup pomocou sekcie `suspendCancellableCoroutine`. Sekcia má k dispozícii objekt `Continuation`, kde vieme zavolať tri metódy:

- `resume()`: pokračuje korutinu s konkrétnym výsledkom
- `cancel()`: zruší korutinu s konkrétnou výnimkou
- `resumeWithException()` pokračuje korutinu s výnimkou.

Kompletný príklad vyzerá nasledovne:

```kotlin
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import okhttp3.Call
import okhttp3.Callback
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import java.io.IOException
import kotlin.coroutines.resume

object Http {
    suspend fun run(url: String): String = withContext(Dispatchers.IO) {
        suspendCancellableCoroutine<String> { continuation ->
            val request = Request.Builder()
                .url(url)
                .get()
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call?, e: IOException?) {
                    continuation.cancel(e)
                }

                override fun onResponse(call: Call, response: Response) {
                    response.body()?.use {
                        continuation.resume(it.string())
                    }
                }
            })
        }
    }

    private val client: OkHttpClient
        get() = OkHttpClient.Builder()
            .followRedirects(false)
            .build()
}

fun main() = runBlocking {
    val xml = Http.run("https://dennikn.sk/minuta/feed/?cat=2386")
    println(xml)
}
```

## Supervízia korutin: `supervisorScope`

Vyššie sme videli, že bežné správanie štruktúrovanej konkurentnosti tvorí obojsmerný vzťah medzi rodičom a potomkami. Ak potomok zhavaruje, zruší rodiča i naopak, zrušený rodič automaticky zruší svojich potomkov.

Niekedy však chceme len jednosmerný vzťah: nech sa deti postarajú samé o seba, bez vplyvu na rodiča. Opačný smer však ostane: ak rodič zhavaruje, deti sa zrušia a samozrejme, rodič vždy počká na ich korektné dobehnutie.

Na tento účel máme špecifický builder `supervisorScope`.

Tento príklad je dobre známy: s prvou výnimkou v potomkovi `launch` sa zrušia aj deti:

```kotlin
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

fun main() = runBlocking {
    repeat(10) {
        launch {
            println(Thread.currentThread().name + " " + it)
            if (it % 2 == 0) {
                throw IllegalStateException("Random failure")
            }
        }
    }
}
```

Ak obalíme blok do `coroutineScope`, správanie sa zmení:

```kotlin
fun main() = runBlocking {
    supervisorScope {
        repeat(10) {
            launch {
                println(Thread.currentThread().name + " " + it)
                if (it % 2 == 0) {
                    throw IllegalStateException("Random failure")
                }
            }
        }
    }
}

```

S týmto scopom uvidíme päť *stack traceov* (z desiatich behov spadne každý druhý), pretože potomkovia v `launch` , u ktorých nastane výnimka už nevyvolajú zrušenie rodiča.

### `SuperVisor` a výnimky

Pre výnimky platia bežné zásady:

- `launch` výnimky hlce, resp. posiela do  *globálnej obsluhy výnimiek* (*coroutine exception handler*)
- `async` výnimky vyberá v `await()`e.

#### Supervízia a `launch`

Keďže máme prvý príklad, hľadá sa v kontexte *handler* a keďže sa žiadny explicitný nenašiel, použije sa bežný výpis na chybový výstup *stderr*.

Skúsme si zaregistrovať vlastný handler. Samotný `supervisorScope` nepodporuje žiadne parametre, ale *handler* môžeme registrovať u rodiča, teda v `runBlocking`.

```kotlin

import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.supervisorScope

fun main() {
    val errorHandler = CoroutineExceptionHandler { _, t -> println("${t.message}") }

    runBlocking(errorHandler) {
        supervisorScope {
            repeat(10) {
                launch {
                    println(Thread.currentThread().name + " " + it)
                    if (it % 2 == 0) {
                        throw IllegalStateException("Random failure")
                    }
                }
            }
        }
    }
}
```

 Vidíme, že výnimky sa teraz vypisujú v zjednodušenom formáte.

Alternatívne riešenie zaregistruje `errorHandler` v samotnej sekcii `launch`:

```kotlin
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.supervisorScope

fun main() = runBlocking {
    val errorHandler = CoroutineExceptionHandler { _, t -> println("${t.message}") }
    supervisorScope {
        repeat(10) {
            launch(errorHandler) {
                println(Thread.currentThread().name + " " + it)
                if (it % 2 == 0) {
                    throw IllegalStateException("Random failure")
                }
            }
        }
    }
}
```

### Supervízia a `async`

V prípade `async` a supervízie sa očakáva, že potomkovia sa o chybové stavy postarajú sami. Dajme si analogický príklad:

```kotlin

import kotlinx.coroutines.Deferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.supervisorScope

fun main() = runBlocking {
    supervisorScope {
        val deferreds = ArrayList<Deferred<Unit>>()
        repeat(10) {
            val deferred = async(Dispatchers.Default) {
                println(Thread.currentThread().name + " " + it)
                if (it % 2 == 0) {
                    throw IllegalStateException("Random failure at $it")
                }
            }
            deferreds.add(deferred)
        }
        deferreds.awaitAll()
        Unit
    }
}

```

V príklade použijeme paralelizovateľnú dekompozíciu. Sekcia `supervisorScope` sa postará o rovnakú funkcionalitu ako `coroutineScope`, a vo vnútri tak môžeme spustiť viacero korutín typu `async`, na separátnom vlákne. Všetky výsledky následne pozbierame do zoznamu `deferreds` a na konci si počkáme na hromadný výsledok.

Výpis bude elegantný:

```
DefaultDispatcher-worker-1 0
DefaultDispatcher-worker-1 1
DefaultDispatcher-worker-1 2
DefaultDispatcher-worker-5 3
DefaultDispatcher-worker-5 4
DefaultDispatcher-worker-5 5
DefaultDispatcher-worker-5 6
DefaultDispatcher-worker-5 7
DefaultDispatcher-worker-8 8
DefaultDispatcher-worker-5 9
Exception in thread "main" java.lang.IllegalStateException: Random failure at 0
	at Supervisor3Kt$main$1$1$1$deferred$1.invokeSuspend(Supervisor3.kt:16)
	at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
	at kotlinx.coroutines.DispatchedTask.run(Dispatched.kt:238)
	at kotlinx.coroutines.scheduling.CoroutineScheduler.runSafely(CoroutineScheduler.kt:594)
	at kotlinx.coroutines.scheduling.CoroutineScheduler.access$runSafely(CoroutineScheduler.kt:60)
	at kotlinx.coroutines.scheduling.CoroutineScheduler$Worker.run(CoroutineScheduler.kt:742)
```

Správanie môže vyzerať záhadne, ale má zmysel. Vidíme, že všetky podkorutiny sa spustili, niektoré zlyhali, ale dozvedeli sme sa len o páde prvej z nich. To je vlastnosť `awaitAll()`, ktorá spadne vo chvíli, keď ktorýkoľvek prvý z deferredov vyhodí výnimku.

Toto môžeme ošetriť pomocou `try`/`catch` bloku. Pozor však na to, že `CoroutineExceptionHandler` nebude fungovať! (Ten totiž pre `async` nie je podporovaný.)

Jedna z možností, ako to opraviť, je nasledovná:

```kotlin

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.supervisorScope

fun main() = runBlocking {
    supervisorScope {
        try {
            (1..10).map {
                async(Dispatchers.Default) {
                    println(Thread.currentThread().name + " " + it)
                    if (it % 2 == 0) {
                        throw IllegalStateException("Random failure at $it")
                    }
                }
            }
                .awaitAll()
            Unit
        } catch (e: Exception) {
            println(e.message)
        }
    }
}
```

Následne uvidíme:

```
DefaultDispatcher-worker-1 1
DefaultDispatcher-worker-3 2
DefaultDispatcher-worker-3 3
DefaultDispatcher-worker-3 4
DefaultDispatcher-worker-3 5
DefaultDispatcher-worker-5 6
DefaultDispatcher-worker-7 7
DefaultDispatcher-worker-6 9
DefaultDispatcher-worker-7 10
DefaultDispatcher-worker-5 8
Random failure at 2
```

# Literatúra

## Tutoriály

- Kotlinlang.org: [Coroutines Guide](https://kotlinlang.org/docs/reference/coroutines/coroutines-guide.html)
- Simply-how.com: [Kotlin Coroutines by Example Guide](https://simply-how.com/kotlin-coroutines-by-example-guide)
- Antonis Lilis: [An Introduction to Kotlin Coroutines](https://antonis.me/2018/12/12/an-introduction-to-kotlin-coroutines/)
- Antionio Leiva: [Coroutines in Kotlin 1.3 explained: Suspending functions, contexts, builders and scopes](https://antonioleiva.com/kotlin-coroutines/)

## Architektúra a vnútornosti

* Kotlin KEEP: [Kotlin Coroutines (Design Proposal)](https://github.com/Kotlin/KEEP/blob/master/proposals/coroutines.md) Dizajnový dokument o vlastnosti jazyka od autorov Kotlinu.
* Roman Elizarov: [The Reason to avoid `GlobalScope](https://medium.com/@elizarov/the-reason-to-avoid-globalscope-835337445abc)`
* Roman Elizarov: [Structured Concurrency](https://medium.com/@elizarov/structured-concurrency-722d765aa952)
* Roman Elizarov: [Coroutine Context And Scope](https://medium.com/@elizarov/coroutine-context-and-scope-c8b255d59055)
* Roman Elizarov: [Blocking Threads, Suspending Coroutines](https://medium.com/@elizarov/blocking-threads-suspending-coroutines-d33e11bf4761)
* Martin Devillers in ProAndroidDev: [Demystifying CoroutineContext](https://proandroiddev.com/demystifying-coroutinecontext-1ce5b68407ad)

# Techniky a patterny
- StackOverflow.com: [How to launch a Kotlin coroutine in a suspend fun that uses the current parent scope](https://stackoverflow.com/questions/53862838/how-to-launch-a-kotlin-coroutine-in-a-suspend-fun-that-uses-the-current-parent) 
- Medium.com: [What is the difference between `coroutineScope`and `withContext`](https://medium.com/@lubotin/what-is-the-difference-between-coroutinescope-and-withcontext-builders-f6fff744d3db)`
- Dmytro Danylyk at ProAndroidDev.com: [Kotlin Coroutines Patterns and Antipatterns](https://proandroiddev.com/kotlin-coroutines-patterns-anti-patterns-f9d12984c68e)
- Kotlin Documentation: [Debugging Coroutines](https://github.com/Kotlin/kotlinx.coroutines/blob/master/docs/debugging.md)

## Výnimky a `launch` 
- [CoroutineExceptionHandler installed on top(-most) scope not always used.](https://github.com/Kotlin/kotlinx.coroutines/issues/1157) Issue #1157 komentujúca inštaláciu obsluhy výnimiek a okrajové prípady
- GitHub.com: [App exits after catching exception thrown by coroutine](https://github.com/Kotlin/kotlinx.coroutines/issues/753), issue #753
- GitHub.com: [Async builder and cancellation in structured concurrency](https://github.com/Kotlin/kotlinx.coroutines/issues/763,), issue #763
- StackOverflow: [Exception thrown by `await()` within a `runBlocking` treated as unhandled even after caught](https://stackoverflow.com/questions/53222045/exception-thrown-by-deferred-await-within-a-runblocking-treated-as-unhandled-e)

## Android
- Google.com: [Using Kotlin Coroutines in your Android app](https://codelabs.developers.google.com/codelabs/kotlin-coroutines)
- Google.com: [Improve App Performance with Kotlin Coroutines](https://developer.android.com/kotlin/coroutines)
- Dmytro Danylyk at ProAndroidDev.com: [Android Coroutine Recipes](https://proandroiddev.com/android-coroutine-recipes-33467a4302e9)
- Craig Russell: [Coroutine Support in ViewModels using the new ViewModelScope extension property](https://craigrussell.io/2019/03/coroutine-support-in-viewmodels-using-the-new-viewmodelscope-extension-property/)
- Mayowa Adegeye: [Coroutine Cancellation and Structured Concurrency](https://proandroiddev.com/part-2-coroutine-cancellation-and-structured-concurrency-2dbc6583c07d)

    

