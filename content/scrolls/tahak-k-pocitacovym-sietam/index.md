---
title: Ťahák k počítačovým sieťam
date: 2019-08-13
---



Prehľad
=======

| L     | Vrstva              | Kýblik dát      | Adresácia         | Relevantné zariadenie | Databáza           |
|-------|---------------------|-----------------|-------------------|-----------------------|--------------------|
| L5-L7 | Aplikačná           | Správa          | z nižších vrstiev |                       |                    |
| L4    | Transportná         | Segment         | Port              | Socket (softvérové)   | \-                 |
| L3    | Sieťová / Network   | Datagram        | IP adresa         | Router                | Smerovacia tabuľka |
| L2    | Spojová / Data Link | Rámec           | MAC adresa        | Switch                | Prepínacia tabuľka |
| L1    | Fyzická vrstva      | Nuly a jednotky | \-                | Hub                   | \-                 |

Internet
========

Internet je sieť sietí:

-   postavená nad protokolom TCP/IP
-   prepájaná metalickými káblami, optickými káblami a bezdrôtovo
-   na okraji sú koncové zariadenia: počítače, mobily, smart televízory
-   vo vnútri sú routery / smerovače, ktoré preposielajú dáta zo siete
    do siete

Vrstvy protokolov na internete
==============================

Internet komunikuje viacerými protokolmi na rozličných vrstvách:

-   na najnižšej fyzickej vrstve je elektrický signál a kódovanie do núl
    a jednotiek
-   až po najvyššiu vrstvu, kde sa vymieňajú správy medzi aplikáciami
    operačného systému

Modely
------

Dva modely vrstiev:

-   ISO/OSI: teoretický model, 7 vrstiev
-   TCP/IP: 4 vrstvy, inšpirované ISO/OSI

### Model TCP/IP

Doručuje kýbliky dát: pakety. Každá vrstva deklaruje konkrétny formát
paketu.

Vrstvy:

-   **aplikačná** / application: komunikácia medzi druhmi programov
    -   webový prehliadač: protokol HTTP
    -   emaily: protokol SMTP
-   **transportná** / transport: prepojenie dvoch procesov na rôznych
    počítačoch
    -   uvažujú v paketoch
    -   protokoly:
        -   TCP: spoľahlivé doručenie, kontrola zahltenia, kontrola
            prietoku
        -   UDP: jednoduché doručovanie paketov
-   **sieťová** / network: doručenie paketu na konkrétne miesto na
    internete
    -   smerovanie paketov medzi sieťami
-   **sieťového rozhrania** / network layer: doručenie paketu na
    konkrétne fyzické zariadenie v danej sieti konkrétnym fyzickým
    médiom
    -   Ethernet: klasický kábel medzi dvoma počítačmi
    -   Wireless LAN / WiFi: pakety šírené vzduchom

Niekde sa **sieťového rozhrania delí**:

-   **spojová** / data link:
    -   identifikuje príjemcu, garantuje korektnosť paketu, rieši, kto
        kedy môže vysielať a prijímať
-   **fyzická** / physical:
    -   identifikuje začiatok a koniec vysielania
    -   identifikuje nuly a jednotky v elektrickom signále

Aplikačná vrstva (L5-L7)
========================

> Ako dosiahnuť, aby dva druhy aplikácii komunikovali?

-   prepravuje **správy**
-   určené pre konkrétny typ aplikácie
    -   príklad: webový prehliadač s webovým serverom
    -   príklad: BitTorrent klienti
-   vymieňajú si **správy**, ktorých formát závisí od protokolu

Črty aplikačných protokolov
---------------------------

-   architektúra:
    -   klient-server:
        -   Server beží vždy
        -   Klienti sa pripájajú podľa potreby
        -   Klienti nekomunikujú medzi sebou
        -   Príklady: webserver, SSH pripojenie, DNS server
    -   peer-to-peer:
        -   všetci klienti sú rovnocenní, komunikujú vzájomne
        -   Príklady: Gnutella
    -   hybrid:
        -   server je registruje a vyhľadáva pripojených klientov
        -   ale peeri komunikujú medzi sebou
        -   Príklady: Skype, Torrent
