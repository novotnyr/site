---
title: Ruby on Rails - Zapomeňte na Javu
date: 2011-02-28T23:44:14+01:00
---
* *Oznam o konání*: http://java.cz/article/czjug-oauth-ror
* *Datum:* 28. 2. 2011
* *Záznam:* http://www.youtube.com/watch?v=eOdSO1sk3mA
* *Přednáší*: Jiří Hradil, Kyberia
* *Slajdy:* http://www.java.cz/dwn/1003/38153_ruby_on_rails_zapomente_na_javu.pdf
* *Blog*  http://www.hradil.org/czjug-ruby-on-rails-zapomente-na-javu/

(Mezititulky RN)

# Přepis

## Úvod
Dobrý večer a dobrou chuť, mé jméno je Jiří Hradil. Jsem ze společnosti Kyberie a dnes bych vám rád prezentoval přednášku na téma Ruby on Rails – Zapomeňte na Javu. Proč jsem si dovolil přijít na CZJUG a říkat, že máte zapomenout na Javu? Důvod je prostý: chtěl jsem, aby vás přišlo co nejvíc a abych rozpoutal diskusi na toto téma, protože z mého pohledu Java či spíše její komunita v České republice už není to, co dřív bývalo. Jak sleduji diskusi na konferenci Java.cz, tak si myslím, že by to chtělo ty stojaté vody trošku rozčeřit a ukázat, že pro vývoj webových aplikací existují i jiné platformy, kde se nemusíme tak moc trápit, jak se možná některí z nás (včetně mě) trápí v Javě. 

## Motivace
Nejprve vysvětlím motivaci, proč jsem sem přišel a řeknu vám, co jsme dělali v Kyberii od roku 2004 v Jave. My jsme chtěli od začátku psát webové aplikace. Pěkně jsme si to rozvrhli na množinu problému, které musíme řešit. 

### Perzistence
Jedna z věcí byla perzistence v Javě pro webové aplikace a ze začátku, přesněji v té době, se nabízelo JDBC. Mysleli jsme si, že by nám to stačilo. Dřív jsme používali PHP a věci jako ORM jsme neřešili. Byli jsme zvyklí na to, že pokud chci používat relační databázi, tak se na to tím klientem připojím, rovnou napíšu dotaz do databáze -  SELECT, INSERT, UPDATE, všechno krásně fungovalo a transakce jsme si řídili sami. To by nám docela fungovalo, ale v té době komunita obecně říkala, že „JDBC je dobrý a funguje, ale to není ta správná věc.  Potřebujeme řešení, které je nezávislé na databázi.“
O tomhle si myslím, že je to v Javě typický nesmysl, resp. v 90% případů se databáze vybere na začátku a pak už není potřeba databáze přepínat. Pokud mám na začátku Oracle, protože jsem zvyklý s ním pracovat, tak ho použiju. I když ty další databáze mají spoustu věci stejných, protože existují specifikace SQL ANSI, stejně jsou tam drobní rozdíly. Když vývojáři používají konkrétní databázi, tak už jsou na ni zvyklí a potřeba switchovat už není tak velká. Někdo to třeba má, ale já jsem to typicky nepoužil.

### Hibernate
Přešli jsme k Hibernate. V té době to byla jedna z mála věcí, o které se říkalo, že s postupným umíráním JDBC bude Hibernate to pravé. Hibernate byl spočátku dobrý a všechny tutoriály vypadali velmi slibně. Pro nás to ale bylo v porovnání s PHP, kde jsme si dotazy psali ručně, příliš složité. Člověk se musel naučit, co jsou to sessiony, jak to funguje, jak se to připojí, jak se poolují spojení. My jsme to neuměli a jsme se v tom na pár měsíců zahrabali. Potom jsme řekli, že Hibernate asi nebude to pravý a po pár měsících jsme to (možná předčasně) opustili. 

To byla z mého pohledu chyba a já se ještě k tomu později vrátím. 

### EJB
Snažili jsme se používat standart. Věřili jsme, že pokud se zaháčkujeme na nějaký standard, tak síla toho standardu bude tak velká, že nemůžeme udělat chybu. Hibernate v roce 2004, když jsme to používali, ještě nebyl tak profláklý, jak je profláklý dnes. Chtěli jsme něco standardního, co se naučíme, věnujeme tomu jistou energii a pak to bude všechno krásné a budeme to sekat jak Baťa cvičky. 
Pak jsme se dostali k EJB, tehdy ve verzi 2.0, resp. 2.1. V půlce přechodu, když jsme se to učili, přišel prototyp EJB 3.0 založený na anotacích. V EJB byla důležitá věc a to speciálně v deploymentu:  neuvěřitelný zvrat ve složitosti. Pokud jste chtěli v EJB 2.0/2.1 cokoliv definovat, např. beany, museli jste to definovat v XML, což bylo příšerný. Pokud jste chtěli změnit nějakou jednoduchou věc, museli jste si udělat XML, všechno napsat. V okamžiku, když chtěl člověk nový bean, museli jste zase otevřít soubor a zase napsat XML, co bylo strašně pomalé pro vývoj. 

### EJB 3.0

EJB 3.0 přineslo anotace. Říkalo se, že předtím to bylo složité a anotace je to pravé. Je zajímavé, že vždy, když v Javě přišli různé frameworky nebo trendy, tak se vždycky říkalo, že to předchozí bylo špatně a teď to už bude dobře; to nové bude to pravé a bude se to rozvíjet. To přesně platilo i pro anotace. Z mého pohledu přinesly anotace další vrstvu složitosti. Co se ušetřilo na zápisu v XML, se zase prodloužilo tím, že vývojář měl spoustu anotací a musel vědět, co z toho chce používat a co ne, atd. 


### Aplikační kontejnery
Teď k aplikačním kontejnerům: opět budu popisovat rok 2004/2005. Zkusili jsme JBoss – extrémně složitá záležitost, opravdu extrémně. V té době byla konfigurace JBossu dělaná ručně. Tuny XML souborů a než člověk přišel na to, proč se projekt nechce deploynout, bylo to dlouhé hledání. Měli jsme spoustu literatury, komínek příruček, které jsme měli načtené, ale deploynout aplikaci a rozběhat ji bylo příšerný. 
Glassfish v té době byla dobrá a pěkná věc. Měl grafické rozhraní, v kterém si to vývojář naklikal a ono to nějak fungovalo. V té době, myslím si, nebyl v úplně stabilní verzi a občas nám to padalo. Rozhodli jsme se, že Glassfish ano, ale ne teď, protože jsme potřebovali něco stabilní.  Kromě JBossu byly aplikační servery od IBM, Oracle Application Server, a museli jsme si vybrat. 
Ještě k standardům: řeknou vám, že existují standardy, ale vy si stejně vyberete jeden aplikační server a pak řešíte drobné nuance. Ono se to občas trochu liší – někdy uděláte WAR nebo EAR a pak vám to nejelo, protože jste to museli nakonfigurovat trochu jinak. Jak jsme postupně přecházeli aplikační servery, tak jsme ztratili moc času, protože to bylo moc složitý v porovnání s PHP, kde se aplikace jednoduše nahraje a jede. Naproti tomu se aplikační servery musejí konfigurovat. 

### Role v týmu
Když jsme se učili základy v rámci certifikátů EJB, tak už Sun deklaroval jisté role: tady tohle je vývojář, tady tohle je ten, kdo to deployuje, tady tohle je ten, kdo sestavuje aplikaci. Samozřejmě, že to může dělat jeden člověk, ale byla tam úzká specializace, o které si myslím, že je to špatně. Zastávám názor, že vývojář by to měl zvládnout od počátku, od klientova zadání až po deployment do produkce a udržování. Když se to dělí přes role, tak potřebujete v týmu víc lidí a víc lidí se špatně řídí. Osobně věřím tomu, že tým by měl mít 3-4 lidi a ne víc. Týmů samozřejmě můžete mít víc, ale ten základ by neměl být větší.

