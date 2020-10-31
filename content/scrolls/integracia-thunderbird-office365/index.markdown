---
title: Integrácia Thunderbird a Office 365
date: 2020-10-31T00:50:08+01:00
---

Thunderbird sa dokáže integrovať s Office 365 podobným spôsobom ako Outlook. 

Budeme potrebovať tri doplnky (add-ons):

- [TBSync](https://addons.thunderbird.net/en-US/thunderbird/addon/tbsync/) --  integrácia kontaktov, kalendáre a úlohy
- [EAS Sync pre TBSync](https://github.com/jobisoft/EAS-4-TbSync/wiki/Compatibility-list-(EAS)) -- podpora pre Exchange ActiveSync, ktorou z Office 365 vytiahneme kontakty
- [OWL for Exchange](https://addons.thunderbird.net/en-US/thunderbird/addon/owl-for-exchange/) -- platený plugin pre e-maily a pozvánky na udalosti pre protokol Outlook Web Access (OWA).

TBSync + EAS Sync: adresár kontaktov
------------------------------------

Hoci TBSync vieme použiť pre kalendáre a služby založené na protokole ActiveSync, mnoho zamestnávateľov využívajúcich Office 365 tento protokol nepovoľuje a tým redukuje tento add-on na adresár s kontaktami.

Kalendár síce vieme prepojiť a zobraziť do rozhrania Thunderbirdu, ale udalosti v mailoch nebudeme vedieť ani schváliť ani zamietnuť. Vždy keď príde pozvánka na udalosť, dostaneme mail s textom:

> To receive meeting invitations as .iCalendar attachments instead of Outlook Web App links, go to https://outlook.office365.com/owa/upjs.sk/?path=/options/popandimap and select Send meeting invitations in iCalendar format.

Na jeseň 2020 je podpora zvláštna -- toto nastavenie sa v Outloooku na webovej verzii Office 365 vôbec nenachádza.

Kalendár / úlohy radšej prepojíme v ďalšej sekcii cez add-on Owl.

### Konfigurácia

Konfigurácia add-onu sa rieši cez separátny dialóg. V hlavnom menu *Tools -> Synchronization Settings (TBSync)* pridáme nový účet *Exchange ActiveSync* a vyberieme si konfiguráciu typu **Microsoft Office 365**.

![TBSync a účet Office365](tbsync-office365.png)

Prihlásime sa do účtu a akceptujeme dialógové okna implementujúce login cez protokol OAuth - čo pravdepodobne vyvolá autentifikáciu cez prihlasovacie okno vášho zamestnávateľa.

V následnom dialógu vypneme synchronizáciu položiek a ponecháme len kontakty (Contacts). Kalendár a ostatné položky vyriešime iným add-onom (cez Owl), a ak by sme na to zabudli, zistili by sme, že máme duplicitné kalendáre (z Owl a TBSync).

![TBSync a účet Office365](tbsync-config.png)

Nezabudneme nastaviť periódu synchronizácie -- štandardná nula zodpovedá ručnej synchronizácii, ale je lepšie použiť napr. hodinový interval.

Owl For Exchange: maily, kalendár a udalosti
---------------------------------------------
Owl for Exchange je platený add-on pre integráciu mailov, kalendárov a udalostí cez protokol OWA. Stojí síce 10 dolárov ročne (s mesačnou skúšobnou lehotou), ale podporíte dlhoročného prispievateľa do zdrojákov Thunderbirdu.

Okrem toho získame podporu pre obsluhu pozvánok na udalosti priamo z okna Thunderbirdu.

![UI s pozvánkami cez Owl](thunderbird-owl.png)

Owl je dokonca propagovaný v Thunderbirde. Ak vytvárame nový účet a zvolíme typ Exchange, dostaneme ponuku pre inštaláciu tohto add-onu.

![Zakladanie nového účtu cez Owl](owl-new-account.png)

Prihlásenie sa realizuje rovnako cez OAuth, čiže zrejme opäť uvidíme prihlasovací screen svojho zamestnávateľa.

Owl zavedie účet medzi štandardné účty spravovateľné cez *Tools -> Account Settings* presne tak ako akýkoľvek iný účet. Prihlásenie je riešené špecificky, cez metódu **Open Login web page**.

Záver
=====

Kolujú anektodálne historky, ako používatelia rozbehali podporu pre pozvánky aj iným spôsobom. Problém je však v šťastnej kombinácii add-onov a verzie Thunderbirdu.

Thunderbird verzie 78 je značne odlišný od predošlých verzií a TBSync rovnako nedoimplementoval podporu pre všetky okrajové prípady.

Kombinácia týchto troch doplnkov je preverená a funguje aj na modernom Thunderbirde, čo sa výmenou za pár eúr ročne oplatí.
