---
title: Vstupno-výstupné metódy v jazyku Java
date: 2007-01-12T00:00:00+01:00
---
# Úvod
Programovací jazyk, ktorý by neponúkal dostatočný repertoár prostriedkov na zabezpečenie vstupu a výstupu (napr. načítavanie z klávesnice, čítanie a zápis do súborov) by bol asi veľmi rýchlo odsúdený na neúspech. Veď čo už s takým programom, s ktorým nemôžete interagovať.

Java poskytuje tento repertoár v plnej miere. Na rozdiel od klasických procedurálnych jazykov sú prostriedky na zabezpečenie vstupu a výstupu reprezentované pomocou viacerých tried a ich metód (združených hlavne v balíčku `java.io`). Výhodou je možnosť vytvárať mnohoraké kombinácie prístupov, ktorými je možné pokryť značné množstvo prípadov použitia (chcete načítavať komprimované dáta z Internetu?). Nevýhodou sa však môže zdať relatívna komplikovanosť niektorých postupov - tam, kde Cčkar napíše `scanf()`, sa musí začiatočník v Jave vysomáriť z toho, ktoré objekty je nutné vytvoriť a čo zavolať na dosiahnutie cieľa. 

Triedy v balíčku `java.io` však majú logické usporiadanie a po pochopení niektorých základných myšlienkových pochodov je práca s nimi bezproblematická.
# Súbory
Práca so súbormi je veľmi častá (príklady si ukážeme nižšíe). Pojmu súbor (i adresár) zodpovedá trieda `java.io.File`. Pomocou takéhoto objektu môžeme testovať existenciu súboru, či získavať zoznam podadresárov (resp. súborov), vytvárať nové súbory a pod. alebo zisťovať absolútne a relatívne cesety. Samotné načítavanie dát zo súboru však rieši iná trieda, o ktorej sa zmienime hneď. 

Nasledovný príklad vypíše mená všetkých adresárov v danom adresári.
```java
File file = new File("D:\\Projects");
if(file.exists()) {
  File[] childFiles = file.listFiles();
  for (File childFile: childFiles) {
    if(childFile.isDirectory()) {
      System.out.println(childFile.getName());
    }
  }
}
```
Metódou `exists()` overíme existenciu súboru či adresára. Metóda `listFiles()` vráti zoznam súborov a adresárov v danom adresári, z ktorých vypíšeme len mená (metóda `getName()`) vráti len meno súboru bez adresárov).

Všimnime si, že na Windowse musíme zdvojiť spätné lomky v ceste k adresáru. Alternatívne môžeme používať aj obyčajné lomky (teda `/`), Java si s tým poradí a to aj na Windowse. 
# Vstupné prúdy
Výlet po triedach balíčka `java.io` začneme vstupnými prúdmi. **Vstupný prúd** je objekt, ktorý dokáže *odniekiaľ* načítavať bajty. Zdrojom bajtov môže byť naozaj hocičo, napr. súbor, rúra či internetové pripojenie.

Vstupnému prúdu zodpovedá trieda `java.io.InputStream`. Táto trieda je abstraktná (čiže si nevyrobíte novú inštanciu). Jej jednotliví dedičia reprezentujú konkrétne zdroje bajtov. Pri pohľade na dokumentáciu sa zamerajme na dve najdôležitejšie metódy:

* `int read()` načíta jeden bajt. Bajt je reprezentovaný `int`om ako číslom medzi 0..255. Ak nastane koniec súboru, vráti sa -1.
* `int read(byte[] buf)` naplní pole bajtmi načítanými zo zdroja. Vráti počet skutočne načítaných bajtov. Treba poznamenať, že vstupno-výstupné operácie sú blokujúce – teda vykonávanie príslušného vlákna sa pozastaví, kým zo zdroja „neprilezú" všetky požadované bajty. (To sa zrejme v praxi ukáže v prípade načítavania bajtov zo siete.)
* `close()` uzatvorí vstupný prúd. V prípade súborov sa oznámi operačnému systému, že súbor je možné uzavrieť, v prípade sieťového spojenia je ho možné ukončiť a pod. Platí zásada, že po skončení práce so vstupným prúdom sme povinní ho uzavrieť.

Všetky metódy hádžu výnimku `java.io.IOException`. Vstupný prúd je nutné uzavrieť vždy a to i v prípade, že nastane výnimka. Vhodným miestom je teda `finally` blok.
## Súborový vstupný prúd
Jedným z konkrétnych vstupných prúdov je súborový vstupný prúd, `java.io.FileInputStream`, ktorý umožňuje načítavať bajty zo súboru. Príklad použitia, kde zo súboru načítame prvé štyri bajty je nasledovný:
```java
InputStream in = null;
try {
  in = new FileInputStream(
    "d:\\Projects\\io\\bin\\InputStreamTest.class");
  for (int i = 0; i < 4; i++) {
    int aByte = in.read();
    System.out.println(Integer.toHexString(aByte));
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    in.close();
  } catch (Exception e) {
    /*
     ak nastala chyba pri zatváraní súboru, už je to jedno, 
     ignorujeme ju
    */
  }
}
```
Objekt `FileInputStream` bol vytvorený nad daným súborom, pričom sme v konštruktore špecifikovali rovno cestu. Jednotlivé bajty sú pred výpisom na konzolu konvertované na šestnástkový zápis – mali by sme vidieť text `CAFEBABE`, čo je hlavička `.class` súborov v Jave.

