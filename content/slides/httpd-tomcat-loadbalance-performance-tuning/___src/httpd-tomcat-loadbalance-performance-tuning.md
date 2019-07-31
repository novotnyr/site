title: httpd a Tomcat – loadbalancing a ladenie výkonu
class: animation-fade
layout: true

<!-- This slide will serve as the base layout for all your slides -->
.bottom-bar[
  {{title}}
]

---

class: impact

# {{title}}
## @RoboNovotny

---

# Dva druhy proxy serverov
- forward proxy
- reverse proxy

---

# Forward Proxy

- browser si nastaví proxy v prehliadači.  
- vysvetlí, že aký server chce navštíviť
- proxy načíta obsah a prepošle ju klientovi
- v Apachovi cez moduly: 
	- proxy
	- proxy_http
	- proxy_connect
---
# reverse proxy (gateway)

- klient nakontaktuje server
- ten je v skutočnosti reverse proxy
- server/reverse-proxy nakontaktuje aplikačné servery
	- získa obsah
	- schrústa
	- pošle klientovi

---

# Typické úlohy reverse proxy
- loadbalancing
- high availability / failover
- decryption
- cache
- kompresia

---
# Apache HTTP (`httpd`)
- vhodný kandidát na reverse proxy
- dokáže loadbalancovať
- dokáže slúžiť ako SSL/TLS terminátor
- dokáže rýchlejšie obsluhovať statické súbory 
    - hoci dnes už diskutabilné

---
# httpd a Tomcat

- httpd môže loadbalansovať Tomcaty
- http môže riešiť SSL komunikáciu s klientom, čím odľahčí Tomcat

---

# Komunikácia medzi HTTPD Proxy a Tomcatom
Dva protokoly pre komunikáciu:

- cez HTTP(S)
- cez AJP

---

# Kedy ktorý?
- AJP ak:
	- SSL končí na **httpd** a potrebujeme vidieť info o SSL
	- preposielanie SSL info je zabudované do protokolu
- HTTP ak:
	- potrebujeme zašifrovať spojenie medzi *httpd* a *Tomcatom*
	- chceme krajšie ladiť
- na rýchlej privátnej LAN sú obe voľby ekvivalentné

---
# HTTP vie obe

Ak potrebujeme:

- aj SSL info v Tomcate 
- aj šifrovaný kanál medzi **httpd** a Tomcatom
- je ľahšie preposielať SSL info cez HTTP než kryptovať AJP

---

# Protokol HTTP(S)
- známy
- overený
- jednoduchý debugging
---
# Protokol AJP
- optimalizovaná binárna verzia HTTP/1.1 protokolu
	- niektoré štandardizované stringy z protokolu sú kódované ako čísla
- nie je zabezpečený!
	- ale dokáže preposielať vybrané info o SSL
	
---
# Verzie AJP
- AJP 1.2 / ajp12 — starý, nepodporuje perzistentné connectiony
- **AJP 1.3 / ajp13 - default v Tomcate**
- AJP 1.4 / ajp14 – experimentálna



---
# Zabezpečenie AJP: žiadne

* AJP nepodporuje šifrovanie
    * žiadne SSL! 
* designová voľba: predpoklad, že `httpd` a Tomcat sú v rovnakej internej sieti
* ale dokáže preposielať vybrané info o SSL
	- certifikát
	- šifru/cipher
	- identifikátor sessiony

---
# Ďalšie technické info AJP

- používa perzistentné TCP pripojenia 
    - znovupoužíva ich pre viacero request-response výmen
	- ale nepoužíva multiplexing: jedno TCP pripojenie je použité pre práve jednu výmenu request-response
- nikdy nebude podporovať HTTP2
	- protokol je iný zápis pre HTTP

