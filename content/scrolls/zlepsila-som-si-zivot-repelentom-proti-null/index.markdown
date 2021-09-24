---
title: Zlepšila som si život prípravkom proti `null`!
date: 2021-09-24
---

V predošlom dieli sme videli použitie návrhového vzoru **monáda** na príklade škatule, ktorá dokázala obaliť ľubovoľný reťazec.

Teraz je čas to trochu vylepšiť.

- Vytvoríme triedu, ktorá dokáže obaliť ľubovoľný dátový typ -- nielen reťazec.
- Pomenujeme ju `Maybe`, pretože „možno bude obsahovať objekt, možno nie“.
- Vylepšíme funkciu `then`, ktorá umožní premeniť obsah vnútra z jedného dátového typu na druhý.

# Načo je trieda `Maybe`?

Keďže `null` je [chyba za miliardu dolárov](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/), skúsme to odstrániť.

Vždy, keď by metóda mala vracať `null`, radšej nech vráti objekt `Maybe`, ktorý buď obsahuje alebo *neobsahuje* hodnotu.
A toto vieme poľahky implementovať návrhovým vzorom **monáda**!

To, že `Maybe` obsahuje hodnotu alebo neobsahuje môžeme programovať dvojako:

- buď v podobnom duchu ako škatuľa `Box`, kde v jedinej triede určíme, či obsahuje alebo neobsahuje hodnotu
- alebo moderne, pomocou dvoch podtried: pre prípad, že objekt obsahuje hodnotu a pre prípad že nie. Tento druhý spôsob je možno zložitejší, ale nakoniec vyrieši mnoho problémov.

```
--------
| Maybe |
--------
    A    A
    |      \
--------     --------     
| Some |     |  None |
--------     ---------
```

# Podtriedy „dačo“ a „nič“

Trieda `Maybe` bude mať dve podtriedy: `Some` pre objekty s hodnotou („nejaká hodnota“) alebo `None` pre prípad, že hodnota nie je, čo je ekvivalent chýbajúcej, nedostupnej, alebo `null` hodnoty. 

> Toto je v skutočnosti variant návrhového vzoru **Null Object**, ale s mnohými vylepšeniami.

Trieda `Maybe` bude mať jedinú metódu: `then`, ktorá ... presne ako v predošlom dieli:

> ... vie na svoj obsah aplikovať Java funkciu a vrátiť novú škatuľu, ale len vtedy, ak nie je prázdna. Ak je škatuľa prázdna, vráti prázdnu škatuľu.

Inými slovami: na svoj obsah aplikuje *funkciu* a vráti nové *Maybe* s novým obsahom, ale len vtedy, ak nie je `None`. Ak je to `None`, vráti `None`.

```java
    public abstract class Maybe<V> {
        public abstract <R> Maybe<R> then(Function<V, Maybe<R>> handler);
    }
```

Oproti škatuli `Box` vie trieda `Maybe` obaliť generický dátový typ `V`, teda vie obaliť ľubovoľný objekt -- `V` ako *value*, alebo „vé ako vnútro“.

Metóda `then` berie funkciu, čo zoberie vnútro `V` a vráti iný objekt `Maybe`, ktorý obalí výslednú hodnotu typu `R` -- `R` ako *result*. Z „možno vé“ sa tak stane „možno er“.

Na to, aby to fungovalo, musíme definovať dve podtriedy -- ideálne vo vnútri triedy `Maybe` -- triedu `None` a triedu `Some`.

## Podtrieda „nič“ -- `None`

Trieda `None` je jednoduchá: keďže nemá vnútro, nemá zmysel naň aplikovať funkciu. Ak sa o to pokúsime, dostaneme z ničoho... nič.

    public static class None<V> extends Maybe<V> {
        public <R> Maybe<R> then(Function<V, Maybe<R>> handler) {
            return new None<>();
        }
    }   

## Podtrieda „dačo“ -- `Some`

Trieda `Some` je zase podobná škatuli `Box`:

    public static class Some<V> extends Maybe<V> {
        private final V value;

        public Some(V value) {
            this.value = value;
        }

        @Override
        public <R> Maybe<R> then(Function<V, Maybe<R>> handler) {
            return handler.apply(this.value);
        }
    }

