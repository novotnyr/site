---
title: Saga - distribuované transakcie v nezávislých databázach
date: 2019-11-23T10:28:31+01:00
---

> „Povedzte učiteľovi, že nemám ságy,“ úctivo odpovedal Ostap.
>
> — Iľf-Petrov, Zlaté teľa (1931)

Kedy ságy?
==========

Ak máme bežnú relačnú databázu na jednom stroji a chceme to mať postavené *dobre*, použijeme **transakcie** spĺňajúce zásady ACID.

Ak máme bežnú relačnú databázu rozdelenú na viacero strojov (partície) a chceme to mať tiež postavené dobre, použijeme **dvojfázový komit** (2PC, *two-phase commit*).

Ak máme viacero nezávislých databáz — napríklad každá mikroslužba má svoju databázu — dvojfázový komit sa nedá realizovať. (V takom prípade možno nemá zmysel ani relačná databáza...)

To je situácia, keď distribuovanú transakciu implementujeme ako **ságu**.

Sága
====

**Sága** je postupnosť lokálnych transakcií v nezávislých službách. 

Každá lokálna transakcia, teda aktualizácia dát v konkrétnej nezávislej databáze jednej služby, musí:

- aktualizovať databázu
- v prípade úspechu vyvolať nasledovný krok ságy
- v prípade neúspechu lokálnej transakcie musí **odvolať** (*undo*) aktualizáciu dát vo svojej databáze a zároveň odvolať zmeny v predošlých krokoch ságy.

Príklad ságy
============

Predstavme si microservicovú architektúru:

- služba `Objednávky` 
- služba `Platby`
- služba `Doručenie`

Súc systémom, očakávam, že:

1. zákazník si objedná tovar
2. prijmeme od neho platbu
3. odošleme tovar.

Toto je *distribuovaná transakcia*, ktorá by sa v bežnej monolitickej databáze riešila s dodržaním pravidiel ACID.

Ako to však riešiť krížom cez viaceré nezávislé databázy?

Architektúry pre ságy
=====================

Implementácia má dva typické prístupy:

- **event/choreography**: bez koordinátora. Každá služba vysiela udalosti a zároveň počúva na udalosti a rozhodne sa, či reagovať.
- **command/orchestration** s koordinátorom, ktorý rozhoduje v ságe, vyvoláva jednotlivých účastníkov ságy, a koordinuje vykonávanie jednotlivých krokov.

Event/Choreography: choreografia
--------------------------------

### Úspešný scenár

Služba `Objednávky` započne transakciu pre vytvorenie objednávky.

1. Služba `Objednávky` publikuje udalosť `ORDER_CREATED`. Na túto udalosť počúvajú ďalšie služby, ktoré podľa potreby vykonajú svoje transakcie a vypublikujú nové udalosti:
   2. Služba `Platby` vyšle `ORDER_BILLED`.
   2. Služba `Doručenie` vyšle `ORDER_DISPATCHED`.
2. Transakcia končí, keď posledná služba dokončí svoju lokálnu transakciu.
3. Transakcia končí i v prípade, keď na udalosť nikto nereagoval.

Služba `Objednávky` vie sledovať všetky udalosti plávajúce v systéme a monitorovať stav.

### Rollbacky v neúspešnom scenári

V prípade, že niektorá z lokálnych transakcií zlyhá, treba odvolať všetky predošlé kroky ságy, teda treba spustiť **kompenzácie**.

Ak služba `Doručenie` zistí, že tovar nie je na sklade, treba odvolať predošlé kroky:

1. Služba `Platby` kompenzuje lokálnu transakciu vrátením peňazí zákazníkovi.
2. Služba `Objednávky` povie zákazníkovi, že objednávka zlyhala (a že ju možno treba zopakovať neskôr.)

### Výhody choreografie

Choreografia sa ľahké chápe, ľahko kreslí na tabuľu, ľahko sa buduje. 

Účastníci sú *loosely coupled*, pretože vzájomne komunikujú len cez správy.

Odporúča sa ju zvážiť pri jednoduchších ságach, ktoré majú 2 až 4 kroky.

Z technického hľadiska treba implementovať korelačné identifikátory v správach. Všetky správy reprezentujúce udalosti v rámci jednej ságy musia mať identifikátor, aby poslucháči vedeli, na ktorú transakciu reagovať.

