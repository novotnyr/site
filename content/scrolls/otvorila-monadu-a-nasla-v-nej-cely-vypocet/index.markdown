---
title: Otvorila monádu a ... našla v nej celý výpočet!
date: 2021-09-26
---

> Otvorila som monádu a ostala som v šoku! Bola v nej celá história!

Výpočty robíme bežne, napríklad:

    var message = "twinkle twinkle little star";
    message = message.toUpperCase();
    message = message.replace(" ", "");
    message = message.substring(0, 14)

Čo keby sme však chceli vedieť, aký je výsledok po každom kroku?
To by sme museli všade napchať logovanie:

    var message = "twinkle twinkle little star";

    message = message.toUpperCase();
    log("Uppercase: " + message);

    message = message.replace(" ", "");
    log("Bez medzier: " + message);
    
    message = message.substring(0, 14)
    log("Prvých 14 znakov: " + message);    

S použitím monády to môžeme spraviť oveľa lepšie: nemusíme rozsievať logovacie hlášky a už vôbec nemusíme upravovať každú z funkcií.

# Trieda `Writer`

Keďže máme funkcie, ktoré vykonávame po sebe, a činnosti medzi nimi chceme obohatiť o dodatočný kód, môžeme použiť návrhový vzor *monáda*.

Refrén po minulých dieloch:

- potrebujeme triedu, ktorá obalí nejaký generický dátový typ `R`.
- potrebujeme metódu, ktorá bežný objekt zabalí do triedy z predošlého bodu
- potrebujeme metódu, ktorá prijme funkciu, čo vybalí vnútro, čosi spočíta a vráti nový zabalený objekt do triedy z prvého bodu

Naša trieda -- nazvime ju `Writer` -- bude iným prípadom oproti `Maybe` alebo zoznamu -- pretože si bude pamätať dve veci:

1. nejakú **hodnotu**, čo bude výsledok posledného „výpočtového kroku“ -- napr. REŤAZEC s veľkými písmenami alebo `reťazecbezmedzier`.
2. **log**, teda zoznam logovacích hlášok, ktoré sa udiali počas predošlých výpočtových krokov.

Prvý nástrel!

```java
package com.github.novotnyr.monad.writer;

import java.util.ArrayList;
import java.util.List;

public class Writer<T> {
    private T value;

    private List<String> log = new ArrayList<>();

    public static <T> Writer<T> log(T value, String message) {
        Writer<T> writer = new Writer<>();
        writer.value = value;
        writer.log.add(message);

        return writer;
    }
}
```

Trieda je len glorifikovaná usporiadaná dvojica (*hodnota* a *log*).

Pomocná metóda `log` je zase glorifikovaný konštruktor, ale takto to bude lepšie vyzerať v testoch.

# Metóda pre zreťazenie

A teraz to dôležité: metóda pre zreťazenie!

```java
public <Result> Writer<Result> then(Function<Value, Writer<Result>> transformer)
```

Metóda zoberie hodnotu typu `Value` a funkciu z `Value` do výsledkov typu `Result` -- ale v obale -- a celý nový obalený výpočet vráti.

Aby sme dodržali konvencie v Jave, generické typy skrátime: `Result` na `R` a hodnoty `Value` na `T`.

```java
public <R> Writer<R> then(Function<T, Writer<R>> transformer)
```


Idea v kóde je nasledovná:

1. Použijeme funkciu na vnútro, získame obalený nový `Writer`.
2. Vytiahneme z neho hodnotu a zapamätáme si ju.
3. Vytiahneme z neho log (je to zoznam), a nalepíme ho na koniec aktuálneho logu.
4. Aj hodnotu, aj celý nový log zabalíme do nového `Writer`-a, ktorý pošleme von ako výsledok.

Naprogramujme to!

```java
public <R> Writer<R> then(Function<T, Writer<R>> transformer) {
    Writer<R> transformedWriter = transformer.apply(this.value);

    var newWriter = new Writer<R>();
    newWriter.value = transformedWriter.value;

    // zlepíme oba logy, metódu dorobíme o chvíľu!
    newWriter.log = concatenate(this.log, transformedWriter.log);
    return newWriter;
}
```

Celý tanec robíme hlavne preto, aby sme garantovali nemennosť (immutability) každého z objektov, čo predíde mnohým (mnohým!) problémom.

Ešte musíme dopracovať metódu `concatenate`:

```java
private static <T> List<T> concatenate(List<T> list1, List<T> list2) {
    List<T> result = new ArrayList<>(list1.size() + list2.size());
    result.addAll(list1);
    result.addAll(list2);
    return result;
}
```

A ako bonus, nezabudnime na *getter*, ktorým vrátime celý log:

```java
public List<String> getLog() {
    return log;
}
```

# Otestujme si monádu

Teraz si to všetko otestujme!