Objekt `Some` *čosi* obaľuje, a ak naň použijeme funkciu, zoberieme ono „čosi“, aplikujeme naň funkciu, ktorá vráti iný objekt, čo má „možno hodnotu, možno nie“.

# Obalenie ľubovoľnej hodnoty

Okrem metódy `then()` potrebujeme možnosť zabaliť ľubovoľnú hodnotu, čo dokážeme cez konštruktor `Some()`.

Ukážme si však ukážku testu, v ktorom použijeme náš kód:

    package com.github.novotnyr.monad;
    
    import com.github.novotnyr.monad.maybe.Maybe.Some;
    import org.junit.jupiter.api.Test;
    
    import static org.junit.jupiter.api.Assertions.assertEquals;
    
    class MaybeTest {
        @Test
        void testRegularRun() {
            EtcPasswd etcPasswd = new EtcPasswd();
    
            new Some<>("root")
                    .then(login -> new Some<>(etcPasswd.findEntry(login)))
                    .then(line -> new Some<>(etcPasswd.getGecos(line)))
                    .then(gecos -> new Some<>(etcPasswd.getEmail(gecos)))
                    .then(email -> {
                        assertEquals("root@example.com", email);
                        return new Some<>(email);
                    });
        }
    }
    
Kód veľmi pripomína používanie škatule `Box`, akurát musíme použiť generický dátový typ. Našťastie, Java sa postará o automatické odvodzovanie (*inferenciu*), takže namiesto `new Some<String>` stačí písať `new Some<>`.

# Opravujeme ukecaný kód

Kód je aj tak ukecaný, takže ho vylepšíme a rovno z dvoch koncov. Oba súvisia so spracovaním `null` hodnôt.

- zavedieme si pomocnú statickú metódu, ktorá vráti rovno hotový `Maybe` a ušetríme si písanie slova `new`.
- upravíme `EtcPasswd`, keďže `null` hodnoty už nie sú potrebné!

## Obalenie priamo v `Maybe`

Do `Maybe` dodajme pomocnú metódu, ktorá automaticky rozhodne, či je vstup `null` alebo nie:

    public static <V> Maybe<V> of(V value) {
        if (value == null) {
            return new None<>();
        } else {
            return new Some<>(value);
        }
    }

Test následne upravme:

    @Test
    void testRegularRun() {
        EtcPasswd etcPasswd = new EtcPasswd();

        Maybe.of("root")
                .then(login -> Maybe.of(etcPasswd.findEntry(login)))
                .then(line -> Maybe.of(etcPasswd.getGecos(line)))
                .then(gecos -> Maybe.of(etcPasswd.getEmail(gecos)))
                .then(email -> {
                    assertEquals("root@example.com", email);
                    return Maybe.of(email);
                });
    }

## Zbavme sa `null` v triede `EtcPasswd`
    
Ak sa chceme zbaviť `null` aj z opačného konca, musíme upraviť `EtcPasswd`. Táto trieda totiž nikdy nebude vracať z metód `null`, ale vždy nejaké `Maybe`!

Najprv si však do `Maybe` dodajme ešte jednu pomocnú metódu:

    public static <V> Maybe<V> none() {
        return new None<>();
    }
    
Následne si vytvorme vylepšenú triedu `SafeEtcPasswd`, kde všetky metódy vracajú `Maybe`. Napr. metóda `getGecos()`:

    public Maybe<String> getGecos(String line) {
        String[] components = line.split(FIELD_SEPARATOR);
        if (components.length < 7) {
            return Maybe.none();
        }
        String gecos = components[4];
        if (gecos.isEmpty()) {
            return new Maybe.None<>();
        }
        return Maybe.of(gecos);
    }

Ostatné metódy necháme na pozorného čitateľa!

Ak si vytvoríme nový test, tak uvidíme, že výsledky volania metód na `SafeEtcPasswd` už nemusíme obaľovať do `Maybe`, pretože sa to deje automaticky -- každá metóda vždy vracia objekt `Maybe`.

        Maybe.of("root")
                .then(login -> etcPasswd.findEntry(login))

