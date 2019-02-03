---
title: "Malá čokoládová REST aplikácia (List Milanovi)"
date: 2019-01-20T14:06:56+01:00
---

Milý Milan,
chcel si vedieť, ako vyzerá minimalistická RESTovská aplikácia postavená na aplikačnom rámci **Spring Boot**.

Tu je.

Predovšetkým, zíde sa ti Maven. Nielenže sa vysporiada so závislosťami v Springu, ale dá ti k dispozícii fajnový plugin pre Jetty, v ktorom bude spúšťanie servera vecou na 10 znakov.

Závislosti
==========

Začni teda POMkom, ktorý oddeď od rodičovského POM súboru a zároveň dodaj
závislosť pre podporu webu a modulu *Spring Web MVC*.

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.1.RELEASE</version>
    </parent>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

Element `<parent>` vďaka dedičnosti dodá do nášho projektu množstvo užitočných závislostí a pluginov, vďaka ktorým sa spúšťanie projektu výrazne zjednoduší.

Nastavenie Springu a jadra webu
===========================
Základná trieda nášho projektu bude obsahovať metódu `main()` a anotáciu
`@SpringBootApplication`, ktorá plní množstvo úloh popísaných nižšie.

Kód, ktorý využijeme bude nasledovný:

    package sk.upjs.ics.novotnyr.chocolate;
    
    import org.springframework.boot.SpringApplication;
    import org.springframework.boot.autoconfigure.SpringBootApplication;
    
    @SpringBootApplication
    public class ApplicationConfiguration {
        public static void main(String[] args) {
            SpringApplication.run(ApplicationConfiguration.class, args);
        }
    }

Anotácia `@SpringBootApplication` plní viacero úloh. Pre jednoduchosť ti spomeniem len to, že takto anotovaná trieda predstavuje vstupný bod aplikácie založenej na *Spring Boot*e. Okrem toho ešte nastaví automatické vyhľadávanie REST endpointov (*kontrolérov*) a ich registráciu v Springu.


Nastavenie kontroléra
=====================
**Kontrolér** je trieda, ktorej metódy budú obsluhovať URL adresy pre RESTovské požiadavky.

Minimalistický kontrolér môže vyzerať takto:

	import java.util.List;
	import java.util.concurrent.CopyOnWriteArrayList;
	
	import org.springframework.http.HttpStatus;
	import org.springframework.web.bind.annotation.*;
	
	@RestController
	@RequestMapping("/chocolates")
	public class ChocolateController {
		private List<Chocolate> chocolates = new CopyOnWriteArrayList<Chocolate>();
	
		public ChocolateController() {
			chocolates.add(new Chocolate("lindt", "Lindt", 72));
			chocolates.add(new Chocolate("choc-o-crap", "Choc'o'crap", 10));
			chocolates.add(new Chocolate("brownella", "Brownella", 52));
		}
	
		@GetMapping
		public List<Chocolate> list() {
			return chocolates;
		}
	}

## Anotácie kontroléra

Začnime zhora: `@RestController` znamená, že táto trieda predstavuje kontrolér pre REST požiadavky, že návratové hodnoty jej metód budú automaticky serializované do výstupu pre klienta (prehliadač), a že sa má automaticky zaregistrovať v springovskom kontexte pri pátraní spôsobenom anotáciou `@SpringBootApplication`.

Druhá anotácia, `@RequestMapping` hovorí, že základná prípona v URL adrese pre tento kontrolér bude `/chocolates`.

V konštruktore si vytvoríš a naplníš inštanciu zoznamu s ukážkovými dátami: a tento zoznam musí byť vláknovo bezpečný, pretože kontrolér v Springu bude singleton a budú k nemu pristupovať viaceré vlákna súčasne (zodpovedajúce súčasným HTTP požiadavkam).

## Anotácie metódy pre GET

Pozri sa teraz na metódu `list()`. Anotácia `@GetMapping` ti naznačí, že táto metóda sa má volať vo chvíli, keď klientská aplikácia navštívi adresu s použitím HTTP slovesa `GET` — čo je presne prípad bežného webového prehliadača. 

Celá cesta v adrese sa určí zlúčením informácie z anotácie `@RequestMapping` nad triedou a prípadnou cestou uvedenou v anotácii `@GetMapping` nad metódou `list()`. Vidíme, že v metódovej anotácii nie je žiadna cesta, preto metóda `list` sa zavolá v momente, keď klient navštívi nasledovnú adresu s použitím HTTP GET:

```
http://localhost:8080/chocolates
```

Návratová hodnota metódy je *zoznam čokolád*, čo je bežný Java objekt. Pamätáš si však na Jacksona v `CLASSPATH`e? Vďaka nemu sa tento zoznam automagicky premení na JSONovský reťazec v HTTP odpovedi. (A Jackson nepotrebuje žiadnu špeciálnu konfiguráciu ani anotácie.)

## Spustenie

Môžeš si to skúsiť: spusti si:

```
mvn spring-boot:run
```

*Spring Boot* automaticky spustí HTTP server na porte 8080 a rovno môžeš navštíviť http://localhost:8080/chocolates. Uvidíš odpoveď:

	[{"id":"lindt","title":"Lindt","percentage":72},{"id":"choc-o-crap","title":"Choc'o'crap","percentage":10},{"id":"brownella","title":"Brownella","percentage":52}]

## Anotácie metódy pre POST
Teraz si skúsme aj opačný postup: dodajme metódu, ktorá *prijme* JSONovský string a vytvorí novú entitu. (V REST filozofii pôjde o mapovanie na HTTP POST).

	@PostMapping
	public Chocolate add(@RequestBody Chocolate chocolate) {
		chocolates.add(chocolate);
		return chocolate;
	}

Ako vidíš, anotácia `@PostMapping` hovorí, že metóda bude sprístupnená na adrese `http:/…/chocolates`, ale v tomto prípade len pre prístup cez HTTP POST.

Pozorovať môžeš ešte jednu anotáciu: parameter metódy objektu `@RequestBody` hovorí, že celé telo v HTTP požiadavke sa má automaticky namapovať na objekt typu `Chocolate`. A keďže máme v `CLASSPATH`e Jacksona, Spring sa automaticky postará o to, aby akákoľvek HTTP POST požiadavka, ktorá má uvedený `Content-Type` ako JSON (teda `application/json`), sa pomocou tohto mŕtveho speváka deserializovala na bežný čokoládový objekt.

Žiaľ, toto sa už nedá vyskúšať pomocou čistého browsera (ten funguje len cez HTTP GET). Na testovanie je najlepšie zobrať niektorý z pluginov prehliadača: napríklad Firefox má svoj ***Poster***, či ***HTTP Requester***. Dôležité je, že požiadavka musí ísť tiež na adresu http://localhost:8080/chocolates, a musí mať správny *Content Type*.

Len bokom ti podotknem, že metóda vracia `Chocolate`. To nie je povinné, ale podľa RESTovských zásad je užitočné, ak sa klientovi na požiadavku vráti nejaký neprázdny obsah: v tomto prípade, keďže sa hrajkáme, stačí vrátiť to, čo prišlo na vstupe: teda čokoládu.