Alternatívne je možné vytvoriť `FileInputStream` nad objektom typu `File`, čiže spôsobom:
```java
File f = new File("d:\\Projects\\io\\bin\\InputStreamTest.class");
InputStream in = new FileInputStream(f);
```
## Vstupný prúd pre URL adresy
Ďalším príkladom vstupného prúdu sú bajty prichádzajúce zo zdroja reprezentovaného URL adresou, typicky z internetovej stránky. Na rozdiel od súborového vstupného prúdu, kde používame `FileInputStream` však nemôžeme použiť `URLInputStream` (taká trieda totiž nejestvuje). Musíme vytvoriť objekt pre URL adresu, teda inštanciu triedy `java.net.URL`, a z neho získať `InputStream`. 

To je možno nekonzistentné s prácou so súbormi (možno by sme očakávali, že aj súbor `File` by nám dokázal poskytnúť `InputStream`, ale nie je to tak), musíme sa však s tým zmieriť.

Príklad získania vstupného prúdu z URL adresy je uvedený nižšie.
```java
InputStream in = null;
try {
  URL url = new URL("http://www.google.com");
  in = url.openStream();
  int i = 0;
  while((i = in.read()) != -1) {
    System.out.print((char) i);
  }
} catch (MalformedURLException e) {
  System.err.println("Neplatná adresa.");
} catch (IOException e) {
  System.err.println("Vstupno-výstupná chyba.");
} finally {
  try {
    in.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
Trieda `URL` nie je obmedzená len na internetové adresy. Pomocou nej možno získavať vstupné prúdy z obyčajných súborov, JAR archívov a pod. Ak vytvoríme objekt URL nasledovne, získame tým vstupný prúd nad obyčajným súborom.
```java
URL url = new URL("file:///c:/autoexec.bat");
```
Všimnime si, že konštruktor `URL` hádže výnimku `java.net.MalformedUrlException` a to v prípade, že adresa používa nepodporovaný protokol. Ak vytvoríme adresu `http://ždiebik.sk`, tak výnimka nenastane (napriek tomu, že taká adresa určite nejestvuje). Na druhej strane, vytvorenie adresy nad [Magnet linkom](http://magnet-uri.sourceforge.net/ ) by výnimku vyvolalo.

# Výstupné prúdy
Ukázali sme si spôsob, ktorým je možné načítavať bajty. Čo však so zápisom? Existuje niečo ako `OutputStream`? Náhľad do dokumentácie ukáže, že áno. Ku vstupným prúdom existujú ich protipóly – výstupné prúdy, ktoré dokážu zapísať „niekam" jeden alebo viac bajtov.

Trieda `java.io.OutputStream` má opäť niekoľko najdôležitejších metód:

* `void write(int b)` zapíše jeden bajt.
* `void write(byte[] b)` zapíše pole bajtov.
* `void flush()` zapíše dáta z medzipamäte na príslušný výstup.
* `void close()` uzatvorí výstupný prúd. Podobne ako v prípade vstupných prúdov je takpovediac povinnosťou po skončení práce uzavrieť výstupný prúd. Ak sa tak nestane, môžu sa dokonca stratiť dáta (napr. sa nemusia zapísať dáta v medzipamäti). Ak zabudneme zavrieť výstupný prúd nad súborom vo Windowse, iné procesy nebudú môcť do tohto súboru zapisovať, čo môže spôsobiť značné problémy.

Všetky metódy tiež hádžu výnimku `java.io.IOException`. 
## Súborový výstupný prúd
`OutputStream` je opäť abstraktná trieda a až jej podtriedy špecifikujú konkrétny cieľ, do ktorého sa budú zapisovať dáta. K dispozícii je napr. súborový vstupný prúd, `java.io.FileOutputStream` demonštrovaný nižšie. Do príslušného súboru zapíšeme štyri bajty:
```java
OutputStream out = null;
try {
  out = new FileOutputStream(
    "d:\\Projects\\paz-pisomka\\InputStreamTest.bin");
  for (int i = 0; i < 4; i++) {
    int aByte = 65 + i;
    out.write(aByte);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    out.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
Namiesto cyklu by sme mohli použiť metódu zapisujúcu pole bajtov:
```java
out.write(new byte[] {65, 66, 67, 68});
```
`FileOutputStream` štandardne súbory prepisuje. Môžeme však použiť alternatívny konštruktor:
```java
OutputStream out 
  = new FileOutputStream("d:\\Projects\\io\\InputStreamTest.bin", 
                         true);