### Nevýhody choreografie

Ak má sága priveľa krokov, je náročné sledovať, ktorá služba má reagovať na ktoré správy.

Navyše, môžu sa zjaviť neočakávané *cyklické závislosti*, keď si služby vzájomne počúvajú na udalosti a zacyklia sa.

Testovanie je náročnejšie, pretože na overenie musíme mať spustené všetky služby.

Command / Orchestration
-----------------------

V tomto štýle zavedieme medzi služby dodatočného účastníka: **saga orchestrator**, ktorý zodpovedá dirigentovi v orchestri.

### Orchestrátor

Orchestrátor ovláda jednotlivé kroky na úspešné splnenie transakcie. V prípade zlyhaní vie *rollbacknúť* ságu, tým, že každej službe pošle rozkaz na odvolanie (*undo*) príslušnej lokálnej transakcie.

### Úspešný scenár

1. Služba `Objednávky` požiada orchestrátora o začatie transakcie
2. Orchestrátor pošle `Platbám` príkaz **vykonaj platbu!**
	1. `Platby` odvetia **platba vykonaná!**
3. Orchestrátor pošle `Doručeniam` príkaz **doručte tovar!**
	1. `Doručenia` odpovedia **tovar doručený!**

### Neúspešný scenár

1. Služba `Objednávky` požiada orchestrátora o začatie transakcie.
2. Orchestrátor pošle `Platbám` príkaz **vykonaj platbu!**
   1. `Platby` odvetia **platba vykonaná!**
3. Orchestrátor pošle `Doručeniam` príkaz **doručte tovar!**
   1. `Doručenia` odpovedia **nemáme tovar!**
4. Orchestrátor vie, že uspela len jedna lokálna transakcia (v službe`Platby`) a prikáže službe `Platby` spustiť kompenzáciu, t. j. refundovať zákazníka.

### Výhody orchestrácie

- Orchestrácia sa podobne ľahko implementuje a dokonca ľahko testuje. 

- Každá služba funguje len na požiadavkách a odpovediach. 
- Orchestrátor je centrálny bod, ktorý vyvoláva jednotlivé služby. Služby sa nevolajú navzájom, čím nemôže dôjsť k cyklickým závislostiam.
- Ak pribudnú nové kroky v ságe, zložitosť implementácie je oproti choreografii omnoho jednoduchšia.
- Rollbacky sú omnoho jednoduchšie implementovateľné. Orchestrátor vie, ktoré lokálne transakcie v postupnosti ságy treba kompenzovať.
- Ak nad jednou entitou beží viacero transakcií naraz, múdry orchestrátor ich vie vhodne usporiadaať.

### Nevýhody orchestrácie

- Orchestrátor je centrálny bod, teda akýsi *single point of failure*. Do architektúry pribudol nový komponent, ktorý treba udržiavať a dbať na jeho správne fungovanie.
- Orchestrátor má tendenciu stať sa premúdrelým komponentom, ktorý v sebe nesie množstvo biznisovej logiky na úkor služieb, ktoré budú len hlúpi vybavovači požiadaviek.

### Implementácia

#### Implementácia správ

Podobne ako v choreografii je treba používať *korelačné identifikátory* v správach prináležiacim k jednej transakcii.

**Adresáta** pre odpovede je dobré vložiť do samotnej správy a nepoužívať centrálne *napečenú* adresu orchestrátora.

Treba sa vyhnúť synchrónnym volaniam v štýle RPC, napr. postaviť orchestrátora a mikroslužbu na synchrónnom HTTP. Mnoho transakcií totiž vie pokračovať aj v prípade, že je druhá strana vypnutá/havarovaná/nedostupná. Na druhej strane, **asynchrónny** model je náročnejší na implementáciu.

Odporúčaná architektúra na komunikáciu využíva **message brokery**. 

Keďže typické *message brokery* využívajú doručenie správ v duchu *at least once* (správa bude doručená aspoň raz, teda napríklad aj 3x v prípade opakovaných pokusov), treba zaručiť **idempotentnosť** operácií v službách i orchestrátorovi.

#### Implementácia orchestrátora

Orchestrátor sa dá implementovať ako konečnostavový automat (*state machine*). 

