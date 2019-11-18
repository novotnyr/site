---
title: Distribuované databázové transakcie cez Two Phase Commit (2PC)
date: 2019-11-18
---

Predstavme si učebnicový prevod peňazí medzi Alicou a Bobom. Ak máme databázu na jednom stroji, implementácia je otázkou *transakcie*. 

Ak je transakcí mnoho a rozdelíme ich medzi viacero strojov, získame síce vyšší výkon, ale vyrobíme si ďalšie problémy.

Algoritmus *Two Phase Commit* (2PC) je prastarý algoritmus na správny beh transakcií v distribuovaných databázach.

Klasické transakcie
===================

Učebnicová transakcia vyzerá nasledovne:

1. Začneme transakciu (begin)
2. Z Alicinho účtu odíde 20 korún.
3. Bobovi príde 20 korún.
4. Ukončíme transakciu
   1. Ak všetko uspelo, transakciu komitneme (potvrdíme).
   2. V prípade chyby celú transakciu abortneme (odvoláme).

Transakcia musí prejsť celá alebo vôbec — je vylúčené, aby Alica prišla o peniaze a Bob nedostal na účet nič. Inak povedané, musíme garantovať **atomicitu** transakcie.

Okrem toho je žiadúce dodržať aj ďalšie vlastnosti transakcií, v štýle ACID:

- **atomicity**: stane sa všetko alebo nič
- **konzistentnosť**: pred komitom sa dodržia invarianty (napríklad pred transakciou i po transakcii nebude Alicin účet prečerpaný)
- **izolácia:** ostatné súčasne bežiace transakcie neovplyvnia tento konkrétny prevod peňazí
- **durabilita** (trvácnosť): ak sa peniaze úspešne presunú, budú navždy presunuté.

Distribuované transakcie
========================

Ak databáza prestane zvládať mnoho prevodov peňazí, môžeme dáta v nej rozdeliť do **partícií** a každú z nich umiestnime na samostatný stroj — uzol. Rozdelenie môže byť jednoduché: povieme napríklad, že všetci zákazníci začínajúci na „A“ budú na stroji A, a  Bobovia, Borisovia a Braňovia budú na uzle B. 

Každý prevod peňazí (transakcia) tak potenciílne ovplyvní viacero partícií a teda viacero uzlov.

Komitovací protokol
-------------------

Hoci sme zvýšili výkon systému, zároveň sme si vyrobili ďalšie problémy:

- ako zaručíme, že každá partícia *komitne* alebo *abortne*?
- čo v prípade, že jeden z uzlov havaruje?
- čo v prípade, že sieť medzi uzlami havaruje?

Potrebujeme definovať **komitovací protokol** (*commit protocol*), ktorý určí pravidlá pre správanie takéhoto distribuovaného systému.

Dvojfázový komit
================

V prípade dvojfázového komitu zavedieme do architektúry tretí uzol — **koordinátora**, ktorý zdiriguje jednotlivé uzly.

Vidlácky komitovací protokol
----------------------------

Optimistický protokol vyzerá nasledovne:

1. Klient banky povie koordinátorovi: **bež!** (presúvaj peniaze)
2. Koordinátor povie uzlu A: **odober 20 korún!**
3. Koordinátor povie uzlu B: **pridaj 20 korún!**
4. Koordinátor odkáže klientovi: **peniaze sa presunuli!**

*What could possibly go wrong?* Zlyhať vieme na mnohých miestach:

- Alica nemá dosť peňazí.
- Bobova partícia (uzol) havarovala pred prijatím správy. Analogicky mohol havarovať aj Alicin uzol.
- Koordinátor odoslal správu Alici, ale pred odoslaním správy Bobovi havaroval.
- Pokaziť sa môže aj sieťové spojenie medzi koordinátorom a uzlom B.

Safety a liveness
-----------------

Distribuované systémy sa riadia dvoma vlastnosťami:

- **safety** (bezpečnosť), v skratke „zlé veci sa nikdy nestanú“. (Deadlocky nenastanú, do chybového stavu sa nikdy nedostaneme, dva procesy nikdy nebudú naraz v kritickej sekcii.)
- **liveness** (činorodosť), v skratke „nadíde čas, keď sa všetko na dobré obráti“. (Nadíde čas, keď proces B vojde do kritickej sekcie — ak ju opustí proces A. Nadíde čas — eventuálne — sa dva uzly dohodnú na platnej hodnote v databáze.)