Postupně jsme se vrátili k jednodušším ORM. Uvažovali jsme TopLink (teď si nepamatuji, zda to už tehdy byla implementace JPA, nebo se to sloučilo později) a Hibernate, který byl docela dobrý. Pokud bych to sečetl, tak dva roky jsme ztratili objevováním standardů. Dva roky! Výsledkem bylo také, že jsme zavrhli EJB, protože to bylo složité.

## Prezentační vrstva

### JSP
Je pěkný, že člověk si vyřeší jednu část a teď musí vyřešit další. Z PHP jsme byli zvyklí mít HTML kód, dát do něj PHP značky a fungovalo to. Pak jsme jako první zkusili JSP, co bylo docela jednoduché a hezké. Později jsme přišli na to, že samotné JSP spíš ne, a že existují knihovny tagů JSTL. Sun měl standardní tagy, které přidali trochu složitosti, ale pořád se to dalo používat. Tagy pro iterace atd., to ještě relativně šlo. 

Pak jsme se naučili JSP, JSTL a co dál? 

### JSF
Přišlo JSF a řeklo se: *„JSTL je mrtvý, ale to JSF! To je ten standard, to je ta pravá věc!“* Zkoušeli jsme JSF ve verzi 1.0 a 1.1… a Sunu doteď nezapomenu, co udělal s JSF. Byla to nejpříšernější věc, co jsem snad viděl. Když jste to chtěli používat na tutoriály, bylo to dobrý, všechno fungovalo, dělali ste „Ahoj světy“, které krásně jeli. Pokud jste však měli psát složitější aplikaci, dát do toho třeba AJAX, nebo si tam pustit nějaké knihovny a trochu si s tím hrát, případně to HTML trochu ohnout, bylo to hrozné. Udělat v JSF 1.0/1.1 vlastní tag… pamatuji si, že dva týdny jsem po webu hledal, jak si mám ten vlastní tag udělat. To prostě nešlo. Tag hackeři od Sunu měli upoutávky, jak se to dělá, ale přidat to tam bylo hrozný. Pro nás byl standard jako takový zklamáním. Zopakuji, že ze začátku jsme si říkali, že pokud se budeme držet standardu, tak to bude všechno krásné a veselé, ale nás to zklamalo. 

### Stripes
Byl tam další pokus o odlehčení. Narazili jsme na Stripes, co je framework pro webové aplikace v Javě. Pokud jste znali Javu a JSP/JSTL, tak jste se Stripes naučili za jedinej den! Ne dva, ne tři měsíce, jeden den! To byla neuvěřitelně jednoduchá záležitost. Udělali jste si HTML, udělali jste si kontrolér a rovnou v URL, kterou jste volali, se to namapovalo na metody javovské třídy. V té době jsem rozhodoval o dlouhodobém projektu pro klienta, kde šlo i investici v desítkách miliónů korun a do Stripes jsem neměl odvahu jít. Při tom zkoušení jsme narazili na pár věcí, které jsme nevěděli udělat a ta komunita byla malá. Dnes jsou Stripes někde jinde, ale když jsme přišli na chybu, kterou jsme reportovali, čekali jsme na odpověď dva týdny. Pak si řekneme *„Co když to budeme mít v produkci, a přijdeme na chybu, o které se s námi nik nebude bavit kvůli malé komunitě?“*
Doteď si myslím, že nejde o to, kolik lidí píše framework, ale jak důležitá je komunita, která to drží. Pokud to používá víc vývojářů, bude tam feedback, budou tam požadavky na změny a na vývojáře bude vyvíjený neustále tlak, aby ho opravovali, aby se o tom bavili, a později můžou otěže vývoje předat někomu dalšímu. Stripes to však v té době neměly.

### Wicket
Potom jsem narazil na Apache Wicket, podle mého názoru až do současných dob to nejlepší pro tvorbu webaplikací, co jsem kdy v Javě viděl. Měl jsem o tom přednášku, tuším 2 roky zpátky a můžete si ji stáhnut z mého webu hradil.cz. Jsou tam slajdy včetně zdrojáků. Bylo to dobrý a líbilo se mi to. Kdybych teď měl začínat vývoj webového řešení pro Javu, tak sáhnu pro Wicket. Muselo se to pořád kompilovat, ale to nebyl problém Wicketu než Javy a se šablonama to bylo velmi pěkné. 

Teď už rok v Javě web nedělám, takže dnes to už určitě bude někde jinde. Kdybych to vybíral před rokem nebo i teď, tak bych sáhnul po něčem, co znám a byl by to právě Wicket. 

### Špagety a Spring
Jak vzít všechny frameworky a spojit jich dohromady? Jak je provázat? Narazil jsem na Spring. Spočátku to vypadalo tak, že Spring vyřeší všechny věci. Nemuseli se psát DAO, použili se jejich a spousta věcí se vyřešila za vás. 

Jenomže Spring je složitý a těžký. Musíte si vybrat, co v tom chcete dělat. Mají transakce, MVC, těch modulů je hafo a než se člověk dopracuje k tomu, co vlastně potřebuje a čím si může zjednodušit život, tak nad tím stráví hafo času. Třeba Spring transakce jsem na webu nebo v diskusi opisoval jako odstrašující příklad toho, jak složitost může růst. Vysvětlení transakcí ve Springu je příšerný. Vývojář musí číst o různých proxy, třídách, o tom, jak se to implementuje. A přitom to jediné, co chce, je řídit si transakce sám, ať mě to pustí. Commit, rollback, hotovo. Ale ve Springu to musíte obalovat a dávat tam anotace. Je tam také pár špeků: když dáte anotace a zavoláte metodu, které má vlastní transakční anotace, tak si musíte dávat pozor, kde se to zavolá, kde se to kříží, což je hrozně těžký. 

Nepochybuji o tom, že ten, kdo to zná a strávil nad řešením těchto věcí měsíce, roky a je v tom zaběhaný, tak to zná. Pokud sem přijal nového vývojáře, který znal jenom Javu v smyslu základů objektového jazyka, a já jsem mu měl vysvětlit, jak má používat Spring, aby to všechno provázal do webových aplikací, bylo to strašně obtížné. Ovládnutí Springu bylo pro mě typicky na několik měsíců. 

### Logování
Pak jsou podružné věci jako logování, sestavení atd. Musíte si vybrat, čím chcete logovat. Myslím si, že postupně se to vyvinulo ve standart log4j. V sestavení jsme používali Apache Ant, co byla krása a udělali jsme v tom všechno. Zase šlo o psaní XML, na spoustu věcí jsou měli připravené tasky, ale zkuste si z toho vybrat, co potřebujete. Než na to člověk přijde, než Ant nastuduje, opět hafo času. 

### Maven
Dále Maven: před rokem, když jsem ho opouštěl, vypadal, že je dobrý. Maven 2 se mi už docela líbil, samo si to řešilo závislosti, ale nelíbilo se mi zase XML. Samozřejmě, že se to dá rozdělit: můžete mít hlavní XML, pak podřízené XML. Máte však stovky řádků k tomu, abyste vyřešili, jaké to má mít závislosti. Občas byly závislosti dané projektem, jenže když jste začali používat hafo různých věcí, pak se to začalo křížit a tyhle věci se zase stali složitými. Nicméně to nebylo až tak složité jako věci, o kterých jsem mluvil předtím. Myslím si, že Maven 2 je v Javě cesta, pokud není něco nového, o čem budete vědet víc vy. 

