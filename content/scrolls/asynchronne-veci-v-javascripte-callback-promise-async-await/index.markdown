---
title: Asynchrónne veci v JavaScripte pomocou callbackov, promises a async/await
date: 2019-10-29T10:49:00+01:00
---

Úvod 
===========================================
*	JavaScript v browseroch sa vykonáva v jednom vlákne
*	ale chceme riešiť veci *na pozadí*
*	príklad: klient REST API
	*	nemôžeme čakať, kým dobehne HTTP request na pozadí, trvalo by to dlho, a vlákno by bolo zablokované 
*	príklad: výkonný server v Node.js
  *	nebudeme pre každého klienta spúšťať nové vlákno, namiesto neho použijeme udalosťami orientovaný systém bez blokovania a čakania
*	JavaScript nemá analógiu javáckych `Thread`ov, ale má iné mechanizmy

Riešení je viacero:

- použitie callbackov, čo je najstaršia a „najhlúpejšia“ filozofia, ale s nepríjemným zápisom
- použitie promisov, čo je objektovo-orientovaný prístup s vylepšeným zápisom
- použitie `async`-`await`, čo je takmer klasický zápis synchrónnych úloh.

Callbacks
=========
Tradičný spôsob: funkcia má medzi parametrami inú funkciu, **callback**, ktorú zavolá po dobehnutí.

## Callback: príklad `setTimeout()` 

Objekt `window` v browseroch má metódu `setTimeout()`, ktorá berie:

*	obslužnú funkciu
*	lehotu, ktorá po vypršaní vyvolá volanie funkcie

Kód:

    function ding() {
        console.log("Ding!")
    }
    
    setTimeout(ding, 3000);

Alternatívne:

```
setTimeout(function() {
    console.log("Three seconds elapsed!");
}, 3000);
```

Callback: príklad práce so súborovým systémom v Node.js
-------------------------------------------------------

```javascript
fs.readFile('/etc/passwd', 'utf8', (err, data) => {
    if (err) throw err;
    console.log(data)
});
```

Callback v Node.js prijíma dva parametre:

- indikátor chyby `err`  pre prípad, že volanie zlyhalo.
- výsledok volania, v našom príklade `data` s textovým obsahom súboru.

Pyramid of Doom
----------------

Callbacky sú jednoduchý spôsob zápisu, ktorý však trpí neprehľadnosťou. Programátorský folklór ich často volá „pyramída hrôzy“, pretože biele miesto v odsadení pripomína otočenú pyramídu.

Skrátene, „Kód ide rýchlejšie doprava než nadol“:

```javascript
const fs = require('fs');

fs.open('/etc/passwd', 'r', (err, fd) => {
    if (err) throw err;
    fs.fstat(fd, (err, stats) => {
        console.log(stats.ctime)
        fs.close(fd, (err) => {
            if (err) throw err;
        });
    });
});
```

V algoritme voláme tri kroky:

1. Otvor súbor a získaj jeho *deskriptor* v premennej `fd`.
2. Zisti informácie o súbore.
3. Zatvor súbor.

Každý krok algoritmu vedie k samostatnému *callbacku* a k ďalšej úrovni zanorenia.

### Žiadne návratové hodnoty

Všimnime si, ako sa vôbec nepoužívajú návratové hodnoty funkcií v algoritme! Namiesto nich používame callbacky, ktoré prijmú výslednú hodnotu:

1. Callback funkcie `open` prijme deskriptor súboru.
2. Callback funkcie `fstat` prijme objekt so štatistikami súboru.
3. Callback funkcie `close` nepríjima žiaden parameter, čo zodpovedá *procedúre*, teda funkcii bez návratovej hodnoty.

Promises
========

Promises (prísľuby) sprehľadňujú zápis *callbackov*.

*	prísľub budúceho výsledku z asynchrónnej operácie.
*	objekty obaľujúce výsledok operácie, ktorý nemusí byť hneď dostupný
*	v Jave je to ekvivalent `CompletableFuture`.

Promises v JavaScripte
-------
Od ES6/ECMAScript 2015 sú promisy súčasťou jazyka. 

V odôvodnených prípadoch možno použiť niektorú z knižníc:

*	`q.js`
*	`when.js`
*	`rsvp.js`
*	jQuery (ale tie sú pokazené!) 

Príklad použitia v prehliadači
----------------

```javascript
let promise = fetch('http://jsonplaceholder.typicode.com/albums')
promise.then(response => showResult(response.statusText))
```

*	Funkcia `fetch()` vracia prísľub budúceho výsledku, `promise`.
*	S premennou `promise` môžeme veselo narábať, aj keď jej výsledok bude dostupný až v momente, keď server pošle všetky dáta.