-   protokol: na príklade HTTP
    -   typy správ: napr. *HTTP GET*, *HTTP POST*, *HTTP Reply*
    -   syntax: HTTP má textové správy s definovaným formátom
    -   sémantika: „HTTP GET sa používa na získanie obsahu na danej
        adrese“
    -   kedy poslať akú správu: „ak server nevie nájsť daný obsah,
        odpovie chybovou správou so stavovým kódom 404“
-   adresácia:
    -   logickými cieľmi: pripoj sa na uzol `alpha`
    -   ale v skutočnosti adresácia s použitím transportnej vrstvy: IP
        adresa a port

Komunikácia
-----------

-   využíva sa nižšia *transportná vrstva*
-   **vždy** dva procesy operačného systému
    -   klient: inicializuje komunikáciu
    -   server: očakáva pripojenia klientov
-   OS ponúka sieťové API v podobe **socketu** (viď nižšie)
-   adresácia pomocou **IP adresy** a **portu**

Vzťah s ISO/OSI
---------------

ISO/OSI delí aplikačnú vrstvu na podvrstvy. Tie sa v TCP/IP často
prelínaju!

-   **aplikačná** / application (L7)
    -   komunikácia medzi druhmi aplikácií
    -   HTTP, DNS
-   **prezentačná** / presentation (L6)
    -   preklad aplikačných dát do sieťového formátu
    -   niekde aj „syntaktická vrstva“: syntax layer
    -   šifrovanie: SSL/TLS
    -   serializácia dát do XML
        -   ale napr. REST/HTTP toto robí na L7
-   **session layer** (L5)
    -   udržiava reláciu / sessions / trvalú konverzáciu medzi dvoma
        procesmi
    -   obnovuje relácie v prípade prerušenia
    -   ak relácia dlho spí, vie ju ukončiť
    -   príklad: SOCKS protokol pre proxy spojení
    -   kontrapríklad: HTTP to robí na L7 pomocou cookies

Transportná vrstva (L4)
=======================

> Ako prepraviť dáta do iného počítača?

-   prepravuje **segmenty**
-   určené pre konkrétny **port**
-   rozhranie pre výmenu správ: **socket**
-   protokoly:
    -   TCP
    -   UDP

Vlastnosti
----------

-   transportná vrstva rozdelí obsah aplikačnej vrstvy (HTTP, SMTP) na
    **segmenty**

-   -   segment obsahuje hlavičku s informáciami pre cieľ

-   segment obsahuje porty (0-65535):
    -   zdrojový port
    -   cieľový port
    -   maximálna veľkosť je cca 1,5 KB
-   adresácia:
    -   samotný segment obsahuje len čísla portov!
    -   ale pracujeme s adresami zdrojových a cieľových staníc
        -   IP adresy zo **sieťovej vrstvy (L3)**

Sockety a porty
===============

-   **socket** je API operačného systému pre sieťovú komunikáciu
    -   operácia: vyrob socket
    -   operácia: napoj ho
    -   operácia: čítaj dáta / zapisuj dáta
-   proces operačného systému otvorí **socket**
-   asociuje ho s číslom portu na niektorom sieťovom rozhraní (alebo na
    viacerých rozhraniach)
    -   buď klientsky socket:
        -   povie IP adresu cieľovej stanice
        -   povie číslo portu cieľovej stanice
        -   povie číslo zdrojového portu, aby bolo kam posielať odpovede
    -   alebo serverový socket:
        -   povie číslo portu alebo požiada OS o voľný port
        -   segment určený pre tento socket musí uviesť tento port ako
            cieľ

Protokoly
---------

### UDP: User Datagram Protocol

> Pošlem pohľadnicu, snáď dôjde.

-   bez spoľahlivého prenosu
-   bez spojenia
-   fire-and-forget
-   žiadne quality control
    -   žiadne detekcie zahltenia siete
    -   žiadna kontrola prietoku

#### Hlavička

-   zdrojový port (2 bajty)
-   cieľový port (2b ajty)
-   dĺžka: počet bajtov segmentu
-   kontrolný súčet (2 bajty)
-   dáta

#### Protokoly bežiace nad UDP

-   DNS: preklad IP adries na doménové mená
-   RIP: konfigurácia smerovacích tabuliek na routeroch
-   DHCP: prideľovanie IP adries
-   streamovanie videí a audia

### TCP

-   najpoužívanejší protokol
-   potvrdzovaný prenos
    -   „telefonát: *Si tam?* / *Áno som tu*.
