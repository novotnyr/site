---
title: Šok! Funkcie v Scale sú objekty!
date: 2021-09-12
---

> Aký je rozdiel medzi súdruhom N. a japonskou kalkulačkou? 
> 
> Žiadny, majú rovnaký počet funkcií.
>
> — anektoda z polovice 20. storočia

## Funkcie a ich skladanie

Vytvorme funkciu, ktorá zoberie jeden súbor `File` a vráti zoznam riadkov, ktoré sa v ňom nachádzajú.
Inak povedané, niečo ako nástroj `cat` z Linuxu.

    import java.io.File
    import scala.io.Source
    
    def cat(file: File): List[String] =
      val source = Source.fromFile(file)
      try
        source.getLines().toList
      finally
        source.close()

Funkcia `cat` má nasledovný dátový typ:

    File => List[String]
        
Pred hrubou šípkou je dátový typ „vstupu“; za hrubou šípkou dátový typ „výstupu“, teda výsledku, teda návratovej hodnoty.

Použiť ju vieme jednoducho:

    @main def main(): Unit =
      val lines = cat(File("/etc/passwd"))
      println(lines)    
      
Nástroj `println` je tiež funkcia! Berie akýkoľvek dátový typ (`Any`) a vracia dátový typ `Unit` reprezentujúci „žiadnu“ návratovú hodnotu“ (analógia `void` z Javy, či `C`).

    Any => Unit

V ukážke sme prakticky použili skladanie funkcií — výstup z `cat` sme napojili na vstup `println`. 

To samozrejme vieme aj skrátiť, teda urobiť viac matematicky:

    @main def main(): Unit =
      println(cat(File("/etc/passwd")))      
      
Výstup z funkcie `cat` sa použije priamo ako parameter funkcie `println`. To je v poriadku, pretože `println` je zhodou okolností jednoparametrová funkcia -- **unárna funkcia**, resp. funkcia s aritou `1`.      

Funkcie v Scale sú však právoplatnými občiankami jazyka a možno s nimi narábať ako s objektami!

    val catFunction = cat
    
Premenná `catFunction` zrazu obsahuje funkciu! Dátový typ prevezme z funkcie `cat`: „funkcia zo súborov do zoznamov reťazcov“. Ak chceme, môžeme ho explicitne uviesť do kódu:

    val catFunction: File => List[String] = cat
    
Funkcia v premennej je zároveň objekt, s metódou `apply()`, ktorou môžeme funkciu zavolať:

    val lines = catFunction.apply(File("/etc/passwd"))
    println(lines)
    
Keďže volanie funkcie so vstupnými parametrami je bežná operácia, bodku a `apply` môžeme vynechať:

    val lines = catFunction(File("/etc/passwd"))
    println(lines)
    
Ak funkcie `catFunction` a `println` poskladáme priamo, uvidíme:

    println(catFunction(File("/etc/passwd")))    
        
Funkcie v Scale však môžeme skladať aj iným spôsobom -- bez použitia argumentov. Zostavíme si kolónu funkcií!

      val pipeline = cat.andThen(println)

Každá unárna funkcia má metódu `andThen`, ktorou vieme jej výstup napojiť na argument inej funkcie:

Aký dátový typ má objekt v premennej `pipeline`? Vstupom je súbor `File` a výstupom `Unit`, čiže ide o funkciu zo súborov do „unitov“ („ničoho“).

    val pipeline: File => Unit = cat.andThen(println)
    
Funkciu `pipeline` si môžeme zavolať a uvidíme výstup na konzole!
      
      pipeline(File("/etc/passwd"))            

## Skladanie troch funkcií

Pridajme si novú funkciu `wc`, ktorá spočíta počet riadkov. Bude trochu nezmyselná názvom i dátami, ale umožní nám ukázať dlhšiu kolónu!

    def wc(lines: List[String]): Int =
      lines.length

Pre poriadok si povedzme, že funkcia `wc` je zo zoznamu riadkov do čísiel, teda jej typ je

    List[String] => Int