### Další věci
A další věci: databáze, testování, nepřetržitá integrace… to se jednoduše musí zvládnout. Pokud chcete zvládnout projekt od začátku do konce, musíte nepřetržitě integrovat. Musíte velmi dobře rozumět SQL, na kterém to všechno stojí a padá, což je bez diskuse. 
Nabízím tedy finální kombinaci, která mě stále spoustu peněz, než se to vyladilo, a než jsme viděli, co z toho používat. Používali jsme Hibernate EntityManager jako implementaci JPA pro persistenci. Pro fulltext jsme použili Hibernate Search, na project management a závislosti jsme použili Maven; Wicket jako prezentační vrstvu, Spring 2.5.5 jako lepidlo, kterým jsme to všechno dali dohromady a PostgreSQL jako relační databázi.

### Náklady časové a finanční

Ovládnutí pro nového člověka, kterého jsem přijmul, trvalo rok studia - pokud existuje někdo, kdo řekne, co máte studovat. Přijmul jsem nového člověka a řekl jsem mu: tady máš hromádku knih, kterou musíš zvládnut. Trvalo mu typicky rok, než se to všechno naučil a než to všechno vstřebal a byl schopen psát aplikace, které my píšeme. My nepíšeme triviální softvéry, ale softvéry pro pojišťovací makléry, kde je spousta věcí relativně složitých. V investici na hlavu je to asi půl milionu a to nepočítám náklady ušlé příležitosti, kde to člověk studuje namísto toho, aby pracoval. Když máte čtyřčlenný tím, potřebujete jej něco naučit, aby byl produktivní a aby vydělával peníze, já říkám, že tady s tím to trvalo rok – rok a půl milionu na hlavu.

## Ruby on Rails
Než se pustím do Railsů: jaké jsou požadavky na softvérový vývoj? Musí být rychle uveditelný na trh. Aplikace se dnes nepíšou měsíce. Pokud potřebujete něco psát pro klienta, ten vám řekne, co potřebuje teď; ne za několik měsíců a nedejbože let. Musíte to dělat rychle. Dále se musí zmenšit bariéry vstupu na trh: přijde absolvent, má pro vás psát, musíte ho něco naučit, musí to být co nejkratší. Musí to mít minimum školení. Nový programátor musí být efektivní co nejdříve. Ono se to pěkně říká, víme, že to tak v praxi není, ale ta doba musí být co nejkratší. 

Agilní vývoj vládne světu – to je jasné. Nelze předvídat budoucnost, externí faktory a prostředí, ve kterém se pohybujeme a ve kterém píšeme softvér, se mění. Mění se legislativa, mění se požadavky od klienta. Agilní vývoj je komplikované označení pro schopnost řešit požadavek, které nastane zítra. Nevíte, co se změnit – máte jednání s klientem, dohodnete si funkcionalitu a on zítra zavolá, že to je všechno jinak - to se nám typicky stávalo. To není chyba klienta, ale takový je svět, je rychlý a vy taky musíte reagovat rychle. Udržet se naživu můžete jen, když jste rychlý a efektivní a okamžitě reagovat. Musíte dělat nepřetržitý deployment. Žádný dlouhosáhlé testovaní – my třeba máme release každej večer. Máme nástroje na rychlý rollback – občas něco pokazíme, ale klient do tohoto rizika jde. Uděláme release a klient si to prokliká a řekne: ano, může to jet do produkce anebo ne, musíte udělat rollback, ale musí to jít rychle. 

Když jsme si to dali dohromady, tak mi z toho vyplynulo, že Java pro web je pro agilní vývoj nevhodná… minimálně v prostředí, kde jsme to dělali my; minimálně nevhodná pro vývoj v naší firmě. 
Co jsme s tím dělali? V té době jsem narazil na Ruby on Rails. To bylo jako osvícení: spoustu let jsme uvažovali, jak to dělat efektivnější, rychlejší. Neustále jsem něco studoval, zkoušel jsem, něco jsem použil a staré pak zahodil a řekl jsem si, že „teď to půjde lépe a radostněji“. 

Ruby on Rails sem ovládnul do úrovně, v které jsem psal webové aplikace, asi za měsíc. Ruby jako jazyk se ukázal mnohem jednodušší než Java. Největší výhodou, ke které se ještě dostanu, byla komplet infrastruktura. Vy ste nic jiného nepotřebovali. To bylo něco, co bylo neuvěřitelný. Nainstalovali jste Rails a mohli jste psát webové aplikace od začátku do konce – se vším. Měli jste vyřešenou perzistenci, web, logování, testováni – všechny najednou. Žádné „tady to všechno nastudovat a pak to slepit Springama“. Všechno v kostce, vzali jste a použili. 

Než se dostanu k ukážce praktické, ukážu verze, na kterých to budu prezentovat. Bude to Ruby 1.8.7, Rails 2.3.11 (aktuální je 3.0.4). Rails 3.x to dále zjednodušuje, ale pro tuto prezentaci to není důležitý. Upozorním jenom na CZ Podcast 45, v kterém je velmi pěkně řečeno, v čem se liší Rails 2.x od Rails 3.x.  Pokud máte zájem, poslechněte si to, mně se to líbilo a je to dobré. Použitá databáze je PostgreSQL 8.4.4. Máme Postgre moc rádi a používáme ho mnoho let a není důvod používat nějakou jinou databázi.

Rails je nástroj – nemám rád slovo „framework“, protože to všechno je přeframeworkované, že používam raději nástroj – je to nástroj pro psaní webových aplikací. Je to „gem“, t. j balíček pro Ruby. Ruby má pro správu svých rozšíření balíčkovací nástroj Gem a Rails je jenom gem pro ruby. Komplet instalace a spuštění máte tady [na slajdu 12]. Instalujete Rails, dáte „rails projekt“, nastartujete server a máte hotovo z hlediska počáteční inicializace. Za chvilku to ukážu.
Proč Ruby on Rails? Především proto, že používa Ruby, což je objektový jazyk, který je *objektový*. Ne jako Java, která je objektová, ale má primitivní typy. Ruby je fakt objektový – čísla jsou objekty, stringy jsou samozřejmě taky objekty (to v Javě taky, ale jsou nějaké pseudostringy a podobné věci), neexistují přimitívní typy. Pokud potřebujete iterovat, tak se s tím pracuje mnohem lépe. 

Má to dynamické datové typy… co vede k dvěma množinám vývojářů. Jedni říkají, že statické typovaní (jako v Javě) je jediné to pravé, musíte deklarovat typ proměnné a pak vám to zachytí kompilátor apod. Druhá část, například my, kdo jsme přišli z PHP, jsme byli zvyklí na to, že jsme něco napsali a ono to nějak poznalo, co to je a fungovalo to.
Ruby je interpretovaný, co je největší výhoda. V Javě změníte třídu, musíte ji překompilovat do .class, musíte redeploynout. Jsou nástroje jako JavaRebel, které říkají, že část redeploye můžete zkrátit, ale tady změníte soubor, dáte [v prohlížeči] Refresh, spustíte to znovu a hned to funguje. Je to jako PHP.

Open classes znamená, že můžete např. vzít Ruby string a přepsat rovnou implementaci metody v tříde, nebo přidat novou, nebo si nějakou odeberete. S třídami pracujete, protože jsou otevřené – pokud potřebujete třeba rozšířit string o nějaký DSL (doménově specifický jazyk), a potřebujete přidat věci, které v něm nejsou, tak si jednoduše místo dědení od Stringu a řešení, co všechno máte překrýt, ho jednoduše otevřete a přidáte metody, které budete v stringu používat a je to. 