-   dáta zo zdrojového socketu doplávajú do cieľového socketu všetky
    -   preusporiada pakety z nižšej vrstvy do správneho poradia
    -   preveruje, či došli všetky a nepoškodené
    -   vynúti opakovaný prenos chybných paketov
-   kontroluje prietok dát
    -   ak príjemca nestíha, zmenšíme prietok
-   kontroluje zahltenie
    -   ak sa začnú strácať pakety, zmenšíme prietok

#### Základné princípy

##### Sekvenčné čísla

-   každý bajt v prúde dát od socketu k socketu má svoje vlastné
    **sekvenčné číslo**
-   každý odoslaný segment nesie **sekvenčné číslo**
    -   na začiatku spojenia vygenerované náhodný základ
    -   klient a server majú rozličné základy
    -   sekvenčné číslo pre nasledovný segment sa odvodí pripočítaním
        dĺžky predošlého segmentu

##### Kumulatívne potvrdenie

-   príjemca odošle **potvrdzovací segment**, tvrdí v ňom, že spracoval
    segmenty so sekvenčným číslom menším než *X*

##### Okná odosielateľa a prijímateľa

-   pipelining: posielanie viacerých segmentov bez nutnosti čakať na
    potvrdenia po jednom
-   okno odosielateľa = LIFO buffer = queue
    -   drží odoslané, ale nepotvrdené segmenty
    -   obe stanice majú vlastné nezávislé buffery
    -   po doručení potvrdzovacieho segmentu sa z bufferu odstránia
        všetky segmenty s číslom menším než X
-   okno príjemcu = buffer
    -   monitorovanie segmentov doručovaných mimo poradia
    -   ako prichádzajú segmenty, výpĺňajú sa bajty v bufferi
    -   súvisle vyplnený úsek na ľavej strane sa považuje za úspešne
        prijatý, čím vieme posunúť okno „doprava“

##### Nadviazanie spojenia - TCP Handshake

-   tri fázy = tri segmenty
    -   SYN: klient si otvorí socket, nastaví sekvenčné čísla, otvorí
        okná, pripojí sa k socketu servera
    -   ACK/ACK: server otvorí nový soket pre klienta, nastaví si
        sekvenčné čísla, otvorí okná
    -   ACK: klient potvrdí prijatie

##### Garantovanie doručenia

Strata paketov znamená

-   ak odosielateľ dostane 3x rovnaké číslo potvrdenia
-   ak nastane timeout pri potvrdení najstaršieho segmentu v okne
    odosielateľa

##### Kontrola toku

-   každý príjemca má dva buffery
    -   okno príjemcu
    -   buffer pre nespracované dáta
-   ak príjemca nestíha spracovávať,
    -   začne zmenšovať svoje okno príjemcu
    -   informuje opačnú stranu o veľkosti okna (chlievik **window** v
        TCP pakete)
    -   odosielateľ si následne primerane zmenší okno **odosielateľa**

##### Kontrola zahltenia

-   ak sa začnú strácať pakety, zrejme je zahltená sieť
-   zmenšíme okno odosielateľa
    -   porekadlo: čím väčšie okno odosielateľa, tým väčšia rýchlosť
        odosielania
-   okno odosielateľa sa dynamicky nafukuje a sfukuje
    -   jedna metóda: začínať zľahka a ak všetko ide dobre, pridáva plyn
        a zväčšuje okno
    -   druhá metóda: zväčšuje postupne a zmenšuje delením

##### Spravodlivosť TCP spojení

-   prenosová rýchlosť sa delí medzi počet TCP spojení
-   ak sa zahltí sieť, všetci účastníci v sieti si zmenšia okná
    odosielateľa
    -   najrýchlejší odosielatelia sa spomalia najviac
    -   časom sa však situácia vybalansuje
-   stanica môže otvárať viacero TCP spojení
    -   akcelerátor sťahovania: spustíme sťahovanie na X vláknach a X
        TCP spojeniach = máme väčšiu rýchlosť

Sieťová vrstva / Network Layer (L3)
===================================

-   Sieťová vrstva prepravuje **datagramy**.
-   Datagram je určený pre všetky routery po ceste
    -   správy aplikačnej vrstvy: pre cieľovú aplikáciu
    -   segment transportnej verstvy: pre cieľový počítač
-   **Adresácia**: IP adresy (v TCP/IP)
-   Bežné **protokoly**:
    -   IPv4 / IPv6
    -   ICMP: pingy a traceroutry