```
kde `true` v druhom parametri nastaví pripájanie dát k existujúcim (*append* mód).

# Načítavanie reťazcov pomocou *readerov*
V predošlých častiach sme demonštrovali triedy slúžiace na načítavanie a zápis bajtov. Veľmi často sa však namiesto bajtov pracuje so znakmi a reťazcami, napr. pri práci s textovým súborom. 

Na načítavanie znakov z vhodného zdroja je k dispozícii trieda `java.io.Reader`. Jej metódy sú veľmi podobné metódam `InputStream`u, ibaže pracujú priamo so znakmi.

* `int read()` načíta jeden znak. Znak je vrátený ako číslo medzi 0..65535, ktoré je možné pretypovať priamo na `char`: `char c = (char) reader.read()`. Ak nastane koniec súboru, vráti sa -1.
* `int read(char[] cbuf)` naplní pole načítanými znakmi a vráti počet skutočne načítaných bajtov. 
* `close()` uzatvorí *reader* a uvoľní systémové prostriedky. 

Metódy vracajú výnimku `IOException` a opäť poznamenávame, že uzatváranie *readerov* je skoro povinné.

Reader je všeobecná abstraktná trieda a preto treba vytvoriť inštanciu z niektorej jeho dediacej triedy. 
## Načítavanie znakov zo súboru
Trieda `java.io.FileReader` umožňuje načítavať znaky zo súboru, pričom sa použije kódovanie nastavené v operačnom systéme (napr. na Windowse je to `cp1250`). Nasledovný príklad načíta zo súboru všetky znaky a vypíše ich na konzolu:
```java
Reader in = null;
try {
  in = new FileReader("d:\\adresa.txt");
  int aByte;
  while((aByte = in.read()) != -1) {
    System.out.print((char) aByte);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    in.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
Alternatívne môžeme použiť aj konštruktor nad objektom `File`
```java
Reader in = new FileReader("d:\\adresa.txt");
```
Poznamenajme, že uvedený príklad vypíše diakritické a podobné znaky správne len v prípade, ak kódovanie súboru je zhodné s kódovaním používaným v operačnom systéme. Ak by sme napr. chceli načítať znaky zo súboru v kódovaní UTF-8 na Windowse (kde je štandardné kódovanie `cp1250`), slovenské znaky by sa zobrazili ako otázniky. Aj tento problém sa dá vyriešiť (ak poznáme kódovanie súboru), zmienime sa o tom nižšie.
## Načítavanie riadkov pomocou *readerov* s buffrom
Načítavanie riadkov pomocou predošlej metódy je síce možné, ale pomerne náročné. Idea by bola zrejme taká, že by sme kumulovali znaky v reťazci/`StringBuilder`i až do chvíle, kým by sme nenačítali koniec riadka, prípadne koniec súboru. Na tento účel by sme si dokonca mohli spraviť vlastnú triedu `LineSupportingFileReader` (`FileReader` s podporou načítavania riadkov).

S tým sa však vôbec nemusíme trápiť, pretože máme  k dispozícii triedu `java.io.BufferedReader`. Tá je reprezentantom filozofie založenej na návrhovom vzore *wrapper*. `BufferedReader` je *reader*, ktorý dodá inému readeru schopnosť načítavať reťazce po riadkoch. Inak povedané, je to reader, ktorý načítava znaky z iného readera a tieto znaky kumuluje do riadkov. Ľubovoľný reader teda môže byť obalený `BufferedReaderom` a tým získať schopnosť riadkového čítania. 

Všimnime si flexibilitu tohto návrhu. Ak by sme chceli navrhnúť reader načítavajúci riadky zo súboru, mohli by sme vytvoriť triedu dediacu z `FileReader`a a dorobiť do nej príslušnú metódu. Lenže čo v prípade, keby sme chceli načítavať riadky z readera nad internetovým pripojením? Museli by sme vytvoriť triedu `LineSupportingInternetConnectionReader` a v nej opäť dopracovať metódu. Ak by sme mali veľa readerov nad rôznymi zdrojmi, nastala by explózia počtu dediacich tried. 

Prístup založený na návrhovom vzoru *wrapper* je elegantnejší – použijeme totiž len jednu triedu poskytujúcu danú schopnosť a zaobalíme ňou ľubovoľný reader z ľubovoľného zdroja.

Požadovaný riadkovo orientovaný reader nad súborom vytvoríme nasledovne:
```java
FileReader fileReader = new FileReader("C:\\autoexec.bat");
BufferedReader in = new BufferedReader(fileReader);
```
Hlavnou metódou `BufferedReader`a je metóda `String readLine()`, ktorá vráti ďalší načítaný riadok alebo `null`, ak sa dosiahol koniec vstupného prúdu. 

Kompletný príklad, kde sa vypíše na konzolu obsah súboru je nasledovný:
```java
BufferedReader in = null;
try {
  in = new BufferedReader(new FileReader("c:\\autoexec.bat"));
  String line = null;
  while((line = in.readLine()) != null) {
    System.out.println(line);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    in.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
Ak zavoláme metódu `close()` na `BufferedReader`i, tak sa zároveň zatvorí aj obalený reader, teda sa zatvorí aj `FileReader`.

# Zápis znakov pomocou *writerov*
Tak ako `InputStream` slúži na načítavanie bajtov a jeho proťajškom `OutputStream` umožňuje ich zápis, k `Reader`u existuje `Writer` slúžiaci na zápis znakov. 

Trieda `java.io.Writer` má nasledovné významné metódy:

* ` void write(int c)` zapíše jeden znak.
* ` void write(String s)` zapíše celý reťazec.
* `void write(char[] cbuf)` zapíše pole znakov.
* `void flush()` zapíše dáta z medzipamäte na príslušný výstup.
* `void close()` uzatvorí výstupný prúd. Silne odporúčané volať po skončení práce, inak sa môžu stratiť dáta, resp. môže nastať odopretie zápisu pre iné procesy.

Všetky metódy tiež hádžu výnimku `java.io.IOException`. 

## Zápis znakov pomocou do súboru
Writer zapisujúci do súboru sa volá, prekvapivo, `java.io.FileWriter` a jeho použitie je skoro také isté, ako `FileOutputStream`u. Príklad, ktorý zapíše do súboru päťkrát daný text je uvedený nižšie:
```java
Writer out = null;
try {
  out = new FileWriter("du.txt");
  String message = "Budem si písať domácu úlohu.\n";
  for (int i = 0; i < 5; i++) {
    out.write(message);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    out.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
Všimnite si, že ak chceme zapísať reťazce po riadkoch, musíme ich ukončiť znakom `\n`. Tento znak zodpovedá UNIXovému koncu riadku. V prípade Windowsu to však nie je veľmi korektné, keďže riadky by mali byť ukončené znakmi `CR` a `LF` (`\r\n`). Program, ktorý je platformovo nezávislý, by mal vyzerať lepšie:
```java
String EOL = System.getProperty("line.separator");
...
String message = "Budem si písať domácu úlohu." + EOL;
```
Tento postup však budeme používať málokedy, pretože na zápis celých riadkov existuje trieda `BufferedWriter`.

## Zápis riadkov pomocou *writerov* s buffrom
Ukázali sme si, že na riadkové načítavanie jestvuje `BufferedReader`, ktorým možno obaliť ľubovoľný reader a tým mu dodať túto schopnosť. Na zápis riadkov je k dispozícii opäť protipól a to `java.io.BufferedWriter`. Jeho hlavná výhoda spočíva v možnosti buffrovať výstup. Obyčajný writer totiž zapisuje znaky na výstup ihneď, čo môže byť niekedy neefektívne. Zrejme je lepšie kumulovať znaky určené na zápis do nejakej medzipamäte, teda buffra a až po jej naplnení ich odoslať na výstup. Dokumentácia odporúča používať `BufferedWriter` vždy, keď je operácia zápisu relatívne náročná (spomína sa špeciálne prípad `FileWriter`a).

`BufferedWriter` poskytuje oproti klasickému `Writer`u jedinú novú metódu `void newLine()`, ktorou sa na výstup zapíše znak konca riadka. Vytvoriť inštanciu je možné napr. nasledovne
```java
BufferedWriter out = new BufferedWriter(new FileWriter("D:\\data.txt"));
```
Zápis riadku je potom možný pomocou
```java
out.write("Ahoj");
out.newLine();
```
To však stále nie je úplne ideálny stav. Našťastie je k dispozícii pomocná trieda `PrintWriter`.
## Zápis textových dát pomocou `PrintWriter`a
Trieda `java.io.PrintWriter` je veľmi užitočný writer, ktorý dokáže obaliť ľubovoľný iný `Writer` alebo `OutputStream` a dodať mu schopnosť zapisovať textové reprezentácie mnohých dátových typov. Popri metódach zdedených od klasického `Writera` poskytuje metódy ako:

* `void println(String x)` zapíše na nový riadok reťazec. Táto metóda je preťažená pre všetky primitívne dátové typy a dokonca aj pre `Object` (v tomto prípade zapíše výsledok metódy `toString()`).
* `void print(String x)` zapíše reťazec (v prípade, že je `null`, zapíše `"null"`). Táto metóda je tiež preťažená pre primitívne dátové typy a pre `Object`.
Ďalšou vlastnosťou `PrintWriter`a je to, že jeho metódy nehádžu výnimky `IOException`. Chybový stav je možné kontrolovať volaním metódy `boolean checkError()`.

Nasledovný príklad zapíše do súboru desať riadkov. Na nepárnych riadkoch je text `"Line:"`, na párnych sú čísla.
```java
PrintWriter out = null;
try {
  out = new PrintWriter(
          new BufferedWriter(new FileWriter("cisla.txt")));
  for (int i = 0; i < 5; i++) {
    out.println("Line:");
    out.println(i);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { 
    out.close();
  } catch (Exception e) {
    // do nothing
  }
}
```
V príklade `PrintWriter` obaľuje `BufferedWriter` (aby sme získali väčšiu efektivitu pri zapisovaní, v opačnom prípade by sa každý zápis odoslal ihneď do súboru, čo nemusí byť efektívne) a ten obaľuje writer nad súborom.

Zatvorenie `PrintWriter`a pomocou `close()` kaskádne zavrie `BufferedWriter` a následne `FileWriter`.

# Čítanie a zápis byteov s buffrovaním
Dosiaľ sme spomenuli možnosť buffrovania pri čítaní resp. zapisovaní reťazcov a znakov. Ale i obyčajné vstupno-výstupné prúdy je možné obohatiť o podporu buffrovania.

Trieda `java.io.BufferedInputStream` používa pri načítavaní bajtov zo vstupu buffer a teda následné volania `read()` pristupujú vo veľkej miere k buffru a nie priamo k vstupnému zdroju. Naviac táto trieda poskytuje podporu pre metódy `mark()` a `reset()`, o ktorých budeme písať v ďalšej sekcii.

Jej zapisovací kamarát `java.io.BufferedOutputStream` ukladá bajty z metódy `write()` do buffra, ktorý zapíše na výstup až po jeho naplnení. Tým znižuje počet volaní zápisu na obaľovanom výstupnom prúde.

Obe triedy sú založené na filozofii obaľovača. Príklad použitia je napr.:
```java
BufferedOutputStream out 
  = new BufferedOutputStream(new FileOutputStream("D:\\data.txt"));
```
## Metódy `mark()` a `reset()`
Metódy `read()` na vstupnom prúde sa po vstupnom prúde posúvajú smerom „dopredu". Niekedy však môže nastať situácia, keď sa chceme vrátiť v prúde späť a teda napr. načítať niektoré dáta z prúdu ešte raz. Na to môžeme použiť dvojicu metód `mark()` a `reset()`.

Metóda `mark()` si umožňuje poznačiť aktuálnu pozíciu vo vstupnom prúde (na dané miesto umiestnime „záložku"). Metódou `reset()` sa zase môžeme vrátiť v prúde naspäť na poznačenú pozíciu. Ak načítame z prúdu dva bajty, položíme záložku pred tretí bajt cez `mark()`, načítame štvrtý a následne piaty bajt a zavoláme `reset()`, ďalšie volanie metódy `read()` načíta opäť štvrtý bajt (prípadné ďalšie volania budú pokračovať piatym, šiestym atď bajtom).

Takáto záložka môže byť v prúde len jedna a je treba poznamenať, že nie všetky vstupné prúdy podporujú túto funkcionalitu. Predstavme si, že televízny signál prichádzajúci do nášho televízora sú bajty. Ak si chceme zopakovať zaujímavý gól, zrejme nemôžeme požiadať vysielateľa, aby nám to spravil na požiadanie. To isté sa týka niektorých vstupných prúdov (napr. bajtov prúdiacich zo sieťového pripojenia). Vstupný prúd `InputStream` má metódu `boolean markAvailable()`, ktorá vráti `true`, ak prúd podporuje značkovanie a návrat na označkovanú pozíciu.

Ak používaný vstupný prúd nepodporuje značkovanie, netreba zúfať. V prípade televízneho signálu by sme mohli získať možnosť púšťať zaujímavé výseky nanovo zapojením DVD rekordéra, ktorý môže slúžiť ako medzipamäť. V prípade potreby prezerania zaujímavých častí budeme čítať dáta z DVD, na ktoré sa bude ukladať prichádzajúce dáta; DVD rekordér teda slúži ako buffer. 

Túto analógiu môžeme použiť aj v prípade vstupných prúdov. Ak obalíme vstupný prúd už spomínaným `BufferedInputStream`om, získame možnosť vracať sa na označkované miesta aj v prípade, že obalený vstupný prúd túto funkciu priamo neponúka.

Poznamenajme ešte, že metóda `mark()` má jeden celočíselný parameter. Po načítaní daného počtu bajtov sa príslušná značka v prúde zneplatní, teda zabudne. Ak si označkujeme vstupný prúd 16timi bajtmi, po načítaní šestnástich bajtov sa značka v prúde zruší.

# Premostenie bytov a znakov – `InputStreamReader` a `OutputStreamWriter`
Ak sa spätne pozrieme na spôsoby, ktorými je možné načítavať dát z vhodného zdroja, zistíme, že ich môžeme logicky rozdeliť na:

* metódy pracujúce s bajtmi (`InputStream`y a `OutputStream`y)
* metódy pracujúce so znakmi a reťazcami (`Reader`y a `Writer`y)
Mohlo by sa zdať, že readery a writery sú zbytočné, veď ich funkcionalitu vieme dosiahnuť len s pomocou vstupných (výstupných) prúdov. Na to by však bolo potrebné vyriešiť niekoľko problémov a to hlavne s mapovaním bajtov na znaky a späť. Tieto náležitosti sa týkajú *kódových stránok*. Napr. v klasickom ASCII kódovaní zodpovedá bajt 65 znaku `A` a každému bajtu zodpovedá jeden znak (v bajte je možné vyjadriť 256 rôznych hodnôt, teda máme 256 znakov). Tento prístup je jednoduchý, ale obmedzuje neanglických používateľov (v ASCII asi nie je možné reprezentovať vetu `Ľaľa, už čmýri sa čmeľ`, pretože znakom ako `ľ`, či `č` nezodpovedá žiaden bajt.) Java rieši tento problém vo svojich útrobách pomocou kódovania Unicode, kde je jeden znak namapovaný na dva bajty. Lenže pri načítavaní súborov je treba vykonávať rôzne konverzie – na Windowse v kódovej stránke `cp1250` máme mapovanie 1 znak-1 bajt, kde treba vyriešiť prevody do Unicode. V kódovaní `utf-8` dokonca niektorým znakom zodpovedá jeden bajt a niektorým dva. Zrejme vidieť, že manuálne riešenie týchto problémov by spôsobilo trhanie vlasov.

Toto všetko Java uľahčuje a dáva k dispozícii triedy, ktoré reprezentuju premostenie medzi svetom bajtov a svetom znakov. 
## Premostenie vstupných prúdov a readerov
Trieda `java.io.InputStreamReader` umožňuje obaliť ľubovoľný `InputStream`, načítavať z neho bajty a prevádzať ich na znaky s použitím zadaného kódovania.

Ak chceme načítavať znaky zo súboru, ktorý je v kódovaní `utf-8`, môžeme použiť nasledovný kód:
```java
FileInputStream fileInputStream = new FileInputStream("D:\\utf8.txt");
// súborovému vstupnému prúdu dodáme podporu buffrovania kvôli
// väčšej efektivite
BufferedInputStream bufferedIn = new BufferedInputStream(fileInputStream);
InputStreamReader in = new InputStreamReader(bufferedIn, "utf-8");
```
`InputStreamReader` má metódy `Reader`a a umožňuje vrátiť používané kódovanie znakov pomocou metódy `String getEncoding()`.

Načítavanie reťazcových riadkov z `InputStream`u získame vhodným skombinovaním viacerých tried: `FileInputStream` bude načítavať bajty zo súboru, `InputStreamReader` ich prevedie na bajty a `BufferedReader` zabezpečí podporu buffrovania a metódu na načítavanie reťazcov.
```java
FileInputStream fileInputStream = new FileInputStream("d:\\utf8.txt");
InputStreamReader inReader = new InputStreamReader(fileInputStream);
BufferedReader reader = new BufferedReader(inReader);
```
Alebo na jeden riadok:
```java
BufferedReader reader 
  = new BufferedReader(
      new InputStreamReader(
        new FileInputStream("d:\utf8.txt")));
```
Možno máte pocit *deja-vu* – veď to isté sme mohli dosiahnuť pomocou kombinácie `FileReader`a a `BufferedReader`a. Nuž, je to tak. Ak si pozriete dokumentáciu k triede `java.io.FileReader`, zistíte, že je to vlastne pomocná trieda dediaca od `InputStreamReader`a, ktorá vo svojich vnútornostiach používa otvára `FileInputStream` a bajty načítavané zo súboru konvertuje na znaky s použitím implicitného kódovania v operačnom systéme. Ak však potrebujeme špecifikovať iné kódovanie než implicitné, `FileReader` nám už postačovať nebude a musíme použiť kombináciu z vyššieuvedeného príkladu.
## Premostenie výstupných prúdov a writerov
Tak ako `InputStreamReader` zabezpečuje prevod bajtov na znaky, `java.io.OutputStreamWriter` zodpovedá za opačný proces: znaky konvertuje na bajty podľa príslušného kódovania.

Filozofia je podobná ako v prípade vstupu, `OutputStreamWriter` obalí ľubovoľný `OutputStream` a obohatí ho o schopnosť zapisovať doň znaky. Príkladom zápisu znakov do súboru je:
```java
FileOutputStream fileOutputStream 
  = new FileOutputStream("utf8-out.txt");
// súborovému výstupnému prúdu dodáme podporu buffrovania kvôli
// väčšej efektivite
BufferedOutputStream bufferedOut = new BufferedOutputStream(fileOutputStream);
OutputStreamWriter outWriter 
  = new OutputStreamWriter(bufferedOut, "utf-8");
```
`OutputStreamWriter` má analogické metódy ako `Writer` a umožňuje nastaviť a vrátiť používané kódovanie.

Pomocným proťajškom k `FileReader`u je `FileWriter`, ktorý nie je ničím iným, ako zabalením `FileOutputStream`u do `OutputStreamWriter`a s použitím štandardného kódovania v operačnom systéme.

# Serializácia – zápis a načítavanie celých objektov
Dosiaľ sme pracovali len bajtmi, znakmi a reťazcami. Java však umožňuje odosielať do výstupných prúdov a načítavať zo vstupných prúdov celé objekty. Typickým príkladom je situácia, keď chceme *niekam* uložiť stav kompletného objektu a neskôr (napr. pri ďalšom spustení aplikácie) si ho obnoviť. Tento proces sa nazýva *serializácia* a Java ho do značnej miery uľahčuje. Serializácia umožňuje previesť ľubovoľný objekt na postupnosť bajtov, s ktorou môžeme spraviť to, čo uznáme za vhodné – uložiť ho do súboru, poslať po sieti a pod.

Serializovať možno ľubovoľný objekt, ktorý implementuje interfejs `java.io.Serializable`. Tento interfejs nemá žiadne metódy, indikuje len schopnosť objektu byť serializovaným. Mapovanie objektu na bajty (a prípadný spätný proces) sa deje automaticky.

Majme napríklad jednoduchú triedu osoby:
```java
import java.io.Serializable;

public class Person implements Serializable {
  private String name;
  
  private int age;

  public Person(String name, int age) {
    super();
    this.name = name;
    this.age = age;
  }

  // gettre a settre    
}
```
Na ukladanie inštancie tejto triedy do výstupného prúdu jestvuje užitočná trieda `java.io.ObjectOutputStream`. Tá reprezentuje `OutputStream`, ktorý dokáže dodať ľubovoľnému inému `OutputStream`u schopnosť ukladať objekty. Protipólom slúžiacim na čítanie je `java.io.ObjectInputStream`, ktorý dodá inému `InputStream`u schopnosť načítavať z neho objekty.

`ObjectOutputStream` má množstvo zaujímavých metód začínajúcich sa na `write` (napr. `void writeBoolean(boolean b)`. Zvyčajne zrejme budeme používať metódu `void writeObject(Object o)`, ktorá zapíše na výstup ľubovoľný objekt implementujúci interfejs `Serializable`.

Nasledovný príklad odserializuje do výstupného prúdu postupne jedno číslo, jeden reťazec a jednu inštanciu triedy `Person`:
```java
ObjectOutputStream oos = null;
try {
  ByteArrayOutputStream byteArrayOut = new ByteArrayOutputStream();
  oos = new ObjectOutputStream(byteArrayOut);

  oos.writeInt(12345);
  oos.writeObject("Today");
  oos.writeObject(new Person("Johnny Walker", 25));

  System.out.println(Arrays.toString(byteArrayOut.toByteArray()));
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try {
    oos.close();
  } catch (Exception e) {
    //do nothing
  }
}
```
Výstupným prúdom je v tomto prípade `java.io.ByteArrayOutputStream`, ktorá zapisuje do poľa bajtov. Obalením tohto výstupného prúdu schopnosťou zapisovať objekty získame možnosť získavať binárnu reprezentáciu inštancií a obsahov premenných. Výsledné pole bajtov získame z `ByteArrayOutputStream`u pomocou metódy `toByteArray()`.

Trieda `ObjectInputStream` slúžiaca na načítanie objektov zo vstupu má užitočné metódy začínajúce sa na `read`. Zvyčajnou je metódy `Object readObject()`, ktorá načíta z prúdu objekt. V príklade máme binárne dáta uložené v poli bajtov. Nad týmto poľom postavíme `java.io.ByteArrayInputStream` a ten obalíme `ObjectInputStream`, ktorý bude interpretovať tieto bajty a deserializovať ich do objektu.
```java
//v poli bajtov máme dáta 
byte[] data = {
    -84, -19, 0, 5, 119, 4, 0, 0, 48, 57, 116, 0, 5, 84, 111, 100, 
    97, 121, 115, 114, 0, 6, 80, 101, 114, 115, 111, 110, 42, -104,
    21, -71, 92, 46, -63, 108, 2, 0, 2, 73, 0, 3, 97, 103, 101, 76, 
    0, 4, 110, 97, 109, 101, 116, 0, 18, 76, 106, 97, 118, 97, 47, 
    108, 97, 110, 103, 47, 83, 116, 114, 105, 110, 103, 59, 120, 
    112, 0, 0, 0, 25, 116, 0, 13, 74, 111, 104, 110, 110, 121, 32, 
    87, 97, 108, 107, 101, 114
};

ObjectInputStream ois = null;
try {
  ByteArrayInputStream byteArrayIn = new ByteArrayInputStream(data);
  ois = new ObjectInputStream(byteArrayIn);
  //načítame jeden int
  System.out.println(ois.readInt());
  //načítame jeden Object (v skutočnosti je to reťazec)
  System.out.println(ois.readObject());
  //načítame jeden objekt Person
  Person person = (Person) ois.readObject();

  System.out.println(person.getName());
  System.out.println(person.getAge());

} catch (IOException e) {
  e.printStackTrace();
} catch (ClassNotFoundException e) {
  // pokúšame sa vytvoriť inštanciu triedy, ktorú
  // nemáme v systéme k dispozícii
  e.printStackTrace();
} finally {
  try {
    ois.close();
  } catch (Exception e) {
    //do nothing
  }
}
```
Treba poznamenať, že trieda `readObject()` hádže výnimku `ClassNotFoundException`. Môže sa stať, že sa budeme snažiť načítavať triedu, ku ktorej neexistuje v systéme binárny kód a teda Java nebude vedieť vytvoriť inštanciu tejto triedy.

Serializovať a deserializovať možno ľubovoľné komplexné objektové prepojenia (napr. `Person`, ktorý obsahuje odkaz na rodiča). Java ich korektne uloží a to vrátane všetkých prepojení a asociácii. Niekedy sa môže stať, že niektorá z asociovaných tried neimplementuje `java.io.Serializable`. V tom prípade sa pri pokuse o serializáciu vyhodí výnimka `java.io.NotSerializableException`. Príkladom môže byť osoba `Person`, ktorá má adresu `Address`, čo je neserializovateľná trieda. Pri pokuse o serializáciu inštancie osoby nastane chyba.

# Ostatné užitočné triedy balíčka `java.io`
Balíček `java.io` obsahuje aj niektoré iné užitočné triedy, ktoré sa trochu vymykajú uvedenej hierarchii.
## `System.out` (a `PrintStream`)
Premennú `System.out` používal zrejme každý už od čias prvého Java programu, ktorý vypisoval `"Ahoj svet!"`. Ak sa pozrieme na dátový typ tejto premennej, zistíme, že ide o `java.io.PrintStream`. Táto trieda je `OutputStream`om, do ktorého je možné zapisovať znaky, reťazce a ostatné primitívne dátové typy. Nie je to však divné? Spomínali sme totiž, že do výstupných prúdov sa zapisujú len bajty. Za zápis znakov (a ostatných primitívnych typov) má byť predsa zodpovedný `Writer` (resp. `PrintWriter`)! Pravda je taká, že táto trieda je v Jave len z historických dôvodov (už od verzie 1.0). V staršej dokumentácii sa dokonca uvádzalo, že `PrintStream` je už zastaralá (*deprecated*) trieda a namiesto nej je lepšie používať `PrintWriter` (iróniou je, že v novej dokumentácii už táto zmienka nie je a ani trieda už nie je zastaralá...). Táto trieda totiž prevádza zapisované znaky a reťazce na bajty s použitím kódovania používaného operačným systémom, čo môže niekedy spôsobiť stratu medzinárodných znakov. 

Metódy `PrintStream`u, podobne ako `PrintWriter`a, nehádžu výnimky `IOException`. Chybový stav je možné zistiť zavolaním booleovskej metódy `checkError`.

Podotknime, že ak by nás napadlo zatvoriť `System.out`, tak to nemusí byť práve najšťastnejším nápadom. Ak náhodou potrebujeme presmerovať štandardný výstup, môžeme použiť statickú metódu `System.setOut(PrintStream out)`, ktorej môžeme nastaviť nový `PrintStream`.
## `System.in`
Táto premenná reprezentuje štandardný vstupný prúd `InputStream`, z ktorého je možné čítať dáta prichádzajúce zo štandardného vstupu (typicky z klávesnice). S týmto `InputStream`om pracujeme ako s každým iným vstupným prúdom.

Ak chceme načítavať riadky z klávesnice, môžeme použiť tradičnú kombináciu `InputStreamReader`a (obalí `System.in` schopnosťou načítavať znaky a reťazce) a `BufferedReader`a (dodá schopnosť načítavať riadky).
```java
BufferedReader console = null;
try {
  console = new BufferedReader(new InputStreamReader(System.in));
  String line = null;
  while((line = console.readLine()) != null) {
    System.out.println(line);
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  /* 
   * zatvárať štandardný vstup nie je múdre,
   * vynecháme preto close()
   */
}
```
Tu si nemožno neodpustiť ironickú poznámku, že kým v Pascale stačí zavolať `readln()`, v Jave je vytvorenie objektu konzoly pomerne nepríjemnou záležitosťou. Začiatočníci zrejme neocenia nutnosť vytvoriť tri inštancie a odchytávať výnimky.

Našťastie, v každej novej verzii Javy prišlo k zlepšeniu.
## Skener `java.util.Scanner` (od JDK 5.0)
Skener `java.util.Scanner` je trieda, ktorá umožňuje načítavať z ľubovoľného textového zdroja reťazce, znaky a ostatné primitívne typy a to i v prípade, že vstupný textový zdroj je formátovaný. Túto triedu možno považovať za analógiou a rozšírenie funkcie `scanf()` z Cčka. Textovým zdrojom môže byť hocičo: `InputStream` (bajty sa prevedú na znaky s použitím kódovania operačného systému), readery, reťazce a pod. 

Užitočným príkladom je skener nad štandardným vstupom. Ak chceme získať analógiou pascalovského `readln()`, použijeme metódu `String nextLine()`
```java
Scanner s = new Scanner(System.in);		
while(s.hasNextLine()) {
  System.out.println(s.nextLine());
}
```
Skener sme vytvorili nad štandardným vstupom. Riadky načítavame pomocou dvoch metód: `hasNextLine()` vráti `true`, ak je možné načítať ďalší riadok (`false` sa vráti v prípade, že nastal koniec súboru). Metóda `nextLine()` zase vráti načítaný riadok.

Skener má popri tom ďalšie dvojice metód `hasNextXXX()` a `nextXXX()` (pre každý primitívny typ jednu). Skener, ktorý načíta z reťazca postupne podreťazec, boolean, celé číslo a byte je nasledovný. Skener vytvoríme nad vstupným reťazcom a nastavíme medzeru ako oddeľovač (použitím metódy `useDelimiter()`).
```java
Scanner s = new Scanner("25 25 true 25");
s.useDelimiter(" ");
System.out.println(s.next());
System.out.println(s.nextInt());
System.out.println(s.nextBoolean());
System.out.println(s.nextByte());
```
Skener nad súborom vyrobíme jednoducho: do konštruktora dodáme inštanciu `File`. Treba dať pozor na to, že ak by sme do konštruktora dali len reťazec s cestou, bude to chybou, skener sa totiž pokúsi spracovávať samotný reťazec, čo zrejme nie je to, čo chceme.
```java
Scanner scanner = null;
try {
  scanner = new Scanner(new File("input.txt"));   
  while(scanner.hasNextLine()) {
    System.out.println(scanner.nextLine());
  }
} catch (IOException e) {
  e.printStackTrace();
} finally {
  scanner.close();
}
```
Podobne ako v prípade vstupných a výstupných prúdov je slušné po skončení práce skener zavrieť, najlepšie vo `finally` bloku.

## Konzola `java.io.Console` (od JDK 6.0)
Po mnohých rokoch a bedákaniach sa do JDK dodala možnosť jednoduchého načítavania textu z konzoly a to v podobe triedy `java.io.Console`. Konzola má niekoľko významných metód:

* `String readLine()` načíta jeden riadok z konzoly. V podstate je to analógia metódy `readln` z Pascalu.
* `String readLine(String format, Object[] values)` vypíše formátovaný reťazec a načíta jeden reťazec.
* `format(String format, Object[] values)`, resp. `printf(String format, Object[] values)` vypíše na konzolu formátovaný reťazec.
V triede jestvujú aj ďalšie metódy (na načítanie hesla, získanie vstupného readera a výstupného writera). Objekt konzoly môžeme získať pomocou `System.console()`, v niektorých prostrediach sa však môže stať, že konzola k dispozícii nebude (napr. Eclipse vo verzii 3.3 ešte takúto konzolu nepodporuje).
```java
System.console().printf("Zadajte riadok:");
String line = System.console().readLine();
System.out.println(line);

int numberCount = 3;
String numberLine = System.console()
   .readLine("Zadajte %s reťazcov oddelených medzerami:", 
             numberCount);
String[] numbers = numberLine.split(" ");
if(numbers != null && numbers.length == 3) {
  for (Object object : numbers) {
    System.console().printf("%s %s\n", object.getClass(), object);
  }
}
```
## Súbor s náhodným prístupom (*random access file*)
Idey tried pre vstupno-výstupné operácie doteraz operovali hlavne s prúdmi dát. V prípade súborov sme mohli dáta zapisovať sekvenčne a načítavať rovnako len „po prúde". Drobnou výnimkou boli vstupné prúdy, kde sme sa mohli na jedno miesto vrátiť viackrát a to po použití metód `mark()` a `reset`. 

Súbor s náhodným prístupom je skôr bližší pojmu poľa bytov, po ktorom sa môžeme hýbať „kurzorom" v ľubovoľnom smere – dopredu i dozadu a to v ľubovoľnej chvíli. Do takéhoto súboru možno podľa potreby čítať a zapisovať a to v ľubovoľnom poradí. 
Na tento účel existuje trieda `java.io.RandomAccessFile`. Jej najdôležitejšie metódy sú:

* konštruktor `RandomAccessFile(File file, String mode)`, ktorý otvorí daný súbor v príslušnom móde. Módy sú podobné tým z jazyka C používané pri funkcii `fopen()`. Napr. mód `"rw"` otvorí súbor na zápis i čítanie.
* metódy `readXXX()` slúžia na načítavanie dát – k dispozícii je načítavanie primitívnych typov a reťazcov
* metódy `writeXXX()` slúžia na zápis dát – k dispozícii je zápis primitívnych typov a reťazcov. Ak zápis presiahne koniec súboru, súbor sa predĺži.
* `long length()` vráti dĺžku súboru.
* `void setLength(long length)` nastaví dĺžku súboru. Súbor je tým možné predĺžiť alebo skrátiť.
* `void seek(long position)` sa umožňuje posúvať po súbore. Parametrom je pozícia od začiatku súboru, na ktorú sa má nastaviť kurzor, čiže pozícia, od ktorej bude prebiehať najbližšie čítanie alebo zápis.
Príkladom použitia je nasledovný kód:
```java
RandomAccessFile raf = null;
try {
  raf = new RandomAccessFile("binary.dat", "rw");
  raf.writeChars("a"); //char zaberá dva bajty
  raf.writeByte(128);  //jeden bajt
  raf.seek(0);         //posun na začiatok
  char c = raf.readChar(); //načíta znak (dva bajty)
  System.out.println(c);   //vypíše znak
  System.out.println(raf.getFilePointer()); // sme na pozícii 2
} catch (FileNotFoundException e) {
  e.printStackTrace();
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try {
    raf.close();
  } catch (Exception e) {
    //do nothing
  }
}
```

# Literatúra a odkazy
* [Introduction to Java IO](http://www.digilife.be/quickreferences/PT/Introduction%20to%20Java%20IO.pdf ) – tutoriál IBM
* [Balíček `java.io`](http://java.sun.com/j2se/1.5.0/docs/api/java/io/package-summary.html ) – dokumentácia
* Java Developer's Almanac. Recepty na riešenie častých úloh s použitím [balíčka `java.io`](http://www.exampledepot.com/egs/java.io/pkg.html )


