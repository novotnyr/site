---
title: Funkcie s korením -- curry a iné príchute
date: 2021-09-13
---

> Lemon curry?
> 
> — Monty Python's Flying Circus, Ep. 33 — Salad Days, 30. 11. 1972

# Naklepávame a koreníme funkcie

V predošlom dieli sme videli, ako možno v Scale 3 jednoducho pretvárať viacparametrové funkcie na menej parametrové pomocou čiastočnej aplikácie (*partial application*).

Spomeňme si na funkciu `wc` z predošlého dielu:

    def wc(countType: String, lines: List[String]): Int = // ...
            
Funkcia `wc`, ktorá berie dva parametre -- typ a zoznam riadkov -- sa dá zmeniť na funkciu `WC` s jedným parametrom `countType` typu `String` , ktorá vracia funkciu s jedným parametrom typu `List[String]`.

    def WC(countType: String) = 
        wc(countType, _)

Všimnime si, ako sme zafixovali vo funkcii `wc` jeden parameter a jeden nechali voľný. Takto sme prakticky zredukovali počet argumentov funkcie `wc` z dvoch na jeden!

Takto vieme postaviť novú kolónu:

    val pipeline = cat.andThen(WC("-w")).andThen(println)
    pipeline(File("/etc/passwd"))

V kolóne rovno zavoláme jednoparametrovú funkciu `WC` s jedným pevným parametrom `-w`. Funkcia `WC` vráti unárnu funkciu (s neznámym menom) a táto unárna funkcia prevezme do argumentu zoznam riadkov, čím ju vieme zakomponovať do kolóny!

## Čo sa presne stalo?

Ako vidno, binárnu funkciu môžeme premeniť na unárnu funkciu, ktorá vracia unárnu funkciu. V našom príklade sme binárnu funkciu `wc` previedli na unárnu funkciu `WC`, ktorá vracia unárnu funkciu.

Ak by sme chceli byť úplne presní a uviedli dátový typ pre výsledok, zápis by bol:

    def WC(countType: String): List[String] => Int =
        wc(countType, _)

`WC` je funkcia z reťazcov do *funkcií zo zoznamov reťazcov do celých čísiel*: a naozaj, dátový typ výsledku je zapísaný ako dátový typ funkcie `List[String] => Int`.

Ak to celé zapíšeme dohromady, funkcia `WC` má dátový typ:

    String => (List[String] => Int)
    -------    --------------------
    parameter    funkcia ako
                 návratová hodnota
                 
V Scale 3, ale aj iných jazykoch platí, že *hrubá šípka asociuje sprava* a teda zátvorky môžeme vynechať:

    String => List[String] => Int

## Aký je rozdiel od čiastočnej aplikácie?

Ak sa pýtame, čím sa to líši od čiastočnej aplikácie... odpoveď je, že zatiaľ ničím. 
Je to úplne rovnaké ako v nasledovnom prípade -- veď koniec koncov, funkciu `WC` sme si zadefinovali úplne rovnako.

    val WC = wc("-w", _)
    val pipeline = cat.andThen(WC).andThen(println)
    pipeline(File("/etc/passwd"))

Zábava však začne pri funkciách viacerých premenných, teda pri viacerých parametroch!

    def grep(pattern: String, inverse: Boolean, lines: List[String]): List[String]
    
Ak má funkcia `grep` tri argumenty, môžeme ju rozbiť do troch unárnych funkcií!

Rozbime to postupne. V prvom kroku:

    def grepPattern(pattern: String) =
      grep(pattern, _, _)
    
Unárna funkcia `grepPattern` zafixuje jeden parameter v ternárnej funkcii `grep` a teda vráti tri-mínus-1-árnu funkciu s neznámym menom. Jej dátový typ je:

    (Boolean, List[String]) => List[String]

Keďže po zafixovaní parametra `pattern` nám ostali už len dva parametre: príznak inverznosti `Boolean` a zoznam riadkov `List[String]`, máme binárnu funkciu, ktorá berie usporiadanú dvojicu príznakov `Boolean` a zoznamov riadkov a vracia zoznam riadkov. 

Použime to nasledovne:

      // grepWithRoot je binárna funkcia s booleovským príznakom a zoznamom riadkkov
      val grepWithRoot = grepPattern("root")
      
      // grepWithRootRegularly je unárna funkcia so zoznamom riadkov      
      val grepWithRootRegularly = grepWithRoot(false, _)
    
      val pipeline = cat.andThen(grepWithRootRegularly).andThen(println)
      pipeline(File("/etc/passwd"))

Ak to prepíšeme do konkrétnych krokov, tak:

    def grepPattern(pattern: String) =
      val grepInverseAndLines = (inverse, lines) => grep(pattern, inverse, lines)
      grepInverseAndLines

Funkcia `grepInverseAndLines` je binárna: berie príznak inverznosti a zoznam riadkov, ktorý pošle do funkcie `grep`. Prvý parameter je zafixovaný -- získame ho z parametra `pattern` funkcie `grepPattern`.