Router (smerovač)
-----------------

-   prijíma datagramy
-   posiela ich správnym smerom
-   používa **smerovaciu tabuľku**
    -   pre cieľovú adresu určuje, ktorému zariadeniu a ktorému
        rozhraniu sa majú doručiť
-   využíva **smerovacie algoritmy**
    -   pre optimálne doručenie

Datagramy a riadenie datagramami
--------------------------------

Na sieťovej vrstve internetu sa nevytvára spojenie.

-   spoľahlivosť riešia koncové zariadenia
-   odľahčujú sa routre a ich logika
-   nemáme garanciu prenosovej rýchlosti ani spoľahlivosť prenosu

Sieťová vrstva na internete
---------------------------

Nasledovné protokoly:

-   IPv4: súčasný protokol pre prenos
-   IPv6: budúcnosť, adresuje nedostatky IPv4
-   ICMP: podporný protokol pre riadenie siete

### Datagram IPv4

Vybrané položky datagramu IPv4:

-   verzia
-   dĺžka
-   maximálna veľkosť: MTU. Minimálne 576.
    -   router rozbije veľké datagramy na fragmenty
-   protokol:
    -   nastavený po doručení do cieľovej stanice
    -   TCP, UDP, ICMP, …
-   zdrojová adresa: IP adresa
-   cieľová adresa: IP adresa
    -   datagramy môžu dôjsť do cieľa rozličnými spôsobmi
-   TTL: cez koľko routerov môže datagram prejsť? (Každý router zníži o
    1).
    -   zabraňuje bludným Holanďanom, ktorý sa donekonečna bezcieľne
        túlajú sieťami
-   fragmentácia: info na poskladanie fragmentov segmentu

### Adresovanie v IPv4

-   IP adresa: 32 bitov
-   každé sieťové rozhranie má vlastnú IP adresu
    -   obvykle 1 sieťové rozhranie = 1 fyzické pripojenie = 1 sieťová
        karta
-   zariadenia z rôznych sietí komunikujú cez routery
-   zariadenia v 1 sieti vedia bez routera
    -   ak majú IP adresy v rovnakej sieti

#### Bežné adresovanie

IP adresa má dve časti:

-   časť pre sieť
-   časť pre stanicu

Dva počítače v jednej sieti musia mať rovnakú sieťovú časť.

##### Triedy

-   A: sieť = prvých 8 bitov, 24b stanica
    -   môže v nej byť 2\^26 \~ 16 mil. staníc
-   B: sieť = 16b sieť, 16 stanica
    -   65 tisíc staníc
-   C: sieť = 24b sieť, 8 stanica
    -   254 staníc
-   D: sieť = 32 b, 0 pre zariadenie. Pre multicasty

##### CIDR

-   maska udáva koľko bitov z IP adresy tvorí sieť. Zvyšok tvorí stanicu

##### Špeci adresy

-   `0.0.0.0/32` zdrojová adresa stanice v lokálnej sieti pri žiadosti
    DHCP o pridelenie IP.
-   `255.255.255.255`: broadcast pre lokálnu sieť: cieľová adresa pre
    všetky rozhrania v lokálnej sieti.
-   `127.0.0.1` loopback. Datagram s cieľovou adresou z tohto rozsahu
    neopúšťajú počítač.
-   Privátne siete pre NAT routre alebo VPN:
    -   `10.0.0.0/8`
    -   `172.16.0.0/12`
    -   `192.168.0.0/16`

### Smerovacia tabuľka

-   vďaka maskám sa redukuje zložitosť

Ukážkový dump routera ASUS:

| Destination | Gateway    | Mask            | Metric | Iface |
|-------------|------------|-----------------|--------|-------|
| 10.8.110.1  | 0.0.0.0    | 255.255.255.255 | 0      | eth0  |
| 192.168.1.0 | 0.0.0.0    | 255.255.255.0   | 0      | br0   |
| 10.8.110.0  | 0.0.0.0    | 255.255.255.0   | 0      | eth0  |
| 0.0.0.0     | 10.8.110.1 | 0.0.0.0         | 0      | eth0  |

