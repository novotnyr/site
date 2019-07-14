# Prečo Gradle a prečo Kotlin?

**Gradle** je rokmi overený nástroj na zostavovanie projektov v Java ekosystéme. Samotné príkazy pre zostavenie boli od nepamätí písané v jazyku Gradle. Novým hitom je však Kotlin! Ukážme si, ako môžeme využiť tento jazyk na zostavovanie projektov.

## Prvý skript v Kotline

Predpokladajme, že máme k dispozícii posledný Gradle, napríklad 5.5.1. V nejakom adresári si založme kotlinovský *build script*:

```shell
touch build.gradle.kts
```

Vytvorme prvý **task**, teda príkaz, ktorý sa bude dať pomocou Gradle vykonať. Task je podobný *targetu* z nástroja `make`, či `ant`.

```kotlin
tasks {
    register("hello") {
        doLast {
            println("Hello world")
        }
    }
}
```

- Blok `tasks` obsahuje deklarácie *taskov*.
- Sekcia `register` (v skutočnosti volanie metódy `register`) zaregistruje nový vlastný task, ktorý si nazveme `hello`.
- Sekcia `doLast` určuje príkazy, ktoré sa vykonajú, keď sa spustí náš task `hello`.

Task môžeme spustiť:

```bash
gradle hello
```

Uvidíme výsledok:

```
> Task :hello
Hello world

BUILD SUCCESSFUL in 546ms
1 actionable task: 1 executed                                     
```

Dlhý obkec sa dá skrátiť:

```
gradle -q hello
```

Následne uvidíme len samotnú správu.

## Elegantný pomenovaný task

Task môžeme zaradiť do logickej skupiny (**group**) a môžeme mu priradiť popis (**description**):

```kotlin
tasks {
    register("hello") {
        group = "Greetings"
        description = "Say hello"
        doLast {
            println("Hello world")
        }
    }
}
```

Ak spustíme task, ktorý nám vypíše zoznam dostupných taskov, uvidíme elegantný popis:

```bash
gradle -q tasks
```

Výsledok bude obsahovať (niekde uprostred):

```
Greetings tasks
---------------
hello - Say hello
```

Tasky založené na existujúcich taskoch
======================================