Tento atletický obrat môžeme zopakovať aj pre funkciu `grepInverseAndLines`: z binárnej funkcie urobíme unárnu funkciu (s príznakom inverznosti), ktorá vracia unárnu funkciu zo zoznamu riadkov do zoznamu riadkov.

    def grepPattern(pattern: String) =
      val grepInverse = (inverse: Boolean) =>
        val grepInverseAndLines = (lines: List[String]) =>
          grep(pattern, inverse, lines)
        grepInverseAndLines
      grepInverse

Ak vynecháme pomocné premenné, zápis vyzerá nasledovne:

    def grepPattern(pattern: String) =
      (inverse: Boolean) =>
        (lines: List[String]) =>
          grep(pattern, inverse, lines)

Hoci sme videli množstvo akrobacie, pôvodná kolóna sa nezmenila:

    val grepWithRoot = grepPattern("root")
    val grepWithRootRegularly = grepWithRoot(false)

    val pipeline = cat.andThen(grepWithRootRegularly).andThen(println)

Načo je toto všetko dobré? Teoretickí matematici a logici majú radosť: vďaka tomuto procesu prepisu *n*-árnej funkcie na reťaz unárnych funkcií sa mnoho úvah zjednodušuje, pretože stačí meditovať nad unárnymi funkciami, ktoré vracajú unárne funkcie.

Tento proces má aj oficiálne meno: volá sa *currying* (**kariovanie**).

My, Scala programátori, to môžeme používať na skvelé triky. Ale najprv ešte trochu zmätku.

Funkcia `grepPattern` je kariovaná a ak by sme ju chceli zavolať so všetkými troma parametrami, musíme použiť trojzátvorkový zápis:

    val lines: List[String] = grepPattern("root")(false)(List("Lorem", "ipsum"))

To zodpovedá postupnosti volaní troch funkcií:

    grepPattern("root")(false)(List("Lorem", "ipsum"))
    -------------------
            grepInverse(....)
            ------------------
            grepInverseAndLines(.....................)

V Scale to vyzerá komplikovane, ale existujú jazyky, kde stačí vynechať zátvorky a zápis sa mimoriadne zjednoduší. Napríklad v Haskelli je každá funkcia kariovaná a zápis by vyzeral nasledovne:

    // Haskell
    grepPattern "root" false ["Lorem", "ipsum"]

V Scale 3 samotné kariovanie nie je až také používané, pretože sa dá takmer vždy nahradiť čiastočnou aplikáciou pomocou podtržníkov, ale existuje jedno veľmi užitočné použitie.

Kariovanie sa v Scale potichu používa pri viacerých zoznamoch parametrov! Funkcia v Scale totiž môže mať viacero sád parametrov (*multiple parameter lists*). 

Vytvorme si funkciu `linesOf`, ktorá zoberie jeden súbor `File` a jednu funkciu -- procesor -- , ktorá spracuje zoznam riadkov a vráti zoznam riadkov. Funkcia `linesOf ` má za úlohu korektne zatvoriť súbor po dokončení spracovávania.

    def linesOf(file: File)(processor: List[String] => List[String]): Unit = {
      val source = Source.fromFile(file)
      try
        val lines = source.getLines().toList
        processor(lines)
      finally
        source.close()
    }

Funkciu `linesOf ` môžeme zavolať jednoducho:

    linesOf(File("/etc/passwd"))(println)

Toto je doslova volanie karifikovanej funkcie! Do prvej sady parametrov pošleme súbor a do druhej sady parametrov funkciu `printnl`, ktorá zoberie zoznam riadkov a vytlačí ju na konzolu.

Scala však podporuje špeciálny zápis pre prípady, že v sade parametrov je funkcia na poslednom mieste:

    val file = File("/etc/passwd")
    linesOf(file) { lines =>
        println(lines)
        lines
    }

Všimnime si, že z funkcie predstavujúcej procesor v `linesOf ` sa stalo niečo ako „blok“, kde sa funkcia dá zapísať v kučeravých zátvorkách, akurát musíme uviesť parameter a hrubú šípku `=>`. Posledný riadok `lines` musíme uviesť, pretože sa očakáva, že procesor vráti zoznam riadkov. 

Vďaka kariovaniu máme viacnásobné parametre a vďaka nim máme možnosť vytvárať vlastné bloky!

## Triky pre profesionálov: kariovanie a odkariovanie

Samotná definícia kariovania je jednoduchá: 

> Každú *n*-árnu funkciu vieme previesť na postupné volanie *n* kusov unárnych funkcií. 

Ak máme funkciu s dvoma argumentami typu `A` a `B` a výsledkom typu `VÝSLEDKY`:

    (A, B) => VÝSLEDKY

Vieme ju previesť na kariovanú formu:

    A => (B => VÝSLEDKY) 

Formálne:

    f(a) = g
    g(b) = výsledok
    
To platí aj pre ternárnu funkciu:

    (A, B, C) => VÝSLEDKY
    
Vieme ju previesť na:

    A => (B => (C => VÝSLEDKY))
    
Keďže hrubá šípka asociuje sprava, je to rovnaké ako:

    A => B => C => VÝSLEDKY         

Formálne:

    f(a) = g
    g(b) = h
    h(c) = výsledok
    
