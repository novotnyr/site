---
title: "Postavme kotlinovský projekt cez Gradle v Kotline"
date: 2019-07-16T09:09:39+01:00
---

Budovanie kotlinovských projektov
=================================

Čo ak chceme vybudovať projekt, ktorého zdrojáky sú v Kotline a gradloidný *build script* je... v Kotline? (Vložte *yo-dawg-meme.png*). Poďme na to!

V prvom rade potrebujeme deklarovať *plugin*, ktorý zapne podporu pre zostavovanie zdrojových kódov napísaných v Kotline. Do nového *build scriptu* uvedieme tri sekcie.

```kotlin
plugins {
    kotlin("jvm") version "1.3.41"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
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

```bash
 mkdir -p src/main/kotlin
```

V tomto adresári si môžeme veselo programovať. Môžeme vytvoriť `Hello.kt` s hlúpym obsahom:

```kotlin
fun main() {
    println("Hello!")
}
```

A veselo buildujme:

```bash
gradle assemble
```

V adresári `build/libs` sa objaví súbor JAR s výsledkom!

## Zdrojáky pre moderné Javy

Vybuildované `.class` súbory pobežia aj na prastarej Java 6. To je síce super, ale mohli by sme sa posunúť. 

Stačí parametrizovať kompilačný *task*:

```kotlin
tasks {
    withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}
```

### Štandardná knižnica pre moderné Javy

Druhou vecou je štandardná knižnica Kotlinu, ktorá je stavaná na kompatibilitu a API pre šestkovú verziu Javy. To vyriešime inou závislosťou: namiesto všeobecnej `stdlib` použijeme `stlib-jdk8`.

Celý *build script* vyzerá nasledovne:

```kotlin
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.3.41"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib-jdk8"))
}

tasks {
    withType<KotlinCompile> {
        kotlinOptions.jvmTarget = "1.8"
    }
}
```

## Mavenovské nastavenia

Aby náš projekt bol naozaj kultúrny, nastavíme mu koordináty: teda mavenovskú skupinu a verziu:

```kotlin
group = "com.github.novotnyr"
version = "0.0.1-SNAPSHOT"
```

### Nastavenia projektu `settings.gradle.kts`.

Názov projektu sa nastavuje na inom mieste, v samostatnom súbore `settings.gradle.kts`, ktorý sa tiež riadi kotlinovskou syntaxou.

Založme si ho s nasledovným obsahom:

```kotlin
// súbor settings.gradle.kts
rootProject.name = "gradle-boot-kotlin"
```

Teraz sa zostaví korektný súbor s názvom, ktorý spĺňa mavenovské konvencie, teda `gradle-boot-kotlin-0.0.1-SNAPSHOT.jar`