Ruby je stavěná pro lidi a nikoli pro rychlost. Rychlost je strašně přeceňovaná věc. Čtu různé konference, kde se uvádí, že Ruby je pomalé apod. Ve finále je však úplně jedno, jestli to iteruje pětkrát pomaleji než v Javě. Vývoj přece není o tom, jak rychle procházíte pole. Ono to může mít dopad na projekt, který píšete, ale jediný způsob, jak to zistit, je udělat si aplikaci a benchmark a zjistit, zda-li to zvládá nebo ne. Když to nezvládá, tak přidám další servery a raději to naškáluji hardvérově, než aby to škáloval uvnitř softvérově, protože to je drahé. Cílem v Ruby je psát jednoduchý a čitelný kód.

## Rake
Rake je task management tool – můžete si to představit jako Ant. Syntaxe Rake je v Ruby. Řešíte tím obsluhu databáze, spouštění testů, generovaní dokumentace, logování, cache a její mazání, mazání sessions. Z toho, co znáte, je to nejpodobnější Antu, akurát s tím, že píšete v Ruby.

## Migrace
V Javě nás trápilo, když máme aplikaci nasazenou v produkci a potřebujeme změnit schéma v SQL databázi. Typicky uděláte patch, a musíte řešit, jak ho distribuovat. V Rails existují tzv. migrace, což je verzovaný přechod databáze od jedného stavu k druhému. Stav databáze má automaticky svoje časové razítko. V migracích jedete dopředu nebo dozadu, což ukážu. V rámci migrace můžete měnit nejenom schéma, ale i data v tabulkách, které jsou také verzované. To, že můžete jít dopředu nebo dozadu je dobré v tom, že když uděláte deploy na produkční server a ten nefunguje, tak i když jste změnili stav databáze, máte k dispozici migraci, která má „up“ nebo „down“ a vy můžete dát „down“ a napsat si ho tak, aby vám vrátil databázi do původního stavu. Všechno standardizovaně, nemusíte tam mít skripty, nemusíte to řešit hromadně a máte to tam uložené, což je super.
Další z důvodů pro Ruby on Rails: scaffolding, t. j. lešení – ideální na prototypování. Ukážete klientovi základ v řádu minut či hodin. Napíšete jenom název třídy, kterou chcete generovat, napíšete atributy, datový typ a všechno se vám vygeneruje. Vygenerují se skripty pro vytvoření tabulek v databázi, vytvoří se kontrolér, model, view, migrace, testy, uvidíte. Příkazem „generate scaffold“ se generuje scaffold, já ho potom mám v praktických ukázkách. 
Nejdůležitější věcí nebo věcí, která se mi nejvíc líbí na Ruby on Rails, je ActiveRecord, tedy ORM používaný v Rails. Dělá se to přes konvence před konfigurací. Pokud do toho moc nerýpáte a zvykněte si na to, co Rails dělají, tak je to něco neuvěřitelné v porovnání třeba s Hibernate, co se týče fungování ORM. Třeba chcete generovat model Contact – automaticky se vytvoří tabulka Contacts. Udělá vám kontroler ContactsControler, udělá vám testy a vy se o to víc nemusíte starat. Vezme Contact, převede to na množné číslo, dodržuje to konvence, je to parádní. V ActiveRecord odpadá dvojí deklarace, kde máte typicky schéma v databázi, pak v Javě máte bean s gettery/settery, a musíte vědět, že co upravíte v databázi, tak musíte reflektovat v javovské třídě; musíte přidat gettery/settery anebo někde externě dát mapovaní ze schématu přes XML do javovské třídy, co v Rails neděláte. 
Jsou tam dynamické findery – to se vám bude moc líbit. Měl sem sérii článků o ActiveRecord na hradil.cz nebo hradil.org. Určitě se podívejte, v čem konkrétně se mi to líbilo. Teď mám tady praktickou ukázku, kde ukážu projekt od počátku inicializace s tím, že ukážu, jak v tom fungují základy. 

*[ demo ]*

Je tam příkaz „rails“, název projektu udělám „abook“, čili AddressBook, dále řeknu databázi, kterou má použít, tedy PostgreSQL. Vytvoří mi standartní adresářovou strukturu, kterou si otevřu v NetBeans. Vidíte třeba, že pro vývoj používam NetBeans, kde je podpora Ruby, co je pěkný. Teď to v NetBeans krouhli, pak zase přidali. Nevím, jaký bude budoucí stav, ale NetBeans jsou na to docela dobrý, doporučuju. 

*[nesrozumitelně z publika]*

Mají málo použivatelů? No jo, co se dá dělat… 

*[nesrozumitelně z publika]*

Když nebudou NetBeans, nemusíte brečet. Jsou i jiná prostředí, můžete používat cokoli dalšího. Nevážete se na NetBeans.

Tady jsou adresáře, které mi to vytvořilo. Máme tady adresáře s modely, kontroléry a s view. Teď jsou prázdné. Teď se v konfiguraci zmíním o připojení k databázi. Mám tady soubor database.yml a vidíme, že Rails používají tři vývojové kontexty:  development, test a production. Na každý kontext používají samostatnou databázi. To je dobré, protože máte databázi na vývoj a jednu databázi na test. Tady zmínim jméno uživatele, kterým se to bude přihlašovat k databázi. Mám lokální databázi a nechám tady PostgreSQL.  

Teď se přepnu do adresáře s projektem a vytvořím databázi přes „rake“, což je něco jako Ant. Dám „rake db create“ a vytvořila se testovací databáze. Je prázdná, nejsou tam žádné tabulky. On tedy udělal „create database“ přes PostgreSQL a všechno to vytvořil. 

### Webový server

Nastartuju webový server, který se používá pro vývoj v Rails. Je dobré, že přes příkaz „rails“ se vygenerovala struktura včetně adresáře „script“, ve kterým jsou různé obslužné skripty. Jeden z těch obslužných skriptů je „server“, který můžete spustit, a nastartuje se HTTP server na portu 3000 pro aplikaci, kterou vyvíjíte. Je tady obrovská výhoda, že když máte víc projektů, nemusíte řešit, že máte někde na locale nainstalovaný Tomcat nebo Jetty a musíte v něm střídat WARka, které v něm máte. Pro každý projekt máte samostatný webovský server, který je součástí vygenerované aplikace a je to všechno zvlášť. Nastartoval sem webový server a tady se říká, že jedete v Rails a co máte dělat dál. 

### Scaffolding
Ukážu scaffolding: z adresáře `script` použiju příkaz „generate scaffold“, kde scaffold znamená lešení a řeknu, že chci vyvíjet Contact, nebo chci přidat Contact. Je to model, ktorý přidávám. Řeknu, že Contact má jméno, které je [typu] string. Potřebuje ho ne proto, že by to nepoznal, ale proto, aby věděl, jaký datový typ má vytvořit v databázi. Dále tam dám poznámku, což je [typu] text. „contact name:string note:text“. Nyní se děje spousta věcí a generuje se spousta souborů. 

Ukážu vám, co se vygenerovalo. Jak jsem říkal, je to MVC a vygeneroval se v kontrolérech ContactsControler. Všimněte si název kontroléru (ten jsem nezadal!). Řekl jsem „Contact“, vygeneroval se „ContactsController“. V modelech mi vygeneroval Contact, ve view mi vygeneroval adresář Contacts a v něm 4 soubory: edit, index, new a show. Vygeneroval mi CRUD pro celou aplikaci a tady jsou součásti pro web, resp. CRUD. 

