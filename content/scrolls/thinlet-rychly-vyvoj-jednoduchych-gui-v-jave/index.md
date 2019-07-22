---
title: Thinlet – rýchly vývoj jednoduchých GUI v Jave
date: 2010-02-14T00:00:00+01:00
---

Úvod
====

„Okienkové“ aplikácie síce netvoria dominantu javovských projektov.
Klasickou voľbou je použitie knižnice Swing (zabudovanej v Jave) či SWT
(od IBM). Obe knižnice sú dostatočne stabilné a tešia sa širokej podpore
a používaniu.

Jednou z ich typických charakteristík je definícia používateľského
rozhrania priamo v kóde. Niekedy v roku 2005 však vznikla vlna
projektov, ktorá pristupovala k implementácii grafických rozhraní
odlišným spôsobom. Samotné používateľské rozhranie je definované v XML
súboroch, a Java kód len definuje samotnú funkcionalitu a príslušnú
obslužnú logiku. Filozofia je teda podobná situácii z webových
aplikačných rámcov, kde je výzor používateľského rozhrania je definovaný
v HTML, čím je možné oddeliť zodpovednosti jednotlivých vývojárov
(webový dizajnér nemusí ovládať Javu a vývojár zase nemusí pamätať na
nuansy návrhu). V prípade grafických aplikácii stráca táto výhoda svoj
význam. I tak však zostáva jedna pozitívna vlastnosť: odčlenením výzoru
od kódu je možné zmeniť vzhľad používateľského rozhrania bez
rekompilácie aplikácie. Navyše, XML je všeobecnejšia štruktúra ako kód,
čím lepší potenciál pre vývoj "vizuálnych klikátiek" grafických
rozhraní.

> **Note**
>
> Inšpiráciou pre túto módnu vlnu bola Mozilla (v dnešnej inkarnácii
> Firefoxu), ktorá používa na definíciu GUI kombináciu XML+JavaScript,
> známu pod skratkou XUL (*XML User Interface Language*). Java projekty,
> ktoré sa ňou inšpirovali, boli školským príkladom módnej vlny, ktorá
> zmizla rovnako rýchlo ako odišla. Z niekdajšieho celkového počtu 10 a
> viac projektov dnes v súčasnosti nie je aktívny ani jeden. Vo svete
> .NET však táto vlna pretrvala \-- jazyk XAML možno použiť na definíciu
> GUI windowsovských aplikácií.

Jedným z mnohých projektov, ktorých životnosť bola o niečo dlhšia, je
Thinlet. Okrem vízie XML definície rozhraní si dával za primárny cieľ
minimálnu veľkosť knižnice a beh na čo najväčšom počte platforiem. V
tomto článku si ukážeme niekoľko jednoduchých príkladov použitia tejto
knižnice (či skôr triedy, keďže Thinlet je tvorený jednou obrovskou
triedou).

Stiahnutie
==========