Zaraďme ju do kolóny troch funkcií:

    val pipeline = cat.andThen(wc).andThen(println)
    pipeline(File("/etc/passwd"))
    
Všimnime si, že takéto skladanie funkcií pomocou `andThen` vôbec nepoužíva argumenty. Matematici sa snažia nájsť funkciu `f` v bode `x`, a my sa snažíme napríklad zistiť hodnotu funkcie `cat` v bode `File("/etc/passwd")`. Keďže v zápise `andThen` sa žiadne body (premenné) nepoužívajú, ide o bezbodový („point-free“) zápis.
    
Upravme teraz funkciu `wc` tak, že ju vylepšíme na binárnu funkciu -- teda funkciu s dvoma argumentami (arita 2).

    def wc(countType: String, lines: List[String]): Int =
      countType match {
        case "-l" => lines.length
        case "-w" =>
          var words = 0
          for(line <- lines) {
            words = words + line.split(" ").length
          }
          words
        case _ => -1
      }
    
Argument `countType` bude podobný ako v Linuxe: ak chceme počítať riadky, použijeme prepínač `-l`, ak slová, uvedieme `-w`.

Hneď prídeme na to, že kolóna sa pokazila: riadok s volaniami `andThen` má chybu:

    Found:    (String, List[String]) => Int
    Required: List[String] => Int
      val pipeline = cat.andThen(wc).andThen(println)

Kolóna totiž očakáva, že funkcia `wc` prijme zoznam reťazcov a vráti číslo `Int`, ale namiesto toho sme poskytli dvojicu argumentov (reťazec `String` a zoznam riadkov `List[String]`), čo prestáva dávať zmysel. Nie je jasné, na ktorý argument máme napojiť výstup z funkcie `cat` a Scala si to sama nedomyslí.

V takejto kolóne totiž môžeme používať len unárne funkcie.

## Partial application -- spevňujeme parametre funkcie

Ako však urobíme z binárnej funkcie `wc` unárnu? Jednoducho: jeden parameter uvedieme napevno.

    val wcLines = wc("-l", _)    
    
Z binárnej funkcie `wc` sme urobili unárnu: prvý parameter sme uviedli napevno a druhý parameter necháme „voľný“, čo zapíšeme podtržníkom `_`.

Dátový typ objektu `wcLines` je funkcia zo zoznamu riadkov (`List[String]`) do celých čísiel `Int`.

Funkcia `wcLines` je opäť unárna a teda vie prijať výsledok z funkcie `cat`, čiže ju môžeme zaradiť do kolóny:

    @main def main(): Unit =
      val wcLines = wc("-l", _)
      val pipeline = cat.andThen(wcLines).andThen(println)
      pipeline(File("/etc/passwd"))    
    
Trik, kde niektoré parametre funkcie uvedieme napevno a niektoré necháme voľné, sa nazýva „partial application“ -- čiastočná aplikácia funkcie. Čiastočná preto, že funkciu použijeme („aplikujeme“) len na niektoré parametre.

Treba si však všimnúť jeden dôležitý rozdiel.

* Toto vracia konkrétnu *hodnotu*: teda číslo `Int` s hodnotou 2:

        wc("-l", List("hello", "world"))
    
* Toto zas vracia *funkciu* s toľkými argumentami, koľko sme ich neuviedli napevno, teda v tomto prípade funkciu s jedným parametrom:

        wc("-l", _)
    
Opäť si všimnime, že tento druhý zápis je funkcia `wc`, ktorá vracia funkciu! V Scale je bežné, že funkcia môže vracať nielen bežné objekty, ale aj iné funkcie.

Vidíme teda, že funkcie:

- môžeme priraďovať do premenných
- môžu vracať iné funkcie
- a ešte: môžu brať funkcie ako parametre!

Pozrime sa, ako sme naprogramovali počítanie slov:

    var words = 0
    for(line <- lines) {
        words = words + line.split(" ").length
    }
    words

Toto je staré dobré procedurálne programovanie, ktoré vieme napísať aj inak.

Pripravme si najprv funkciu, ktorá dokáže zrátať počet slov v riadku:

    def wordsInLine(line: String): Int =
      line.split(" ").length