### Migrace
Nejdůležitější věc, která tam je: v podadresáři „migrate“ mi vygeneroval migraci, tedy změnu stavu databáze. Použil jsem Contact a on udělal CREATE CONTACTS, protože jsem použil scaffolding, tak jsem chtěl použit Contact. Udělal tady dvě metody „up“ a „down“. Metoda „up“, čili změna z jednoho stavu do druhého, hovoří, ať se vytvoří tabulka CONTACTS s datovými typy: STRING je „name“, „TEXT“ je note. Ještě je tady výchozí timestamp, o tom ještě řeknu, co to je. Dále je tady „down“ v případě, že chci migraci zvrátit a řekne mi, že chci DROPnout tabulku kontaktů. Teď udělám „rake db migrate“ a RoR vytvoří tabulku v databázi. Když se podíváme, máme tady tabulku CONTACTS. Do tabulky SCHEMA_MIGRATIONS ukládá verzované čísla timestampů, kde šel přes migrace nahoru nebo dolů. Podíváme se do CONTACTS a vidíme, že máme tady „name“ a STRING namapovaný na VARCHAR(255), dále NOTE namapovaný na TEXT. Na začátku je ID INTEGER jako primární klíč s automatickou sekvencí v PostgreSQL. Tady je standard Rails: já jsem nikdy neřekl, že chci generovat ID, jenom jsem řekl, že chci Contact a Rails si řekl, že si tam dodá ID a bude tam zdvíhající se sekvence. Dá se to změnit, když například potřebujete složené klíče, dá se to v migraci změnit. Můžete se s tím hrát, ale v 99% případů vám jednoduché ID stačí. 

Jsou tady ještě timestampy: created_at, updated_at, které se používají při tvoření záznamu, když v tabulce najde sloupečky s tímhle jménem a datovým typem, tak je automaticky vyplňuje s časem, kdy byl záznam vytvořen a kdy byl automaticky změněný. Teď, když jsem to migroval, můžu tady bez toho, abych cokoliv redeployoval [v prohlížeči] „/contacts“ a mám tady zavolaný index kontaktů. Můžu si zakládat nový kontakt a mám tady hotové formuláře. To jsem nedělal já, všechny formuláře mi udělal scaffold. Dám „create“, mám tady „zpět“, můžete se podívat na detail, můžete to upravit. Můžete to smazat a tady máte dokonce JavaScript, který se vás zeptá, jestli to skutečně chcete smazat. Tady se strašně dobře píšou prototypy: můžete mít model, ve kterém naskládáte deset atributů, řekněte, že datový typ je „date“ a on vám udělá javascriptový výběr datumu, kde si to rozklikněte a zvolíte datum namísto toho, aby jste ho museli psát ručně. To tam všechno standartně je. 

### Kontroléry
Podívám se ještě na ten kontrolér, abyste viděli provázaní, které tam je. Tady je vygenerovaný kontrolér a vidíme, že při výchozím volání, pokud dám „/contacts“, kde se vylistují kontakty, tak to jde do kontroléru, do metody „index“ a tady mi řekne, ať si do lokální proměnné načte všechny kontakty, a pak vyhodí response. Je to automaticky provázaný; pokud máte metodu „index“, tak potom (když mu neřeknete, že má vygenerovat jinou stránku) jde do views, do podadresáře „contacts“ a tam se automaticky napojí na index.html.erb. ERB znamená „embedded Ruby“, t. j. HTML s vloženými Ruby příkazmi. Pro ten „index“ máme „contacts“, najde všechny kontakty. V indexu je iterace přes všechny kontakty: contacts.each čili každý z kontaktů uloží do proměnné contact a je tady „date“ na výpis, co máte možnost vidět. 

### Logování

Přidám ještě jeden kontakt, aby bylo co ukazovat. Je dobrý, že pokud v jednom terminálu nastartujete webový server, tak automaticky při requestu vypisuje, co přesně dělá a nemusíte to nijak zapínat. Vím, že jsme nějakou dobu bojovali s Hibernate, aby vypisoval, co pouští do databáze, co se děje. Přes log4j jsme říkali, že se na to má napojit a že to má vypisovat. Tady to funguje hned a vidíte, že nejprve generuje SQL, potom zpracovává metodu index() v ContactsController, pro kterou IP adresu kdy co hodil (v tomhle případě GET). Potom nahrál kontakty a vypisuje se přímo to, co se pustilo do databáze. Žádný ORM, který je stejný pro všechny databáze. Použili jste jednu databázi, a bude se vám vypisovat syntaxi třeba Oracle nebo MySql, co se samozřejmě může lišit. Ideální pro debugování – když máte stránky a potřebujete vědet, co se na databázi posílá, nemusíte dělat vůbec nic. Podíváte se na výstup a je to. 

Dám třeba „/show“ a řekne mi to, že zavolá „SELECT * FROM CONTACTS WHERE contact_id = 1“. Dám „/update“ a něco v tom změním. Rails jsou chytrý. Pokud děláte editaci objektu, podívá se, co se změnilo a UPDATE do databáze pustí pouze tehdy, pokud se v tom skutečně něco změnilo. Pokud dám rovnou uložit, tedy kliknu „update“, vidíte, že udělá begin() a udělá commit() transakce, ale mezi tím není žádný UPDATE. Když něco skutečně změním a dám „update“, pak pozná, že se změnili atributy a máme ten slavný UPDATE, kterým to vytvořilo. Vidíte, že on automaticky aktualizuje [sloupec] „updated_at“ – ne proto, že bych mu to řekl, ale proto, že ten sloupeček tam prostě je v databázi a on ho tam automaticky dá. 

### Modely
Teď pěkná část – podívám se do modelu kontaktu a to je ono: žádné properties, žádné gettery, žádné settery. Odkud to bere? Krásná věc!  Bere to ze schématu databáze. V okamžiku, když potřebujete přidat atribut pod kontakt, třeba datum, tak to změníte pouze migrací v databázi. Migrace nemusíte používat – měli byste, ale nemusíte. Můžete se rovnou přes konzolu databáze připojit, změnit to schéma, dáte „refresh“ a on se vždy podívá do schématu databáze, zjistí, že se schéma změnilo, refreshne to a nemusíte psát žádné gettery, žádne settery. Bere to ze schématu databáze a automaticky to mapuje. Tohle to je super věc.

*[nesrozumitelně z publika]*

Stane se, že on po requestu zkusí ten objekt namapovat do databáze a pokud tam nenajde ty zodpovídající sloupečky, tak si myslím, že to vyhodí výjimku. Tohle konkrétně jsem nezkoušel, můžete si to zkusit.

## Findery
Můžete se podívat - v Railsech mám perfektní věc, tzv. konzolu, což si můžete představit jako příkazový řádek nad vaším projektem. V Javě, když jsme měli projekt a měli jsme NetBeans nebo Eclipse a potřebovali jsme si vyzkoušet kousek kódu a to, jak se to volá do databáze, co se vrací atd., tak jsme si museli udělat klienta, který se na to připojil, a v metodě main() něco dělal. Dnes to snad jde už třeba jinak, nebo jsou nějaké nástroje, kde si můžete třeba přímo v Hibernate dotazy ladit. V Eclipse byl sandbox, kde jste si psali Javu a on to uvnitř zkompiloval a pak vypisoval, co to dělá. Ale tady to je výborná věc, a můžete to spustit nad každým z těch prostředí, které máte a v okamžiku, kdy máte aplikaci deploynutou do produkce a potřebujete na tom něco udělat, tak se rovnou připojíte na produkční konzolu a produkční databázi a můžete si hrát s vaší aplikací. 
Mám tady Contact a zavolám Contact.all, tak on se připojí do databáze a vrátí to pole všech kontaktů. Dále můžu dát Contact.find (tuhle metodu má myslím standardně i Hibernate) a vrátí mi to kontakt s konkrétním ID. Pokud použiju neexistující ID, tak samozřejmě vyhodí výnimku, čili žádný takový kontakt není. 

