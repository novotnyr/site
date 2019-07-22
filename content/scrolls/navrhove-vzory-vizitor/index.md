---
title: "Návrhové vzory: Visitor"
date: 2019-07-21T12:00:00+01:00
---

O návrhovom vzore
=================

> Predstavuje operáciu, ktorá sa má vykonať na prvkoch objektovej štrultúry. Návštevník umožňuje definovať novú operáciu bez nutnosti zmeniť triedy prvkov, na ktorých bude operovať
>
> — Gang of Four: Design Patterns (1994)

Účelom návrhového vzoru **visitor** (*návštevník*) je oddelenie dátovej štruktúry od operácie, ktorú chceme vykonávať na jej prvkoch. 

- Ak chceme prejsť prvky **zoznamu** a na *každom* z nich **niečo** spraviť.
- Ak chceme prejsť uzlami **stromu** s prehľadávaním do šírky a na každom z nich **niečo** spraviť.
- Ak chceme prejsť všetkými uzlami **grafu** a na každom z nich **niečo** spraviť.
- Ak chceme prejsť po súboroch a adresároch v **súborovom systéme** a na každom z nich **niečo** spraviť.

Samotná implementácia záleží na tom, aký máme programovací jazyk. 

- Ak jazyk podporuje funkcie vyššieho rádu (*higher-order functions*), alebo *lambda-výrazy*, *visitor* sa dá implementovať prakticky jedným riadkom.
- Ak jazyk takéto funkcie nepodporuje (napr. Java 7 a staršia), môžeme to simulovať objektom.

Jazyky bez lambda výrazov
=========================

Java 7 ako príklad jazyka bez lambda výrazov, či funkcií vyššieho rádu, dokáže navrhúť visitora pomocou interfejsu:

```java
public interface Visitor<T> {
  void visit(T element);
}
```

Implementácia interfejsu hovorí, **ako** spracujeme prvky dátovej štruktúry. Napríklad:

```java
public class SystemOutPrintlnVisitor<T> implements Visitor<T> {
    public void visit(T element) {
        System.out.println(element);
    }
}    
```

Ak chceme prejsť prvky zoznamu, môžeme si vytvoriť statickú metódu s dvoma parametrami:

- dátová štruktúra, tuto zoznam `List`
- objekt visitora

```java
public static <T> void visit(List<T> list, Visitor<T> visitor) {
    for (T element : list) {
        visitor.visit(element);
    }
}
```

Použiť to môžeme nasledovne:

```java
List<String> names = Arrays.asList("John", "Paul", "Ringo", "George");
Visitor.visit(names, new SystemOutPrintlnVisitor<>());
```

Tento princíp môžeme použiť na akúkoľvek dátovú štruktúru a jej prechod. Ak máme strom, môžeme implementovať prehľadávanie do šírky ako metódu `visitBreadthFirst()` a na každom prvku zavolať visitorovu metódu. Klient našej metódy potom špecifikuje, **ako** spracujeme každý uzol stromu.

Jazyky s lambda výrazmi
=======================

Java 8, zoznamy a visitor
-------------------------

Java 8 podporuje *visitora* na zoznamoch od prírody, a to hlavne preto, že má k dispozícii lambda výrazy. Na zozname existuje metóda `forEach()`, ktorá navštívi každý prvok. Metóda berie parameter typu `Consumer`, ktorý môžeme implementovať napríklad nasledovne.

```java
public static class SystemOutPrintlnConsumer<T> implements Consumer<T> {
    @Override
    public void accept(T element) {
        System.out.println(element);
    }
}
```

Následne môžeme navštíviť každý prvok nasledovne:

```java
List<String> names = Arrays.asList("John", "Paul", "Ringo", "George");
names.forEach(new SystemOutPrintlnConsumer<>());
```

Samozrejme, s prítomnosťou Java 8 a lambda výrazov vieme skrátiť jednometódový interfejs na lambda výraz reprezentujúci funkciu.

```java
List<String> names = Arrays.asList("John", "Paul", "Ringo", "George");
Consumer<String> visitor = element -> System.out.println(element);
names.forEach(visitor);
```

*Visitor* je v tomto prípade objekt typu `Consumer<String>`, teda funkcia s jedným parametrom typu `String`, ktorá v tele vytlačí každý prvok.

Java 8 umožňuje skrátiť visitora na jediný riadok reprezentovaný zápisom funkcie.

```java
names.forEach(element -> System.out.println(element));
```

A keďže visitor zoberie *element* a zavolá metódu (funkciu) `println()`, ktorá tiež berie taký istý jeden element, môžeme metódu `println()` rovno za *visitora* prvkov zoznamu, a to s použitím odkazu na metódu (**method reference**).

```
names.forEach(System.out::println);
```

Kotlin a prechádzka ružovými kolekciami
---------------------------------------

Kotlin podporuje visitora na základných dátových štruktúrach priamo. 

### Prechádzanie zoznamom

Napríklad prechádzanie zoznamom:

```kotlin
val names = listOf("John", "Paul", "Ringo", "George")
names.forEach { println(it) }
```

Pre každý prvok zoznamu sa zavolá funkcia `println()`, ktorá dostane aktuálny prvok v implicitnej premennej `it`.

To sa dá tiež skrátiť cez **method reference**, teda odkaz na metódu:

```kotlin
val names = listOf("John", "Paul", "Ringo", "George")
names.forEach(::println)
```

### Prechádzky mapou

Podobný trik funguje aj pre mapy:

```kotlin
val members = mapOf("John" to 1940, "Paul" to 1942, "George" to 1943, "Ringo" to 1940)
members.forEach { (name, year) -> println(LocalDate.now().year - year) }
```

V tomto prípade je *visitor* reprezentovaný funkciou (lambda výrazom) s dvoma parametrami: menom (`name`) a rokom narodenia `year`, ktorá vypíše vek.

### Prechádzky grafom

Ak chceme napríklad prechádzať graf do šírky, vieme visitora definovať ako jednoduchú funkciu z uzlov do *ničoho* (teda `Unit`). 

Samotné prehľadávanie môže mať potom nasledovnú hlavičku:

```kotlin
fun<T> Node<T>.breadthFirst(visitor: (Node<T>) -> Unit)
```

Máme dva parametre: *receiver* metód reprezentujúci koreň hľadania a samotný *visitor*. Implementáciu kódu necháme radšej na pozorného čitateľa.

### Počítajúci visitor

Ak chceme visitora, ktorý spočíta riadky, nie je nič jednoduchšie. Môžeme si vytvoriť vhodný objekt / teda funkciu a použiť ju. Do konkrétnej premennej si budeme narátavať čiarku za každý navštívený prvok.

```kotlin
var count = 0
val nodeVisitor: NodeVisitor<String> = { count++ }
root.breadthFirst(nodeVisitor)
println(count)
```

A keďže Kotlin podporuje elegantnú syntax pre funkcie, ktoré berú lambda výraz ako posledný parameter, toto celé môžeme radikálne skrátiť:

```kotlin
var count = 0
root.breadthFirst {
    count++
}
println(count)
```