-   Destination: cieľová adresa siete
-   Gateway (Brána): pre spojovú vrstvu / link layer (o úroveň nižšie)
    -   `0.0.0.0` znamená, že *rozhranie* je v rovnakej sieti ako
        cieľová IP adresa z datagramu.
    -   konkrétna IP adresa udáva adresu najbližšieho routera
    -   Posledný riadok tabuľky je cieľ `0.0.0.0` a maska `0.0.0.0` čiže
        sa vždy použije. Brána udáva IP adresu routera, ktorým sme
        pripojení do internetu.
-   Maska: určuje adresu siete
-   Metrika: Ak sa zhoduje viacero riadkov, najmenšia metrika vyhráva.
-   Interface: sieťové rozhranie, kam sa pošle datagram v prípade zhody.
-   Riadky sú usporiadané podľa počtu jednotkových bitov v maske

#### Vyhodnocovanie

Pre každý datagram sa zhora nadol vyhodnocuje tabuľka:

1.  Cieľová adresa z datagramu **AND** maska z tabuľky (= adresa siete).
2.  Porovná sa s hodnotou v *cieľovej adresy siete*.
3.  Ak zhoda, pošle sa na *rozhranie* (*iface*) z tabuľky.

NAT: Network Address Translation
--------------------------------

Provider pridelí domácnosti jedinú IPv4 adresu. Čo ak chceme mať doma
viacero notebookov, mobilov, tlačiarní, atď?

-   Riešenie 1: žiadať viacero IP adries. Provider rád poskytne za
    poplatok!
-   Riešenie 2: NAT

### Konfigurácia routera

-   každé rozhranie routera má svoju IP adresu
-   sieťové rozhranie WAN (*Wide Area Network*): nastavíme na IP adresu
    providera.
-   sieťové rozhranie LAN (*Local Area Network*): nastavíme neverejnú IP
    adresu pre privátne siete (napr. `10.0.0.1/8`)
-   stanice v domácej sieti:
    -   buď im nastavíme IP adresy napevno
    -   alebo využijeme DHCP protokol na routeri na dynamické
        prideľovanie

### Algoritmus prekladu

Router **prekladá** adresy paketov z lokálnej siete do providerovej
siete a naopak.

Udržiava si prekladovú tabuľku **Network Address Translation Table**.

-   Počítač `10.0.0.2/8` chce získať dáta zo `158.197.31.35` a portu 80.
    Otvorí si port 3345 pre odpoveď.
    -   Vytvorí TCP spojenie na cieľový počítač a port.
    -   Zdrojová adresa je `10.0.0.2`.
    -   Lenže TCP SYNACK zlyhá: veď vzdialený server neuvidí počítač v
        domácej sieti!
-   NAT Router s LAN `10.0.0.1/8` a WAN `138.76.29.7`
    -   otvorí si voľný port na WAN rozhraní, napr. 5001
    -   do tabuľky uvedie:
        -   WAN: `138.76.29.7`
        -   WAN port: 5001
        -   LAN: `10.0.0.2`
        -   LAN port: 3345
    -   **prepíše paket**:
        -   nastaví zdrojovú IP adresu na `138.76.29.7`
        -   nastaví zdrojový port na 5001
    -   pošle ho do cieľa
-   ak príde odpoveď do NAT routera:
    -   pristane na WAN rozhraní, na IP adrese `138.76.29.7`, na porte
        5001
    -   **prepíše paket**:
        -   cieľová adresa na `10.0.0.2`
        -   cieľovú port na 3345

### Vlastnosti

-   Stanica v privátnej LAN sieti ani nevie, že je za NAT routerom.
-   Máme limit na počet portov na NAT
    -   max. 65535 portov
    -   typický počítač má maximálne stovky nezávislých spojení
    -   štandardne okolo 100 počítačov v privátnej sieti
-   vieme obchádzať limit na IPv4 adresy

### Limitácie

-   ak si v LAN sieti založíme server, klienti zvonku sa nevedia napájať
    -   neexistuje verejná IP adresa
    -   **NAT Traversal Problem**
    -   v privátnej sieti si neurobíme verejný HTTP server, ani P2P
        server

#### Manuálne nastavenie NAT tabuľky

-   ručne určíme, kam preposielať pakety

#### UPNP

-   služba UPNP (Universal Plug and Play) / Internet Gateway Device
    (IGD)
-   stanica v privátnej sieti vie pracovať s NAT routerom:
    -   zistiť verejnú IP adresu na WAN rozhraní
    -   meniť riadky prekladovej tabuľky
    -   zisťovať stav prekladovej tabuľky