Zoznam riadkov -- objekt typu `List[String]` -- má metódu `.map()`, ktorá dokáže namapovať každý prvok zoznamu na iný prvok.
V našom prípade namapujeme každý riadok `String` na počet slov `Int`, a na toto mapovanie využijeme funkciu `wordsInLine`.

Povedané inými slovami: metóda `map()` na zozname `List[String]` prijíma ako parameter *funkciu z reťazcov* do iných objektov.

Zoberme teda riadky, namapujme ich na zoznam čísiel a pomocou metódy `sum` ich sčítajme.

    lines.map(wordsInLine).sum

Celá metóda bude nasledovná:

    def wc(countType: String, lines: List[String]): Int =
      countType match {
        case "-l" => lines.length
        case "-w" =>
          val words = lines
            .map(wordsInLine)
            .sum
          words
        case _ => -1
      }
      
## Tri parametre a štyri funkcie v kolóne      

Urobme si teraz trojargumentovú funkciu na hľadanie podreťazca! 

    def grep(pattern: String, inverse: Boolean, lines: List[String]): List[String] =
      val newLines = ListBuffer.empty[String]
      for (line <- lines)
        val matchFound = line.contains(pattern)
        if ((matchFound && !inverse) || (!matchFound && inverse))
          newLines += line
    
      newLines.toList
        
Máme teraz ternárnu funkciu (arita 3), ktorú môžeme pri použití v kolóne čiastočne aplikovať nasledovne:

    val grepNotRoot = grep("root", true, _)
    
Ak uvedieme dva argumenty napevno — hľadáme riadky, ktoré neobsahujú reťazec `root` —, výsledkom je unárna (tri-mínus-dva-árna) funkcia zo zoznamu riadkov do zoznamu riadkov.

Kolóna vyzerá nasledovne:

    val pipeline = cat.andThen(grepNotRoot).andThen(wcLines).andThen(println)
    
Ak by sme zafixovali len prvý argument, získali by sme binárnu funkciu:

    val grepWithRoot = grep("root", _, _)
    
Funkcia `grepWithRoot` je z pravdivostných hodnôt a zoznamu reťazcov do zoznamu reťazcov.

    (Boolean, List[String]) => List[String]

Ak by sme funkciu `grepWithRoot` chceli použiť v rúre, fungovať to nebude, pretože nesedí počet parametrov:

    // nefunkčný kód
    val grepWithRoot = grep("root", _, _)
    val pipeline = cat.andThen(grepWithRoot).andThen(wcLines).andThen(println)    

Uvidíme chybovú hlášku, podobnú ako v prípade funkcie `wc`: nesedí ani počet, ani dátový typ parametrov v rúre:
    
    Found:    (grepWithRoot : (Boolean, List[String]) => List[String])
    Required: List[String] => Any
      val pipeline = cat.andThen(grepWithRoot).andThen(wcLines).andThen(println)
    
Keďže výstup funkcie `cat` je tvorený zoznamom riadkov `List[String]`, očakáva sa, že tento dátový typ prijme nasledovná funkcia v kolóne `pipeline`.

Tá je však binárna -- dátový typ je `(Boolean, List[String]) => List[String]` -- a nie je jasné, do ktorého parametra by sa mal zoznam riadkov napojiť.

Čo s tým? Opäť sa očakáva, že v kolóne bude len unárna funkcia.

Zapísať to môžeme zafixovaním niektorého z dvoch dostupných parametrov binárnej funkcie `grepWithRoot`, napr. použitím hodnoty `false` pre inverzné vyhľadávanie:

    val grepWithRoot = grep("root", _, _)
    val grepWithRootRegularly = grepWithRoot(false, _)
      
    val pipeline = cat.andThen(grepWithRootRegularly).andThen(wcLines).andThen(println)

Funkcia `grepWithRootRegularly` je teraz opäť unárna -- z binárnej funkcie `grepWithRoot` sme vytvorili unárnu funkciu v premennej `grepWithRootRegularly`. Dátový typ tejto funkcie je `List[String] => List[String]`.