Ak orchestrátor posiela **požiadavku**, vyvolá príslušnú službu, uloží stav entity (napr. Objednávky) v rámci ságy (napr. *Pending*, *Created*) a čaká na **odpoveď**. 

Pri odpovedi orchestrátor zistí stav entity z databázy, potom rozhodne, ktorého účastníka zavolá, aktualizuje stav entity.

Implementácia ságy
==================

Asynchrónna komunikácia a message broker
----------------------------------------

Účastníci ságy komunikujú **asynchrónne**. Buď odosielajú udalosti a reagujú na ne (v prípade choreografie) alebo používajú asynchrónny štýl *request/response* (v prípade orchestrácie).

Asynchrónny spôsob sa dá dosiahnuť použitím *message brokera* (RabbitMQ, Kafka a pod.)

Potrebujeme totiž nutne garantovať, že sága skončí, aj keď je niektorý účastník vyradený. Na to potrebujeme:

- garantovať **at least once delivery**, teda vedieť reagovať na situácie, že tá istá správa je doručená viackrát. Toto dosiahneme idempotentnými metódami.
- podporiť **durable subscriptions**, teda správa musí sedieť vo fronte dovtedy, kým ju účastník nebude schopný spracovať.

Databázy
--------

Lokálna transakcia v rámci jednej služby musí **atomicky**:

1. Aktualizovať databázu
2. A zároveň odoslať správu s udalosťou, či notifikáciou o úspechu či zlyhaní.

Inými slovami, musíme sa vyhnúť situáciám:

- Služba nesmie aktualizovať svoju databázu a havarovať pred odoslaním správy.
- Služba nesmie odoslať správu a havarovať počas aktualizácie dát.

To vieme zabezpečiť dvoma *návrhovými vzormi pre mikroslužby*:

- **Transactional Outbox** je v stručnosti prístup, kde zmeny v databáze zapíšeme v rámci lokálnej transakcie do samostatnej tabuľky `OUTBOX`, ktorú číta *message broker*.
- **Event Sourcing**, kde dáta v databáze predstavujú sekvenciu zmien nad nimi. Zmena v databáze je potom prirodzeným pridaním nového riadku so zmenami.

Kompenzácie: ako sa vysporiadať s lokálnou transakciou, ktorá zlyhala
=====================================================================

Každá lokálna transakcia skôr či neskôr zlyhá — obvykle kvôli narušeniu pravidiel biznisovej logiky. Chceme vydať tovar, ktorý nie je na sklade? Lokálna transakcia musí zlyhať a sága sa musí zrušiť.

Služba podieľajúca sa na ságe musí explicitne deklarovať **kompenzujúcu transakciu**, ktorá zodpovedá *undo* kroku, teda odvolá, či zvráti účinky lokálnej transakcie.

Implementácia kompenzujúcej transakcie má nasledovné výzvy:

- narušenia ACID zásad: vzájomné prepisovanie dát a stratené zmeny
- čo s nevratnými operáciami: ako kompenzovať odoslanú SMSku či mail?
- zlyhané kompenzujúce transakcie: čo keď treba zachrániť záchranárov? Stručne povedané, kompenzujúca transakcia sa **musí** podariť, pretože možností na zotavenie nie je veľa.

Škodlivé prístupy k dátam
-------------------------

Škodlivé prístupy k dátam, ktoré adresujú zásady ACID v bežných transakciách, sa môžu prejaviť aj v ságach.

### Dirty Read

Klasický príklad je spracovanie objednávky. Ak je sága A pomalá, sága B môže v rámci kompenzácie objednávku zrušiť skôr než ju sága A úspešne dokončí („komitne“). Takto dôjde k dokončeniu už zrušenej objednávky, čo je rozhodne neželaný stav. Ukazuje fenomén *dirty read*, teda čítanie nekomitnutých dát, ktorý vieme ošetriť použitím **sémantických zámkov** (viď nižšie). 

### Lost Update

Iné očividné riešenie kompenzujúcej transakcie navádza na postup:

1. Pred lokálnou transakciou si zapamätáme stav entity. *Stav účtu je 20 korún.*

2. Vykonáme lokálnu transakciu. *Stav účtu po zaplatení je 10 korún*.

3. Paralelná transakcia nastaví stav účtu na 5 korún.

4. Okolnosti nás prinútia kompenzovať, čo dosiahneme pôvodnými hodnotami. *Nastavíme stav účtu na 20 korún*.

