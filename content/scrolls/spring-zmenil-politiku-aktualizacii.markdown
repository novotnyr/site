---
title: Spring zmenil politiku aktualizácií - rana pod pás open source?
date: 2008-09-21T22:59:29+01:00
---

Niet nad trochu IT bulváru v sobotu ráno.

SpringSource, spoločnosť stojaca za aplikačným rámcom Spring, v sobotu ráno oznámila, že mení politiku vydávania aktualizácií Springu. A v diskusiách sa hneď strhla radikálna nálada a krik o konci open-source.

Dosiaľ mala komunita k dispozícii všetky aktualizované verzie Springu, ale situácia sa zmení. Po vydaní novej významnej verzie Springu začne plynúť trojmesačná doba, počas ktorej budú prípadné aktualizované verzie dostupné komunite. Po jej uplynutí budú aktualizované verzie dostupné len zákazníkom programu SpringSource Enterprise. Opravy chýb budú zahrnuté do hlavnej vetvy vývojového stromu a budú dostupné v ďalšej významnej verzii. (Originálne znenie politiky nájdete na stránkach [SpringSource](http://www.springsource.com/products/enterprise/maintenancepolicy )). Pod významnou verziou sa rozumie napr. verzia 3.x, 3.1.x, 3.2.x,... 4.x atď.

Komunita je zmätená. Čo presne znamená toto vyhlásenie? Ak 1. 1. 2009 vydajú Spring 3.0 a v apríli sa nájde kritická chyba, znamená to, že komunita sa k aktualizovanej verzii dostane až vo verzii 3.1, ktorej dátum vydania nemusí byť jasný?

Mark Brewer zo SpringSource [objasnil v diskusii na TheServerSide](http://www.theserverside.com/news/thread.tss?thread_id=50727#268886 ), že komunita bude mať v trojmesačnej dobe po vydaní významnej verzie k dispozícii aktualizované verzie (teda napr. 3.0.1, 3.0.2) atď. Po uplynutí tejto lehoty budú aktualizované verzie k dispozícii len pre komerčných zákazníkov. Opravy budú k dispozícii v opensource vývojovom strome, odkiaľ si ich môžete stiahnuť a skompilovať si vlastnú verziu.

[V diskusii sa ďalej zjavil Rod Johnson](http://www.theserverside.com/news/thread.tss?thread_id=50727#269378 ), ktorý objasnil, že dôvod je nasledovný: nie je viac možné venovať energiu na udržiavanie množstva verzií Springu, ktoré sa aktívne používajú (minimálne 1.x, 2.x a 2.5.x). Ak ste neplatiaci open-source priaznivec, zrejme budete automaticky používať tie najnovšie a najhorúcejšie verziu a teda sa pre vás nič nezmení. Ak ste komerčný zákazník a ste nútený ostávať na staršej verzii a chcete získavať jej aktualizácie, tak si priplaťte.

V súvislosti s tým vznikla ešte konšpiračná teória o tom, že SpringSource si potichu oddelilo open-source vývojový strom od komerčného. V JIRE jestvuje temer 100 chýb priradených k Springu 3.0M1, pričom plánované vydanie tohto milestonu je v októbri (pôvodne v septembri).
Tieto obavy boli, zdá sa, vyvrátené. Jednak preto, že vývoj na M1 sa má čoskoro znovu rozbehnúť (ako oznámil Jurgen Holler) a jednak preto, že všetky opravy novoobjavených chýb by mali byť k dispozícii vo vývojovom strome.

Komunita sa búri hlavne preto, že formulácia tejto politiky nebola uvedená príliš jasne. Množstvo ľudí si myslelo, že sa kód uzavrie, že Spring bude len za peniaze a zavelilo na odchod od Springu, rituálne pálenie loga, poukazovanie na vendor lock-in, prípadne veľký prostredník Roda Johnsona a brojí za nutnosť začať študovať JBoss Seam a migrovať na Guice...

Počas víkendu sa situácia ujasnila a vystihuje ju veta:
"Komunita bude mať k dispozícii aktualizované binárky, ktoré vyjdu počas 3 mesačnej doby od vydania významnej verzie. Aktualizované binárky, ktoré vyjdu po uplynutí tejto doby budú k dispozícii len pre platiacich zákazníkov."

Keď sa na to dívam, jediným potenciálnym zádrheľom može byť byť situácia, keď uplynie trojmesačná lehota, budete vidieť chybu, ale musíte čakať na oficiálne vydanie novej významnej verzie. Alternatívne si môžete stiahnuť kód a backportovať chyby z novej verzie sami, prípadne si zostaviť vlastnú verziu z vývojového stromu.

Na jednej strane je tu fakt, že významné verzie sa dosiaľ vydávali veľmi sporadicky (namiesto nich tu bolo viacero minoritných vydaní: Spring je vo verzii 2.0.8 resp 2.5.5), čo môže vyvolať obavy z dlhého čakania. Na druhej strane kód Springu je natoľko kvalitný, že aktualizácie minoritných verzií v našich projektoch neboli v podstate potrebné.

# Komentáre

#### ~Dmitrij — 02 October 2008, 21:25
>no jo, takhle to dopada s kazdym vetsim poradnym projektem..nekdo to vymyslel, rozjel, lidi to zacali pouzivat a bum..platte nam za nas skvely napad..
Google zatim drzi, bohudik, jinou politiku..coz snad tak i zustane..
jinak to je docela spatna zprava, ale diky za info


#### ~novotnyr — 02 October 2008, 11:27
>Po burlivej diskusii este bezi debata, ci budu v source repository tagy, podla ktorych bude mozne zostavit lubovolnu minoritnu verziu. V sucasnosti je to tak, ze tagy pre nekomunitne verzie nie su, ale Rod Johnson povedal, ze sa o tom bude diskutovat.
>
>Dalsim bodom, ktory sa ukazal je to, ze ceny sa komercne verzie su znacne a podla niektorych ludi si to male firmy jednoducho nebudu moct dovolit.

#### ~Daniel — 02 October 2008, 08:39
>Pokud cas, ktery vyvojari zadarmo poskytuji k udrzovani soucasneho stavu presahuje rozumne meze, je potreba, aby se ten cas zpoplatnil. Doufam, ze drtiva vetsina lidi si to uvedomuje a ze skupina kryptoparazitu, kteri se zastituji recmi o "svobode", pricemz ve skutecnosti akorat chteji stavet sve ultradrahe enterprise aplikace za co nejmensi prachy, bude minoritni.


#### ~Karel  &mdash;  01 October 2008, 15:45
>Takže v podstatě, jestliže si chcete se Springem hrát máte ho zadarmo, jestliže ho chcete nasadit musíte zaplatit. To že bych si sám backportoval opravy z aktuální verze do verze kterou provozuji je dost nereálné. A když nasadím u zákazníka poslední verzi, tak bude za tři měsíce v podstatě nepodporovaná. Tohle se asi opravdu open source komunitě nebude líbit, doufejme že zajistí podporu starších verzí sama.


#### ~kares — 21 September 2008, 21:24
>velmi pekne zhrnute a vysvetlene ... pochopil som to cele poriadne az po precitani tohoto clanku.