## Dynamické findery. 
Ukážu, že když se připojím do databáze a vy víte, že se jsou tady atributy „id“, „name“ a „note“. Teď pozor: nemusíte dělat žádnou fasádu jako v Javě. Kdybyste řekli, že potřebujete nějaký takový finder, v Javě se typicky dělala fasáda. Člověk udělal atribut a potom se musel rozhodnou, jaké udělat findery k tomu, co z databáze potřebuje tahat. Udělal find_by_id, findByName. ActiveRecord to dělá automaticky a sám. V okamžiku, kdy potřebuje udělat kontakt podle jména, dám findByXXX a použiju název atributu z databáze. Dám tady „jirka“ a zavolám to a on sparsuje tu metodu, která tam je přes Ruby. Ruby má zajímavou věc a to „method_missing“. Je to metoda, která se zavolá na objektu, pokud metoda, kterou voláte, neexistuje. Je to něco jako fallback – když dáte název nějaké neexistující metody, tak v Ruby je implementována metoda „method_missing“ a tam se můžete podívat, co bylo voláno. To používá právě ActiveRecord k tomu, že pokud to začíná „find_by“, tak on tam rozparsuje názvy atributů, které máte, a udělá volání do databáze a vrátí to a s tím nemusíte dělat vůbec nic. Ono to jde i spojovat: já můžu dát find_by_name_and_note a dám tady a, b, c, d a přidám ty atributy. Teď se dívejte, to je pěkné: můžete to dát v jakýmkoliv poradí, a nemusíte se o to vůbec starat. Prohodím to: note_and_name. Dám tady a, b, c, d a tohle zrušíme… já tam mám dvě uvozovky, pardón. 

Findery můžete libovolně kombinovat. Pokud přidáte atribut do databáze, tak automaticky získate finder ve všech možných kombinacích, které tam jsou. Tady to skutečně udržuje přehlednost modelu na maximum, protože nepřemýšlíte o tom, že existuje nějaká fasáda. Je to dynamické, používejte si to, jak chcete včetně všech atributů, které tam jsou. Můžu tam dát třeba i tohle… klíčové slovo pro spojování je „and“. Pozná to a podle toho v tom dokáže vyhledat. 
Samozřejme, že můžete objekt i měnit. Můžu tady dát proměnné a můžu si udělat „a.name =“ – opět, nemusím psát žádné gettery/settery, protože je to automatické. Dám „Miloš“ a dám „save“. Uloží mi to do databáze, podívám se do ní a vidím, že to mám změněno i v databázi. Ideální, když potřebuji něco rychle změnit i v produkci. Je to dobrý, připojíte se… a konzola je dobrá i v tom, že vám k databázi přistupuje přes ovladač, který tam máte. [nesrozumitelné] Pokud použijete tuhle konzolu, tak když Rails ví, že mají jít s Oraclem, tak s ním pracují způsobem, kdy generuje odpovídající syntaxi podle databáze, kterou používáte. To SQL vypadá v některých případech jinak pro MySQL, jinak pro Oracle atd. 

## Testování
Když jsem vygeneroval scaffolding, v Railsech je už od začátku kladen velký důraz na testování. V okamžiku, kdy  máte projekt, který není staticky [typovaný]… nebo používá Ruby (které není staticky typované), tak Rails komunita říká, že to dohání testami. Dobře, není to staticky typované, nemáte kontrolu typů, je to interpretované atd., tak budete psát testy. Spousta lidí říká, že v Railsech musíte mít aplikaci pokrytou testama víc než na 90% a to je dobře, že na to tlačí, to je výborná věc. 

Když se podívaté, já jsem vygeneroval scaffolding a v adresáři „test“ udělal… tady máme nějaké standardní adresáře. V Rails jsou 3 druhy testů: jednotkový (unit), funkcionální (testy kontrolérů) a integrační (test přes více kontrolérů, typicky procházení aplikací; voláte více různých požadavků přes různé kontrolery). On vám tady v „test/unit“ vygeneroval ContactTest. Samozřejme on vám tu linku nenapíše. Tady vygeneroval test, který je vždycky pravdivý. Pojmenuji si to jako název kontaktu a [dále] si to pojmenuju jako assert_equal, čím řeknu, že chci testovat string… a teď pozor… teď něco napíšu a pak vám to vysvětlím. 

### Kontexty
Jakým způsobem se dostávají do Rails testovací data? Na začátku jsem říkal, že máte 3 kontexty, v kterých vám aplikace beží. Development pro vývoj, test a production. Production teď není důležitý, to je pro produkční data. Nás teď zajímá ten „test“. Tam máte databázi, která se jmenuje [názevprojektu]_test – v tomhle případe abook_test. On ji používá pro testování, čili: máte vývojovou databázi, kde si děláte, co chcete a potom máte bokem testovací databázi, která slouží jenom pro spouštění testů. Tady to jsme řešili typicky v Javě, že člověk, když chtěl pouštět jednotkové testy a neměl to nějak mockované, tak to pouštěl vůči té vývojové databázi. V tom případě si ale musel dávat pozor, když pustí testy, a něco tam změní, tak třeba musel pak DROPnout schéma a založit nové. To ty Railsy v tomhle případě dělají samy. 

### Fixtures
Ale odkud ty Rails berou testovací data? Kde jsou ty data, které se dají do testovací databáze? Rails používají tzv. fixtures, což je podadresář pod „test/files“ a tam my opět scaffolding vytvořil Contacts.yml. YML je formát pro serializaci dat, který používají Rails. YML není věc, která je závislá na Rails, to je projekt, který je bokem, ale Railsy to používají proto, že je to dobré. Tady to je, dá se říct, odpověď na XML. Nemáte tady žádnou sémantiku a podobné věci, ale je tady řečeno, že mi vytvořil do testovací databáze dva kontakty: jeden se jmenuje „one“ a druhý se jmenuje „two“ (tak neví, jak to má naplnit, když je to kontakt a pomenoval to univerzálně). Prvý, „one“ má jméno…viděl, že je to string, tak tam dal „mystring“, potom vědel, že „note“ je [typu] text, tak tam dal „mytext“. 

Když chcete něco otestovat, tak zavoláte Contacts, což je metoda, která se používá při tom testováni a která říká „jdi do fixtures pro kontakty“ (on to má provázano přes konvenci a ví, že to má načíst Contacts.yml), „tady použi klíč „one“ a z toho mi vezmi „name“. Udělal instanci objektu Contact, z toho zavolal „name“ a potom pustím testy… opět přes rake. Je to standardizované, nemáte nic, kde by jste spoustu věci spouštěli jinak. Při prvním spuštění se podívá a řekne si „aha, tam žádná databáze test není“, tak ji vytvoří, a udělá tabulky, které tam chybí. Co je dobré, je, že to jede v transakci. Na konci, když ty testy dojede, tak tu databázi vrátí do konzistentního stavu. Když v testech přidáte kontakt, uberete atd., tak pro tu testovací databázi platí to, co je v fixtures. To je dobré a nemusíte se o to starat. 

Když budete testy psát hlouběji […] a když těch testů máte hodně, tak to abstraktní poměnování není dobré. Když víte, že to je Contact, tak je dobré i to testovací prostředí popsat příbehy. Abyste později vědeli, že co to je „one“ [nesrozumitelné]. [Raději] řeknu, že mám kontakt Jirka a kontakt Petr a když jsem to změnil, tak si to zavolám tak, aby sem věděl, že je tady dále Jirka. To je dobré, používat příběhy. Ty příběhy by měl dělat klient. Podle toho, jak se s klientem bavíte a on řekne „Přihlásil jsem se jako Petr, přidal jsem tam příkaz k úhradě, pak to Marta odeslala“ tak je dobré si dělat use-casy s tím, aby byly v porovnání s klientem, protože vám to pak hrozně zjednoduší následní debugování a tyhle ty věci. Když se bavíte v kontextu té aplikace, je to strašně důležitá věc. Pokud mám ten kontakt jenom jeden, je to v pohodě, ale pokud máte těch doménových tříd třeba 200 nebo 300 jako my, pak je dobré to popsat příběhy, protože to v hlavě neudržíte. Tady jsou testy jednotkové, pak máme testy funkcionální, tedy testy kontrolérů, které jsou taky předgenerované scaffoldingem. On mi pro ten CRUD udělal testy, které se používají už tak… testy to jsou testy kontrolérů, takže on řekne „zavolej mi GET na index, čekám response Success a otestuj mi, že přiřazení do proměnné contacts bude „not nil“. 

