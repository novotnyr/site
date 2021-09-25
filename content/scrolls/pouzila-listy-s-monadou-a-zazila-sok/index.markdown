---
title: Použila listy s monádou a zažila šok!
date: 2021-09-25
---

> Odkedy používam zoznamy s monádou, môj život je omnoho lepší!

Už včera sme videli, že škatule a objekty `Maybe` zlepšujú zápis alebo predchádzajú chybám s `null`! A to všetko vďaka návrhovému vzoru **monáda**.

Teraz je čas postúpiť ďalej: kým škatule a *môžbyť* obsahovali vec alebo „žiadnu vec“, ukážme si namonádovaný zoznam, ktorý obsahuje **viac položiek!**

Monáda potrebuje:

- Dátový typ, ktorý obalí,
- Spôsob, akým obalí veci daného typu,
- Metódu, ktorá vybalí vnútro monády, použije naň *funkciu* a z nej získa novú zabalenú vec.


# Monadický zoznam!

Vyrobme si teraz monadický zoznam prvkov a nazvime ho **superzoznam** `SuperList`, pretože bude omnoho lepší než klasický zoznam!

- obalíme ľubovoľný typ `T` a pripravíme si:
    - konštruktor, ktorý vie prevziať kolekciu prvkov typu `T`
    - pomocnú statickú metódu, ktorou vybudujeme superlist na základe viacerých prvkov
- pripravíme si zabaľovaco-vybaľovaco-spracovateľskú metódu, ale teraz sa nebude volať `then`, ale `bind`.

## Metóda `bind`
Metóda `then`, teda `bind` bude vyzerať nasledovne:

- pripravíme si prázdny výsledný zoznam prvkov
- nad každým prvkom z aktuálneho superzoznamu zavoláme funkciu, ktorá spočíta údaje a vráti nový superzoznam
- z tohto nového superzoznamu vytiahneme vnútro -- teda prvky a prehodíme ich do celkového výsledného zoznamu prvkov
- na konci obalíme výsledný zoznam prvkov do superzoznamu a vrátime ho ako výsledok!

```java
public <R> SuperList<R> bind(Function<T, SuperList<R>> handler) {
    List<R> newItems = new ArrayList<>(); 
    for (T item : items) {
        SuperList<R> partialSuperList = handler.apply(item);
        newItems.addAll(partialSuperList.getItems());
    }
    return new SuperList<>(newItems);
}
```    

## Celý kód

Celý kód obsahuje už len tri veci:

- konštruktor, ktorým vytvoríme superzoznam na základe klasickej kolekcie
- pomocná metóda na vytváranie superzoznamu z prvkov, čo sa hodí v testoch
- a metóda, ktorou získame zo superzoznamu klasický zoznamu


```java
package com.github.novotnyr.monad.list;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.function.Function;

public class SuperList<T> {
    private final List<T> items = new ArrayList<>();

    public SuperList(Collection<T> entries) {
        this.items.addAll(entries);
    }

    public <R> SuperList<R> bind(Function<T, SuperList<R>> handler) {
        List<R> newItems = new ArrayList<>(); 
        for (T item : items) {
            SuperList<R> partialSuperList = handler.apply(item);
            newItems.addAll(partialSuperList.getItems());
        }
        return new SuperList<>(newItems);
    }

    public static <T> SuperList<T> listOf(T... items) {
        return new SuperList<>(Arrays.asList(items));
    }

    public List<T> getItems() {
        return this.items;
    }
}
```

Unit test bude vytvorí zoznam troch čísiel, vynásobí ich dvoma a zistí, či to zbehlo v poriadli:

```java
package com.github.novotnyr.monad.list;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.List;

import static com.github.novotnyr.monad.list.SuperList.listOf;

class SuperListTest {
    @Test
    public void testMultiplication() {
        List<Integer> doubles = listOf(1, 2, 3)
                .bind(n -> listOf(n * 2))
                .getItems();

        Assertions.assertEquals(Arrays.asList(2, 4, 6), doubles);
    }
}
```

Keďže sme si umne pripravili statickú metódu `listOf()`, s použitím statického importu máme celkom pekný zápis!

# Pravá zábava: výpočty nad funkciami s viacerými výsledkami

Toto je samozrejme v poriadku, ale pravá zábava nastáva vtedy, ak máme výpočty, ktoré môžu vracať viac hodnôt **naraz**!

Vymyslime si metódu, ktorá pre číslo *n* vráti jeho susedov: teda číslo o jedna menšie, samotné číslo a číslo o 1 väčšie.

Inak povedané, vstupom metódy je číslo a výsledkom je trojica čísiel. 
Keďže máme superzoznam, neváhajme ho použiť!

```java
package com.github.novotnyr.monad.list;

import static com.github.novotnyr.monad.list.SuperList.listOf;

public class Utils {
    public static SuperList<Integer> neighbours(int number) {
        return listOf(number - 1, number, number + 1);
    }
}
```