```java
package com.github.novotnyr.monad.writer;

import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import static com.github.novotnyr.monad.writer.Writer.log;
import static org.junit.jupiter.api.Assertions.assertEquals;

class WriterTest {
    @Test
    public void test() {
        AtomicReference<String> result = new AtomicReference<>();

        Writer<String> writer = log("twinkle twinkle little star", "START")
                .then(s -> log(s.toUpperCase(), "To upper case: [" + s + "]"))
                .then(s -> log(s.replace(" ", ""), "Remove spaces: [" + s + "]"))
                .then(s -> log(s.substring(0, 14), "First fourteen: [" + s + "]"))
                .then(s -> {
                    result.set(s);
                    return log(s, "EOF");
                });
        List<String> log = writer.getLog();

        assertEquals("TWINKLETWINKLE", result.get());
        assertEquals(5, log.size());
        System.out.println(log);
    }

}
```

Logovanie začneme pevným reťazcom, ktorý postupne transformujeme vrátane logovacích hlášok.

Ak sa pozrieme na výsledný log, bude vyzerať nasledovne:

    START
    To upper case: [twinkle twinkle little star]
    Remove spaces: [TWINKLE TWINKLE LITTLE STAR]
    First fourteen: [TWINKLETWINKLELITTLESTAR]
    EOF
    
# Sprehľadnenie zápisov    
    
Zápis môžeme skrátiť ďalšou užitočnou metódou vo triede `Writer`:

    public static <T> Writer<T> logResult(T result, String description) {
        return log(result, description + ": [" + result + "]");
    }
    
Test sa potom skráti:

```java
@Test
public void testWithHelperMethod() {
    AtomicReference<String> result = new AtomicReference<>();

    Writer<String> writer = log("twinkle twinkle little star", "START")
            .then(s -> logResult(s.toUpperCase(), "To upper case"))
            .then(s -> logResult(s.replace(" ", ""), "Remove spaces"))
            .then(s -> logResult(s.substring(0, 14), "First fourteen"))
            .then(s -> {
                result.set(s);
                return log(s, "EOF");
            });
    List<String> log = writer.getLog();

    assertEquals("TWINKLETWINKLE", result.get());
    assertEquals(5, log.size());

}   
```     

# Ešte viac sprehľadnenia

Tento zápis nie je úplne ideálny. Je viac spôsobov, ako ho skrátiť, a jeden z nich je vytiahnuť funkcie do premenných:

```java
@Test
public void testWithFunctions() {
    AtomicReference<String> result = new AtomicReference<>();

    Function<String, Writer<String>> toUpperCase = s -> logResult(s.toUpperCase(), "To upper case");
    Function<String, Writer<String>> removeSpaces = s -> logResult(s.replace(" ", ""), "Remove spaces");
    Function<String, Writer<String>> firstFourteen = s -> logResult(s.substring(0, 14), "First fourteen");

    Writer<String> writer = log("twinkle twinkle little star", "START")
            .then(toUpperCase)
            .then(removeSpaces)
            .then(firstFourteen)
            .then(s -> {
                result.set(s);
                return log(s, "EOF");
            });
    List<String> log = writer.getLog();

    assertEquals("TWINKLETWINKLE", result.get());
    assertEquals(5, log.size());

    System.out.println(log);
}
```

Aj toto by sa ešte dalo skrátiť, ale to by sme sa dostali do krajiny kompozícií funkcií, na čo teraz nemáme čas.

Funkcie sú teraz elegantne zreťazené a všetko sa loguje správne!

# Rúry logovaných funkcií

Pre odvážlivcov môžeme pripraviť dvojicu užitočných metód: `start()` a `pipe()`:

Metóda `start` v triede `Writer` len obalí výsledok s prázdnou hláškou.

```java
public static <T> Writer<T> start(T value) {
    return log(value, "");
}
```

Metóda `pipe` zavolá reťazec funkcií a začne logovať:

```java
@SafeVarargs
public final Writer<T> pipe(Function<T, Writer<T>>... transformers) {
    Writer<T> intermediateWriter = this;
    for (Function<T, Writer<T>> transformer : transformers) {
        intermediateWriter = intermediateWriter.then(transformer);
    }
    return intermediateWriter;
}
```

A kód potom vyzerá už celkom milo:

```java
Function<String, Writer<String>> toUpperCase = s -> logResult(s.toUpperCase(), "To upper case");
Function<String, Writer<String>> removeSpaces = s -> logResult(s.replace(" ", ""), "Remove spaces");
Function<String, Writer<String>> firstFourteen = s -> logResult(s.substring(0, 14), "First fourteen");

var writer = start("twinkle twinkle little star")
        .pipe(toUpperCase, removeSpaces, firstFourteen)
```

Tu si utešene vytvoríme rúru (*pipe*) a dáta prepasírujeme cez viaceré funkcie, pričom po ceste vyrábame log!

# Záver

Vidíme, že monáda môže fungovať aj nad viacerými zložkami naraz -- monáda `Writer` ukazuje príklad „programovateľnej bodkočiarky“, kde sa medzi jednotlivými krokmi programu automaticky dejú ľubovoľné veci -- napríklad zápis medzivýsledkov do logu.    