### Odbočka: nil

Oni nepoužívají null, oni používají nil. Jsou věci, které já nikdy nepochopím, proč tohle dělají. Když máte null, proč tam dají nil? Tady je nějaká perverzní snaha se odlišit nebo říct, že null byl 4 písmena a dvě „L“, tak oni dají nil. Tisíckrát jsem napsal, když jsem přešel z Javy, null. Nefunguje, v Ruby máte nil. Rozumíte někdo, proč to dělají? 

*[nesrozumitelně z publika]*

Nevím. Já doteď nevím, ale zavání mi to pankáčstvím, a možná i nějakou perverzí, protože to není normální. Nicméně, je to v pohodě. Kdybych měl specifikovat celé Rails, tak jsou o pankáčství. Je to vývoj webových aplikací pankáčským spůsobem. Předjedete všechny a řeknete „Hoši, proč to děláte? Máte Railsy, proč používáte Javu?“ Musíte být trochu pankáči.

### Integrační testy
Co se týče integračních testů: on vám samozřejmě žádný negeneruje. Když si potřebujete vygenerovat test, tak to děláte přes příkaz „generate“. Dáte „generate integration_test“ a napíšte si, jak má procházet aplikaci a co má dělat. Scaffold tohle nedělá, protože se říká, resp. teorie o testování říká, že 90% testů mají být jednotkové, zbytek funkcionální a integrační. Ten core, který to testuje, jsou právě jednotkové testy. Samozřejmě, můžete říct, že integrační testy se u nás nepoužívají. Ten zápis, nebo ty metody v těch integračních testech jsou podobné jako tohle to. Můžete říct, že používáte Selenium… používali jste ho dřív, používate ho i teď. Klidně, pohoda, můžete.

… fixtures jsem vám ukázal, YML taky…

U téhle ukázky bych se zastavil, protože čas máme omezený. Neberte to jako vyčerpávající úvod do Rails, ale jenom jako chuťovka, aby jste věděli, že to jde. Nečekám, že odpovím všechny otázky, ale čekám, že řeknete „sakra, co když ten Hradil měl pravdu“ a co kdybych se na to podíval. To je přesně ten pocit, který chci, aby jste si z toho odnesli. 

## Projekty a podporní nástroje

### Capistrano
Teď se budu bavit ještě o věcech, které se týkají projektu, které potřebujete řešit. Jedna je deploy na serveri. V Rails se obecně používá, nebo de facto standardem je nástroj Capistrano. Je to taky gem, čili rozšíření. Na všechny servery, které máte v clusteru, si dáte uživatele pod stejným přihlašovacím jménem a heslem nebo klíčem. Pak řeknete Capistranu „udělej deploy“ a on se tam připojí. Když máte cluster 20 serverů, tak se připojí na každý z nich a automaticky deployne aplikaci. Nemusíte se o to starat. Máte stejné prostředí a on to udělá na všech najednou. Nemusíte řešit, že máte WAR pro jeden, WAR pro druhý, třetí, a člověk se uklikne, vynechá jeden node z clusteru a pak jeden z 20 requestů spadne a nevíme proč… a pak mi někdo řekne „aha, tak jsem to deploynul trochu blbě“. Já si myslím, že v Javě to taky lze nějak vyřešit, dělám si srandu. Tady se to dělá přes Capistrano. Není to však nástroj jenom pro deploy. 

Jedna z částí Capistrana je, že se dá používat pro deploy, ale můžete s tím dělat cokoliv. Můžete tím pouštět na dálku migrace, můžete startovat skripty, posílat maily, můžete tam dát stránku, že momentálně probíhá údržba, ale zachvilku to už bude dobré. Tasky do Capistrana se píšou v Ruby a potom to typicky vypadá tak, že zadáte „cap“, tedy příkaz pro Capistrano a zadáte „cap [názevaplikace] deploy“. Připravil jsem si tady ukázkovej skript, aby jste viděli, jak je krátký.

Tohle je nástroj pro Capistrano, který mi nastaví název aplikace a řekne, kde je repository. To je důležitý, protože řeknete Capistranu… deploy děláte z vývojářského notebooku, který má přístup přes SSH na všechny servery, kam děláte deploy. Řeknete mu, že každý server se má připojit na repository, odkud má tahat zdrojáky. Tady se připojuji přes SSH na server, kde beží Git, tady mám název repository, a branch a mám tady udělaný task s názvem projektu a mám tady řečeno servery, které fungují jako proxy servující statický obsah, potom IP na aplikační a databázový server a řeknu, pod kterým použivatelem a kam to mám deployovat. Tady do „/home/abook“. Potom když chci deployovat, napíšu jenom tohle, dám Enter a on automaticky na všechny servery, pro které jsem zadal IP adresy, do adresáře „/home/abook“ skopíruje celou adresářovou strukturu, kterou jste viděl,i a provede vzdálený restart. Nemusíte se o to starat. 

Pomocí tohoto nástroje můžete udělat i rollback. Můžete dát „cap [názevprojektu] rollback“. Použijte standardní tasky nebo si napište svoje. Je tady definováno, co má udělat rollback. Má poslat omluvný mail? Vyčistit logy, pustit migraci směrem dolů… můžete si s tím hrát, je to docela jednoduchý. Ta analogie je opravdu dobrá. Rake a Capistrano dohromady dává spojení jako s Antem… nebo analogie, která tam je, je neblíž asi Antu, jak to chápou javisti, nebo jak to chápu já, když jsem přišel z Javy.

## Škálování
Co se týče aplikačních serverů…. Tam se ještě dostanu. Ještě předtím mám škálování. Co je škálování? V Rails škálování funguje. Jsou nějaké otázky? Prostě funguje to. Jak to funguje? Aplikační servery nebo všechny clustery o sobě nevědí. Tam je „share nothing“. Před servery dáte balancer – apache, nginx – a on to střídá na jednotlivé servery. Pokročilé balancery to umí podle zátěže, ale to my nepoužíváme. 
Sessions ukládáte do databáze, takže v okamžiku, kdy se připojíte na některý ze serverů, tak použivatele pozná podle session. Ukládá se to do tabulek sessions, které jsou v databázi. Rails to umožňují ukládat do cookie, ale standardem od nějaké verze je ukládat to do databáze. 
Zdílení [nesrozumitelné] dvaceti [nesrozumitelné] v clusteru. Každý server generuje nějakej log a my to děláme standarně přes linuxový rsys log, kde každému serveru řeknu, kde je logovací server a posílají do něj přes rsys log. My to neřešíme… místo toho, aby jsme přemýšleli, kdy bude nějaký Ruby nástroj na posílání logů – to je taková perverze, která je zachována v Javě, že na všechno je framework, který tam musíte honem integrovat – tak tady je lepší používat to, co funguje a když existuje externí nástroj, proč ho nepoužít. 