Test potom vyzerá nasledovne:

```java
@Test
void testNeighbours() {
    List<Integer> neighbours = listOf(1, 2, 3)
            .bind(Utils::neighbours)
            .getItems();

    List<Integer> expected = Arrays.asList(0, 1, 2, 1, 2, 3, 2, 3, 4);
    Assertions.assertEquals(expected, neighbours);
}
```

Vytvorili sme superzoznam troch čísiel, aplikovali naň funkciu `neighbours` a výsledkom je .. spľasnutý zoznam deviatich čísiel!

Presnešie povedané, postupne prechádzame zoznam troch čísiel, na každé z nich použijeme `neighbours` a výsledné čiastkové superzoznamy zlúčime dohromady do jedného zoznamu.

Postupne to vyzerá nasledovne

```
1 -> [0, 1, 2]
2 -> [1, 2, 3]
3 -> [2, 3, 4]
```

Máme teda zoznam troch zoznamov:

```
[[0, 1, 2], [1, 2, 3], [2, 3, 4]]
```

Funkcia `bind` zoberie tri čiastkové superzoznamy a zlepí ich dohromady do jedného veľkého superzoznamu:

## Susedia a duplikácie!


Môžeme si urobiť aj iný test, kde zistíme susedov a každého z nich zduplikujeme!

```java
@Test
void testNeighboursAndDuplicate() {
    List<Integer> neighbours = listOf(7)
            .bind(Utils::neighbours)
            .bind(n -> listOf(n * 2))
            .getItems();

    List<Integer> expected = Arrays.asList(12, 14, 16);
    Assertions.assertEquals(expected, neighbours);
}
```    

Z čísla 7 vzniknú susedia 6, 7 a 8, a keď ich zduplikujeme, očakávame 12, 14 a 16!

# Alternatívny bind - skratka pre prevod prvku na prvok

Metóda `bind` očakávala funkciu, ktorá vráti superzoznam, teda monadický zoznam. 
Mnohokrát sme však leniví a vieme, že každý prvok zoznamu budeme premieňať na iný prvok zoznamu.

Nebolo by skvelé niečo takéto?

    List<Integer> doubles = listOf(1, 2, 3)
            .bind(n -> n * 2)
            .getItems();
            
Určite áno!

Našťastie, ak skombinujeme `bind` a obaľovaciu funkciu `listOf`, vieme si zjednodušiť život.

Dôležité je, že funkcia v parametri už nevracia superzoznam `SuperList<R>`, ale len bežný jednoduchý prvok `R`.

Iniciálny kód:

```java
public <R> SuperList<R> map(Function<T, R> mapper) {
    List<R> newItems = new ArrayList<>();
    for (T item : items) {
        R partialItem = mapper.apply(item);
        newItems.add(partialItem);
    }
    return new SuperList<>(newItems);
}
```

Otestujeme to so zjednodušeným zápisom:

```
@Test
public void testMultiplicationWithMap() {
    List<Integer> doubles = listOf(1, 2, 3)
            .map(n -> n * 2)
            .getItems();

    Assertions.assertEquals(Arrays.asList(2, 4, 6), doubles);
}
```

Namiesto zápisu `bind(n -> listOf(n * 2)` už vraciame len jednoduchý dvojnásobok. Funkcia `map` sa postará o odbalenie a zabalenie do monádového superzoznamu.


Ak by sme chceli skombinovať `bind` a `listOf` a máme odvahu skladať funkcie, spravme to:

```
public <R> SuperList<R> map(Function<T, R> mapper) {
    Function<T, SuperList<R>> handler = mapper.andThen(SuperList::listOf);
    return bind(handler);
}
```

# Čo sme ukázali?

Náš superzoznam je tretí príklad monády, ktorý ukazuje, že stačí definovať triedu obaľujúcu typ, pridať pár konštruktorov, a metódu `then`, resp `bind` a vieme robiť kúzelné veci!

Pekné prekvapenie je, že v Jave už superzoznam existuje: stačí na `java.util.List` zavolať metódu `stream()` a získať prúd `java.util.stream.Stream!`

- metóda `map` je rovnaká ako naša metóda `map`
- a metóda `flatMap` je rovnaká ako naša metóda `bind`. 

Názov `flatMap` znamená, že prvok premeníme -- namapujeme -- na iný prvok zoznamu a ak by náhodou tento výsledný prvok predstavoval zoznam, tak ho odbalíme („spľaštíme“) a jeho vnorené prvky vložíme do výsledku bez obalu.

    @Test
    void testStream() {
        List<Integer> neighbours = Stream.of(1, 2, 3)
                .flatMap(n -> Stream.of(n - 1, n, n + 1))
                .collect(Collectors.toList());

        List<Integer> expected = Arrays.asList(0, 1, 2, 1, 2, 3, 2, 3, 4);
        Assertions.assertEquals(expected, neighbours);
    }

To je dôkaz, že od istej chvíle všetko bude vyzerať ako monáda!     


