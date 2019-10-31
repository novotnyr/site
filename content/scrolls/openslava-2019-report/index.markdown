---
title: OpenSlava 2019 — zápisky
date: 2019-10-31T10:36:17+01:00
---

Nebojím sa povedať, že OpenSlava je najväčšia vývojárska konferencia na Slovensku. Celý deň, päť trackov, 40 (!) talkov, málo bullshitu a marketingu. A bezplatná (lebo Accenture). A pekné priestory (lebo STU v Bratislave).

OpenSlave sa darí dobre vyhmatať súčasné trendy — napríklad túto sezónu letí AI / Machine Learning, masírovanie dát zľava is sprava, orchestrácia služieb Kubernetes, platformy pre aplikácie GraalVM a Quarkus, a samozrejme nevyhnutný blockchain.

<img src="openslava-pink.jpg" alt="openslava-pink" style="zoom:50%;" />

Google Flutter (Roman Schiefer)
===============================

[Prvá prednáška](https://www.youtube.com/watch?v=WLDtH03dNfY), ktorú som navštívil bola o Google Flutter. (Keynote som nestihol, pretože doprava z pražského Java User Group do Bratislavy nie je triviálna). Hoci nie som frontendista, Flutter znie dobre, lebo vyzerá ako alternatíva k React Native. V skratke: jeden kód pokryje Android, iOS, i desktop. 

Roman Schiefer začal veľmi zoširoka, ale veľmi rýchlo sa prepol do hardcore režimu, kde začal kódiť naživo a ukázal ToDo appku, ktorú predviedol na Androide a desktope.

Zlé jazyky hovoria, že také appky vyzerajú jednotne… jednotne zle na každej platforme, ale to je určite otázka vkusu. Zaujímavé pozorovanie o Flutteri je použitie jazyka Dart, ktorý vyzeral už takmer mŕtvo, ale toto ho zrejme oživí.

Prednáška mi prišla ako klasický štandard: info o technológii, live coding (!) a dobré podanie.

Responsible Microservices (Nate Schutta)
========================================

OpenSlava má pekný koncept lighting talkov, ktoré sú krátke, úderné a odohrávajú sa v miestnosti plnej tulivakov. Publikum ich väčšinou zažíva z polohy ležmo. (Okrem toho, lighting talky sú ako inkubátor pre speakerov — takto sa mi podarilo mať pred rokmi prednášku o [Consule](http://ics.upjs.sk/~novotnyr/home/prezentacie/consul/openslava%20spring%20consul.pdf))

Nate Schutta z Pivotalu má však prednášky, ktoré rozhýbu každého. (Schválne hovorím prednášky, lebo mal ešte jednu, tzv. „grand finale“). Keďže microservicy zažívajú éru sebareflexie a možno aj krízy, Nate Schutta [za osem minút zhrnul](https://www.youtube.com/watch?v=VSaSwudm4qE), kedy *áno*, kedy *nie*. Bez nejakých detailov to bola turbotúra všetkými dôležitými bodmi. Určite sa to oplatí ako druhá prednáška, hneď po „microservisy sú übercool“.

<img src="openslava-nate-schutta.jpg" alt="openslava-nate-schutta" style="zoom:50%;" />

Quarkus, what is it and how it is used (Pablo di Vita, Natale Vinto)
====================================================================

Podľa Murphyho zákona o konferenciách sa skvelé veci vždy dejú naraz, a to bol dôvod, prečo som sa rozbehol na *Quarkus*. Ako som spomínal vyššie, GraalVM a príľahlé technológie na rýchle spúšťanie backendových aplikácii bez ohľadu na platformu sú (a budú) hitom, Quarkus vyzeral zaujímavo.

Quarkus chce zobrať klasické javácke backendové technológie (lôg bol plný slajd), napríklad JPA a JAX-RS a s klasickými, rokmi overenými znalosťami, chce dať možnosť vybudovať kubernetesovskú, graal-vm-ovateľnú aplikáciu.

Dvaja speakeri sú vždy super, pretože osobnosťami sa vedia dopĺňať. Pozoruhodným momentom bolo lešenie — speakeri nepokryte išli cez akýsi redhatovský tutoriál zverejnený na webe a demonštrovali príklady z neho, s občasným komentárom: od jednoduchého JAX-RS servera, cez jeho deployment na Kubernetes a administráciu

V každom prípade to vyzerá veľmi zaujímavo: Micronaut, Quarkus a čoskoro aj Spring si užijú na Graale v najbližších mesiacoch veľa *technologických flamewarov*.

Obed
====

OpenSlava dáva obed zadarmo, ale ten som využil na stretnutia mimo konferencie. Novinkou tohto roka bola až dvojhodinová pauza umne určená na socializáciu a voľný keynote, ktorý som — samozrejme — zmeškal.

<img src="openslava-ludia.jpg" alt="openslava-ludia" style="zoom:50%;" />

Open Data, Open API & My Data Coming to a e-government Near You (Jano Suchal)
=============================================================================

Jano Suchal je chodiaca legenda slovensko.digital, ktorú som nikdy nevidel rozprávať. Táto [prednáška](https://www.youtube.com/watch?v=PmYaIodUyUQ) bola dokonalé intro k tomu, čo robia, prečo to robia, s občasnými historkami so zákopov. (Akurát v angličtine.) 

Prednáška bola dokonca takticky nastavené na diskusiu — kým mnohé prednášky zbehli bez otázok (dokonca sa nečítalo ani obligátne Sli.do), tuto ľudia diskutovali azda aj 15 minút.

Prestávka
=========

Slovenskodigitálna prednáška bola pre mňa energetický vrchol, kde som nasledovný blok vynechal, jednak preto, že ma nič neinteresovalo a jednak pre únavovú krízu. 

Nezvládol som ani návštevu 90minútovej panelovej diskusie o budúcnosti vzdelávania, kde bol pomer panelistiek ku panelistom 3:2!

GraalVM (Jorge Hidalgo)
=======================

Jorge Hidalgo je klasik OpenSlavy, na ktorého sa oplatí ísť bez ohľadu na to, o čom rozpráva. Každý rok  vytočí trendovú prednášku plnú dobrej nálady, určenej pre developerov, a plnej pragmatizmu — jednoducho niečo, čo sa mi páči a čo rád na svojich prednáškach robím tiež.

Tentokrát dovliekol GraalVM, čo sme nazvali „platforma pre spúšťanie všetkého nad všetkým a to veľmi rýchlo“. 

[Porozprával realisticky](https://www.youtube.com/watch?v=3-UuzCIJkmo), ako to s Graalom vyzerá, čo od toho čakať (aplikácie sa naozaj nakompilujú pre cieľovú platformu), kde sú zádrhele (napríklad ako funguje reflexia v Jave), a čo s tým dá robiť, a celý čas kódil naživo.

Na rozdiel od Quarkus-u vidno, že Jorge má veci vyskúšané, zažité a v rukách, a nebál sa hovoriť, kedy čo nefungovalo, resp. s čím nemá skúsenosti.

Thinking Architecturally (Nate Schutta sa vracia)
=================================================

Keby existovalo veľké finále konferencie, tak Nate Schutta ho [dodal](https://www.youtube.com/watch?v=giKlW14TnaY). Nate je autorom O’Reilly knihy *Thinking Architecturally* a tento talk bol 40 minútovým sumárom. Už pri lightning talku bolo vidieť energiu, ale tuto sa Nate rozbehol naplno. 

Nate vyzeral ako správny ideológ / motivátor — naplno porozprával, na čo všetko si konceptuálne / filozoficky treba dať pozor pri projektoch ako takých. Jeho prednášky sú skvelé k žehleniu košieľ, nie sú nudné, sú takmer bez technológií, sú však o soft skilloch, medziľudských vzťahoch, prinášajú nové veci a netreba sa plne sústrediť napríklad na presné kroky pri programovaní. (Speakerský tip: na slajdoch používa tweety.) Inými slovami, prednáška je typu „polovicu netechnických aspektov projektu som tušil, ale je dobré mi ich pripomenúť, prípadne mi ich oplieskať o hlavu“.

Publikum ho očividne žralo a jedna z otázok na Sli.do ho otvorene pozývala na pivo.

<img src="openslava-nate-schutta-2.jpg" alt="openslava-nate-schutta-2" style="zoom:50%;" />

Záver
=====

OpenSlava nikdy nedopadla zle. Za sedem rokov majú na mnoho % vyladené organizačné veci, prakticky ich nič neprekvapí. Ľudí bolo primerane veľa (netlačili sa, ani to nevyzeralo poloprázdne), i keď azda menej než minulého roku, a rozhodne menej mužov.

(Organizačný protip: tohto roku tlačili menovky operatívne na minitlačiarňach, namiesto zúfalého hľadania medzi stovkami registrovaných ľudí. Organizačná otázka: prečo sú tam ženy, ktorých úloha je stáť a otvárať dvere na konferečných miestnostiach?).

Ak to má byť populárne-technologická konferencia na Slovensku, tak za mňa jednoznačne 100%.