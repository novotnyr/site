---
title: XUL – Vytvorenie nového rozšírenia pre Firefox
date: 2005-02-17T19:30:01+01:00
---
(pozn: viacmenej okopírované z tutoriálu na [XULPlanet.com](http://xulplanet.com/tutorials/xultu/xulfile.html ))

## Úvod
Na prípravu nového rozšírenia potrebujeme

* adresárovú štruktúru
* upraviť `contents.rdf`
* upraviť `installed-chrome.txt`

## Adresárová štruktúra
Súbory rozšírenia by sa mali nachádzať v úhľadnom JARe, ale pri ladení ich nechceme do archívu neustále zabaľovať a odbaľovať. Môžeme si založiť adresár v adresári `chrome`, v prípade Firefoxu napr. `c:\Program Files\Mozilla Firefox\chrome`.
Nech sa naša aplikácia volá „textedit". Založíme teda nasledovnú štruktúru
```
c:\Program Files\Mozilla Firefox\chrome
  |
  |-textedit
      |-content
      |-skin
      |-locale
```
Adresáre `skin` a `locale` zatiaľ ponecháme prázdne. Naše súbory `.xul` budeme pchať do adresára `content`.

## contents.rdf
Súbor `contents.rdf` popisuje obsah balíčka, je to bežný XML súbor. Tento súbor uložíme (podľa mňa ako UTF-8) do adresára `textedit/content`.

```xml
<?xml version="1.0"?>

<RDF:RDF xmlns:RDF="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:chrome="http://www.mozilla.org/rdf/chrome#">

  <RDF:Seq about="urn:mozilla:package:root">
    <RDF:li resource="urn:mozilla:package:textedit"/>
  </RDF:Seq>

  <RDF:Description about="urn:mozilla:package:textedit"
          chrome:displayName="Nas mocny textovy editor"
          chrome:author="Fero Tarabak"
          chrome:name="textedit"
          chrome:extension="true"/>
</RDF:RDF>
```

## Úprava `installed-chrome.txt`
Upravíme súbor `c:\Program Files\Mozilla Firefox\chrome\installed-chrome.txt`, aby sme upovedomili Firefox o našom rozšírení. Na koniec tohto súboru pridáme riadok
```
content,install,url,resource:/chrome/textedit/content/
```
Uistíme sa, že na konci cesty je spätná lomka a že na konci súboru je prázdny riadok. Riadok znamená, že inštalujeme súčasť `content` (podrobnosti v tutoriále).

Spustíme Firefox. Ak bola inštalácia úspešná, názov našeho rozšírenia by sa mal objaviť v súbore `c:\Program Files\Mozilla Firefox\chrome\chrome.rdf`. Ak nie, je niečo zhnité (je `contents.rdf` validné XML?)