Takéto systémy musia vyvážiť požiadavky na bezpečnosť s požiadavkami na činorodosť. V bankových systémoch je obvykle dôraz na bezpečnosť, hoci potvrdenie transakcie môže chvíľu trvať. Na druhej strane, v sociálnych sieťach môžeme uprednosťovať činorodosť, najmä ak je dôležité okamžite vidieť novopribúdajúce statusy.

### Safety a liveness v komitovacom protokole

Požiadavky na bezpečnosť sú jednoduché:

- ak jeden uzol komitne, nikto nesmie abortnúť.
- ak jeden uzol abortne, nik nesmie komitnúť

Činorodosť má tiež svoje požiadavky:

- ak sa nič nepokazí a všetky uzly vedia komitnúť, komitneme celú transakciu
- ak nastane zlyhanie, ihneď musíme vyhodnotiť transakciu vhodným spôsobom.

Inými slovami, žiaden účastník nesmie komitnúť, kým sa všetci nezhodli na komite.

Zároveň vyriešime dva aspekty:

- timeouty: ak správy neprichádzajú v danej lehote, znamená to, že buď spadla sieť alebo niektorý z uzlov havaroval.
- reštarty: nie je vylúčené, že niektorý účastník síce havaroval, ale snaží sa spamätať. 

Poriadny komitovací protokol
----------------------------

Pre ujasnenie budeme v poriadnom 2PC protokole rozoznávať 

- klient: ten, ktorý iniciuje transakciu
- podriadený: uzol s partíciami (nesú databázy s bankovými účtami)
- koordinátor: diriguje podriadených.

Algoritmus bude vyzerať nasledovne:

1. klient koordinátorovi: **makaj!**
2. koordinátor podriadenému A: **priprav sa!**
3. koordinátor podriadenému B: **priprav sa!**
4. Podriadený A odpovie (zahlasuje) koordinátorovi: **áno** alebo **nie**, podľa toho, či vie uskutočniť transakciu nad svojimi dátami.
5. Podriadený B nezávisle zahlasuje **áno** alebo **nie** a odpovie koordinátorovi.
6. Koordinátor vyhodnotí hlasovanie:
   1. Ak všetci podriadení zahlasovali **áno**, každému podriadenému pošle správu **komitni!** (Podriadení komitnú zmeny v dátach vo svojich partíciách.)
   2. Ak niektorý podriadený povedal **nie**, každému podriadenému pošle správu **abortni!** (Podriadení abortnú zmeny vo svojich partíciách.)

7. Koordinátor oznámi klientovi: buď **OK** alebo **zlyhali sme**.

Kde sa čaká?
------------

Základným *problémom* dvojfázového komitu je blokovanie. Presnejšie:

1. Koordinátor čaká na odpoveď **áno** / **nie** od každého podriadeného
2. Podriadení čakajú na **komitni!** alebo **abortni!** od koordinátora.

### Riešenie čakania na podriadených

V prvom prípade koordinátor čaká na výsledok hlasovania od podriadených. Keďže zatiaľ neposlal žiaden komit, môže *čakať* a po vypršaní timeoutu abortnúť celú transakciu.

Toto je konzervatívny prístup, ktorý zachová korektnosť, ale obetuje výkon. (Čo keď zlyhala sieť a podriadení nemôžu odpovedať?).

### Riešenie čakania na koordinátora

V prípade, že podriadení zahlasovali, a čakajú na koordinátora, môžu nastať dva prípady. 

1. Ak niektorý z podriadených zahlasoval **nie**, môže bezpečne abortnúť (hlasovanie už nikdy neprejde.)
2. Ak podriadený zahlasoval **áno**, môže *čakať navždy*, pretože bez informácie od koordinátora nevie rozhodnúť, či komitnúť alebo abortnúť. Táto situácia je charakteristickým problémom pre dvojfázový komit.

Reštarty po zlyhaní
-------------------

Medzi možné situácie zlyhania patrí nasledovné:

1. Koordinátor pošle **komitni!** a havaruje.
2. Podriadený pošle **áno** a havaruje.

### Write Ahead Log

Jedným z riešení je použitie **write-ahead logu**, teda záznamu aktivít, ktoré sa mienia vykonať. Zjednodušene povedané, WAL je debilníček s plánom činností a keď účastník úspešne dokončí danú činnosť, odčiarkne si ju. Ak ho niekto vyruší (reštartne), nemá problém sa k debilníčku vrátiť a zistiť, čo už bolo splnené a čo nie.