5. Práve sme dali zákazníkovi viac peňazí než má právo.

   Tento prístup zjavne nefunguje a je ukážkou fenoménu *lost update* (stratené zmeny)

Jedným z riešení je použitie **komutatívnych zmien** (viď nižšie.)

### Dirty Read

Dvakrát pričítame ku kreditu zákazníka, raz z jednej, raz z druhej transakcie, hoci druhé pričítanie nie je komitnuté a bude odvolané. Medzi týmito operáciami si zákazník môže dokončiť ságu, ktorá je nad jeho reálne financie.

Rodiny lokálnych transakcií
---------------------------

Vedecké články deklarujú tri rodiny lokálnych transakcií:

- **kompenzovateľné** (*compensatable*): transakcie, ktoré sa dajú zvrátiť cez kompenzáciu.
- **pivoty**: po komitnutí tejto lokálnej transakcie sa celá sága dokončí. Inými slovami, pivot je *point of no return*, ak tu uspejeme, musíme uspieť v celej ságe.
  - Pivot nemusí byť zopakovateľný (*retriable*).
  - Pivot nemusí byť kompenzovateľný.
  - Pivot môže byť posledná kompenzovateľná lokálna transakcia v ságe.
  - Alternatívne môže byť pivot prvý *retriable* (zopakovateľná) transakcia.
- **zopakovateľné** (*retriable*). Transakcie, ktoré majú garantovaný úspech (skôr či neskôr.) Takéto lokálne transakcie nasledujú po pivote.

V príklade rezervácie stola v reštaurácii: ak `Autorizácia platby` uspeje (pivot), potom `Rezervácia stola` musí tiež uspieť (retriable).

Iný príklad ságy navrhnutej nasledovne:

1. Vytvorenie objednávky (a kompenzácia cez zamietnutie objednávky).
2. Rezervácia kreditu (pivot), ktorá môže zlyhať, kompenzáciu nepotrebuje (pozri nižšie.)
3. Schválenie objednávky (retriable): nemôže zlyhať, nepotrebuje kompenzáciu.

Keďže `Schválenie` nemôže zlyhať, rezervácia kreditu nepotrebuje kompenzáciu.

### Rady a odporúčania

Kroky ságy vyslovenie závisia od činnosti, ktorú chceme dosiahnuť. Je teda vysoko aplikačne-špecifická.

Ak krok ságy závisí na predošlom kroku, je to prirodzené. Niekedy si však môžeme vybrať poradie krokov a preusporiadať ho. Ideálne je, ak môžeme aktualizácie dát (*updates*) presunúť až za pivot, pretože tým sa zbavíme povinnosti tvoriť kompenzačné transakcie.

Opatrenia proti ACID fenoménom
------------------------------

Ľiteratúra deklaruje nasledovné oblastí, kde vieme zabrániť fenoménom z ACID zásad:

- sémantické zámky ako ochrana proti *dirty reads* a *dirty writes*
- komutatívne zmeny a znovunačítanie hodnoty ako ochrana proti *lost updates*
- pesimistické pohľady ako ochrana pred *dirty read*
- verzovacie súbory ako taktika na preusporiadanie krokov ságy

### Semantic Locks — sémantické zámky

Pomocou *sémantického zámku* oddelíme *špinavé dáta* (zmenené, ale nekomitnuté) od ostatných dát a zabránime fenoménu *dirty read*.

Na to sa odporúča, aby každá biznisová entita (napr. Objednávka) mala svoj evidovaný stav v rámci ságy. 

Napríklad započatá Objednávka bude mať stav *Pending* (nevyriešená). Vybavená objednávka sa po dokončení transakcie prepne do stavu *Approved* (analógia komitu) alebo *Rejected* (analógia abortu).

Predstavme si, že paralelne bežiaca lokálna transakcia sa rozhodne zrušiť nevyriešenú objednávku. Toto nie je povolený stav a preto táto paralelná transakcia oznámi klientovi, že musí skúsiť neskôr.

Tieto opakované pokusy:

- buď hodia bremeno opakovaní na plecia klienta, čím ho skomplikujú.
- alebo môžu blokovať na strane servera, ale v tom prípade server musí manažovať zámky a detegovať uviaznutia (*deadlock*)