---
# AJP dokumentácia	
- [mod_proxy_ajp - Apache HTTP Server Version 2.4](https://httpd.apache.org/docs/2.4/mod/mod_proxy_ajp.html)	
- design dokument – analogický popis v dokumentácii ku konektoru  [http://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html](http://tomcat.apache.org/connectors-doc/ajp/ajpv13a.html) 

---

# Použitie AJP v Apache HTTPD
- buď `mod_proxy` + `mod_proxy_ajp`
- alebo `mod_jk`

## Zapudené varianty
- `mod_jk2` — opustený pokus, zmeny sa zahrnuli do `mod_jk`
- `mod_jserv` — praotec. Nepoužívať, nepodporovaný, starý.
- `mod_webapp` — nepoužívať. Nebeží na Windowse
- `warp` — nepoužívať.

---
# Kedy `mod_jk` a kedy `mod_proxy`

- pradávno boli veľké rozdiely vo funkcionalite
- dnes je to prakticky jedno
- ak na zelenej lúke, `mod_proxy` má menší kognitívny load

---

# Kedy `mod_jk`?
- švajčiarsky armádny nožík
	- podporuje sticky sessions 
		- ale samotný Tomcat vie používať *Session Manager* pre zdieľané sessiony
	- podporuje viacero typov load balansingu
- vyvíjajú ho Tomcatisti

---
# Prečo nie `mod_jk`?

- pokročilá konfigurácia v divnom formáte: 
    - treba totiž udržiavať dedikovaný `properties` súbor
- nutné kompilovať modul
	- binárky len pre Windows
- kedysi jediná možnosť pre obrovské pakety nad 8kB
	- všetky hlavičky requestu sa musia zmestiť do 1 paketu
	- to však už podporuje aj moderný `mod_proxy`

---

# Konfigurácia `mod_jk`
- loadbalansing i reverse proxy sa konfigurujú vo `workers.properties`
- konfiguruje sa Apache, nie Tomcat!
- pre *load balancing*:
	- definuje sa zoznam workerov
		- worker = Tomcat
			- definuje protokol: obvykle `ajp13`
			- definuje port AJP konektora v Tomcate: napr. 8009
			- definuje adresu workera

---
# HTTP Sessions pri loadbalancingu
- každý loadbalansovaný Tomcat má nezávislý manažment HTTP sessions
- keby klient lietal medzi rozličnými Tomcatmi, stratil by sa stav

## Riešenie 1: sticky sessions

- prilepme požiadavky klienta ku konkrétnej inštancii Tomcatu

## Riešenie 2: zdieľaný session store v Tomcate
- Tomcaty zdieľajú sessions cez spoločný Session Manager
- dáme ich do spoločného clustera
- všetky inštancie si budú synchronizovať sessiony 

---
# Sticky sessions v `mod_jk`

- každý Tomcat nafasuje meno
    - v `<Engine>` atribút `jvmRoute`
- to sa docapne za *session ID*

---
# Loadbalansing podľa záťaže v `mod_jk`

- možnosť nastaviť *lbfactor*
- váha pre loadbalancing: čím vyššie, tým viac requestov zvláda worker

---

# Použitie `mod_proxy` + `mod_proxy_ajp`
- štandardná súčasť Apacha
- vyvíjajú ho Apachisti
- oba apachovské moduly musia byť dostupné a zapnuté
	- `mod_proxy` rieši všeobecnú konfiguráciu
	- `mod_proxy_ajp` je implementácia AJP protokolu medzi Apachom a Tomcatom

---
# Výhody `mod_proxy_*`
- možnosť používať akýkoľvek protokol:
	- rýdze HTTP
	- HTTPS
	- AJP (pridaním `mod_proxy_ajp`)
	- dokonca aj kombinácia v rovnakom balanceri
- s použitím HTTPS možno ľahké dosiahnuť zabezpečený kanál Proxy<->Tomcat
- konfigurované normálnym spôsobom v `httpd`
---
# Výhody `mod_proxy_*`
- za tie roky dobehol vlastnosti, čo boli len v `mod_jk`
    - veľké pakety nad 8 kB
    - pokročilý loadbalancing
    - regulárne výrazy v mapovaní URL adries

- Dokumentácia z 2014: [The difference between mod_jk and mod_proxy](https://www.programering.com/a/MTO3gDMwATg.html)

---
# Veľké pakety v `mod_proxy`
- vlastnosť [`ProxyIOBufferSize`](https://httpd.apache.org/docs/2.4/mod/mod_proxy.html)
- default 8 kB
- ak sa zmení, treba zmeniť aj `packetSize` v Tomcate na tú istú hodnotu!
- toto bolo kedysi len v `mod_jk`
    - [Comparing mod_proxy and mod_jk (Mladen Turk, 2007)](https://developer.jboss.org/blogs/mladen.turk/2007/07/16/comparing-modproxy-and-modjk?_sscc=t)

---

# Pokročilý load balancing v `mod_proxy`
- `lbmethod`
	- `byrequest` - vážené rátanie požiadaviek
	- `bytraffic` - vážené rátanie bajtov
	- `bybusiness` - podľa čakajúcich požiadaviek
- podporuje sa aj *sticky sessions*


---
# AJP na strane Tomcatu

---

# Použitie AJP na strane Tomcatu
- máme **Connector** s podporou AJP protokolu
- Tri implementácie, z hľadiska vlastností sú viacmenej rovnaké:
	- `AjpNioProtocol`— klasické Java NIO
	- `AjpNio2Protocol` — NIO2, výkon rovnaký, interný prepis, zrejme bude default v budúcich Tomcatoch
	- `AjpAprProtocol` — pre použitie s natívnou library Tomcat Native Library (APR)
- Porovnanie konektorov: [Apache Tomcat 8 Configuration Reference (8.5.43) - The AJP Connector](https://tomcat.apache.org/tomcat-8.5-doc/config/ajp.html#Connector_Comparison)

---

# Konfigurácia konektora AJP

- `protocol`
   - default hodnota je `AJP 1.3`
    	- automaticky sa vyberie buď NIO
    	- alebo APR, ak je knižnica k dispozícii
```
<Connector port="8009" protocol="AJP/1.3" redirectPort="4443" />
```

---
# Atribúty konektora AJP

- viď [dokumentácia](https://tomcat.apache.org/tomcat-8.5-doc/config/ajp.html)
- **scheme**: buď HTTP alebo HTTPS pre HTTPS konektor
- **secure**: metóda `isSecure()` na HttpRequeste bude vracať túto hodnotu
	- presvedčíme Tomcat, že dáta sú zabezpečené
    	- `httpd` sa postará o SSL 
    	- do AJP pošle otvorené plaintext dáta
    	   - AJP nevie šifrovať!
    	- sme však v internej bezpečnej LAN sieti, takže je to bezpečné!
- **redirectPort**: 
	- ak konektor podporuje plaintextové requesty
	- a príde request, ktorý vyžaduje SSL (v `<security-constraint>`)
	- konektor presmeruje požiadavku na uvedený port
		- tam môže sedieť iný konektor

---
 
# Zabezpečenie AJP protokolu (nie je)
- viď [Secure AJP over SSL Nabble Thread](http://tomcat.10.x6.nabble.com/Secure-AJP-over-ssl-td2083890.html)
- (2011) AJP nepodporuje šifrovanie AJP protokolu
- predpokladá sa, že load balancer/reverse proxy a Tomcaty sú na rovnakej internej sieti

---

# Čo ak potrebujem bezpečný kanál medzi `httpd` a Tomcatmi?

- AJP v SSH tunneli: rýchly, menej robustný
- AJP v OpenVPN: lebo aj k dispozícii autoreconnect
- vykašľať sa na AJP
    - HTTPS a `mod_proxy`: asi najpomalší z týchto troch možností

---
# `mod_proxy` a HTTPS medzi `httpd` a Tomcatmi

- SSL informácie z `httpd` sa v HTTPS nepropagujú automaticky
    - AJP toto robí automaticky
    - v HTTPS to budeme emulovať
- na strane `httpd`: pridať vlastné hlavičky do requestu
	- šifra 
	- certifikát klienta
	- id SSL sessiony
	- a veľkosť kľúča
- na strane Tomcatu: pridať `SSLValve`, ktorými sa odbalia
- detaily v [dokumentácii](https://tomcat.apache.org/tomcat-8.0-doc/config/valve.html#SSL_Valve)

---

# Sekcia: Tomcat a konektory

---

# Tomcat a konektory

- **connector** 
    - rieši sieťovú komunikáciu
    - počúva na konkrétnom porte
    - rozumie konkrétnemu protokolu
    
---

# Tomcat a HTTP(S) konektory
Podľa: [Apache Tomcat Connector Selection - YouTube](https://www.youtube.com/watch?v=LBSWixIwMmU)

- BIO - blocking IO
	- používa Java implementáciu SSL (JSSE)
	- od Tomcatu 9 zrušené
- APR - natívna knižnica v C (tá istá ako má `httpd`)
	- používa OpenSSL pre SSL
- NIO (Tomcat 6+) – neblokujúce
	- používa JSSE pre SSL
	- možnosť OpenSSL od Tomcatu 9
- NIO2 (Tomcat 8+) – neblokujúce
	- používa JSSE pre SSL
	- možnosť OpenSSL od Tomcatu 9
	- NIO2 je rovnako výkonný, ale alternatívne napísaný NIO konektor

---
# Tomcat a AJP konektory
- BIO 
	- zastaralá od Tomcatu 9
- APR
	- zdieľajú kód s HTTP konektormi
	- redukuje sa náročnosť údržby
- NIO (od Tomcatu 7)
- NIO2 (od Tomcatu 8)
- žiaden support pre SSL
	- AJP to vôbec nepodporuje!

---
# APR konektory
- vie sa prepínať medzi blok a nonblocking režimom
	- vhodné pre Servlety Async
	- a pre WebSockety
- dobre škáluje
	- 1 vlákno na 1 connection, len ak prišli nejaké dáta na spracovanie
- thread pool
- vie spracovať viac spojení než je vlákien
- C knižnica
	- výkon
	- v obskúrnych situáciach môže JVM zdochnúť
- OpenSSL
	- rýchlejšie než Java SSL 
---

# NIO konektory
- nonblocking
- pre servletové IO emuluje blocking mód
- 1 thread na spojenie
- takisto používa poller na spracovanie idle spojení
	- do pollera sa pridá socket
	- polleru sa povie, akú operáciu (Read? Write?) chceme spraviť
	- čakáme na pollera, ktorý oznámi, keď je socket pripravený spracovať operáciu
- defaultne používa Java SSL

---
# NIO2 konektory
- podobné k NIO
- namiesto pollera sa používajú callbacky
	- iný model pre spracovanie *idle* spojení
	- „iným spôsobom komplexné“
	- informácia o dokončení I/O operácie sa odovzdáva cez callbacky / Futures / CompletionHandlery.


---

# NIO/NIO2 a SSL
- štandardne sa používa Java SSL 
- od Tomcatu 9 možnosť použiť OpenSSL
    - obvykle rýchlejšie než Java SSE
    	- podľa algoritmu
    	- podľa veľkosti odpovede
    	- Mozilla zistila zhruba 20% zrýchlenie pri vhodnom algoritme
    	- čím väčšia odpoveď, tým viac v prospech OpenSSL
    - vyžaduje Tomcat Native Library (tá istá ako pri APR)

---
# Odporúčania pre plaintext HTTP

- BIO je mŕtve, nepoužívať!
- ostatné sú veľmi podobné
- NIO možno jemne lepšie než APR, veľmi ťažko porovnať výkony
	- APRko môže padať, lebo krachnutý natívny kód zomrie aj s JVM
- otestujte, benchmarkujte, zvoľte jeden z NIO/NIO2/APR

---
# Odporúčania pre HTTPS

- BIO je mŕtve
- surový TLS výkon => 
	- Tomcat 8: APR
	- Tomcat 9: NIO+OpenSSL
- pre bežné použitie:
	- Tomcat 8:
		- APR je rýchlejšie ako NIO(2)+JSSE
		- NIO + OpenSSL viacmenej ako APR
			- možno APR jemne lepšie
	- Tomcat 9:
		- NIO(2) + OpenSSL je zarovno s APR
- NIO/OpenSSL > APR >> NIO/JSSE > NIO2/JSSE

---
# Odporúčania pre HTTPS

- NIO/OpenSSL
	- hranice Java-Native sa prekračujú pri šifrovaní
- APR/OpenSSL
	- hranice sa prekračujú pri každom IO
	- buffering je ten rozdiel
	- ako veľmi app zapisuje v jednom fľuse
	- toto je jemne rýchlejšie, NIO/OpenSSL je jemne stabilnejšie
- `markt` vám urobí benchmark, ktorý dokáže, čo potrebujete

---

# Ladenie performance
- veľa performance problémov je v appke, nie v Tomcate!
- zámena konektorov ponúka toľko riešení, ktoľko môže spôsobiť problémv
- nezamieňajte konektory len preto, že to môže byť rýchlejšie

---
# Konfigurácia konektorov

- `maxThreads` - počet vlákien v threadpoole. Default: 200
    - v starom BIO: 1 vlákno = 1 connection
    - v NIO(2): 1 vlákno môže obslúžiť viacero connectionov 
    - ak má konektor nastavený *executor*, `maxThreads` sa ignoruje
- `maxConnections` - connections nad limit budú akceptované, ale blokované, kým sa nespracujú tie existujúce 
    - NIO(2): 10000
    - APR: 8192. (Použije sa násobok 1024 menší ako uvedené číslo)
- `minSpareThreads` - minimálny počet stále bežiacich vlákien. Default: 10
    - rátajú sa aktívne i *idle* vlákna 

---
# Konfigurácia konektorov

- `acceptCount` - dĺžka frontu, kde čakajú connectiony, keď sú všetky vlákna vyťažené. Default: 10
- `acceptorThreadCount` - počet vlákien, ktoré akceptujú connections. 
    - default 1
    - na viacerých jadrách možno zvýšiť. napr. na 2
    - ak je veľa non-keep-alive spojení, možno zvýšiť 

---
# Executor
- konektor má vlastný interný thread pool
- konektory však môžu zdieľať threadpooly cez `<Executor>`
- vlákna sa potom nastavujú na exekútore, nie na konektore
- `maxThreads` a `minSpareThreads`
- `maxQueueSize`: sémantika `acceptCount`

---
# Kompresia a `sendfile`

- možno šetriť pásmo cez GZIP kompresiu
    - `compression` na konektore
        - zapne / zapne pre text / zapne od istej veľkosti / zapne všade
- možno šetriť CPU cez `sendfile`
    - systémové volanie pre turborýchle transfery zo súboru do socketu
- `sendfile` sa vzájomne vylučuje s GZIP!

---
# Výkonnosť v spolupráci s `httpd` 
- viď [Connectors - Apache Tomcat - Apache Software Foundation](https://cwiki.apache.org/confluence/display/TOMCAT/Connectors)
- Apache ako urýchľovač statického obsahu?
	- okrem brutálnych prietokov nedáva zmysel
	- vďaka APR/sendFile sa zdieľa natívna knižnica a teda aj výkon je podobný
	- jedine hranica medzi JVM a natívnym kódom
		- Apache má lepšie handlovanie socketov pri chybách
			- bombardovanie zlými paketmi
			- dropnutými spojeniami
			- divné requesty z divných IP
	- ak sa rozhodujete či postaviť Apache pred Tomcat len kvôli rýchlosti, je to zbytočné.

---
# Literatúra
- [Apache Tomcat Reverse Proxies (2012)](https://home.apache.org/~markt/presentations/2012-10-Apache-Tomcat-Reverse-proxies.pdf)
- [Choosing Tomcat Connectors (2014)](https://events.static.linuxfound.org/sites/events/files/slides/TomcatConnectorsEU_0.pdf)
- [Tomcat 9 NIO vs NIO2](http://tomcat.10.x6.nabble.com/Tomcat-9-connector-refactoring-NIO-vs-NIO2-td5034011.html)
- [The Challenge Tomcat Faces in High Throughput Production Systems (2017)](https://events.static.linuxfound.org/sites/events/files/slides/TomcatCon2017.pdf)
- [Tomcat Clustering (2017)](http://people.apache.org/~markt/presentations/2017-09-26-b-clustering.pdf)
- Prezentácie od [markt](http://people.apache.org/~markt/presentations/)
- [How can Tomcat Require Redirect to a Secure Connection when Behind Apache HTTP Server Reverse Proxy (Pivotal)](https://webcache.googleusercontent.com/search?q=cache:TANF4ss0syoJ:https://community.pivotal.io/s/article/How-can-Tomcat-require-redirect-to-a-secure-connection-when-behind-an-Apache-HTTP-Server-reverse-proxy-2007800+&cd=13&hl=en&ct=clnk&gl=il)

---