Keďže do metódy `then` posielame funkciu, ktorá je priamym volaním metódy na objekte, môžeme použiť odkaz na metódu, **method reference**:

    @Test
    void testSafeEtcPasswd() {
        SafeEtcPasswd etcPasswd = new SafeEtcPasswd();

        Maybe.of("root")
            .then(etcPasswd::findEntry)
            .then(etcPasswd::getGecos)
            .then(etcPasswd::getEmail)
            .then(email -> {
                assertEquals("root@example.com", email);
                return Maybe.of(email);
            });
    }

Zápis je teraz už omnoho krajší ako na začiatku, nehovoriac o pyramíde hrôzy!

# A čo so zlyhanými výsledkami?

Toto platí aj pre prípad, že postupnosť volaní zlyhá, a teda, že niektorý krok vráti `None`.

Aha, test, kde zámerne vyrobíme nespracovateľný riadok, kde je položka GECOS prázdna:

    @Test
    void testWithUnparsableLine() {
        AtomicBoolean testFailed = new AtomicBoolean(false);
        SafeEtcPasswd etcPasswd = new SafeEtcPasswd();
        Maybe.of("root:*:0:0::/var/root:/bin/sh")
                .then(etcPasswd::getGecos)
                .then(etcPasswd::getEmail)
                .then(email -> {
                    testFailed.set(true);
                    return Maybe.of(email);
                });
        assertFalse(testFailed.get());
    }
    
Test sa nikdy nedopracuje k spracovaniu emailu, ba dokonca ani k volaniu metódy `getEmail`! Keďže položka `GECOS` je prázdna, výsledkom volania `getGecos()` je hodnota `None` a zvyšok zreťazených volaní metódy `then` sa nepoužije.

Máme tak elegantný objekt `Maybe`, ktorá nikdy nenarazí na `null` a nikdy sa ním nemusíme zapodievať.

A samozrejme nezabudnime, že metóda `then()` podporuje aj iné dátové typy!

# Premieňame čísla na reťazce

Dopracujme do `SafeEtcPasswd` metódu na spracovanie identifikátora používateľa z tretej položky riadku:

    public Maybe<Integer> getUid(String line) {
        String[] components = line.split(FIELD_SEPARATOR);
        if (components.length < 7) {
            return Maybe.none();
        }
        try {
            String uidValue = components[2];
            int uid = Integer.parseInt(uidValue);
            return Maybe.of(uid);
        } catch (NumberFormatException e) {
            return Maybe.none();
        }

    }
    
Test potom vyzerá úplne rovnako ako v predošlom prípade -- metóda `getUid()` vracia možno číslo -- možno nie, ale vždy ho vráti obalené v objekte `Maybe<Integer>`. Ten pošleme na ďalšie spracovanie do `then` a ak je všetko v poriadku, výsledok je `null`.

    @Test
    void testUid() {
        SafeEtcPasswd etcPasswd = new SafeEtcPasswd();

        Maybe.of("root")
                .then(etcPasswd::findEntry)
                .then(etcPasswd::getUid)
                .then(uid -> {
                    assertEquals(0, uid);
                    return Maybe.of(uid);
                });
    }    

# Čo sme teda dostali?

Máme teda triedu `Maybe` reprezentovanú ako monádu:

- obaliť ľubovoľný objekt môžeme pomocou metódy `of()`
- v metóde `then()` dokážeme zmeniť „možno reťazec“, na „možno číslo“
- ukázali sme si iný spôsob, ako možno reprezentovať situácie, keď hodnota existuje alebo neexistuje.

Naša trieda má však stále priestor na vylepšenie:

- prečo sa vlastne oplatilo vytvárať podtriedy `Some` a `None`?
- čo keď sa vpašuje omylom do výsledkov `null`?
- nemôžeme si predsa len urobiť metódu, ktorá mapuje vnútro na vnútro bez nutnosti obaľovať výsledok do `Maybe`?

To si ukážeme nabudúce!