Nájsť správnu verziu Thinletu nie je napodiv až také jednoduché. Možno
nájsť projekt na
[SourceForge.net](http://thinlet.sourceforge.net/home.html), kde je
posledná verzia pod názvom `thinlet-2005-03-28.zip`.

> **Note**
>
> Ak zamierite na portál Thinlet.com, ukáže sa, že existuje ešte novšia
> verzia 0.75beta. Tá je však kompletným prepisom pôvodnej verzie, ktorá
> síce ponúka viac možností, ale vyžaduje vyššiu verziu Javy, a
> neobsahuje niektorú dôležitú funkcionalitu. (Absentuje napríklad
> layout manager, ktorý funguje aj pri zmene veľkosti okna.)

Do projektu si následne pridáme `thinlet.jar` (38 kB) a môžeme začať
vyvíjať.

Vytváranie aplikácie
====================

Naša aplikácia bude jednoduchá: z internetu zistí aktuálny kurz dolára v
Európskej centrálnej banke. Najprv však spravme primitívne okno, ktoré
bude obsahovať jediný popisok *label* a jedno textové políčko.
Predovšetkým budeme potrebovať definíciu používateľského rozhrania.

Vytvorme súbor `ExchangeRateForm.xml` a uložme ho do vhodného adresára,
najlepšie do zdrojového adresára zodpovedajúceho balíčku exchangerates.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE panel PUBLIC '-//Thinlets 1.0//EN' 'https://thinlet.dev.java.net/thinlet.dtd'>

<panel>
    <label text="Current Exchange Rate for USD:" />
    <textfield text="[unknown]"  />
</panel>
```

Samotné okno zodpovedá panelu (všeobecnému kontajneru pre komponenty),
do ktorého umiestnime popisok *label* a textové políčko *textfield*.
Nadpis v políčku, resp. text obsiahnutý v textovom poli nastavíme
pomocou atribútu name.

Prejdime teraz k samotnej triede s názvom
`exchangerates.ExchangeRateForm`.

```java
package exchangerates;

import java.io.IOException;

import thinlet.FrameLauncher;
import thinlet.Thinlet;

public class ExchangeRateForm extends Thinlet {
    public ExchangeRateForm() {
        try {
            add(parse(getClass().getSimpleName() + ".xml"));
        } catch (IOException e) {
            throw new IllegalStateException("Illegal or missing form definition.", e);
        }
    }

    public static void main(String[] args) {
        FrameLauncher frameLauncher = new FrameLauncher("Exchange Rate", new ExchangeRateForm(), 320, 200);
        frameLauncher.pack();
    }
}
```

Trieda dedí od triedy `thinlet.Thinlet` a v rámci konštruktora načíta
svoju definíciu z XML súboru, ktorý má rovnaké meno ako ona a nachádza
sa v rovnakom balíčku. Samozrejme, možno zvoliť ľubovoľnú inú konvenciu,
dôležité je, aby bol definičný súbor XML k dispozícii.

> **Warning**
>
> Jednou z očividných nevýhod Thinletu sú absolútne nepomáhajúce chybové
> hlášky. V prípade, že načítavate súbor z CLASSPATH a ten sa nenájde,
> získate len ničnehovoriacu NullPointerException.

Pre jednoduchosť sme tiež dodali metódu main(), v ktorej využijeme na
zobrazenie nášho formulára triedu `FrameLauncher`. V jeho konštruktore
uvedieme postupne text, ktorý sa zobrazí v záhlaví okna, našu inštanciu
`Thinlet`u a odporúčané rozmery hlavného okna.

`FrameLauncher` je zároveň inštanciou triedy `java.awt.Frame` a v
prípade, že rozmery nevieme vhodne umiestniť, môžeme sa spoľahnúť na
implicitné rozmery ovládacích prvkov a zavolaním metódy pack() nastaviť
veľkosť okna automaticky.

Po vytvorení inštancie `FrameLaunchera` sa automaticky zobrazí nové okno
s dvoma komponentami. Thinlet automaticky rozloží komponenty vedľa seba
a nastaví im preferované (implicitné) rozmery

Ak sa zdá, že sú komponenty príliš "nahusto", stačí upraviť okraje:
atribúty left, right, bottom, right udávajú šírku príslušného okraja a
element gap udáva veľkosť medzery medzi komponentami.

    <panel top="5" left="5" bottom="5" right="5" gap="5">
    ...

Naše okno je zatiaľ pasívne - nenačítavajú sa žiadne údaje a dokonca aj
používateľova interakcia je obmedzená na obdivovanie obsahu formulára.
Skúsme to napraviť – a začneme tým, že pri inicializácii okna načítame
príslušný výmenný kurz zo stránok ECB.

> **Note**
>
> Európska centrálna banka poskytuje údaje v rozličných formátoch, z
> ktorých je pre programové spracovanie najefektívnejší XML. Aktuálne
> údaje možno nájsť na
> <http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml>.

Stiahnime si triedu [`exchangerates.ExchangeRateService`](???) a
pridajme si ju do projektu. Táto trieda obsahuje jedinú metódu
getCurrentExchange(), do ktorej uvedieme kód meny.

```java
package exchangerates;

public class ExchangeRateService {
    public BigDecimal getCurrentExchange(String currencyCode) throws CurrencyException {
        String urlString = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
        try {
            InputStream in = new URL(urlString).openStream();
            DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
            Document document = documentBuilderFactory.newDocumentBuilder().parse(in);
            
            NodeList cubeElements = document.getElementsByTagName("Cube");
            BigDecimal result = null;
            for(int i = 0; i < cubeElements.getLength(); i++) {
                Element cubeElement = (Element) cubeElements.item(i);
                if(currencyCode.equals(cubeElement.getAttribute("currency"))) {
                    result = new BigDecimal(cubeElement.getAttribute("rate"));
                    return result;
                }
            }
            return result;
        } catch (MalformedURLException e) {
            throw new CurrencyException("Illegal URL for currency service: " + urlString, e);
        } catch (IOException e) {
            throw new CurrencyException("I/O error while retrieving currency rates data " + e.getMessage(), e);
        } catch (SAXException e) {
            throw new CurrencyException("Error while parsing XML response from server: " + e.getMessage(), e);
        } catch (ParserConfigurationException e) {
            throw new CurrencyException("Error while configuring response parser from server: " + e.getMessage(), e);
        } catch (NumberFormatException e) {
            throw new CurrencyException("Exchange rate is not a string.");
        }
    }
}
```

Ďalej dodáme do triedy `ExchangeRateForm` príslušnú metódu s hlavičkou
public void loadExchangeRates(). Prvotný nástrel vyzerá nasledovne:

```java
public void loadExchangeRates() {
    try {
        ExchangeRateService service = new ExchangeRateService();
        BigDecimal currentExchange = service.getCurrentExchange("USD");
        if(currentExchange != null) {
        }
    } catch (CurrencyException e) {
        e.printStackTrace();
    }
}
```

Ako uvedieme získaný kurz do požadovaného textového políčka? Každý
ovládací prvok v Thinlete môže byť v XML definícii pomenovaný pomocou
atribútu name, ktorý slúži v Java kóde ako jeho identifikátor. Dodajme
teda do textového políčka token atribút name s hodnotou exchangeRate:

```xml
<textfield text="[unknown]" name="exchangeRate" />
```

Pomocou metódy `find()` vieme nájsť ovládací komponent podľa mena, a
využitím metódy setStringValue() programovo nastaviť hodnotu konkrétneho
ovládacieho prvku.

```java
BigDecimal currentExchange = service.getCurrentExchange("USD");
if(currentExchange != null) {
    setString(find("exchangeRate"), "text", currentExchange.toString());
}
```

Metóda `find()` vracia prekvapivo inštanciu typu `Object`. To zodpovedá
implementačnej filozofii Thinletu, kde je prvotnou ideou jednoduchosť a
minimalistickosť kódu (hoci na úkor rozumného návrhu). Ovládacie prvky
nie sú reprezentované žiadnymi špeciálnymi triedami — všetko sú to
všeobecné `Object`y. Z toho vyplýva, že samotný komponent nemá žiadne
metódy, a akékoľvek nastavenia ich vlastností sú riešené pomocou metód
samotného `Thinlet`u – príkladom je metóda `setString()`, ktorá berie
parameter zodpovedajúci komponentu, ďalej názov vlastnosti (*property*),
ktorá sa má zmeniť a nakoniec jej hodnota.

Samotné volanie metódy `loadExchangeRates()` môžeme vykonať v
konštruktore:

```java
public ExchangeRateForm() {
    try {
        add(parse(getClass().getSimpleName() + ".xml"));
        loadExchangeRates();

    } catch (IOException e) {
        throw new IllegalStateException("Illegal or missing form definition.", e);
    }
}
```

Upravme si teraz formulár tak, aby mal používateľ možnosť zadať vlastný
kód meny, pre ktorý sa má zistiť aktuálny kurz. Dodajme teda dva
komponenty: textové políčko pre zadanie kódu (s menom currency) a
tlačidlo button, ktorým môže získať nové dáta.

```xml
<panel top="5" left="5" bottom="5" right="5" gap="5">
    <label text="Current Exchange Rate for:" />
    <textfield text="USD" name="currency" />  
    <label text="[unknown]" name="exchangeRate" />
    <button text="Refresh" action="loadExchangeRates" />
</panel>
```

Všimnime si ešte tlačidlo button, ktoré má špeciálny atribút `action`.
Jeho hodnota udáva metódu v inštancii `Thinlet`u, ktorá sa má zavolať po
kliknutí. V našom prípade zavoláme metódu `loadExchangeRates()`, čiže
znovu načítame informácie z Európskej centrálnej banky a vyhľadáme
príslušný kurz.

V tomto prípade sme ešte zmenili textové políčko s výsledným kurzom na
komponent typu *label*, čo lepšie zodpovedá statickému textu. Keďže jeho
obsah je reprezentovaný atribútom text, ktorý je rovnaký ako v prípade
textového políčka, v kóde nemusíme nič zmeniť.

Ak si spustíme upravené okno, uvidíme nasledovný výzor:

Samozrejme, ešte stále nemáme možnosť vidieť kurz inej meny než dolára.
V tomto prípade máme viacero možností. Prvá je nasledovná: Metóda
`loadExchangeRates()` si sama nájde komponent s menom `currency` (teda
textové políčko), vytiahne z neho hodnotu a získa údaje zo servera.

Skúsme upraviť metódu `loadExchangeRates()`.

    public void loadExchangeRates() {
        try {
            String currencyCode = getString(find("currency"), "text");
            
            ExchangeRateService service = new ExchangeRateService();
            BigDecimal currentExchange = service.getCurrentExchange(currencyCode);
            if(currentExchange != null) {
                setString(find("exchangeRate"), "text", currentExchange.toString());
            }
        } catch (CurrencyException e) {
            e.printStackTrace();
        }
    }

Metódou `find()` vieme nájsť komponent s menom `currency`. Metóda
`getString()` je protipólom metódy `setString()`, ktorou možno získať
hodnotu danej vlastnosti špecifikovaného komponentu.

Alternatívnou možnosťou je vytvoriť metódu, ktorá bude mať argument typu
`String` reprezentujúci kód, a o samotné naplnenie parametra sa postará
niekto iný. (Inak povedané, metóda nebude vyhľadávať obsah textových
políčiek sama, ale získa ho z parametra.) V tomto prípade však musíme
prerobiť definíciu v XML súbore:

```xml
<panel top="5" left="5" bottom="5" right="5" gap="5">
    <label text="Current Exchange Rate for:" />
    <textfield text="USD" name="currency" />  
    <label text="[unknown]" name="exchangeRate" />
    <button text="Refresh" action="loadExchangeRates(currency.text)" />
</panel>
```

Akcia `loadExchangeRates(currency.text)` zavolá rovnomennú metódu a do jej
parametra vloží aktuálnu hodnotu atribútu text ovládacieho prvka s
identifikátorom currency. Inak povedané, metóda získa do parametra
hodnotu textového políčka s kódom meny.

> **Note**
>
> Existuje ešte jedno miesto, kde sa dá sprehľadniť kód. Namiesto
> explicitného volania metód `setString(find())` je možné vytvoriť sadu
> getterov a setterov.
>
> 
>        public void setExchangeRateText(String exchangeRate) {
>            setString(find("exchangeRate"), "text", exchangeRate);
>        }

Prvotná funkcionalita je už hotová, a teraz je zrejme vhodný čas na
úpravu vizuálu.

Všimnime si, že všetky komponenty boli do formulára ukladané vedľa seba,
smerom zľava doprava. Po rozložení sa ich veľkosť už nikdy nezmení — po zmene rozmerov formulára ostáva rovnaká. Skúsme to napraviť.

Panel si možno predstaviť ako mriežku, do ktorej Thinlet rozkladá
komponenty. V základnom nastavení sa predpokladá, že mriežka má jeden
riadok a neobmedzený počet sĺpcov. Ak však nastavíme

```xml
<panel columns="1" top="5" left="5" bottom="5" right="5" gap="5">
```

rozloženie sa zmení na jednostĺpcové (s neobmedzeným počtom riadkov).

Skúsme umierniť label a textové políčko vedľa seba, pod ne umiestniť
výsledok a na spodok dať tlačidlo Refresh. Pri tom môžeme využiť
vnáranie panelov. Prvý vnorený panel bude obsahovať label a textové
políčko (rozkladané zľava doprava, teda v rozložení 1 riadok krát
neobmedzený počet stĺpcov), a pod ním bude ďalší panel s troma
statickými labelmi vedľa seba (prostredný s názvom exchangeRate obsiahne
výsledok). Oba panely majú päťpixelovú medzeru medzi vnútornými
komponentami.

```xml
<panel columns="1" top="5" left="5" bottom="5" right="5" gap="5">
    <panel gap="5">
        <label text="Current Exchange Rate for:" />
        <textfield text="USD" name="currency" />
    </panel>
    <panel halign="center" gap="5">   
        <label text="1€ ="/>
        <label text="[unknown]" name="exchangeRate" />
        <label name="currencyCode" text="USD"/>
    </panel>
    <button text="Refresh" action="loadExchangeRates(currency.text)" />
</panel>
```

Atribút `halign="center"` na vnorenom paneli spôsobí vycentrovanie
labelov.

Stále nám však chýba dôležitá vlastnosť: automatická zmena veľkosti
("naťahovanie" komponentov) pri zväčšovaní či zmenšovaní okna. To sa dá
vyriešiť jednoducho. Pri zmene veľkosti kontajnera (okna, panela) možno
každému vnorenému komponentu priradiť percentuálnu váhu, o ktorú sa má
natiahnuť či zmenšiť pri úprave veľkosti rodičovského kontajnera.

V našom okne máme jeden stĺpec. Ak priradíme vnoreným panelom a tlačidlu
váhu 1, znamená to, že pri zmene veľkosti okna sa im priradí 100%
rozdielu medzi novou a pôvodnou veľkosťou rodičovského panela. Váha sa
nastavuje samostatne v horizontále (atribút weightx) a vo vertikále
(atribút weighty).

    <panel columns="1" top="5" left="5" bottom="5" right="5" gap="5">
        <panel gap="5" weightx="1">
            <label text="Current Exchange Rate for:" />
            <textfield text="USD" name="currency" />
        </panel>
        <panel halign="center" gap="5" weightx="1">  
            <label text="1€ ="/>
            <label text="[unknown]" name="exchangeRate" />
            <label name="currencyCode" text="USD"/>
        </panel>
        <button text="Refresh" action="loadExchangeRates(currency.text)" weightx="1"/>
    </panel>

Všimnime si, že prostredný panel má roztiahnutý obsah, a stále si
zachováva centrovanie komponentov, ktoré sú v ňom obsiahnuté.

Vyriešme ešte rozťahovanie labelu a textového políčka. Ich rodičovský
panel má síce váhu 1, ale keďže ani label, ani textové pole nemajú svoju
vlastnú váhu, nebudú sa vôbec rozťahovať. Všetko nadbytočné miesto sa
prejaví ako prázdne miesto napravo od nich. Skúsme nastaviť:

```xml
<label weightx="50" text="Current Exchange Rate for:" />
<textfield weightx="50" text="USD" name="currency" />
```

Znamená to, že pri zmene veľkosti rodičovského panelu sa label natiahne
či zmenší o 150% rozdielu medzi pôvodnou a novou veľkosťou tohto panelu.
To isté sa týka aj textového políčka. Ak chceme, aby sa label rozťahoval
menej a textové políčko viac, stačí im inak prerozdeliť váhy. Ak chceme
zabrániť rozťahovaniu labelu, stačí mu nastaviť váhu na 0.

Ak ešte nastavíme

```xml
<panel gap="5" halign="center" weighty="50" valign="center">
    <label text="1€ ="/>
    <label text="[unknown]" name="exchangeRate"/>
    <label name="currencyCode" text="USD"/>
</panel>
```

dosiahneme tým vertikálne rozťahovanie panelu (ostatné komponenty si
ponechajú pôvodnú výšku) a vnútorné komponenty budú vertikálne
centrované na šírku.

Textové políčko nezabraňuje používateľovi vyhľadávať kurz pre menu,
ktorá neexistuje, alebo ktorej kurzy ECB neuvádza. Ak by sme však
nahradili textové políčko rozbaľovacím zoznamom (*combo boxom*), tento
problém by vymizol.

```xml
<panel gap="5" weightx="1">
    <label weightx="0" text="Current Exchange Rate for:" alignment="right"/>
    <combobox name="currency" editable="false" text="[ choose currency ]">
        <choice text="USD"/>
        <choice text="CZK"/>
        <choice text="GBP"/>
        <choice text="RUB"/>
    </combobox>
</panel>
```

Rozbaľovaciemu zoznamu zodpovedá element `<combobox>` a jeho jednotlivým
položkám `<choice>`. Atribút `editable` určuje, či je rozbaľovací zoznam
kombinovaný s textovým políčkom. V našom prípade chceme zabrániť, aby
používateľ zadal vlastný kód, preto túto možnosť vypneme.

Ak chceme zistiť text vybranej položky, opäť nemusíme v kóde meniť nič — objaví sa v atribúte text rozbaľovacieho zoznamu.

Zobrazovanie a skrývanie okien
------------------------------

Zatiaľ sme pracovali len s jediným oknom. Niekedy sa však stane, že
chcem používateľovi zobraziť dodatočné okno – buď jednoduché hlásenie
(*message box*) alebo rozšírenejšie okno s podrobnejšími informáciami.

> **Important**
>
> Thinlet je primárne stavaný na aplikácie, ktoré pracujú s jediným
> oknom. Inak povedané, všetky okná, ktoré thinletová aplikácia môže
> otvárať, sa musia nachádzať v hlavnom okne. To je rozdiel oproti
> Swingu či AWT, ktoré v tomto ohľade nie sú obmedzené. Limitácia
> pochádza z dizajnérskej filozofie, ktorá umožňovala beh aj na
> mobiloch, u ktorých sa predpokladá, že aplikácia zaberá celú veľkosť
> displeja.

V našej aplikácii to môžeme demonštrovať na okno s informáciami o
aplikácii (*about box*). Predovšetkým musíme vytvoriť nový XML súbor 
každé okno musí mať svoju vlastnú definíciu. Na rozdiel od hlavného
okna, ktorého obsah je tvorený panelom (a teda definovaný elementom
`<panel>`, sú vnorené okná (dialógy) definované v rámci rovnomenného
elementu `<dialog>`. Vytvorme teda súbor `AboutBox.xml` s nasledovným
obsahom:

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE dialog PUBLIC '-//Thinlets 1.0//EN' 'https://thinlet.dev.java.net/thinlet.dtd'>

<dialog text="About" top="5" left="5" bottom="5" right="5" gap="5" columns="1" modal="true">
    <label text="Currency Exchange Rate Monitor" font="bold"/>
    <button text="Close" action="closeAboutBox" />
</dialog>
```

V definícii nie je nič prekvapivé: používame jeden *label* a jedno
tlačidlo, ktoré sú rozložené pod sebou (layout je v jednom stĺpci).
Drobnosťou je akurát atribút font, ktorým zvýrazníme label a atribút
text, kde uvedieme titulok okna.

Všimnime si ale atribút `modal="true"` v elemente `<dialog>`. Týmto
zaistíme modalitu dialógu, teda po jeho zobrazení nebude možné
pristupovať ku komponentom, ktoré sa nachádzajú "za" ním. Užívateľ bude
môcť ďalej pracovať s aplikáciou až po zavretí modálneho okna.

Zobrazenie tohto okna potom pozostáva z dvoch fáz: v prvej načítame
definíciu zo XML súboru pomocou metódy `parse()`. Pridaním okna do
rodičovského kontajnera ho zobrazíme (zavolaním metódy `add()`). Ak chceme
okno skryť, musíme ho z rodičovského okna odobrať, t. j. zavolať metódu
`remove()`.

Načítavanie sa môže udiať v konštruktore a načítané okno si uložíme do
inštančnej premennej.

```java
private Object aboutBox;

public ExchangeRateForm() {
    try {
        add(parse(getClass().getSimpleName() + ".xml"));
        aboutBox = parse("AboutBox.xml");

        loadExchangeRates("USD");

    } catch (IOException e) {
        throw new IllegalStateException("Illegal or missing form definition.", e);
    }
}
```

To však nie je všetko: potrebujeme ešte dodať ovládací prvok, ktorým
toto okno zobrazíme. Zabezpečíme to dodaním tlačidla do hlavného okna:

```xml
<panel>
    <button text="Refresh" action="loadExchangeRates(currency.text)" weightx="1"/>
    <button text="?" action="showAboutBox" />
</panel>
```

Poslednou vecou je dodanie dvoch metód, ktoré budú obsluhovať kód:
jednou z nich zobrazíme okno (metóda `showAboutBox()`) a druhou ho zase
schováme (metóda `closeAboutBox()`).

```java
public void showAboutBox() {
    add(aboutBox);
}

public void closeAboutBox() {
    remove(aboutBox);
}
```

Po spustení aplikácie a zobrazení okna budeme vidieť nasledovný stav:

Implementačné detaily a porovnanie s inými knižnicami
=====================================================

Samotný Thinlet je postavený ako jednoduchá nadstavba nad AWT. Hoci
samotné AWT použije dnes už len máloktorý vývojár, jeho výhodou je
jednoduchosť, podpora v starých verziách Javy a na mobilných
zariadeniach. Jeho ďalším hlavným pozitívom je rýchly vývoj rozhrania
pre jednoduché aplikácie, samozrejme za predpokladu, že si uvedomíme
obmedzenia:

* **obmedzenie na jediné okno**: Aplikácia môže mať jediné hlavné okno, všetky vnorené okná musia byť v rámci hlavného okna.

* **jediný layout manager:** Ak ste zvyknutí na plejádu rôznorodých manažérov, v Thinlete máte k dispozícii len jediný – tabuľkový. Ten je však dostatočne flexibilný a dokážete ním realizovať množstvo rozličných prípadov.

* **žiadne modely komponentov:** v Swingu a SWT je štandardom oddelenie dát od spôsobu ich zobrazovania. Dáta bývajú obvykle uložené v modeli (modelovom objekte) a samotný komponent sa len stará o zobrazenie (prezentáciu modelu). Thinletovské komponenty však modely nepodporujú, inak povedané, komponent je zároveň modelom.

* **komponent môže mať len jediný listener danej udalosti:** na rozdiel od Swingu, kde môže mať komponent viacero listenerov, sú tuto listenery skryté. V tomto prípade je listenerom verejná metóda, ktorá sa však musí nachádzať v hlavnej triede.

* **občasné obskúrne chybové hlášky:** Kód Thinletu je stelesnením programovania na výkon a efektivitu, ale na úkor prehľadnosti. Čo je horšie, chybové hlášky často vonkoncom nezodpovedajú realite a je treba chvíľu pátrať (či krokovať) po pravej príčine problému.

* **obmedzené vláknové programovanie:** V Swingu platí zásada, že dlhotrvajúce operácie by mali bežať v
separátnom vlákne. V tomto prípade však žiadny takýto mechanizmus
nie je k dispozícii a teda tiahle operácie spôsobia vytuhnutie
používateľského rozhrania.

* **obmedzená tvorba vlastných komponentov:** Tvorba vlastných komponentov je obmedzená na pasívne komponenty
dediace od `java.awt.Component`. Takého komponenty nebudú prijímať
žiadne udalosti.

* **nefunkčnosť niektorých vlastností:** Niektoré vlastnosti, ktoré komponenty ponúkajú, nie sú funkčné. V
praxi sme sa stretli s nefunkčnosťou zatváracích, maximalizujúcich a
minimalizujúcich tlačidiel vo vnorených dialógoch (tlačidlá sa
vykreslia, ale sú pasívne), teda o atribúty closable, maximalizable
a minimalizable.

Ďalšie pramene
==============

* [Zdrojové kódy s ukážkovým projektom](http://ics.upjs.sk/~novotnyr/wiki/uploads/Java/Thinlet/exchange-rates-thinlet.zip)
* [Hlavná stránka verzie Thinletu, ktorá je používaná v tomto článku](http://thinlet.sourceforge.net/home.html)
* [Posledná verzia kompletne prepísanej verzie Thinletu, chýbajú jej
    však niektoré dôležité vlastnosti.](http://thinlet.com)
* [Thinlet FAQ](http://thinlet.blog-city.com/frequently_asked_questions.htm) – často kladené otázky k Thinletu.
* [Thinlet-ZEE](http://www.zee.ch/thinlet/) – Zbierka patchov a dodatočnej funkcionality k pôvodnej verzii Thinletu
