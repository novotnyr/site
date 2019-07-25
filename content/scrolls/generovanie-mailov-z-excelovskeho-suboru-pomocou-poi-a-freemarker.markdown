---
title: Generovanie mailov z excelovského súboru pomocou POI a Freemarker-a
date: 2010-02-23T00:00:52+01:00
---
# Problém?
Na istú nemenovanú konferenciu bolo v istú chvíľu upozorniť autorov, že sa blíži termín pre splnenie určitých povinností. Každý z autorov článku mal splniť niekoľko náležitostí, napr.:

* zaslanie registračného formulára
* rezervácia hotela
* zaslanie článku
* zaplatenie konferenčného poplatku.

Údaje o autoroch sa nachádzali v excelovskom súbore, kde sa na druhom liste nachádzala tabuľka obsahujúca po riadkoch meno autora. V ďalších štyroch bunkách na riadku boli postupne uvedené nuly alebo jednotky, ktoré indikovali splnenie príslušnej povinnosti.

Na základe tejto tabuľky bolo potrebné vygenerovať automaticky mail, kde sa uviedlo meno autora a zoznam povinností, ktoré ešte musí daný autor splniť. V prípade, že napr. nezaslal registračný formulár ani článok, v zozname povinností mali byť len tieto dve položky.
# Riešenie pomocou POI a Freemarker-u
Úloha sa dá v Jave vyriešiť veľmi elegantne pomocou dvoch knižníc:

* [Apache POI](http://poi.apache.org/ ) je knižnica poskytujúca možnosť vytvárania a úpravy excelovských súborov
* [Freemarker](http://freemarker.org/ ) je viacúčelový nástroj na generovanie textov na základe šablóny, tzv. *template engine*

## Načítanie excelovského súboru
Načítanie excelovského súboru je elegantné:
```java
POIFSFileSystem fs = new POIFSFileSystem(
  new FileInputStream("data.xls"));
HSSFWorkbook wb = new HSSFWorkbook(fs);
HSSFSheet sheet = wb.getSheetAt(1);
```
Prvý riadok vytvorí súborový systém podporujúci prácu s OLE2 dokumentami. Druhý riadok otvorí nový *workbook* (*sešit*), z ktorého vytiahneme druhý *sheet* (*list*)) (z indexu 1).

Metódy na získavanie obsahu buniek sú prosté. Zo sheetu vytiahneme riadok pomocou `getRow()`, čím získame objekt riadka. Z riadku zase vieme vytiahnuť objekt bunky cez `getCell()`, a na nej vieme volať metódy pre získanie hodnoty, formátov a pod.

Keďže nevieme, koľko riadkov obsahuje daný list, budeme iterovať riadky dovtedy, kým nezískame `null` hodnotu, čo indikuje to, že ďalší riadok už je prázdny.

```java
do {
  HSSFRow row = sheet.getRow(i);
  if(row == null) {
    break;
  }
  //...
  i++;
} while(true);
```

Každý riadok obsahuje teda vo svojich bunkách riadky o autorovi. Vypísať obsah buniek môžeme jednoducho:
```java
for (short j = 1; j < 5; j++) {
  HSSFCell cell = row.getCell(j);
  System.out.println(cell.getNumericCellValue());
}
```
Tento kód vypíše numerické hodnoty buniek z druhého až piateho stĺpca. POI rozlišuje medzi typmi buniek -- nie je možné vypisovať číselné hodnoty z reťazcových buniek a naopak. (Typ bunky je možné zistiť volaním metódy `getCellType()` na bunke, čo vracia celočíselnú konštantu, možné hodnoty sú v [dokumentácii](http://poi.apache.org/apidocs/index.html?org/apache/poi/hssf/usermodel/HSSFCell.html ).) Metóda `getNumericCellValue()` získa obsah číselnej bunky ako `double`. Hodnoty z textových buniek môžeme získať zase pomocou `getRichStringCellValue().getString()`.

Jednotlivé riadky môžeme pohodlne namapovať na pomocné objekty obsahujúce dáta o používateľoch. S týmito objektami sa potom bude pohodlne pracovať v šablóne.

Vytvoríme si teda pomocnú triedu `Item`:
```java
public class Item {
  String name;

  boolean hasFirst;

  boolean hasSecond;

  boolean hasThird;

  boolean hasFourth;

  //gettre a settre
  ...
  //

  public void setFirst(double first) {
    this.hasFirst = (first != 0.0);
  }

  public void setSecond(double second) {
    this.hasSecond = (second != 0.0);
  }

  public void setThird(double third) {
    this.hasThird = (third != 0.0);
  }

  public void setFourth(double fourth) {
    this.hasFourth = (fourth != 0.0);
  }
}
```
Keďže číselné hodnoty v bunkách sú poskytované v podobe `double` hodnôt a pre šablónu je lepšie mať hodnoty typu `boolean`, vyrobíme si pomocné settre.

Pre každý riadok z listu teda vytvoríme novú položku typu `Item` a pre jej zapamätanie ju môžeme hodiť do pomocného zoznamu.
```java
List<Item> items = new ArrayList<Item>();
//...otvaranie suborov...
int i = 1; //skip the first row
do {
  HSSFRow row = sheet.getRow(i);
  if(row == null) {
    break;
  }
  Item item = new Item();
  item.setName(row.getCell((short)0).getRichStringCellValue()
               .getString());
  item.setFirst(row.getCell((short)1).getNumericCellValue());
  item.setSecond(row.getCell((short)2).getNumericCellValue());
  item.setThird(row.getCell((short)3).getNumericCellValue());
  item.setFourth(row.getCell((short)4).getNumericCellValue());

  items.add(item);
  i++;
} while(true);
```

## Generovanie mailov zo šablóny
Na generovanie mailov zo šablóny potrebujeme dve náležitosti:

* samotnú šablónu mailu
* dáta, ktoré sa budú do šablóny dopĺňať.
### Šablóna (súbor `template.ftl`)
```
Vážený používateľ ${item.name}!
Vzhľadom na to, že sa blíži termín konania konferencie, 
dovoľujeme si Vám pripomenúť, že je potrebné splniť nasledovné 
náležitosti:
<#if !item.first>
* zaslať registračný formulár
</#if>
<#if !item.second>
* zaplatiť konferečný poplatok
</#if>
<#if !item.third>
* zaslať camera-ready kópiu článku
</#if>
<#if !item.fourth>
* rezervovať hotel
</#if>
----------------------------------------------
```
Reťazec `${item.name}` predstavuje premennú, ktorá bude nahradená vo výsledku skutočným textom.

Značka `<#if..` predstavuje direktívu (jej syntax je podobná HTML značkám), v tomto prípade podmienku. Syntax podmienky je analogická Jave. Podmienka
```
<#if !item.fourth>
* rezervovať hotel
</#if>
```
špecifikuje, že text sa má zobraziť len vtedy, ak premenná `item.fourth` má hodnotu `false`.

### Konfigurácia Freemarkera
```java
Configuration cfg = new Configuration();
cfg.setDirectoryForTemplateLoading(new File("."));

Template template = cfg.getTemplate("template.ftl");
```
Pred použitím Freemarkera ho potrebujeme nakonfigurovať, teda vytvoriť objekt `Configuration`. Na ňom nastavíme adresár, v ktorom sa budú nachádzať šablóny.
Objekt šablóny získame na treťom riadku -- šablóna sa načíta z daného súboru.

Následne potrebujeme nastaviť obsahy pre premenné definované v šablóne (ide o premenné `item.name`, `item.first`, ... `item.fourth`. Názvy a ich hodnoty sú reprezentované v mape, ktorú vytvoríme
```java
Map model = new HashMap();
model.put("item", item)
```
Táto mapa priradí premennej `item` objekt `item` typu `Item`. Premenné definované v šablóne potom môžu používať bodkovú notáciu pri práci s objektom `item` a pristupovať tak k jeho gettrom.

Napr. premenná `${item.name}` vezme obsah premennej `item` (čo je objekt typu `Item`) a na ňom zavolá metódu `getName()`. Na výstupe sa teda objaví meno používateľa.

Analogicky podmienka `!item.fourth` zavolá metódu `getFourth()` na obsahu premennej `item` a zneguje ju.

Výsledný kód na vygenerovanie textu mailov a jeho zobrazenie na štandardný výstup je potom:
```java
Configuration cfg = new Configuration();
cfg.setDirectoryForTemplateLoading(new File("."));

Template template = cfg.getTemplate("template.ftl");
	
Writer out = new OutputStreamWriter(System.out);
Map rootModel = new HashMap();
for (Item item : items) {
  rootModel.put("item", item);
  template.process(rootModel, out);
  out.flush(); 			
}
```
Vytvoríme objekt šablóny, vytvoríme objekt `out`, do ktorého sa bude zapisovať výsledok (teda na konzolu). Prejdeme zoznamom položiek, pomocou metódy `process()` asociujeme dáta z položky so šablónou a vypľujeme ju na výstup.

Samotný objekt šablóny môžeme medzi zmenami dát recyklovať, keďže je bezstavový (nemusíme teda pre každú položku načítavať šablónu nanovo). Rovnako je užitočné `flush()`núť výstup, aby sa nestalo, že dáta ostanú v medzipamäti.

# Punchline
Na tento účel sa dá využiť aj *Hromadná korešpondencia z Wordu*, ktorá dokáže pomerne pekne zabezpečiť získavanie dát pre maily z excelovského súboru.

# Odkazy
* [Apache POI](http://poi.apache.org/ ) 
* [Freemarker](http://freemarker.org/ )
* [Java Excel API](http://jexcelapi.sourceforge.net/ ) - iný prístup k excelovským súborom
