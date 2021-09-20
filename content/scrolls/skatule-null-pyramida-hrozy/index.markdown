---
title: Škatule na `null` a pyramídy hrôzy
date: 2021-09-20
---

Predstavme si, že chceme parsovať súbor s nasledovnými vlastnosťami:

- po riadkoch sú uvedené údaje o používateľoch systému
- každý riadok obsahuje položky oddelené dvojbodkami
- piata položka obsahuje kontaktné údaje oddelené čiarkou

Príklad riadku?

    root:*:0:0:System Administrator,42A,555-798-4765,555-291-3511,root@example.com:/var/root:/bin/sh
    
Áno, je to riadok z unixového súboru `/etc/passwd`. 

- Prvá položka predstavuje login používateľa: `root`.
- Druhá, tretia a štvrtá položka nie je zaujímavá.
- Piata položka -- záznam GECOS obsahuje:
    - popis používateľa
    - číslo miestnosti
    - pracovné telefónne číslo
    - súkromné telefónne číslo
    - mailovú adresu

Urobme si triedu s metódou, ktorá zistí e-mailovú adresu používateľa. 

Na to potrebujeme metódy:

- dohľadanie riadku so zadaným loginom. Ak sa riadok nenájde, výsledok bude `null`.
- dohľadanie piatej položky GECOS. Ak sa položka nenachádza, alebo je prázdna, výsledok bude tiež `null`.
- dohľadanie piatej položky -- ale inej! -- v položke GECOS. Ak sa e-mailová adresa nenachádza, výsledok je `null`.

Vytvorme si cvičnú triedu:

```java
public class EtcPasswd {
    public static final String FIELD_SEPARATOR = ":";

    public static final String GECOS_SEPARATOR = ",";

    public String findEntry(String username) {
        return "root:*:0:0:System Administrator,42A,555-798-4765,555-291-3511,root@example.com:/var/root:/bin/sh";
    }

    public String getGecos(String line) {
        String[] components = line.split(FIELD_SEPARATOR);
        if (components.length < 7) {
            return null;
        }
        return components[4];
    }

    public String getEmail(String gecosField) {
        String[] components = gecosField.split(GECOS_SEPARATOR);
        if (components.length < 7) {
            return null;
        }
        return components[5];
    }
}
```

Metóda `findEntry()` bude zatiaľ napečená natvrdo: vráti konštantný `String`. Všetky ostatné metódy zoberú `String` a vrátia buď `String` alebo `null`, ak sa príslušný údaj (položka, záznam, podpoložka) nenájdu.

Samozrejme, kód musíme otestovať! 

```java
package com.github.novotnyr.monad;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EtcPasswdTest {
    @Test
    void testParseRootEmail() {
        EtcPasswd etcPasswd = new EtcPasswd();
        String entry = etcPasswd.findEntry("root");
        if (entry != null) {
            String gecos = etcPasswd.getGecos(entry);
            if (gecos != null) {
                String email = etcPasswd.getEmail(gecos);
                if (email != null) {
                    assertEquals("root@example.com", email);
                }
                return;
            }
        }
        fail("Failed to parse entry");
    }
}
```

Ak chceme byť hyperbezpeční, musíme každú metódu ošetriť pre prípady, že vracajú `null`. Čo sa však stalo?

    INDIANA
       JONES
          A
             PYRAMÍDA
                 HRôZY
                   !!!!!!!
                !!!
            !!!
          !!!
        !!!
    !!!
    
Každé overenie `null` odsadí kód doprava.

A toto nie je len fiktívny príklad: takýchto situácii je veľa -- napr. v starom dobrom JDBC pre prístup k databáze.

    Connection con = ...
    if(con != null)
        PreparedStatement ps = con.getPreparedStatement(...)
        if(ps != null)
            ResultSet rs = ps....
                if(rs != null) 
                    ...
                    
Nedá sa to spraviť lepšie?

Ale dá. Kód totiž opakuje dva cviky: 

1. Získaj hodnotu z metódy, zober parameter z predošlého kroku.
2. Over, či nie je `null`
3. GOTO 1.
                    
Na toto by sme si mohli urobiť užitočnú triedu!

Užitočná trieda bude škatuľa Š, ktorá dokáže:

- obaliť akýkoľvek reťazec
- zavolať na ňom akúkoľvek funkciu -- výpočtový krok, úkon, získanie riadku, získanie GECOS položky -- ktorá zoberie reťazec, vykoná nad ním, čo treba a výsledok vráti v novej škatuli.

```java
package com.github.novotnyr.monad;

import java.util.function.Function;

public class Box {
    private String value;

    public Box() {
        // vytvorí prázdnu škatuľu
    }

    public Box(String value) {
        this.value = value;
    }

    public Box then(Function<String, Box> handler) {
        if (this.value == null) {
            return new Box();
        }
        return handler.apply(this.value);
    }
}
```

Škatuľa:

- obaľuje reťazcovú hodnotu,
- má konštruktor pre prázdnu škatuľu
- vie obaliť reťazec
- vie na svoj obsah aplikovať Java funkciu a vrátiť novú škatuľu, ale len vtedy, ak nie je prázdna. Ak je škatuľa prázdna, vráti prázdnu škatuľu.

Vyrobme si test!

```java
@Test
void testWithBox() {
    EtcPasswd etcPasswd = new EtcPasswd();
    new Box("root")
            .then(login -> new Box(etcPasswd.findEntry(login)))
            .then(line -> new Box(etcPasswd.getGecos(line)))
            .then(gecos -> new Box(etcPasswd.getEmail(gecos)))
            .then(email -> {
                assertEquals("root@example.com", email);
                return new Box(email);
            });
}
```
Vyrobii sme si krabicu s iniciálnym obsahom a postupne sme aplikovali funkcie:

-   na nájdenie riadku so záznamom
-   na získanie GECOS
-   na získanie e-mailovej adresy
-   a na konci na výpis, resp. overenie testu. Finálnu škatuľu sme vrátili plnú e-mailu len preto, aby sme splnili požiadavky na funkciu.

Zbavili sme sa pyramídy hrôzy! Namiesto `if` vo vnútri `if` vo vnútri `if` sa jednotlivé kroky uvádzajú utešene pod seba. O overovanie `null`-ovosti sa stará samotná škatuľa. 

Metóda `then()` v škatuli robí dva úkony medzi dvoma krokmi algoritmu:

- overuje výsledok a jeho nie-nullovosť
- výsledok použije ako vstup do ďalšieho kroku

Táto metóda je teda **programovateľná bodkočiarka!** medzi dvoma riadkami algoritmu!

Čo však v prípade podivných vstupov? Napíšme si test:

```java
    @Test
    void testWithUnparsableLine() {
        AtomicBoolean testPassed = new AtomicBoolean(false);
        EtcPasswd etcPasswd = new EtcPasswd();
        new Box("root:*:0:0::/var/root:/bin/sh")
                .then(line -> new Box(etcPasswd.getGecos(line)))
                .then(gecos -> new Box(etcPasswd.getEmail(gecos)))
                .then(email -> {
                    testPassed.set(true);
                    return new Box(email);
                });
        assertFalse(testPassed.get());
    }
```    

Okrem `AtomicBoolean`, ktorý slúži na prepravu údajov z vnútra funkcie v `then` do overenia úspechu testu, uvidíme hneď, že test úspešne zlyhá, ak sa parsovanie nepodarí.

Ku škatuli sa oplatí jedno vylepšenie: získanie hodnoty z vnútra, a to priamo. Keďže však nechceme, aby škatuľa vracala `null`, ošetríme to výnimkou.

```java
public String getOrElse() throws NoSuchElementException {
    if (this.value == null) {
        throw new NoSuchElementException();
    }
    return this.value;
}
```
    
V teste potom:

```java
@Test
void testGetOrElse() {
    EtcPasswd etcPasswd = new EtcPasswd();
    String email = new Box("root")
            .then(login -> new Box(etcPasswd.findEntry(login)))
            .then(line -> new Box(etcPasswd.getGecos(line)))
            .then(gecos -> new Box(etcPasswd.getEmail(gecos)))
            .getOrElse();
    assertEquals("root@example.com", email);
}    
```

Rovnako môžeme otestovať aj prípad, keď parsovanie zlyhá:

```java
@Test
void testFailWithUnparsableLine() {
    EtcPasswd etcPasswd = new EtcPasswd();

    assertThrows(NoSuchElementException.class, () -> {
        new Box("root:*:0:0::/var/root:/bin/sh")
                .then(line -> new Box(etcPasswd.getGecos(line)))
                .then(gecos -> new Box(etcPasswd.getEmail(gecos)))
                .getOrElse();
    });
}
```
    
Škatuľa `Box` je v skutočnosti obal, ktorý bezpečne pracuje s `null` hodnotami!

A teraz prekvapenie: premenujme triedu `Box` na jej známy ekvivalent, pretože `Box` je to takmer isté, čo `java.util.Optional` alebo konštrukcia `Maybe` z iných jazykov.

Prečo `Maybe`? Pretože škatuľa „možno obsahuje hodnotu“.

A prečo `Optional`? Stačí

- zovšeobecniť `Box` na škatuľu s ľubovoľným dátovým typom, nielen reťazcom.
- premenovať metódu `then()` na `flatMap()`
- a umožniť z nej vracať aj iný dátový typ, než reťazec `String`.

V každom prípade, teraz to robiť nebudeme, pretože škatuľa `Box` má viacero drobných problémov, ktoré musíme vyriešiť veľkým prepisom, ale o tom nabudúce.

Nabudúce sa tiež dozvieme, že vylepšený škatuľový objekt, ktorý dokáže obaliť hodnotu, aplikovať na ňu funkciu, ktorá vracia iný škatuľový objekt, sa nazýva **monáda** a mnoho skvelých vlastností.



    


    