### Commutative Updates — komutatívne zmeny

**Komutatívne zmeny**  sú ochranou proti fenoménu *lost updates*, teda keď v rámci transakcie sa načítajú dáta, uložia do pamäte, následne zapíšu, ale medzičasom dáta v databáze upravila iná transakcia. Zmeny z inej transakcie sa tak stratili.

1. Transakcia A načíta stav Heleninho účtu, ktorý je 100 korún. Poznačí si to do premennej.
2. Transakcia B zistí, že Helena má na účte stále 100 korún.
3. Transakcia B vyberie z Heleninho účtu 40 korún, zakúpi čln, nastaví stav účtu na 60 a komitne.
4. Transakcia A príde na rad. Od stavu účtu v premennej odoberie 20 korún, kúpi si luk a výsledok (80 korún) zapíše do databázy a komitne.

Nielenže má Helena na účte 80 korún, ale pribudol jej čln a luk v celkovej cene 60 korún. Stratila sa 40korunová zmena.

Databázové zmeny sú komutatívne, ak sa dajú vykonať v ľubovoľnom poradí. Matematické operácie odčítania a kompenzácie v podobe čítania sú prirodzene komutatívne. Ak nebudeme zapisovať finálne stavy účtov, ale len rozdiely, vyhneme sa *lost updateom*.

Operácie sú jednoduché: odčítam 20 v transakci A, odčítam 40 v transakcii B sa dajú vykonať aj v opačnom poradí a výsledok sa zachová.

To platí aj pre kompenzácie. Ak zažijeme kombináciu 

```
A: mínus 20, B: mínus 40, kompenzácia B: plus 40
```

je to to isté ako 

```
B: mínus 40, A: mínus 20, kompenzácia B: plus 40.
```

Bežné operácie sú *rezervuj kredit*-*odomkni kredit*, alebo *prirátaj sumu*-*odrátaj sumu*.

### Pessimistic View — pesimistické pohľady

Pesimistické pohľady chránia pred fenoménom *dirty read*, teda keď modrá transakcia číta zmenené, ale nekomitnuté dáta z červenej transakcie.

V tomto prípade preusporiadame kroky ságy vhodným spôsobom.

Typické riziko je dlhodobé držanie dát, ktoré by sa mali v jednoduchej databáze zamykať. Učebnicový príklad je kapacita voľných miest vo vlaku, kde medzi počiatočným získaním obsadenosti a predaním lístka môže uplynúť pridlhá doba a dôjde k *overbookingu*.

Riešením sú:

- kompenzovateľné transakcie, ktoré však môžu obmedziť zákazníka – predstavme si, že si zakliká lístok, ale po zlyhanej platbe mu niekto pod nosom vyfúkne posledné miesto! Toto je dokonca príklad fenoménu *nonrepeatable read*, keď dvojité čítanie toho istého riadka (stav sedadla) v rámci jednej transakcie povedie k odlišným výsledkom. 

