---
title: Materská škola JavaScriptu
date: 2017-05-11
toc: true
---

# Prečo JavaScript

JavaScript je mimoriadne perspektívny a populárny jazyk.

*   Je to hlavný programovací jazyk pre vývoj na webe. Všetky moderné webové prehliadače podporujú JavaScript.
*   Podporuje vývoj na všetkých platformách:
    *   appky pre mobilné zariadenia, napr. cez [React Native](https://facebook.github.io/react-native/).
    *   serverové aplikácie, napr. cez [Node.js](https://nodejs.org/en/)
    *   desktopové aplikácie, napr. cez [Electron](https://electron.atom.io/)

# Čo je vlastne JavaScript?

JavaScript má rozličné verzie a pomenovania.

* norma _ECMAScript 2015 alias ES6_. Moderná syntax, podporovaný v takmer
všetkých moderných prehliadačoch.
* norma _ECMAScript 3.0_. Staršia, menej pohodlná syntax. Podporovaná aj
v pravekých prehliadačoch.
* _JavaScript_. Voľné pomenovanie "toho-jazyka, v ktorom sa robia weby",
obvykle sa tým myslí stará známa rozšírená _ECMAScript 3.0_.

# V čom vyvíjať?

*   Hračkárske programy sa dajú písať priamo na stránke [JSFiddle.net](https://jsfiddle.net/).
*   alebo sa dá zvoliť ľubovoľné IDE:
    *   skvelý platený [WebStorm](https://www.jetbrains.com/webstorm/buy/#edition=personal)
    *   [Visual Studio Code](https://code.visualstudio.com/)
    *   platený editor [Sublime](https://www.sublimetext.com/)
    *   editor [Atom](https://atom.io/) implementovaný v JavaSCripte

Hrajkáme sa v prehliadači
=========================

## Hello World

*   Otvorme si si [JSFiddle.net](https://jsfiddle.net/).
*   Otvorme si webový prehliadač, a klávesovou skratkou F12 vyvolajme okno Vývojárskych nástrojov (*Developer Tools*). V nich si zobrazme *Console* (konzolu)
*   Spusťme prvý program:

    ```javascript
    console.log("Old McDonald had a farm");
    ```

*   JavaScript podporuje objektovo orientovaný prístup
    *   Premenná `console` je objekt s metódou `log()`.
    *   Parametrom je reťazec v úvodzovkách Povolené sú aj apostrofy: `'Old McDonald had a farm'`
    *   Riadok sa končí bodkočiarkou (ale nie je to povinné).

## Premenné

JavaScript deklaruje premenné pomocou `let`. Dátové typy sa neuvádzajú.

```javascript
let song = "Old McDonald had a farm. I-a-i-a-oh";
```

Premenná na pozadí má typ reťazec (`String`).

## Reťazce

Reťazce môžu byť uvádzané v `"úvodzovkách"` alebo `'apostrofoch'`.

Pre niektoré prípady je ešte alternatíva zvaná *template literal*, ktorá
podporuje viacriadkové reťazce. Takýto reťazec
je oddelený pomocou spätných úvodzoviek (*backticks*).

```javascript
let song = `Old McDonald had a farm
I-a-i-a-oh`;
```

Viacriadkové reťazce tak nemusíme lepiť / konkatenovať pomocou `+`.

Užitočná môže byť aj interpolácia premenných:

```javascript
let animal = "cow";
let song = `Old McDonald had a farm. And on his farm he had some ${animal}`.
```

V premennej `song` máme odkaz na premennú `animal`, uzavretú v dolári a zložených
zátvorkách, ktorá sa nahradí jej obsahom.

## Polia

```javascript
let animals = [ "cow", "pig", "t-rex" ];
```

Položky polí sú v hranatých zátvorkách. Pristupovať k jednotlivým prvkom
možno cez hranatozátvorkovú notáciu.

```javascript
console.log(animals[0]); // "cow"
```

Polia majú dĺžku definovanú vo vlastnosti (*property*) zvanej `length`.

```javascript
console.log(animals.length)); // 3
```

## Cykly

### Cyklus `for`

Najčastejšie používaný je cyklus `for`, a to v zápise "foreach", kde
sa prechádzajú postupne prvky poľa.

```javascript
for(let animal of animals) {
    console.log(animal);
}
```

### Klasický Java/C cyklus

K dispozícii je aj starý dobrý `for` cyklus s premennou

```javascript
for(let i = 0; i < animals.length; i++) {
    console.log(animals[i]);
}
```

## Podmienky

Podmienka `if` má tradičnú syntax známu z C/C++/Javy a pod.

```javascript
if (animals.length > 0) {
    console.log("Old McDonald had a farm");
}
```

Pozor však na porovnávanie! Obvyklý operátor na porovnanie hodnôt je `==`.

```javascript
if (animals.length == 0) {
    console.log("Old McDonald hasn't a farm");
}
```

JavaScript však dokáže automaticky prevádzať dátové typy jeden na druhý
podľa potreby, z čoho je [množstvo vtipov](https://www.destroyallsoftware.com/talks/wat).

Je to vidieť v situácii:

```javascript
let farmCapacity = "25"; //reťazec
if (farmCapacity == 25) {
    console.log("This farm is seriously large!");
}
```

V tomto prípade JavaScript dokáže pochopiť, že kapacity farmy -- napriek tomu,
že je to reťazec -- sa dá bez problémov porovnať s číslom.

V niektorých prípadoch je toto správanie výhodné, ale inokedy je zdrojom prekvapení.

Porovnaním cez tri "rovná sa" sa striktne porovnajú nielen hodnoty, ale
aj dátové typy

```javascript
if (farmCapacity === 25) {
    console.log("This farm is seriously large!");
}
```

## Funkcie

Funkcie sa zapisujú kľúčovým slovom `function`.

```javascript
function sing(animal, sound) {
    let song = `Old McDonald had a farm, I-a-i-a-oh.\n
    And on his farm he had some ${animal}\n
    I-a-i-a-oh\n
    \n
    And a ${sound} ${sound} here\n
    And a ${sound} ${sound} there\n
    Here ${sound}, ${sound} quack\n
    Everywhere a ${sound} ${sound}`;
    return song;
}
```

*   Neuvádzajú sa dátové typy pre parametre, ani pre návratovú hodnotu.
*   Funkcia pre spievanie má dva parametre: `animal` a `sound`. Návratovú hodnotu (výsledok funkcie) vraciame pomocou `return`.

Funkciu voláme klasicky:

```javascript
console.log(sing("Cow", "moo moo"));
```

## Objektové programovanie

V JavaScripte sú podporované triedy a objekty.

```javascript
class Animal {
    constructor(name, sound) {
        this._name = name;
        this._sound = sound;
    }

    makeSound() {
        return this.sound;
    }
    
    get name() {
    	return this._name;
    }
    
    set name(name) {
      this._name = name
    }
    
    toString() {
        return this._name + " makes " + this._sound;
    }
}
```

Trieda pre kravu má:

*  konštruktor, uvádzaný kľúčovým slovom `constructor`
*  metódy, uvádzané ako funkcie, ale bez kľúčového slova `function`
*  metóda `toString()` je prekrytá a vracia textovú reprezentáciu objektu, používanú napr. vo výpisoch cez `console.log`.

 Novú kravu vytvoríme nasledovne:

```javascript
let cow = new Animal("cow", "moo");
```

Použijeme ju:

    console.log(cow.makeSound());

Modifikátory viditeľnosti v JavaScripte neexistujú. V príklade
sme použili `_` ako predponu pre "pseudoprivátne premenné".

Existujú aj gettery a settery. Ak máme novú kravu, môžeme jej meno získať
cez

```javascript
cow.name
```

Toto volanie zavolá príslušnú metódu `get name()`.

## Funkcionálne programovanie

S funkciami v JavaScripte sa dajú robiť skvelé veci! Funkcie sú integrálnou
súčasťou jazyka.

Vytvorme si funkciu:

```javascript
function singToConsole(animal) {
    let song = `Old McDonald had a farm, I-a-i-a-oh.\n
    And on his farm he had some ${animal.name}\n
    I-a-i-a-oh\n
    \n
    And a ${animal.sound} ${animal.sound} here\n
    And a ${animal.sound} ${animal.sound} there\n
    Here ${animal.sound}, there ${animal.sound}\n
    Everywhere a ${animal.sound} ${animal.sound}`;
    
    console.log(song);
}
```

Ak máme pole, môžeme na ňom volať metódu `forEach`. V nej sa "pre každý"
prvok poľa zavolá príslušná funkcia.

```javascript
let animals = [ new Animal("cow", "moo"), new Animal("pig", "oink") ];
animals.forEach(singToConsole);
```

Pre každé zviera sa zavolá funkcia `singToConsole`, ktorá má jeden parameter. Pre každý
prvom sa tak zaspieva jedna sloha.

Ako vidno, metóda `forEach` má jediný parameter typu *funkcia*.

### Skrátený zápis funkcií

V niektorých prípadoch chceme použiť skrátený zápis pre funkcie používané
v parametroch.

Predstavme si veľkú farmu

```javascript
let animals = [ 
    new Animal("cow", "moo"), 
    new Animal("cow", "moo, moo, moo"),
    new Animal("pig", "oink"),
    new Animal("pig", "oink, oinky oink"),
];
```

Ak chceme vypísať len zvuky kráv, môžeme si pripraviť funkciu:

```javascript
function isCow(animal) {
    if (animal.name == "cow") {
        return true;
    } else {
        return false;
    } 
}
```

Tento zápis je ťažkopádny, pokojne môžeme vynechať `if`:

```javascript
function isCow(animal) {
    return animal.name == "cow";
}
```

Každé javascriptové pole má metódu `filter`, ktorá slúži ako filtračný papierik.
Do metódy vložíme funkciu s jedným parametrom. Každý prvok, ktorý funkcia
overí a vráti preňho `true`, prejde filtrom a pošle sa na ďalšie spracovanie.

Metóda `filter` potom vráti len pole prvkov, ktoré prešli filtráciou.

```javascript
let onlyCows = animals.filter(isCow);
console.log(onlyCows);
```

V tomto prípade môžeme použiť aj skrátený zápis funkcie:

```javascript
let onlyCows = animals.filter(animal => animal.name === "cow");
```

Všimnime si skrátený zápis: máme funkciu, ktorá berie jeden parameter, nazvaný
`animal` a vráti `true` pre každé zviera, ktoré sa volá `cow`.

V tomto skrátenom zápise netreba používať `return`, ten sa domyslí.

Výsledok si môžeme nechať vypísať:

```javascript
console.log(onlyCows.toString());
```

Technická poznámka: na rozdiel od Javy/C# a pod, metóda `log` nie vždy
volá `toString()` na poliach.

Iný príklad, ktorý odfiltruje zvieratá a zároveň ich vypíše, je nasledovný:

```javascript
animals.filter(animal => animal.name === "cow")
       .forEach(animal => console.log(animal));
```

Iný príklad môže vypisovať zvieratá tak, aby MÚKALI VEĽKÝMI PÍSMENAMI.
Metóda `map()` na poli dokáže postupne brať jednotlivé prvky poľa, aplikovať
na každý prvok konkrétnu funkciu ("namapovať prvky na iné") a výsledné
prvky pozbiera do nového poľa.

```javascript
animals.map(animal => animal.name.toUpperCase()
       .forEach(animal => console.log(animal));
```
# JavaScript a Node.js

**Node.js** je platforma pre spúšťanie programov v JavaScripte mimo browsera. V súčasnosti je to veľmi populárna voľba na vývoj výkonných serverových aplikácii. 

Node.js beží na každom operačnom systéme a v srdci mu búši výkonný javascriptový engine V8 od Googlu (rovnaký ako v prehliadači Chrome).

## Predpoklady

*   Nainštalujte `node.js`.
*   Overte, že funguje správca balíčkov `npm` (Node Package Manager):

## Vytvorenie projektu

*   Vytvorme projekt založený na ECMAScript 6

    *   Vo WebStorme, resp. v IntelliJ IDEA v *Preferences*, *Languages and Behaviour* nastaviť *ECMAScript 6*.

*   V adresári projektu inicializujme projekt

    ```shell
    npm init
    ```

*   Vznikne popisovač projektu `package.json`:

    ```json
    {
       "name": "kindergarten.js",
       "version": "1.0.0",
     }
    ```


## Ukážka `lodash`

`lodash` je knižnica (**modul**) pre JavaScript s viacerými užitočnými funkciami pre prácu s kolekciami a pod.

### Inštalácia `lodash`

```shell
npm install lodash --save
```

Z internetu sa stiahnu závislosti a do `package.json` pribudne sekcia
so závislosťami (*dependencies*):

```json
"dependencies": {
    "lodash": "^4.17.4"
}
```

### Použitie v projekte

Vytvorme zdrojový súbor `index.js`, kde demonštrujeme použitie *lodash*. 

Ak píšeme JavaScript pre prostredie `Node.js`, môžeme využiť závislosť
na module pomocou funkcie `require()`:

```javascript
const _ = require("lodash");

let temperatures = [10, 11, 6, 12, 18, 15, 5, 7]
let minimumTemperature = _.min(temperatures);

console.log(minimumTemperature)
```

### Spustenie

Z príkazového riadku spusťme:

```shell
node index.js
```

Uvidíme výsledok v podobe najmenšieho čísla:

```
5
```

Ukážka `fetch` (REST klient)
----------------------------

Moderné webové prehliadače sprístupňujú klienta pre REST služby v podobe [*Fetch API*](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API). Tento klient sa dá použiť aj v Node.js, v module `node-fetch`.

### Inštalácia

```shell
npm install node-fetch --save
```

Stiahnu sa závislosti pre knižnicu `node-fetch` a v `package.json` pribudne nový záznam.

### Použitie

```javascript
const fetch = require('node-fetch');
fetch('http://ics.upjs.sk/~novotnyr/javascript/animals')
        .then(response => response.json())
        .then(json => console.log(json))
        .catch(error => console.log(error))
```

Funkcia `fetch` používa filozofiu *Promises*, ktoré skracujú zápis asynchrónnych volaní s podporou spracovania chýb. Podrobnosti možno nájsť v článku [Asynchrónne veci v JavaScripte pomocou callbackov, promises a async/await](https://novotnyr.github.io/scrolls/asynchronne-veci-v-javascripte-callback-promise-async-await/).

Spusťme skript znovu:

```shell
node index.js
```

Uvidíme výsledný JSON:

```json
[ { name: 'Venus', type: 'cow' },
  { name: 'Mr Pink', type: 'pig' } ]
```