## Vylepšenie HTTP POSTu
Príklad by si mohol ešte vylepšiť. Hovorí sa, že ak sa úspešne podarí vytvoriť RESTovský *resource*, server má odpovedať so stavovým kódom `HTTP 201 Created`. Nie je nič ľahšie: stačí dodať nad metódu `add()` anotáciu `@ResponseStatus` s príslušným stavovým kódom:

	@PostMapping
	@ResponseStatus(value = HttpStatus.CREATED)
	public Chocolate add(@RequestBody Chocolate chocolate) {

## Metódy s parametrami URL adries
Zatiaľ si videl len dve metódy: jednu na získanie zoznamu všetkých čokolád a druhú na vytvorenie novej čokolády. Pri RESTe však často budeš potrebovať získať informácie o *jedinej* čokoláde. Podľa restovaných zásad sa takáto informácia o čokoláde Lindt namapuje napr. URL adresu:

	http://localhost:8080/chocolates/lindt

Obslúžiť takéto volanie v REST kontroléri možno vytvorením novej metódy, ktorá zároveň dokáže inteligentne vytiahnuť z URL adresy identifikátor čokolády.

	@GetMapping("/{id}")
	public Chocolate get(@PathVariable String id) {
		Chocolate chocolate = findById(id);
		if(chocolate == null) {
			throw new ChocolateNotFoundException();
		}
		return chocolate;
	}

Opäť si všimni anotáciu `@GetMapping`: tá teraz udáva už aj parameter `/{id}`. Všetko, čo je v kučeravých zátvorkách (`id`) udáva tzv. *path parameter* alebo *path variable*, teda premennú cesty. Ak klient navštívi adresu `http://localhost:8080/chocolates/lindt`, Spring sa snaží vypátrať metódu v kontroléri, ktorá dokáže obslúžiť požiadavku s touto URL, a používa pri tom anotácie `@***Mapping` nad triedou a `***Mapping` nad metódami. Ako som Ti spomenul vyššie, prípony ciest v anotácii nad triedou a nad metódou sa snaží „zlepiť“ dohromady.

Prípona URL v `@RequestMapping`-u na kontroléri zlepená s hodnotou `@PostMapping`-u na metóde dá dohromady `/chocolates/{id}`.

Ak si chceš vyzdvihnúť hodnotu parametra cesty `id` v metóde, použi na to štandardný parameter metódy `String id`. Aby bolo jasné, že sa do parametra má napchať hodnota z URL adresy... tiež na to použiješ anotáciu. V tomto prípade pôjde o anotáciu `@PathVariable`.

Iste sa pýtaš, ako sa odhadne názov parametra. Spring používa vúdú, ktoré toto hádanie urobí automaticky (premenná cesty `id` sa namapuje na rovnomenný parameter metódy).

Zvyšok metódy by mal byť jasný: vrátime bežnú inštanciu čokolády serializovanú na JSON.

S jedinou špecialitou: tou je prípad, že sa čokoláda s daným ID nenájde.

## Výnimky
Ako vidíš, v metódach kontroléra možno hádzať výnimky. REST však vôbec nepozná koncept výnimky (koniec koncov, klient môže byť implementovaný v hocijakom, aj neobjektovom jazyku.). Detekovať výnimočné stavy môžeme pomocou HTTP stavových kódov a vhodne navolenému obsahu v tele odpovede HTTP.

Ak voláš REST adresu pre získanie objektu, ktorý neexistuje, mala by sa zjaviť stará známa klasika: stavový kód 404 (Not found).

A ako tieto stavové kódy súvisia s výnimkami? Jednoducho. Ak si vytvoríš triedu pre vlastnú výnimku, dodáš nad ňu anotáciu `@ResponseStatus` (áno, túto anotáciu som už raz použil vyššie), a v kóde metódy túto výnimku vyhodíš, Spring ju automaticky odchytí a vráti stavový kód HTTP, ktorý uvedieš v tejto anotácii.

Tu je príklad výnimky, ktorá sa prevedie na stavový kód 404:

	@ResponseStatus(value = HttpStatus.NOT_FOUND)
	public class ChocolateNotFoundException extends RuntimeException {
		// no body needed
	}

Záver
======
Záverom tohto listu ti už len prajem veľa šťastia a zdaru pri vlastných projektoch.

S priateľským pozdravom

&nbsp;&nbsp;&nbsp;Róbert

P.&nbsp;S. Kompletné zdrojáky nájdeš na GitHube, v repozitári [novotnyr/spring-boot-chocolate-rest-demo](https://github.com/novotnyr/spring-boot-chocolate-rest-demo).

Ďalšie zdroje na čítanie
========================
*	Tutoriál [Designing and Implementing RESTful Web Services with Spring](https://spring.io/guides/tutorials/rest/)
*	[Best Practices for A Pragmatic RESTFul API]([http://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api) -- kolekcia odporúčaní pri zostavovaní REST API
*	[Building a RESTful Web Service](http://spring.io/guides/gs/rest-service/) -- budovanie REST endpointov pomocou Springu a Spring Bootu
*	[Spring MVC bez `web.xml`](http://ics.upjs.sk/~novotnyr/blog/1235/aha-aplikacia-spring-mvc-bez-xml)
*	[Spring MVC 2.5](http://ics.upjs.sk/~novotnyr/wiki/Java/SpringMVC25): starší článok z roku 2009 k Spring MVC 2.5, ale mnoho ideí stále platí.
*	[Spring MVC:
  jarý rámec pre webové aplikácie](http://bezadis.ics.upjs.sk/pub/resources/robert-novotny2/slidy.pdf) -- prezentácia Bezadis '11