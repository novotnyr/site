---
title: Programovanie, algoritmy, zložitosť 2006
year: 2006/2007
date: 2006-09-23T12:56:00+01:00
course: UINF/PAZ1c

---

Záverečný projekt – Spracovanie konfiguračných súborov
======================================================


Úlohou aplikácie je zabezpečiť pohodlnú prácu s konfiguračnými súbormi typu INI a XML. Aplikácia musí podporovať nasledovné činnosti:

- načítanie konfiguračného súboru zo súboru (voliteľne: načítanie konfiguračného súboru z CLASSPATH, z URL)
- získavanie hodnôt z jednotlivých konfiguračných kľúčov s pohodlnou automatickou konverziou medzi typmi, teda metódu na načítanie celého čísla, reálneho čísla, reťazca a booleovskej hodnoty. Aplikácia musí podporovať spôsob získania hodnoty s ošetrením situácie, keď sa daný kľúč v konfiguračnom súbore nenachádza (možnosť vrátiť nedefinovanú hodnotu alebo možnosť vrátiť užívateľom určenú implicitnú hodnotu).

- získavanie všetkých kľúčov z konfiguračného súboru
- získavanie všetkých kľúčov z danej sekcie
- získavanie párov (kľúč, hodnota) buď zo sekcie, alebo z celého súboru
- získanie všetkých sekcií zo súboru



Aplikácia musí podporovať nasledovné typy konfiguračných súborov:

- konfiguračný súbor INI
- konfiguračný súbor XML

## Konfiguračný súbor INI

Obsahuje po riadkoch dvojice *kľúč = hodnota*. Dvojice môžu byť logicky združené v sekciách (názov sekcie je uvedený v hranatých zátvorkách). Súbor môže obsahovať komentáre uvedené znakom bodkočiarky. Kvôli prenositeľnosti musí aplikácia podporovať špecifikáciu komentárového znaku.

Príklad inicializačného súboru INI. Obsahuje koreňový element configuration, element pre sekcie section, ktorý môže obsahovať elementy pre jednotlivé konfiguračné dvojice. 
```
; for 16-bit app support 
[fonts] 
[files] 
[Mail] 
MAPI=1 
MAPIX=1 
[MCI Extensions.BAK] 
aif=MPEGVideo 
aifc=MPEGVideo 
aiff=MPEGVideo 
asf=MPEGVideo
```

## Konfiguračný súbor XML
```xml
<?xml version="1.0" ?>
<configuration>
    <section title="fonts"></section> 
    <section title="files"> </section>
    <section title="Mail">
        <item key="MAPI">1</item> 
        <item key="MAPIX">1</item> 
    </section>
    <section title="MCI Extensions.BAK">
        <item key="aif">MPEFVideo</item>
        <item key="aifc">MPEGVideo</item>
    </section>
</configuration>
```