Špecifikácia Promises/A+
--------------------------
*	promise je objekt/funkcia s metódou `then()`, ktorá sa správa podľa [špecifikácie Promises/A+](https://promisesaplus.com/).
*	thenable: objekt/funkcia s metódou `then()`

Promisy z ES6 a zmienených knižníc zodpovedajú tejto špecifikácii.

Promise: stavy a prechody
-------------------------
*	**pending**: prechod do **fulfilled** ALEBO do **rejected**
*	**fulfilled**: promise je splnený, a nesie v sebe hodnotu, ktorá sa nesmie zmeniť (immutability v zmysle `===`). Stav sa niekde volá aj **resolved**.
*	**rejected**: promise je zamietnutý, a nesie v sebe **dôvod zamietnutia** (*reason*), čo je ľubovoľná hodnota, ktorá sa nesmie zmeniť. *Reason* je obvykle objekt výnimky.

Splnený, ani zamietnutý prísľub sa už nikdy nemôže dostať do stavu *pending*. 

Poznámka: natívne promisy v ES2015 neposkytujú spôsob, ako zistiť ich stav.

Metóda `then()`
---------------

Metóda `then()` na promise berie dva parametre, tzv. **callbacky** (niekde tiež *handlery*), reprezentujúce dve funkcie.

*	funkcia `onFulfilled`:
	*	zavolaná po splnení prísľubu
	*	prvým parametrom je hodnota prísľubu
*	funkcia `onRejected`
	*	zavolaná po zamietnutí prísľubu
	*	prvým parametrom je dôvod zamietnutia (obvykle výnimka)

### Návratová hodnota `then()`

Po zavolaní metódy `then()` získame nový promise, ktorý je splnený po dobehnutí handlera pre splnenie, či zamietnutý po dobehnutí zamietacieho handlera. V prípade úspechu je hodnota v splnenom promise prevzatá z návratovej hodnoty callbacku.

To nám dáva možnosť reťaziť prísľuby, o čom si povieme podrobnejšie v sekcii *Reťazenie promisov*.

### Použitie `then` s dvoma callbackmi

```javascript
fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => console.log(response.statusText), err => console.error(err));
```

Funkcia [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) je zabudovaná funkcia v ES6/ECMAScript v prehliadači, ktorá predstavuje náhradu ajaxového API *XMLHttpRequest*.

Výsledkom funkcie je promise, ktorému podsunieme dva callbacky:

- v prípade úspechu získame objekt odpovede typu [`Response`](https://developer.mozilla.org/en-US/docs/Web/API/Response), z ktorého zalogujeme stavovú správu.
- v prípade zlyhania vypíšeme na konzolu chybu.

Skúsme zámerne urobiť preklep v adrese URL, napríklad na `ftp://` a uvidíme zamietnutý promise s volaním chybového callbacku.

### Použitie `then`  s jedným callbackom

Ak funkciu `onRejected` (druhý callback) vynecháme, použije sa štandardná obsluha chýb: chyba sa prepadne do zreťazeného promisu (viď nižšie) a ak taký neexistuje, prostredie ju môže vypísať na konzolu, prípadne do logu.

Reťazenie promisov
------------------

Funkcia `then` vracia ďalší *promise*, ktorý môžeme použiť na ďalšie spracovanie údajov. Stav tohto promisu záleží od návratovej hodnoty callbackov.

Callback (funkcia, ktorá je parametrom pre `then()`) môže vracať tri veci:

*	nič
*	bežnú hodnotu
*	promise
*	vyhodiť výnimku

Ak callback nevracia nič, alebo vracia nejakú hodnotu, je promise vrátený funkciou `then` [automaticky splnený](https://promisesaplus.com/#point-64).

Ak callback vyhodí výnimku, promise je zamietnutý.

Ak callback promisu P vracia iný promise Q, promise P prevezme stav vráteného promisu Q (promise P musí byť v stave *pending* dovtedy, kým je v stave *pending* vrátený promise Q. Podobne sa spriahne aj prechod do splneného či zamietnutého vzťahu. Podrobnosti určuje [špecifikácia](https://promisesaplus.com/#point-49).). 

### Ukážka reťazenia

V ukážke vidíme dvojité reťazenie promisov, v dvoch rozličných situáciách,.

```javascript
fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => response.json())
    .then(json => console.log(json))
```

1. Prvý callback vracia JSON z odpovede. Keďže metóda [`json()`](https://developer.mozilla.org/en-US/docs/Web/API/Body/json) vracia `Promise`, stav promisu vráteného z prvého `then` sa spriahne s prísľubom `json()`. 
2. Druhý callback prevezme parameter `json`, obsahujúci odbalenú hodnotu z predošlého promisu, teda samotný objekt s dátami, a vypíše ho. Callback nevracia nič, ale promise vrátený z druhej `then` už ani nepotrebujeme.

### Volanie `catch()` odchytáva výnimky

```javascript
fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => response.json())
    .then(json => console.log(json))
    .catch(err => console.error(err));
```

Volanie `catch()` je len syntaktický cukor pre volanie `.then()`, kde prvý parameter je `undefined`.

```javascript
.then(undefined, err => console.error(err))
```

### Skracovanie zreťazených promisov

Ak sú kroky a obsluhy výnimiek implementované ako funkcie, máme takmer Java/.NET *try-catch* štýl. Môžeme využiť trik *eta-redukcia*, kde volanie funkcie s jedným parametrom nahradíme priamo jej názvom:

```javascript
fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => response.json())
    .then(console.log)
    .catch(console.error);
```

Komplexné volania REST API
--------------------------

Komplexné volania REST API pomocou promisov sú veľmi bežné. Predstavme si nasledovnú situáciu:

1. Získame zoznam albumov pomocou volania REST.
2. Pre každý album dotiahneme samostatným volaním majiteľa (používateľa).
3. Majiteľa asociujeme s albumom.
4. Vrátime zoznam albumov s asociovanými majiteľmi.

Niektoré operácie sú asynchrónne: získanie zoznamu a dotiahnutie majiteľa. 

Záludnosť spočíva v poslednom kroku: máme zoznam albumov, pre každú položku asynchrónne dotiahneme majiteľa a obohatíme existujúci album. Výsledný zoznam albumov však nemôžeme používať dovtedy, kým nedobehli všetky získavania jednotlivých majiteľov. Preto musíme *počkať* na splnenie všetkých prísľubov s majiteľmi albumov; to však urobíme asynchrónne, bez blokujúceho čakania!

Poďme si to rozobrať po kroku:

### Získanie albumu 

```javascript
fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => response.json())
    .then(fetchAlbumOwnersAsync)
    .then(JSON.stringify)
    .then(console.log)
    .catch(console.error);
```

Získanie albumu zrealizujeme jednoducho: získame odpoveď, z nej vytiahneme JSON, a následne zavoláme funkciu `fetchAlbumOwnersAsync` (tá ešte neexistuje, ale vznikne). Funkcia vráti finálny zoznam albumov, ktorý následne zalogujeme, a obslúžime prípadné chyby.

Všimnime si, že to všetko zrealizujeme reťazení promisov!

Jednotlivé kroky si postupne odovzdávajú výsledky:

1. objekt `Response`.
2. prísľub, ktorý obsiahne JSONovskú reprezentáciu objektu v odpovedi
3. zoznam albumov, vrátane majiteľov
4. ich reťazová reprezentácia
5. nič (po zalogovaní), ak sa všetko vykoná bez problémov
6. nič (po zalogovaní chyby), v prípade chýb.

### Získanie majiteľov albumov

Funkcia `fetchAlbumOwnersAsync` zoberie sadu albumov, a pre každý album v nej dotiahne autora pomocou vnoreného prísľubu. 

Funkcia má príponu `Async`, čo je menná konvencia z niektorých projektov, ktorá naznačuje, že návratovou hodnotou je *promise*.

```javascript
function fetchAlbumOwnersAsync(albums) {
    let userPromises = albums.map(findUserByAlbumAsync);
    return Promise.all(userPromises)
        .then(users => associate(albums, users))
}
```

Funkcia prakticky namapuje každý album na prísľub, ktorý bude obsahovať jeho majiteľa. Mapovanie zrealizuje ďalšia funkcia, `findUserByAlbumAsync`, ku ktorej sa ihneď dostaneme:

```javascript
function findUserByAlbumAsync(album) {
    return fetch(`http://jsonplaceholder.typicode.com/users/${album.userId}`)
        .then(response => response.json())
}
```

Táto funkcia je jednoduchá: vráti prísľub s jedným používateľom, podľa identifikátora `userId` v albume.

Opäť pripomeňme, že táto funkcia mapuje album na prísľub používateľa a preto sme jej dali príponu `Async`.

Ak sa vrátime naspäť k `fetchAlbumOwnersAsync`, uvidíme premennú `userPromises`, ktorá obsahuje zoznam prísľubov (s majiteľmi). V tejto chvíli musíme „počkať“ na dobehnutie všetkých promisov, pretože inak nevieme albumom priradiť ich celé objekty majiteľov. Slovo „počkať“ je zámerne v úvodzovkách, lebo ide o **neblokujúce čakanie**, ktoré nezbrzdí (jediné) vlákno prehliadača. Vďaka špinavým trikom ide o neblokujúce čakanie, ktoré dosiahneme pomocou metódy `Promise.all`.

Metóda `all` — statická na triede `Promise` — počká na dobehnutie promisov v poli, alebo na zlyhanie ktoréhokoľvek z nich a vráti prísľub s jedným poľom obsahujúcim výsledky jednotlivých promisov.

Inak povedané, `all` prevádza pole prísľubov na pole s výsledkami prísľubov, pričom počká na úspech alebo prvé zlyhanie. 

Výsledné pole s výsledkami (s majiteľmi albumov v takom poradí, v akom sme zaslali albumy) následne preiterujeme a priradíme k nim albumy pomocou funkcie `associate()`.

### Asociovanie majiteľa s albumom

Na asociovanie majiteľa s albumom si urobíme pomocnú funkciu:

```javascript
function associate(albums, users) {
    albums.forEach((album, i) => album.user = users[i]);
    return albums
}
```

Funkcia prejde dve polia, index po indexe a priradí majiteľa zo zoznamu používateľov do dynamickej premennej `user` v príslušnom albume. Táto funkcia je úplne bežná, nie je asynchrónna, ani nevracia prísľub, ale bežný, upravený zoznam albumov.

### Výsledný kód

```javascript
function associate(albums, users) {
    albums.forEach((album, i) => album.user = users[i]);
    return albums
}

function findUserByAlbumAsync(album) {
    return fetch(`http://jsonplaceholder.typicode.com/users/${album.userId}`)
        .then(response => response.json())
}

function fetchAlbumOwnersAsync(albums) {
    let userPromises = albums.map(findUserByAlbumAsync);
    return Promise.all(userPromises)
        .then(users => associate(albums, users))
}

fetch('http://jsonplaceholder.typicode.com/albums')
    .then(response => response.json())
    .then(fetchAlbumOwnersAsync)
    .then(JSON.stringify)
    .then(console.log)
    .catch(console.error);
```

Async-Await
===========

Mechanizmus `async`/`await` slúži na *návrat* ku klasickému zápisu, kde máme premenné a priradenia do nich z návratových hodnôt funkcií namiesto používania `then` a callbackov.

Kľúčové slová `async` /`await` sú k dispozícii vo viacerých programovacích jazykoch, napr. v modernom JavaScripte a v C#.

* `async` označuje funkciu, ktorej návratová hodnota sa automaticky zabalí do prísľubu.
* `await` automaticky prevedie prísľub na hodnotu. Zamietnuté prísľuby prevedie na vyhodenie výnimky.

Kľúčové slovo `await` môžeme v JavaScripte používať len vo funkciách označených ako `async`.

Prebudujme teraz náš kód tak, aby používal `async`-`await`.

Začnime zhora: a rovno povieme, že funkcie `associate` sa nedotkneme, lebo tá nie je asynchrónna.

## Vyhľadanie používateľa podľa albumu

```javascript
async function findUserByAlbum(album) {
    let response = await fetch(`http://jsonplaceholder.typicode.com/users/${album.userId}`);
    return response.json()
}
```

Keďže funkcia `fetch` vracia prísľub, je to skvelý kandidát na prepis `then` na bežné priradenie do premennej. Keďže prísľub musíme odbaliť do hodnoty, použijeme slovo `await` (“očakávaj”).

Odpoveď používa metódu `json()`, ktorá vracia prísľub s objektovou reprezentáciou albumov, ktorý prepočleme ďalej.

A keďže funkcia `findUserByAlbum` vracia prísľub a keďže funkcia využíva `await`, musíme ju vyhlásiť za `async`, teda asynchrónnu.

Dotiahnutie majiteľov albumu
----------------------------

```javascript
async function fetchAlbumOwners(albums) {
    let userPromises = albums.map(findUserByAlbum);
    let users = await Promise.all(userPromises);
    return associate(albums, users)
}
```

Funkcia je tiež asynchrónna. Keďže `all` vracia prísľub, môžeme ho nahradiť očakávaním odpovede s poľom používateľov, ktoré priradíme do premennej s použitím `await`. Výsledok následne použijeme ako argument pre funkciu `associate`, ktorá nevracia prísľub, ale bežnú hodnotu. To neprekáža, pretože vďaka kľúčovému slovu `async` nad funkciou sa návratová hodnota funkcie `fetchAlbumOwners` vždy zabalí do prísľubu.

Spustenie mašinérie
-------------------

Keďže zavolanie zoznamu albumov chceme prepísať do `async`/`await`, čo je možné len v rámci `async` funkcie, upracme v kóde:

```javascript
async function findFullAlbums() {
    let response = await fetch('http://jsonplaceholder.typicode.com/albums');
    let albums = await response.json();
    return fetchAlbumOwners(albums);
}
```

Odpoveď z funkcie `fetch` je prísľub, preto ho odbalíme do premennej `response`. 

V ďalšom kroku prevedieme prísľub z funkcie `json()` na zoznam albumov, opäť odbalením pomocou `await`. 

Výslednú zbierku albumov následne použijeme ako argument pre funkciu `fetchAlbumOwners`, ktorá vracia prísľub. Ten použijeme ako návratovú hodnotu z našej funkcie.

### Vajce-sliepka pri asynchrónnych funkciách

Samotná mašinéria teraz trpí problémom vajca a sliepky. Potrebujeme zavolať `findFullAlbums`, ktorá je asynchrónna, ale to môžeme robiť len v rámci asynchrónnej funkcie. Ako z toho von?

Pripravíme si **anonymnú asynchrónnu funkciu**, ktorá sa navyše nielen zadeklaruje, ale aj sama spustí. Ide o *immediately invoked async function expression*, čo je rozšírenie vzorca IIFE z JavaScriptu.

```javascript
(async function () {
    try {
        let fullAlbums = await findFullAlbums();
        console.log(JSON.stringify(fullAlbums));
    } catch (e) {
        console.error(e)
    }
})();
```

Kolekcia zátvoriek definuje anonymnú funkciu (medzi úplne prvou guľatou zátvorkou a jej párom), ktorú následne okamžite vykoná (úplne posledný pár zátvoriek pred finálnou bodkočiarkou.).

Takto máme asynchrónnu funkciu, kde vieme získať zoznam celých albumov (i s majiteľmi), priradiť do do premennej s odbalením prísľubu a následným zalogovaním.

Obsluha výnimiek a flow
-----------------------

Všimnime si, ako sa vieme vrátiť k civilizovanej obsluhe výnimiek pomocou `try`/`catch`, čo je obvyklý spôsob! Vďaka `async`/`await` vieme používať asynchrónny kód skoro tak isto ako bežný, synchrónny"

Celý kód
--------

```javascript
function associate(albums, users) {
    albums.forEach((album, i) => album.user = users[i]);
    return albums
}

async function findUserByAlbum(album) {
    let response = await fetch(`http://jsonplaceholder.typicode.com/users/${album.userId}`);
    return response.json()
}

async function fetchAlbumOwners(albums) {
    let userPromises = albums.map(findUserByAlbum);
    let users = await Promise.all(userPromises);
    return associate(albums, users)
}

async function findFullAlbums() {
    let response = await fetch('http://jsonplaceholder.typicode.com/albums');
    let albums = await response.json();
    return fetchAlbumOwners(albums);
}

(async function () {
    try {
        let fullAlbums = await findFullAlbums();
        console.log(JSON.stringify(fullAlbums));
    } catch (e) {
        console.error(e)
    }
})();
```

Repozitár v Gite
================

Ukážkový kód sa nachádza v repozitári na GitHube, v repe [`novotnyr/javascript-async-rest-client`](https://github.com/novotnyr/javascript-async-rest-client).

Pramene
========

* [Asynchrónne veci v JavaScripte cez Promises](http://ics.upjs.sk/~novotnyr/blog/1996/asynchronne-veci-v-javascripte-cez-promises) — staršia verzia článku z roku 2014, pred príchodom promisov do jadra JavaScriptu.

* [Promises, Promises (slides)](http://www.slideshare.net/domenicdenicola/promises-promises)

* [You're Missing the Point of Promises](https://blog.domenic.me/youre-missing-the-point-of-promises/), @domenic, 14. October 2012

* [Making Promises with JavaScript](http://www.shakyshane.com/javascript/2013/11/16/making-promises-with-javascript/)

* [Promises/A+ Specification](https://promisesaplus.com/)

* [States and Fates](https://github.com/domenic/promises-unwrapping/blob/master/docs/states-and-fates.md) — popis stavov prísľubov a prechodov medzi nimi 

* [Promises/A Specification](http://wiki.commonjs.org/wiki/Promises/A)

* [Promise Anti-Patterns](https://github.com/petkaantonov/bluebird/wiki/Promise-anti-patterns)

* [JavaScript a `async`-`await`](https://javascript.info/async-await)

  