Všimnime si ešte ako bonus, že kariovanie binárnej funkcie je rovnaké ako čiastočná aplikácia binárnej funkcie: výsledkom po prvom kroku je unárna funkcia a po druhom výsledok. 
Pri ternárnych a viacargumentových funkciách to už nemusí platiť!    

## Prevody v kóde

Tento prevod -- kariovanie -- môžeme zveriť Scale!

### Kariovanie v Scale 3
Binárne, ternárne a *n*-árne funkcie v Scale majú metódu `curried`, ktorá automaticky urobí prevod.

    val grepPattern = grep.curried

Ak bola funkcia `grep` ternárna, s parametrami `String`, ďalej `Boolean` a `List[String]`, výsledkom bude objekt typu

    String => Boolean => List[String] => List[String]

Čítame to zľava doprava: ide o funkciu, ktorá berie reťazec `String` a vracia funkciu z `Boolean` do funkcií, ktoré berú zoznam reťazcov a vracajú zoznam reťazcov.

Úprimne povedané, v Scale nemá takáto karifikácia valný zmysel, keďže je prakticky stále zastúpená čiastočnou aplikáciou, ale sú jazyky (napr. Haskell), kde to má veľmi hlboký zmysel.

### Odstránenie kariovania v Scale 3

Existuje aj možnosť odstránenia korenia -- dekariovanie (*uncurry*), kde poskladáme reťaz funkcií naspäť do starej dobrej viacparametrovej funkcie.

Zoberme opäť našu funkciu `linesOf` s dvoma sadami parametrov, čo je prakticky iný zápis kariovanej funkcie

    def linesOf(file: File)(processor: List[String] => List[String]): Unit
    
Ak zavoláme metódu `uncurried` na objekte `Function` a do parametra uvedieme kariovanú funkciu, získame dekariovanú funkciu.

    val linesOfFileWithProcessor = Function.uncurried(linesOf)

Dátovým typom dekariovanej funkcie `linesOfFileWithProcessor` bude `(File, List[String] => List[String]) => Unit`, čiže funkcia zo súborov a funkcií zo zoznamov reťazcov do zoznamov reťazcov do „ničoho“.

     súbor          procesor               výsledok
     ----- ----------------------------    ------
    (File, List[String] => List[String]) => Unit
           ----------------------------
               funkcia zo zoznamov
               riadkov do zoznamov 
               riadkov

Dekariovaná funkcia má dva parametre, ktoré použijeme obvyklým spôsobom, napr. s použitím zabudovanej funkcie `identity`, ktorá mapuje ľubovoľný objekt na seba samého.

    linesOfFileWithProcessor(File("/etc/passwd"), identity)    

# Kde to má naozajstný zmysel?

V Scale sa oplatí používať kariovanie pre funkcie, ktoré používajú často opakovaný parameter. 
V našich funkciách sa neustále používa parameter pre zoznam riadkov, ktorý môžeme vyčleniť do samostatného zoznamu parametrov a teda funkcie automaticky považovať za kariované.

Kariované počítanie slov, či riadkov:

    def wc(countType: String)(lines: List[String]): Int =
      val wordsInLine = (line: String) => line.split(" ").length
      countType match
        case "-l" => lines.length
        case "-w" =>
          val words = lines
            .map(wordsInLine)
            .sum
          words
        case _ => -1

Vyhľadávanie slov, teda citrusové ovocie s korením:

    def grep(pattern: String, inverse: Boolean)(lines: List[String]): List[String] =
      val shouldMatch = (line: String) =>
        val matchFound = line.contains(pattern)
        (matchFound && !inverse) || (!matchFound && inverse)
    
      lines.filter(shouldMatch)

Kolónu príkazu potom vieme zapísať:

    val file = File("/etc/passwd")
    val pipeline = cat.andThen(grep("root", false)).andThen(wc("-l")).andThen(println)

Všimnime si, ako sa posledný parameter vždy zamlčí: 

- `grep("root", false)` v kariovanej forme bez uvedeného posledného parametra vracia funkciu zo zoznamu riadkov do zoznamu riadkov
- `wc("-l")` v kariovanej forme bez uvedeného posledného parametra vracia takisto funkciu zo zoznamu riadkov do zoznamu riadkov

Takéto funkcie môžeme elegantne poskladať do kolóny.

Ak použijeme utajený infixný zápis a vynecháme bodky a zátvorky, uvidíme takmer shellový zápis:

    val pipeline = cat andThen grep("root", false) andThen wc("-l") andThen println

Tento zápis je „point-free“ (bezbodový) a využíva kariovanie.

# Záver

Kariovanie zjednodušuje formálne uvažovanie nad funkciami -- stačí uvažovať nad unárnymi funkciami, ktoré vracajú unárne funkcie.
V Scale 3 to samozrejme môžeme elegantne nasimulovať:

-  použitím podtržníka na vhodných miestach
-  v núdzi použitím funkcie `curried`
-  a najmä s využitím viacnásobných zoznamov parametrov, ktoré sa často používajú na viacero účelov, napr. pre opakované parametre.