## Relační databáze
Jediné slabé místo, což je u všech webových aplikací, a přijdete na to, je co? Relační databáze. Vždycky. Úplně jedno, co používáte… Javu, PHP, Ruby atd. Vždycky bude tím slabým místem databáze. Ten trend jede k používaní NoSQL databází, které se replikují tak-nějak samy; které mohou být eventuálně nekonzistentní v řádu pár sekund, což vám vadí třeba u velkých finančních transakcí, ale nevadí při běžným používaní, kde uživatel uvidí data o pár vteřin později, co mu nevadí. 
Samozřejmě je možné používat cacheovaní přes memcached. Dokonce od nějaké verze umožňují memcached používat rovno a nemusíte to nijak instalovat. Můžete to pak vyladit tak, že do databáze budete sahat jenom při zápisu. To je samozřejmě cíl, ke kterému by to mělo směrovat, protože [když chcete] škálovat, tak to všechno musíte cacheovat.

## Phusion Passenger
Phusion Passenger je server, pod kterým potom běží samotné Railsy. Máte tady odkaz – je zadara, běží to tuším pod MIT licencí (nebo nějakou jinou). Můžete si koupit support a můžete si koupit enterprise Ruby, t. j. implementace, resp. fork, který říká, že v zatížení vám to běží o 30% rychleji nebo s 30% menší paměťovou náročností. Je to modul pre Apache / nginx a pokud tá webaplikace spadne, tak webserver stále běží a při dalším requestu se udělá restart, takže se o to prakticky nemusíte starat. Deploy znamená, že vezmete celý root aplikace a skopírujete ho do webrootu. Žádný WARka atd. Vezmete a nahrnete a i to dělá Capistrano. 

Už konec? Jěště minuta.

Nicméně, Phusion je doporučeno autory Ruby on Rails. 

## Nepřetržitá integrace: nástroj Cerberus. 
Automaticky se připojí do repository. Spustí „rake test“, mailem pošle, jestli to prošlo nebo neprošlo. Víc nepotřebujete, žádný grafický výstup tam není, z příkazového řádku to funguje – podívejte se na to. 

## Hosting
Heroku nebo Engine Yard… jiné jsem nezkoušel. Heroku vypadá dobře, řeknete si, co chcete naklikat a oni vám to pak stahují z platební karty. Můžete si to vyzkoušet. My to však neřešíme, servery máme vlastní a webhosting jsem moc neřešil. 

## Mýty a legendy
Tady bych navázal na diskusi, o které jsem si myslel, že bychom ji mohli snad stihnout… ještě uvidíme. 

### Ruby je pomalé? 
Musím se zeptat, kdy a jak je pomalé - musíte profilovat. Je blbost říci, že Java je rychlejší, Ruby je pomalé. Vždy je to v kontextu dané aplikace. To, co potřebujete změřit, je skutečný request-response. Ideálně to děláme třeba přes JMeter, kterým tu aplikaci měříme. 

Další mýtus je, že...
### „není to staticky typované = více chyb“. 

V určitých případech to může nastat, ale tady se to dohání tím, že jste tlačeni, abyste měli víc testů. 

### Ruby on Rails není dost enterprise

„Enterprise“ – víme co to je… [jenomže to,] že za technologií stojí velká firma neznamená vůbec nic. Důležitá je komunita lidí, kteří to používají, tedy vývojářů.

### Nemá support velkých firem
To je možná pravda, neznáte to, není to tak profláklý jako třeba Java. „Nikdy jsem o tom neslyšel, takže to nefunguje“ je špatný přístup. Ale pár lidí mi řeklo, že „Kdyby to bylo tak dobré, tak by se to všude používalo.“ Nepoužívá se to, protože lidi o tom třeba neví. 

### Jednobarevní svět
Mikdy nemáte nástroj, který řeší všechny problémy. Musíte, musíte! jako vývojáři nasávat nové trendy. To je strašně důležitá věc! Znám spoustu vývojářů, kteří si myslí, že se naučí Javu, pár frameworků a myslí si, že jsou do konce života imunní k požadavkům. Musíte sledovat trendy, protože je tady důležitá věc. Kdo si myslíte, že rozhoduje o tom, aby se v aplikaci používala konkrétní platforma nebo framework? To nejsou obchodníci, to jste vy, vývojáři! Je na vás, abyste klienty přesvědčili, že to jde jednoduše, líp a levněji. Podle interních měření v Kyberii píšeme v Rails desetkrát rychleji než v Javě. Mám to měřeno na tom, že když se zadá požadavek na změnu, tak od zadání požadavku do uvedení do produkce je ten vývoj desetkrát rychlejší - už jenom tím, že se to nemusí stupidně pořád kompilovat a redeployovat. Máte to hned, F5 a vidím změnu, super, jsme rychlejší.

## Otázky a odpovědi?

*[nesrozumitelně z publika]*

Mínus? Zjistili jsme, že to trochu pomaleji pracuje s polem.
Ne, já si fakt nedělám srandu. Opravdu to takhle je. Jsem překvapený, jak bezproblémový ten provoz je. Sice pořádně zaklepám. [* klepání na dřevo *], ale ono to fakt funguje. Nebavím se tady o aplikaci, která vám píše deníček, ale o aplikaci, kde máte tisícovky uživatelů, přes který tečou peníze v rámci desítek milionů až miliard a ono to fakt jede. To je na tom to pěkný, že když se podíváte, jak ta architektura jede, tak škálování a věci, které jsou kritické pro skutečně drahé aplikace, tak… škálování bez problémů; další databáze je úzké místo všude a musíte cacheovat; řešíte hlídaní procesů, když vám někde něco spadlo, ale to je všude. 

Ale něco, kde bych si někdo řekl, že „Rails byly špatná volba“, na to jsem nenarazil. My jsme fakt přes Rails vyřešili úplně všechno.

*[nesrozumitelně z publika]*

Omlouvám se, ale za prvé se ty informace dají dohledat a za druhé mám nějaké smlouvy, kde nesmím mluvit o technických implementacích a detailech. Nemůžu vám tedy přesně říct kde, a tak vám nezbývá nic než mi věřit.

*[nesrozumitelně z publika]*

Cože? Pardon? Ne, ne, ne, jsou to pojišťovací makléři. Další otázka?
[nesrozumitelně z publika]
Už jsem to říkal, 200 až 300 tříd modelu. Počet tabulek v databázi tomu odpovídá, plus nějaké spojovací tabulky, ale jsou to typicky stovky tříd. Řádově. 

*[nesrozumitelně z publika]*

Máme malé vývojové týmy.

*Z publika: Existují pro to nějaké komponenty, třeba kalendář?*

Rozumím. Pro Ruby se rozšíření instalují přes gem, pro Rails taky. V okamžiku, když to potřebujete rozšířit třeba o stránkováni, pro výběr kalendáře, tak těch gemů jsou tisíce. Prakticky v tom najdete všechno – chcete řešit výběr kalendáře, stránkování, propojení na externí server… jde to udělat přes gemy.

*[nesrozumitelně z publika]*

Rails používají nějaký javascriptový framework, kde ten AJAX jde udělat. Kontroléry jakoby počítají s tím, že jsou volané asynchronně a vy pak nevracíte celou HTML, ale jenom fragment stránky. Je to zakomponované přímo v Rails, ale my to moc nepoužíváme, protože AJAX moc nepotřebujeme. 

*[nesrozumitelně z publika]*

My jsme v PHP moc nehledali. Věděli jsme, že PHP… my jsme to PHP nepoužívali objektově. Chtěli jsme přijít do nějakého objektového jazyka a tak tedy přišla Java. Protože to bylo krásné a kdo programoval v Javě byl tak sexi a cool, tak jsme programovali v Javě a nakonec jsme skončili u Ruby on Rails. Věřím tomu, že i v PHP jsou teď i jiné nástroje, kde se to dá, ale tady to jsme to nepoužívali… v roce 2003/2004, když jsme o tom rozhodovali.

Děkuju za pozornost. Pokud chcete další otázky, přijeďte ke mně, já budu rád, když se to rozvine. Potřebuji vaše reakce.

