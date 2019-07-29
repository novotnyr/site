---
title: Exago
date: 2009-03-04T17:51:08+01:00
---

# Inštalácia

Exago je implementované ako rozšírenie (extension) pre Firefox 3.0 a novší. Inštaláciu realizujeme ako v každom inom rozšírení.

Navštívením [adresy rozšírenia](http://ics.upjs.sk/~novotnyr/exago/exago.xpi ) vo Firefoxe, potvrdením inštalácie a reštartovaním Firefoxu.

Po inštalácii si zapneme z hlavného menu View | Sidebar | Exago Sidebar. Vľavo sa zobrazí lišta s užívateľským rozhraním.

## Nastavenie servera
Údaje o anotovaných stránkach sa odosielajú na server. Konfiguráciu realizujeme pomocou tlačidla **Settings**. Uvedieme 
* prihlasovacie meno (používa sa pri identifikácii anotátora)
* heslo (v súčasnej verzii nepoužívané)
* server: hodnota má byť `http://dbserver.ics.upjs.sk:8080`

# Používanie
Pohybom myšou nad stránkou sa červenou farbou zvýrazňujú elementy, ktoré je možné anotovať.

V súčasnej verzii je k dispozícii možnosť anotácie elementov
* *p* 
* *h1*
* *h2*
* *h3*

Po kliknutí na zvýraznený element sa zobrazí dialógové okno, v ktorom je potrebné zadať názov atribútu objektu, ktorého hodnota sa nachádza v anotovanom texte. (Príklad: *nadpis* stránky.)

Anotovaný element sa zjaví v zozname anotácií v lište naľavo. 

Následne môžu byť informácie o anotovaní odoslané na server. V zozname v lište vľavo vyberieme anotačný element, ktorý chceme odoslať na server a kliknutím na tlačidlo *Submit* ho odošleme. 

V súčasnej verzii nie je možnosť hromadného odosielania elementov.

# Anotácia elementov na základe existujúcej stránky
Množstvo stránok sa vyznačuje podobným vzhľadom a štruktúrou DOM. To možno s výhodou použiť na urýchlenie anotácie. 

Kliknutím na *Load Data From Similar Page* sa z centrálneho servera načítajú anotované stránky. Používateľ môže zvoliť stránku, ktorá bude slúžiť ako predloha pre anotovanie zobrazenej stránky. Z predlohy sa načítajú všetky anotované atribúty.

Kliknutím pravým tlačidlom myši na atribút v zozname v lište vľavo a vybratím položky *Apply on current page* sa použije anotovaný atribút z predlohy na aktuálnu stránku (použitie sa prejaví červeným zvýraznením elementu).

Takto anotovaný dokument je ďalej nutné zaslať na centrálny server zvyčajným spôsobom.

# Vzhľad aplikácie
Kliknutím na [odkaz](http://ics.upjs.sk/~novotnyr/exago/exago.png ) zobrazíte náhľad na aplikáciu.