- opakovateľné *retriable* transakcie, ktoré sú náročnejšie, ale sú pohodlnejšie pre zákazníka.

  Článok [Integrity Problems in Distributed Accounting Systems with Semantic ACID Properties](https://link.springer.com/content/pdf/10.1007/978-0-387-35501-6_11.pdf) odporúča používať kompenzovateľné transakcie (a pivoty) na znižovanie dostupného stavu a opakovateľné transakcie na zvyšovanie dostupného stavu.

  To je príklad zrušenia objednávky. Preusporiadame kroky tak, že vrátenie peňazí (zvýšenie kreditu) odsunieme do neskoršej fázy, kde ho použijeme v opakovateľnej transakcii.

  1. Nastavíme stav entity *Objednávka* na zrušená.
  2. Zrušíme doručenie (*pivot*).
  3. Zvýšime peňažný kredit (*retriable*).

### Reread Value – znovunačítanie hodnoty

Znovunačítanie hodnôt chráni pred fenoménom *lost updates*, keď sa zmeny stratia.

Pred aktualizáciou riadku načítame jeho dáta a porovnáme ich s dátami v cache, či premenných. Ak zistíme rozdiely, ságu abortneme a spustíme kompenzácie.

Toto je variant princípu *optimistického uzamykania* (*optimistic offline lock*).

### Version File – verzovací súbor

Verzovací súbor sa používa v kombinácii s komutatívnymi zmenami.

Do verzovacieho súboru sa v rámci transakcie ukladajú záznamy s nasledovnou štruktúrou:

- časová pečiatka
- buď údaje po zmene (ak sa zmení adresa, vložíme riadky s novou adresou)
- alebo typ transakcie a zmenový parameter (napríklad „vklad, 20 korún“).

Paralelne bežiace operácie sa zaznamenajú do verzovacieho súboru, a následne sa preusporiadajú do správneho poradia.

V prípade viacerých zmien nad tou istou entitou môžeme rozhodnúť poslednú platnú zmenu pomocou časovej pečiatky.

V prípade duplicitných zmien môžeme optimalizovať vykonávanie krokov.

Ak máme nasledovný sled krokov:

1. Červená transakcia autorizuje Ireninu kartu.
2. Modrá transakcia vytvorí novú Ireninu objednávku.
3. Červený transakcia zistí, že Irenina karta nebola autorizovaná.
4. Modrá transakcia autorizuje Ireninu kartu.

Ak sa tieto operácie uložia do verzovacieho súboru, môžeme odstrániť duplicitnú autorizáciu karty.

[Učebnicový príklad](https://onlinelibrary.wiley.com/doi/abs/10.1002/(SICI)1097-024X(199801)28:1%3C77::AID-SPE148%3E3.0.CO;2-R) používa príklad banky, kde sa zmeny na účtoch ukladali do verzovacieho súboru. Finálny balans účtu sa vypočítaval periodicky (raz za deň) alebo na požiadanie. Keďže zmeny na účte sú komutatívne, prepočítavalo sa len v prípade zmeny balansu z nekomutatívnej transakcie.

Ak používame režim s typom transakcie a zmenovými parametrami, môžeme to použiť na opakovateľné i kompenzovateľné transakcie, pretože stav databázového riadku môžeme rekalkulovať pomocou starej verzie a aplikovaním príslušných zmenových parametrov.

Odporúčania pre ságy
====================

Kedže ságy sú vysoko aplikačne špecifické, nie je nutné používať ich vždy a všade. 

V prípade kritických operácií (prevod veľkých peňazí) je stále možné navrhnúť architektúru s použitím klasických distribuovaných transakcií. Ságy je zase možné využiť pri výkonných, ale menej riskantných prípadoch.

Jednotlivé kroky ságy zároveň môžeme navrhnúť tak, aby vysoko rizikové operácie so šancou na pád sa vykonali ako prvé a s postupujúcimi krokmi riziko narastá až po transakcie za pivotom, ktoré sú opakovateľné. 

Zdroje
======

- [Saga Pattern | How to implement business transactions using Microservices - Part I | The Couchbase Blog](https://blog.couchbase.com/saga-pattern-implement-business-transactions-using-microservices-part/)
- [Managing data consistency in a microservice architecture using Sagas - part 1](https://chrisrichardson.net/post/antipatterns/2019/07/09/developing-sagas-part-1.html)
- [Managing data consistency in a microservice architecture using Sagas part 2 - coordinating sagas](https://chrisrichardson.net/post/sagas/2019/08/04/developing-sagas-part-2.html)
- [Managing data consistency in a microservice architecture using Sagas - part 3 - implementing a choreography-based saga](https://chrisrichardson.net/post/sagas/2019/08/15/developing-sagas-part-3.html)
- Frank, L. and Zahle, T. U. (1998), Semantic acid properties in multidatabases using remote procedure calls and update propagations. Softw: Pract. Exper., 28: 77-98. doi:[10.1002/(SICI)1097-024X(199801)28:1<77::AID-SPE148>3.0.CO;2-R](https://doi.org/10.1002/(SICI)1097-024X(199801)28:1<77::AID-SPE148>3.0.CO;2-R)
- Frank L. (2000) Integrity Problems in Distributed Accounting Systems with Semantic ACID Properties. In: van Biene-Hershey M.E., Strous L. (eds) Integrity and Internal Control in Information Systems. IICIS 1999. IFIP — The International Federation for Information Processing, vol 37. Springer, Boston, MA
- Richardson C. (2018) Managing transactions with sagas. In: Microservice Patterns. ISBN 9781617294549. Manning
- [Compensating Transaction Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction). Microsoft Azure Cloud Design Patterns.