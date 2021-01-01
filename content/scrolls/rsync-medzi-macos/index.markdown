---
title: Migrácia medzi dvoma MacOS pomocou `rsync`
date: 2021-01-01T23:27:50+01:00
---

Migrácia na nový MacBook Pro je malina. Naozaj sa nestratia žiadne dáta?

Štandardný postup je jednoduchý

1. Oba stroje sa pripoja k rovnakej WiFi.
1. Na každom stroji sa pustí *Migration Assistant*.
2. Po pár hodinách je všetko magicky zmigrované.

Akurát pri mojej migrácii Macbook Pro zahlásil:

> Niektoré súbory sa nepodarilo zmigrovať.


Ktoré? Všetky? Niektoré náhodné? Nik nevie.

## Nový stroj jede... Jenom neseje.
Nový stroj zdanlivo išiel bez problémov - až zázračne. A to sa migrovala High Sierra na Big Sur! Všetky nastavenia sa zmigrovali úplne magicky - WiFi, aplikácie, používateľské kontá... až do momentu, kým iTerm2 nezahlásil, že nevie nájsť symlinky na *dotfiles*.

Vysvitlo, že adresár s projektami sa zmigroval len z jednej pätiny, čo je trochu viac ako „niektoré súbory“. Stovky binárok `.class` a `node_modules` asi spôsobili migračnému asistentovi bolehlav a rovno to vzdal s tým, že "niektoré súbory..."

## Biedne pokusy

Pokusy s Forkliftom a podobne rovno zlyhali -- opäť tisícky súborov boli nad sily.

## RSync!

Nástroj `rsync` je starý dobrý unixoidný systém na synchronizáciu medzi dvoma adresármi s rozumným protokolom.

Dokonca je k dispozícii aj natívne na MacOS, ale v prastarej verzii. Silne odporúčam doinštalovať aktuálnu verziu cez `homebrew`

    brew install rsync

V tomto prípade využijeme optimalizáciu s `rsync` démonom, teda v duchu klient-server architektúry.

### Na strane „servera“ -- pôvodného stroja

Na strane pôvodného servera vytvorme konfigurák pre démona `rsyncu`:

```
vim /tmp/rsyncd.conf
```
Obsah:
```
list = yes
read only = yes
use chroot = false
[projects]
path = /Users/novotnyr/projects
exclude = /Users/novotnyr/Library/Caches
```

Dôležité nastavenia:

- vypneme `chroot` - klientovi sa to nepáči.
- nastavíme režim len na čítanie

Sekcie sa mapujú na adresáre. Definujeme adresár `projects`, kde uvedieme vypublikovaný adresár a vynecháme zbytočné adresáre, ktoré nechceme synchronizovať.

Démona spustíme:

```
rsync --daemon --config=/tmp/rsyncd.conf
``` 

### Na strane klienta - nového stroja

Na strane klienta spustíme:

```
rsync -avc rsync://192.168.1.240/novotnyr/ /Users/novotnyr
```

Prepínače:

- `-a` - zapne rekurzívnu sychronizáciu a uchová atribúty súborov
- `-v` - zapne ukecaný *verbose* výstup
- `-c` - porovná rovnaké súbory na základe kontrolného súčtu namiesto času

Dá sa skúsiť aj beh „nasucho“ - stačí zapnúť prepínač `-n`.

Pri prvej ceste je **dôležitá** lomka na konci (`novotnyr/`), pretože v opačnom prípade sa nakopíruje adresár do klientovho `/Users/novotnyr`.

Synchronizácia beží značne rýchlo - `rsync` je totiž naozaj dobre vymyslený protokol

## Porovnanie obsahu

Voliteľne môžeme aj porovnať obsahy:

```
rsync -avun rsync://192.168.1.240/novotnyr/ /Users/novotnyr 
```
Prepínač `-u` preskočí súbory, ktoré sú novšie v cieli --  v tomto prípade na novšom stroji,