### Prostredník

-   preposielať komunikáciu cez počítač s verejnou IP adresou
-   Skype: účastníci sa napoja na stanicu s verejnou adresou

DHCP: Dynamic Host Configuration Protocol
-----------------------------------------

-   automatické prideľovanie IP adries staniciam
-   protokol na aplikačnej vrstve
-   využíva všetky tri vrstvy:
    -   aplikačnú: rozličné príkady
    -   transportnú: UDP a porty 67/68
    -   sieťovú: broadcastovú cieľovú adresu

### Algoritmus

Zariadenie sa chce pripojiť do siete. Vie, že *niekde* v sieti je DHCP
server na porte 67.

1.  Požiadavka zariadenia: **DHCP Discover**

    1.  na sieťovej úrovni:

        -   cieľová adresa: broadcastová adresa lokálnej siete
            `255.255.255.255`

        -   zdrojová adresa: `0.0.0.0` . Máme vajce-sliepka problém,
            takže zdroj nevieme.

    2.  na transportnej úrovni:

        -   protokol UDP

        -   port: 67

    3.  na aplikačnej úrovni:

        -   jednoznačný identifikátor

        -   údaje správy DHCP discover

2.  Odpoveď DHCP Servera: **DHCP Lease Offer** s ponúknutou IP adresou

-   na sieťovej úrovni: cieľová adresa: `255.255.255.255`
-   na transportnej úrovni: UDP, cieľový port 68
-   na aplikačnej úrovni: jednoznačný identifikátor z *Discovery*

1.  Požiadavka klienta na pridelenie adresy: **DHCP Request**

-   na sieťovej úrovni: cieľová adresa: `255.255.255.255`
-   na transportnej úrovni: UDP, cieľový port 67 (server)
-   na aplikačnej úrovni: všetky parametre z *DHCP Lease Offer*

1.  Odpoveď DHCP Servera: **DHCP Ack**

-   na sieťovej úrovni: cieľová adresa: `255.255.255.255`
-   na transportnej úrovni: UDP, cieľový port 67 (server)
-   na aplikačnej úrovni: všetky parametre z *DHCP Lease Offer*

1.  Klient si nastaví ponúknutú IP adresu a komunikuje.

### Vlastnosti

#### Životnosť

-   pridelená IP adresa má životnosť
-   pred vypršaním sa zopakujú **DHCP Request** a **DHCP Lease**.
-   už netreba broadcastovať
    -   stačí priamo poslať na IP adresu DHCP servera
    -   DHCP server nemusí odpovedať broadcastom, keďže pozná IP adresu
        zariadenia

#### Relaying

-   v danej sieti nemusí existovať DHCP server
-   na routroch môže byť *relay agent*
-   preposiela požiadavky a odpovede do siete, kde DHCP server je
    prítomný

#### Recyklácia

-   vďaka DHCP môžeme dynamicky recyklovať IP adresy
-   ak sa zamestnanci pripájajú do siete notebookmi a vieme, že nikdy
    neprídu do práce naraz, môžeme alokovať menej IP adries v sieti než
    je zamestnancov

ICMP
----

-   sieťový (nie aplikačný!) protokol pre zisťovanie stavu siete
-   ping: dostupnosť stanice s IP adresou
-   traceroute / tracert: diagnostika suete
    -   postupne posiela datagramy s narastajúcim TTL
    -   každý router zníži TTL o jedna
    -   odpovede sa s TTL o jedna nižším
    -   takto vieme zistiť, ktorý router už prestal odpovedať

### Hlavička ICMP protokolu

-   code
-   type

Príklady:

-   Ping Echo Request = type 8, code 0
-   Ping Echo Reply = type 0, code 0
-   Traceroute TTL Expired = type 11, code 0
-   Destination Port Unreachable = type 3, code 3
    -   ak je v UDP segmente nedostupný port
-   Destination Network Unreachable = type 3, coe 0
    -   niektorý router po ceste je vypnutý / nefunkčný

V tele odpovede sa môže nachádzať hlavička a 8 bajtov z tela chybového
datagramu.

Smerovacie algoritmy
--------------------

-   ručné nastavenie smerovacej tabuľky
    -   ak vypadne cieľový router, smerovanie paketov prestane fungovať