Každá správa, ktorú koordinátor alebo podriadení pošlú, sa zapíše do logu, ktorý poslúži v prípade zotavenia.

### Reštart koordinátora

Ak koordinátor pošle **komitni!** a reštartuje sa, po obnovení činnosti nahliadne do write-ahead logu.

Ak tam nenájde príkaz **komitni!**, abortne transakciu. Ak sa príkaz **komitni!** v logu nachádza, zopakuje ho.

### Reštart podriadeného

Ak podriadený nenájde vo svojom write-ahead logu hlasovanie **áno**, môže abortnúť (ešte nehlasoval, teda koordinátor nemohol komitnúť.)

A naopak, ak podriadený už hlasoval **áno** (má to vo WAL logu), je blokovaný, pretože čaká na rozhodnutie koordinátora.

Poznámky k implementácii
------------------------

Pri hlbšom pohľade na algoritmus sa často používa ešte jeden typ správ: vždy, keď podriadený vykoná komit alebo abort, odpovie koordinátorovi správou **vykonané!** (**ack**)

V kombinácii s write-ahead logom vyzerá postup nasledovne:

1. klient koordinátorovi: **makaj!**
2. koordinátor podriadenému A: **priprav sa!**
3. koordinátor podriadenému B: **priprav sa!**
4. Podriadený A zapíše do svojho WAL logu **áno** alebo **nie** a odpovie koordinátorovi hlasovaním **áno** alebo **nie**.
5. Podriadený B nezávisle zapíše do vlastného WAL logu **áno** alebo **nie** a zahlasuje koordinátorovi príslušné rozhodnutie.
6. Koordinátor vyhodnotí hlasovanie:
   1. Ak všetci podriadení zahlasovali **áno**, 
      1. Do svojho logu WAL zapíše **komitni!**
      2. Každému podriadenému pošle správu **komitni!**
      3. Každý podriadený zapíše do vlastného WAL logu správu **komitni!**, vykoná zmeny v dátach svojej partície a odošle koordinátorovi správu **vykonané!**
   2. Ak niektorý podriadený povedal **nie**, 
      1. Do svojho logu WAL zapíše **abortni!**
      2. Každému podriadenému pošle správu **abortni!** 
      3. Každý podriadený zapíše do WAL logu správu **abortni!**, odvolá zmeny vo svojej partícii a odošle koordinátorovi správu **vykonané!**

7. Koordinátor vyzbiera všetky správy **vykonané!** od podriadených a oznámi klientovi: buď **OK** alebo **zlyhali sme**.

V tomto rozšírenom správaní môžeme niektoré správy posielať opakovane.

- Ak koordinátor nedostal správy **vykonané!** (lebo podriadení sa reštartujú), vie ich opakovať, kým ich nezíska.
- Ak je podriadený pripravený, ale čaká na koordinátora (ktorý sa reštartuje), môže sa ho opakovane pýtať na stav transakcie.

Bezpečnosť a činorodosť v 2PC
-----------------------------

Bezpečnosť (safety) je zaručená spôsobom hlasovania. Všetci podriadení sa musia zhodnúť na hlasovaní **áno**, inak sa ransakcia nemôže vykonať.

Liveness (činorodosť) je dosiahnutá v prípade, že nik nezlyhal. Ak všetci hlasovali **áno**, potom sa transakcia ihneď komitne. V prípade zlyhaní musíme čakať (blokovať), kým sa havarovaní účastníci nereštartnú, čo je kritický moment protokolu.

Pramene
=======

- [Daniel Suo: COS 418 — Distributed Systems Lecture 6](https://www.cs.princeton.edu/courses/archive/fall16/cos418/docs/L6-2pc.pdf)
- [Muhammad Atif: Analysis and Verification of Two-Phase Commit &Three-Phase Commit Protocols](https://www.win.tue.nl/~atif/reports/paper4ICET.pdf)
- [Peter Gurský: Princípy databáz, prednáška 8](http://gursky.sk/pd/slidy2015/prednaska8.pdf)
- [Jozef Jirásek: Paralelné a distribuované systémy, prednáška 8](http://ics.upjs.sk/~jirasek/pds/pds08e.pdf)