Alternatívne môžeme zafixovať parametre aj priamo v kolóne -- funkcie sa totiž dajú volať obvyklým spôsobom:

    val grepWithRoot = grep("root", _, _)
    val pipeline = cat.andThen(grepWithRoot(false, _)).andThen(wcLines).andThen(println)

## Funkcie a metódy

Doteraz sme v ukážke vždy využívali funkcie v tvare `def cat(...) =`.  V Scale 3 sa takéto zápisy nazývajú **top-level methods**, teda metódy na najvyššej úrovni.

V klasickom objektovo-orientovanom programovaní sa metódy vždy musia vzťahovať k nejakej triede, ale v Scale 3 to nie je nutné. Metóda na najvyššej úrovni v Scale nepatrí k žiadnemu objektu a preto sa dá prakticky stotožniť s funkciou. 

Bežná funkcia je objekt, ktorý sa vytvára nasledovným spôsobom:

    def grep(pattern: String, inverse: Boolean, lines: List[String]): List[String] =
      // funkcia, nie metóda!
      val isGrepped = (line: String) =>
        val matchFound = line.contains(pattern)
        (matchFound && !inverse) || (!matchFound && inverse)
    
      lines.filter(isGrepped)

Objekt `isGrepped` je deklarovaný ako funkcia z reťazcov do pravdivostných hodnôt, a teda jeho dátový typ je 

    String => Boolean
    
Pred hrubou šípkou udávame parametre — ich názvy a dátové typy — a za šípkou nasleduje kód funkcie. V ukážke máme dvojriadkovú funkciu, výsledkom je hodnota druhého riadku.    

Zoznam riadkov má metódu `filter`, ktorá dokáže prijať funkciu z reťazcov do `Boolean`-ov a vyhodiť tie prvky, ktoré nespĺňajú podmienku reprezentovanú funkciou v parametri.

Ak pošleme do metódy `filter` našu funkciu `isGrepped`, všetko zaklapne a vieme vyhľadávať!

Metóda `filter` je **funkcia vyššieho rádu** (**higher-order function**), pretože ide o funkciu, ktorá berie do parametra inú funkciu.

Ak by sme tento spôsob chceli zapísať metódou, museli by sme to komplikovane rozbiť na dve ternárne metódy a použiť čiastočnú aplikáciu funkcie, čo teda na tomto mieste robiť nebudeme.

Okrem toho, Scala 3 už takmer vôbec nerozlišuje medzi použitím metódy a použitím funkcie. Vždy, keď máme funkciu vyššieho rádu, môžeme ako parameter použiť buď funkciu, alebo metódu -- ak sedia dátové typy, Scala sa postará o zvyšok.

Či už máme definíciu metódy:

    def isComment(line: String) = line.startsWith("#")
    
alebo definíciu funkcie:

    val isComment = (line: String) => line.startsWith("#")
 
 môžeme ju použiť ako parameter vo funkcii vyššieho rádu, ktorá prijíma funkciu z reťazcov `String`  do pravdivostných hodnôť `Boolean`.
 
Ak metóda `filter` na zozname reťazcov berie ako parameter funkciu typu `String => Boolean`, môžeme použiť buď metódu alebo funkciu:
 
    lines.filter(isComment)
    
Táto vlastnosť sa oficiálne nazýva **eta-redukcia** (*η*-redukcia), čo je pojem z formálnej logiky, ale pri programovaní si na to ani nespomenieme.

## Záver

Funkcie v Scale majú naozaj dôležitý zmysel:

- pracujeme s nimi ako s objektami -- majú metódu `apply`
- môžeme ich skladať dohromady -- majú metódu `andThen`
- môžeme ich čiastočne aplikovať -- vytvárať nové funkcie s nižšou aritou pri použití podtržníka `_`
- môžeme vytvárať funkcie vyššieho rádu -- funkcie, ktoré berú do parametrov funkcie
- môžeme ich vytvárať ako funkcie alebo ako metódy
- rozdiel medzi funkciami a metódami sa v Scale 3 stiera
    
    




