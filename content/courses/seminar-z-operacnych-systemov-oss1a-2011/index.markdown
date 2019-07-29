---
title: Seminár k operačným systémom 2011
date: 2011-09-15T19:30:01+01:00
year: 2011/2012
course: UINF/OSS1a
---
- Semester: zimný

- Rok: 2011

# Zadania
Zadanie je potrebné poslať mailom do 6. 2. 2012 23:59.
## Zadania k Powershellu
Vytvorte skript v PowerShelli, ktorý vytvorí sumárnu informáciu o aktuálnom stroji. V sumárnej informácii uveďte nasledovné informácie.

* Názov aktuálneho stroja
* Veľkosť nainštalovanej pamäte RAM
* MAC adresy sieťových adaptérov
* IP adresu v aktuálne pripojenej sieti
* Počet fyzických diskov
* Všetky logické jednotky a ich veľkosti.
* Zoznam používateľov aktuálneho stroja
* Pre každého používateľa veľkosť jeho domovského adresára a cestu k nemu.

V skripte deklarujte vlastnú triedu `LocalStationInfo` s vhodne zvolenými inštančnými premennými.

Vytvorte cmdlet `GetLocalStationInfo`, ktorý prijme z rúry inštanciu LocalStationInfo a do rúry pošle prehľadne naformátované informácie o aktuálnom stroji. Informácia nech je reprezentovaná v používateľsky prítulnom HTML súbore.

Pripravte powershellovský skript, ktorý vezme ako parameter názov súboru. Po spustení skriptu nech sa do zadaného súboru zapíše uvedená HTML správa o aktuálnom stroji.

## Zadanie k shell scriptingu
Vytvorte sadu shell skriptov, ktoré realizujú zálohovanie ľubovoľného adresára na vzdialené úložisko v duchu nástroja `rsync`

Zvoľte jeden vhodný typ vzdialeného úložiska, inšpiráciou môže byť:

* HTTP upload 
* FTP
* SCP

Odporúča sa použiť HTTP upload, pričom na strane servera vytvorte jednoduchý PHP skript a na strane shellskriptu využite nástroj `cURL`.

Každá záloha adresára nech je vo vzdialenom úložisku identifikovaná časovou značkou, ktorá je jednoznačná.

Nástroj nech podporuje nasledovné operácie:

* odzálohovanie ľubovoľného adresára zadaného z parametra do úložiska
  
  Odporúča sa využiť niektorý z komprimačných nástrojov, napr. tradičnú kombinácu `tar` a `gz`.

```
backup /home/novotnyr
```

* výpis všetkých záloh na vzdialenom úložisku
```
$> retrieve
Zoznam zaloh:
2011/10/10
2011/12/1
2012/1/2
```
* obnovenie zálohy na základe zadanej časovej značky do zadaného adresára
```
$> restore 2011/10/10 /home/tmp/backup
```
Záloha musí byť obnovená do identického stavu, v akom sa nachádzala pri zálohovaní, čo platí pri obnove súborov do existujúceho adresára. Ak používateľ obnovuje do existujúceho adresára, vyžadujte od neho potvrdenie (použite `read` alebo vyžadujte špeciálny parameter)).
* zistenie zoznamu rozdielnych súborov (pribudnutých, odbudnutých, zmenených) medzi dvoma zálohami.
```
$> difference 2011/10/10 2012/1/2
+ index.html
+ wiki/wiki.html
- chata.jpg
- ozierka.jpg
1.  changelog
1.  zoznamuloh.jpg
```
Jedno z riešení odošle na server spolu s komprimovaným adresárom aj súbor obsahujúci cesty pre každý zo zoznamu súborov.

### Všeobecné zásady

Kód nech dodržuje všetky zásady POSIXového shellu. Vyhnite sa bashismom a podobným nekompatibilitám. Skripty testujte na shelli `dash` alebo `ash`, ktorý je prítomný na serveri `s.ics.upjs.sk`, uveďte do shebangu `/bin/dash`) a na debianovských distribúciách, alternatívne využite projekt `busybox`, alebo niektorý z mikrodistribúcií (napr. TinyCore Linux).