-   dynamické smerovanie
    -   cez niektorý algoritmus
    -   zistia optimálnu cestu k dostupným sieťam
    -   modifikuje smerovacie tabuľky
    -   administrátor viacerých sietí a routerov volí vhodný smerovací
        protokol vo svojom **autonómnom systéme**
    -   používajú sa rozličné grafové algoritmy

### Komunikácia v systémoch

-   routery v autonómnych systémoch vzájomne komunikujú
    -   aplikačné protokoly RIP (Routing Information Protocol) a
    -   OSPF (Open Shortest Path First)
-   autonómne systémy vzájomne komunikujú
    -   BGP: border gateway protocol: štandard v Internete

Komunikácia si dynamicky vymieňa informácie o dostupnosti a
vzdialenostiach.

Smerovacie schémy
-----------------

-   **unicast**: datagramy smerujú k presne určenej stanici
    -   vyžadované v TCP
-   **anycast**: viacero potenciálnych príjemcov, doručí sa vždy len
    jednému
    -   máme 13 koreňových DNS serverov
    -   ale jedna IP adresa je použitá pre viaceré stanice
    -   požiadavka môže prísť na jeden ľubovoľný server.
-   **broadcast**: „amplión“: doručenie všetkým uzlom / podsieťam
    -   Príklady:
        -   komunikácia v smerovacích protokoloch
        -   DHCP
        -   ARP na spojovej vrstve
        -   peer-to-peer protokoly
    -   problímy:
        -   ako posielať správy, aby sme nespôsobili *broadcastovú
            búrku*, teda nekontrolované zahltenie routerov
        -   riešenie cez grafové algoritmy (minimálna kostra a pod.)
-   **multicast**: doručenie každému prihlásenému v multicastovej doméne
    -   stanice môžu povedať, že chcú/nechcú prijímať správy
    -   streamovanie televízie a rádií
    -   videokonferencie, gridy, sieťové hry
    -   protokol **IGMP** (Internet Group Management Protocol)
        -   sieťový protokol pre spravovanie členov multicastovej
            skupiny

Spojová vrstva / Data Link Layer (L2)
=====================================

Ako preniesť datagram konkrétnym prenosovým médiom?

-   drát kovový
-   drát optikový
-   vzduch

Vlastnosti
----------

-   rieši komunikáciu v rámci **jednej** siete
-   adresácia cez **MAC adresy**
-   datagram je obalený do **rámca** / **frame**
    -   finálna postupnosť 0 a 1, ktorá sa pošle do spoja
-   podporuje sa odhaľovanie chýb
    -   overenie, že príjemca dostal to, čo odosielateľ poslal
-   typické protokoly:
    -   Ethernet: viď nižšie
    -   PPP (Point-To-Point) pre vytáčané spojenia, sériové káble a
        optiku

Adresácia cez MAC Adresy
------------------------

-   fyzické adresy = hardvérové adresy = ethernetové adresy
-   6 bajtov: `AA:BB:CC:DD:EE.FF`
-   sú nezávislé od siete
    -   „napečené“ do sieťovej karty
-   organizácia IEEE prideľuje výrobcom sieťových zariadení rozsahy MAC
    adries
    -   napríklad WiFi adaptér na MacBook Pro má prefix `AC:BC:32`, čo
        je prefix pridelený Applu
-   MAC adresa je nezávislá od siete! Metafora „rodné číslo“

Ethernet
--------

-   adresuje spojovú vrstvu L2 v ISO/OSI modelu, i najnižšiu fyzickú
    vrstvu L1
-   v TCP/IP („Internet“) patrí do najnižšej vrstvy **sieťového
    rozhrania** (**network layer**)
-   používa metódu CSMA/CD
    -   datagramy sieťovej vrstvy sú obalené do rámcov
    -   rámce sú pomocou spojovej metódy CSMA/CD posielané do spoja

### Ethernetové rámce / Ethernet Frames

-   **preambula**: 7 bajtov. Striedavé nuly a jednotky.
-   **start frame delimiter (SFD)**: 1 bajt. Striedavé 0/1 ukončené
    dvoma jednotkami.
-   **cieľová MAC adresa**
-   **zdrojová MAC adresa**
-   **protokol vyššej vrstvy (EtherType)**:
    -   0x0800 = IPv4
    -   0x86DD = IPv6
    -   0x0806 = ARP
-   **payload**: telo rámca. V drôtovom Ethernete podľa MTU maximálne
    1500 bajtov