Niekedy máme šťastie a vieme využiť tasky, ktoré sú k dispozícii buď automaticky, alebo z niektorých pluginov. Gradle ponúka [viacero zabudovaných taskov](https://docs.gradle.org/current/dsl/#N10437), napr. task `Exec` na spúšťanie programov. 

```
tasks {
    register<Exec>("workdir") {
        executable = "pwd"
    }
}
```

V tomto prípade sme zaregistrovali task s názvom `workdir`, ktorý využíva zabudovanú predlohu (*task type*) s názvom `Exec`. Vysvetlenie tohto zápisu je zatiaľ zložité, ale povedzme si len, že predloha *task type* sa udáva do lomených zátvoriek.

V rámci tasku sme nastavili vlastnosť (*property*) `executable`, ktorá berie reťazec s názvom systémového programu.

# Kotlin, OOP a Gradle

Kotlin je objektovo orientovaný jazyk, presne tak ako Java. Môžeme si teda vytvárať vlastné tasky ako objekty (inštancie) danej triedy.

Deklarujme si task ako triedu`HelloTask`:

```kotlin
open class HelloTask : DefaultTask() {
    @TaskAction
    fun sayHello() {
        println("Hello world")
    }
}
```

Vidíme viacero vecí:

- Trieda `HelloTask` dedí od zabudovanej triedy `org.gradle.api.DefaultTask`. Keďže náš program je gradleovský *build file*, balíček `org.gradle.api` nemusíme písať. 
- Dedičnosť sa uvádza cez dvojbodku `:`. Zátvorky `()` uvádzajú volanie rodičovského konštruktora.
- Trieda má modifikátor `open`, ktorý indikuje, že trieda môže mať potomkov (cez *dedičnosť* / *inheritance*). Tasky musia byť *open*, pretože s nimi Gradle robí čoro-moro.

- V triede máme jedinú metódu `sayHello()` reprezentovanú funkciou. 
  - Funkcie uvádzame kľúčovým slovom `fun`. 
  - Nemáme žiadne parametre a nevraciame nič. Na rozdiel od Javy neuvádzame žiadny `void`, ani nič podobné.
  - Funkcia má **anotáciu** `@TaskAction`, ktorá hovorí, že toto je vykonateľná metóda tasku. Keďže sme v gradleáckom súbore, balíček pre  `org.gradle.api.tasks.TaskAction` nemusíme importovať.

```kotlin
tasks {
    register("hello", HelloTask::class)
}
```

Funkciu zaregistrujeme pomocou názvu `hello` a odkazom na triedu tasku. Konštrukcia `::class` reprezentuje mechanizmus známy z Javy, kde je uvádzaný cez dvojbodku.

Task môžeme spustiť obvyklým spôsobom cez `gradle hello`!

## Registrácia ustáleným spôsobom

Idiomatický spôsob používa kratší zápis, ale jeho vysvetlenie nie je v tejto chvíli jednoduché:

```kotlin
tasks {
    register<HelloTask>("hello")
}
```

## Vlastnosti / properties a inicializačný blok pre konštruktor

Ak chceme nastaviť skupinu (**group**) a popis (**description**) v triede, môžeme využiť nasledovný zápis:

```kotlin
open class HelloTask : DefaultTask() {
    init {
        group = "Greetings"
        description = "Say hello"
    }

    @TaskAction
    fun sayHello() {
        println("Hello world")
    }
}
```

Sekcia `init` reprezentuje kód, ktorý sa zavolá v rámci konštruktora triedy.

Každá trieda v Kotline má totiž **primárny** konštruktor, ktorý je súčasťou hlavičky. V našom prípade ho vidíme v okrúhlych zátvorkách za `DefaultTask()`. Keďže zátvorky uvádzame za rodičovskou triedou, znamená to, že tento konštruktor sme zdedili. 

Primárny konštruktor nesmie obsahovať kód, ale prípadné príkazy uvádzame do sekcie `init`.

V rámci sekcie `init` využívame dve *properties* (vlastnosti): pre skupinu a popis. Na rozdiel od Javy, kde sú *properties* reprezentované gettermi a settermi, je v Kotline prístup riešený bežným priradením do premennej (pre *setter*), resp. čítaním z premennej (pre *getter*).

Obe vlastnosti, `group` i `description` sme zdedili od rodiča, a pokojne by sme mohli použiť aj ekvivalentný zápis `setGroup(“greetings”)`, resp. `setDescription(“Say Hello”)`.

Task si môžeme spustiť obvyklým spôsobom:

```
gradle -q hello
```

# Premenné, inferencia typov a kolekcie

Kotlin ponúka elegantnú syntax pre kolekcie (zoznamy/polia, mapy/slovníky/asociatívne polia, množiny). Vyrobme si najprv ďalší Gradle task, ktorý vypíše všetky súbory v aktuálnom *projektovom* adresári:

```kotlin
open class LsTask: DefaultTask() {
    @TaskAction
    fun listFiles() {
        println(project.projectDir)
    }
}

tasks {
    register<LsTask>("ls")
}
```

Ak spustíme task `gradle ls`, uvidíme celú cestu k adresáru, v ktorom sa nachádza `build.gradle.kts`.

Opäť využívame *properties*, pretože rodičovská trieda `DefaultTask` má metódu `getProject()`, ktorá sa v Kotline dá zavolať aj jednoduchšie. Trik sa ešte raz zopakuje, keď trieda `Project` ponúka metódu `getProjectDir()`, prístupnú cez *property* `projectDir`.

## Premenné

Cestu k projektu si môžeme priradiť do **premennej**:

```kotlin
val dir = project.projectDir
println(dir)
```

Konštrukcia `val dir` reprezentuje deklaráciu **immutable** (nemeniteľnej) premennej. 

Dátový typ nie je nutné uvádzať, pretože Kotlin si ho odvodí sám vďaka mechanizmu **type inference**, teda automatického odvodzovania dátových typov. Keďže `projectDir`, teda výsledok volania metódy `getProjectDir()` je typu `java.io.File`, Kotlin si *domyslí*, že premenná `dir` môže byť tiež iba `File`.

Kotlin je *silne typovaný jazyk*, kde každá premenná a každý výraz má konkrétny dátový typ, akurát ho v kóde nemusíme uvádzať, ak to nie je nutné.

V niektorých prípadoch je samozrejme možné typ uviesť explicitne, napríklad:

```kotlin
val dir: File = project.projectDir
```

Premenná `dir` je typu `File`, a keďže Gradle automaticky importuje balíček `java.io`, stačí uvádzať skrátený názov.

## Polia a premenné s null-safety: ochrana proti výnimkám `NullPointerException`

Práca s `null` môže byť nepríjemná, pretože treba rozlišovať medzi dvoma svetmi: premenná s objektom, na ktorom možno volať metódy a premenná bez objektu, na ktorej metódy nemôžeme volať. Ak sa to popletie, nastávajú výnimky `NullPointerException`>

Kotlin sa rozhodol zrušiť `null`. To je samozrejme skvelé, ale keďže musíme interagovať so štandardnou knižnicou Javy, je treba nájsť kompromis. 

Ukážme si to na príklade našej funkcie, kde chceme vypísať zoznam súborov/adresárov v projektovom adresári. Objekt `File` reprezentujúci projektový adresár, má metódu `list()`, ktorá vráti pole objektov `File` s potomkami alebo vráti `null`. 

Potrebujeme vybaviť dve veci:

1. polia v Kotline
2. a premenné, ktoré nikdy nesmú byť `null`.

Polia (*arrays*) v Kotline — na rozdiel od Javy — sú reprezentované triedou `Array`. Dátový typ jednotlivých prvkov sa uvádza v lomených zátvorkách, teda pole reťazcov je `Array<File>` (podobne ako v Jave ide o **generický typ**).

Pre prípady, keď Kotlin potrebuje vybaviť *interoperabilitu* s Javou, kde objekt môže byť `null`, je dátový typ okrášlený otáznikom:  `Array<String>?` znamená, že máme pole reťazcov, ktoré môže byť `null`, a treba to vybaviť špeciálnym spôsobom:

```kotlin
val children: Array<File>? = project.projectDir.listFiles()
```

S použitím typovej inferencie je zápis samozrejme kratši:

```kotlin
val children = project.projectDir.listFiles()
```

Poďme teraz vypisovať! Prípad, ak je premenná nenullová, vieme vyriešiť *if*om:

```kotlin
val children = project.projectDir.listFiles()
if (children != null) {
    for (c in children) {
        println(c)
    }
}
```

V kóde vidíme ďalšiu elegantnú vec: **smart cast**, teda chytré pretypovanie. Kotlin *vie*, že vo vnútri `if` je premenná nenullová, a preto s ňou môžeme pracovať bezpečným spôsobom bez obáv, že nastane `NullPointerException`.

Zároveň vidíme ukážku cyklu `for`, kde prechádzame prvkami poľa. Dátový typ premennej `c` nemusíme uvádzať!

## Lambda výrazy

Kotlin — podobne ako Java — podporuje lambda výrazy, teda zápisy pre funkcie, s ktorými môžeme zaobchádzať ako s objektami. 

Napríklad nasledovná funkcia berie jeden parameter `f` typu `File`, vie ho vytlačiť na konzolu a samotnú funkciu priradíme do objektu `doPrint`.

```
val doPrint = { f: File -> println(f) }
```

S lambdami sa dajú robiť psie kusy. Ak máme funkciu, ktorá ako parameter berie inú funkciu, máme **funkciu vyššieho rádu**. Namiesto teórie si dajme príklad.

Pole má metódu (teda funkciu) `forEach()`, ktorá ako parameter berie *funkciu*, ktorá sa zavolá pre každý prvok. Môžeme teda spraviť toto:

```kotlin
val children = project.projectDir.listFiles()
val doPrint = { f: File -> println(f) }
children.forEach(doPrint)
```

Tento zápis je síce správny, ale takmer nikto ho v praxi nepoužije. Kotlin má totiž skvelú syntaktickú vlastnosť (prevzatú z Groovy): funkcia druhého rádu môže vynechať guľaté zátvorky. Kód funkcie v parametri sa dá uviesť medzi zložené zátvorky, čo pripomína klasický *blok*:

```kotlin
val children = project.projectDir.listFiles()
children.forEach { 
  f: File -> println(f) 
}
```

Vďaka skracovacej mánii môžeme pokračovať:

- Keďže Kotllin vie, že prechádzame pole súborov `File`, dátový typ premennej `f` môžeme vynechať.
- Pre prípady, že lambda má len jeden parameter, nemusíme uvádzať ani ten. V lambde je k dispozícii premenná `it` („to“).

Výsledok je:

```
children.forEach { println(it) }
```

Zápis sa dá zjednodušiť ešte viac, ale to si nechajme na *prílepok*. Ešte sme stále nevyriešili jedno varovanie kompilátora, ktoré indikuje situáciu, kde `children` môže byť `null`. 

Namiesto `if` , kde skontrolujeme nenullovosť, môžeme použiť špeciálny operátor **safe call**, teda bezpečného volania. Namiesto klasického volania metódy cez bodku použijeme `?.`, ktorá neurobí nič, ak je premenná `children` náhodou `null`.

Funkcia pre výpis súborov tak môže vyzerať nasledovne:

```kotlin
@TaskAction
fun listFiles() {
    project.projectDir.listFiles()?.forEach { 
        println(it)
    }
}
```

# Inštančné premenné a vlastné konštruktory

Vylepšime náš *task* o možnosť prijať adresár z nejakého parametra, či premennej. Na toto môžeme využiť inštančnú premennú!

```kotlin
open class LsTask: DefaultTask() {
    val directory = File("/tmp")

		/* ... */
}
```

Do triedy `LsTask` sme dodali inštančnú premennú `directory`. Platia pre ňu viaceré vlastnosti:

- Ide o premennú len na čítanie, teda *read-only*, teda premennú s getterom, ale bez settera.
- Premenná je rovno inicializovaná a to tým, že sme vytvorili objekt typu `File`. Na rozdiel od Javy pri vytváraní objektov nepoužívame kľúčové slovo `new`, jednoducho sa tvárime, že voláme funkciu `File()`, ktorá vytvorí objekt. Pre jednoduchosť povieme, že chceme vypisovať obsah adresára `/tmp`.
- Premenná musí byť inicializovaná niečím, čo nie je `null`, pretože takto to má Kotlin rád.
- Používame inferenciu dátového typu, kde Kotlin *vie*, že premenná `directory` bude typu `File`.

Samozrejme, upravíme aj funkciu pre výpis:

```kotlin
open class LsTask: DefaultTask() {
    val directory = File("/tmp")

    @TaskAction
    fun listFiles() {
        directory.listFiles()?.forEach {
            println(it)
        }
    }
}
```

Často sa používa konvencia, kde inicializácia inštančných premenných zbehne v primárnom konštruktore. Zápis vyzerá nasledovne:

```kotlin
open class LsTask(val directory: File = File("/tmp")) : DefaultTask() {
    @TaskAction
    fun listFiles() {
        directory.listFiles()?.forEach {
            println(it)
        }
    }
}

```

Všimnime si, ako sme premennú deklarovali a inicializovali v hlavičke triedy.

V našom prípade to urobíme ale inak, keďže v Gradle môžeme parametrizovať tasky pomocou tzv. *extras*. 

# Parametrizovateľné tasky

Tasky možno parametrizovať, napríklad chceme volať:

```
 gradle ls --directory=/Users
```

V takom prípade stačí dodať nad príslušnú inštančnú premennú anotáciu `@Option` a uviesť názov parametra a popis.

```kotlin
open class LsTask: DefaultTask() {
    @Option(option = "directory", description = "A directory to list")
    var directory = project.buildDir.toString()

    @TaskAction
    fun listFiles() {
        File(directory).listFiles()?.forEach {
            println(it)
        }
    }
}

```

Premenná `directory` sa zmení na reťazec `String`, pretože automatický prevod parametrov z príkazového riadka na inštančnú premennú podporuje len reťazce, booleany, enumy a zoznamy reťazcov. Preto sme primerane upravili aj kód.

Úplne zadarmo dostaneme aj pomocníka, ktorý vypíše podporované parametre.

```
 gradle help --task ls
```

Budovanie kotlinovských projektov
=================================

Dosiaľ sme písali *build script* v Kotline. Čo ak chceme vybudovať projekt, ktorého zdrojáky sú v Kotline a gradloidný *build script* je v Kotline? Poďme na to!

V prvom rade potrebujeme deklarovať *plugin*, ktorý zapne podporu pre zostavovanie zdrojových kódov napísaných v Kotline. Do nového *build scriptu* uvedieme tri sekcie.

```kotlin
plugins {
    kotlin("jvm") version "1.3.41"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
}
```

* **plugins**: sekcia `plugins` slúži na zavádzanie pluginov. A keďže kotlinovský *build script* je skvelý, použijeme špecifický zápis pre kotlinovské projekty.
* **repositories**: uvedie repozitáre pre artefakty (závislosti a pluginy), ktoré sa majú stiahnuť do projektu. Uviedli sme povestný centrálny repozitár Mavenu.
* **dependencies**: uvedie závislosti, teda knižnice, ktoré sú nutné na beh projektu. Kotlinovský projekt závisí na štandardnej knižnici Kotlinu, ktorú musíme zaviesť do projektu.

Teraz sa môžeme pokúsiť zbuildovať projekt:

```bash
gradle assemble
```

Samozrejme, nestane sa nič užitočné, lebo nemáme žiadne zdrojáky!

## Zdrojáky v Kotline

Kotlin očakáva zdrojáky v adresári `src/main/kotlin`, vytvorme ho teda.

```shell
 mkdir -p src/main/kotlin
```

V tomto adresári si môžeme veselo programovať. Môžeme vytvoriť `Hello.kt` s hlúpym obsahom:

```kotlin
fun main() {
    println("Hello!")
}
```

A veselo buildujme:

```
gradle assemble
```

V adresári `build/libs` sa objaví súbor JAR s výsledkom!

# Prílepky

## Hardcore: Member References — referencie na metódy a vlastnosti

Podobne ako v Jave existujú *method references*, ktoré využívajú fakt, kde každá metóda je vlastne lambda výraz, je v Kotline mechanizmus *member reference*. 

V príklade považujeme funkciu `println()` za lambda výraz, ktorý berie jeden objekt a čosi s ním spraví.

```kotlin
children.forEach(this::println)
```

Keďže funkcia `println()` je automaticky k dispozícii, a objekt, na ktorom ju voláme, je `this`, môžeme i toto zjednodušiť a `this` vynechať:

```
children.forEach(::println)
```

## Hardcore: syntax Kotlinu v *script file*

Syntax *build scriptov* využíva naplno vymoženosti Kotlinu. Napríklad nasledovný kód:

```
repositories {
    mavenCentral()
}
```

*Build script* je v skutočnosti nastavovanie vlastností na objekte typu `KotlinBuildScript`. Sekcia `repositories` prakticky volá metódu `repositories()`, ktorej parametrom je lambda. Keďže guľaté zátvorky okolo volania funkcie s lambdou možno vynechať, zrazu je zápis elegantný!