-   **kontrolný súčet**: CRC pre 4 bajty

### Topológia sietí

-   **star**: hviezdica. Zariadenia pripojené na centrálne zariadenie.
    Najbežnejšie súčasné:
-   **bus** (**zbernica**) pre stanice na tom istom drôte, **token
    ring** (kruh)

### Centrálne zariadenia

#### Hub / Rozbočovač (L1)

-   signál zo zásuvky vezme, zosilní a pošle do všetkých ostatných
    zásuviek
-   funguje len na fyzickej vrstve (L1), hlúpy, chápe len 0/1, vie len
    rekonštruovať zašumený signál
-   ak začnú vysielať viacerí, nastane kolízia. Všetci sú v jednej
    kolíznej doméne.

#### Repeater / Opakovač (L1)

-   hub s 2 zásuvkami

#### Switch / Prepínač (L2)

-   vníma MAC adresy
-   ak vie, na ktorej zásuvke je napojená MAC príjemcu, signál posiela
    len do nej
    -   zariadenia v jednej sieti si nesledujú komunikáciu
    -   predchádza sa kolíziám
        -   v kolíznej doméne je len switch a stanica
        -   ethernetové káble dokáže full-duplex (príjem a vysielanie
            separátnymi drôtikmi), takže kolízie nehrozia vôbec
    -   switche *store-and-forward* posielajú frame, až keď ho dostanú
        celý
        -   vedia switchovať megabitovú a gigabitovú sieť
-   udržiava si **prepínaciu tabuľku** / **switching table**
-   je to transparentné zariadenie: stanice nevedia o jeho existencii
    -   manažovateľné switche majú obvykle aj MAC adresu, i webové
        rozhranie na konfiguráciu

##### Prepínacia tabuľka

-   číslo zásuvky
-   MAC adresa uzla napojeného na zásuvku
-   timestamp aktualizácie záznamu

Switch tabuľku aktualizuje sám:

-   Ak príde rámec do zásuvky:
    -   prečítaj zdrojovú MAC adresu a poznač si ich do tabuľky
    -   prečítaj cieľovú MAC, dohľadaj v tabuľke:
        -   ak si nič nedohľadal, funguj ako hub. Pošli rámec do
            všetkých ostatných zásuviek.
        -   ak sa dohľadaná zásuvka zhoduje zo zdrojovou zásuvkou, zahoď
            rámec
        -   inak pošli rámec do dohľadanej zásuvky

Pozor, broadcastové rámce (`FF:FF:FF:FF:FF:FF`) sa posielajú v režime
*hub*.

#### Bridge / Most (L2)

-   switch s dvoma zásuvkami

### ARP: Preklad z IPv4 adries na MAC

Každé zariadenie (routre, počítače) obsahuje ARP tabuľku:

-   IPv4 adresa
-   MAC adresa

ARP tabuľka:

-   nemusí obsahovať všetky uzly v siete
-   pravidelne sa premazáva

#### Algoritmus

Počítač Lenovo chce pingovať adresu `192.168.1.1` vo svojej lokálnej
sieti. (ICMP protokol na sieťovej vrstve L2).

1.  Pozrie sa do svojej ARP tabuľky, či nemá záznam o MAC adrese.
    1.  Ak nájde záznam, rovno ho použije. (ARP sa preskočí)
    2.  Ak nenájde hodnotu, spustí sa ARP.
        1.  Pošle **ARP Request** broadcastový rámec s otázkou „Kto je
            `192.168.1.1`?
        2.  Stanica s danou IP adresou odpovie **ARP Response**
            unicastovým rámcom „Ja som `192.168.1.1` a moja MAC adresa
            je \_\_\_“ (pozná MAC adresu odosielateľa)
        3.  Lenovo si poznačí do svojej tabuľky dvojicu.

#### Vytváranie rámca

Pri vytváraní rámca na spojovej vrstve:

-   vieme IP adresu príjemcu
-   vieme IP odosielateľa
-   potrebujeme vyplniť
    -   MAC odosielateľa: to poznáme, lebo to sme my
    -   MAC príjemcu.
        -   Je IP adresa príjemcu z našej siete?
            -   Ak áno, ideme ARPovať.
            -   Ak nie, zistíme zo smerovacej tabuľky na routeri (L3)
                bránu a ideme ARPovať.
