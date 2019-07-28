---
title: Popoludnie s jazykom Java 2006
date: 2006-04-09T12:29:02+01:00
---

# O projekte
**Popoludnie s jazykom Java** je neformálny „hands-on" seminár venujúci sa jazyku Java a súvisiacim technológiám pod vedením Róberta Novotného a Karola Bučeka. Prebieha každý utorok od 13.30 v laboratóriu P7.

# Otázky
E-mail: http://s.ics.upjs.sk/~novotnyr/img/email.gif, ICQ: http://s.ics.upjs.sk/~novotnyr/img/icq-arial-10.gif

# Oznamy
* Po dvanástich stretnutiach sa skončila oficiálna časť seminára. Celý seminár dokázalo zvládnuť 5 účastníkov! 

# Stretnutia
*21. 1. 2006*. Prvé stretnutie
------------------------------

6 účastníkov. 

História Javy, inštalácia JDK, inštalácia Eclipse. Hello World. Letom svetom Eclipseom. public static void main, ify, fory, základné typy. Trieda Vypinac s jedným dátovým členom a tromi metódami, iné triedy (StringBuffer). Kontajnery: ArrayList v 1.4 a v Java5.

*28. 1. 2006*. Druhé stretnutie
-------------------------------

16 účastníkov.

V princípe deja-vu z prvého stretnutia. Naviac akurát použitie cudzích knižníc (`seminar.jar`).

*7. 3. 2006*. Tretie stretnutie
-------------------------------

10+ účastníkov. 

Polia. Obkec o PHP a JSP. Inštalácia Tomcatu. Vytvorenie adresárovej štruktúry pre JSP a konfiguračného súboru pre Tomcat. Vytvorenie `hello.jsp`. Nový projekt v Eclipse, a riešenie zmätkov okolo adresára pre zdrojové kódy. Vytvorenie triedy `Student` a pokus o jej použitie v JSP. Package. Metóda `toString` - dedičnosť za 30 sekúnd.

*14. 3. 2006*. Štvrté stretnutie
--------------------------------

10 účastníkov. Jednoduché formuláre v JSP. Vyťahovanie dát z objektu `Request`. Konverzia typov. Nastavenie `reloadable` v Tomcate. Ošetrenie null a prázdnych reťazcov. Sessions.

*21. 3. 2006*. Piate stretnutie
-------------------------------

10 účastníkov.

Práca s databázami: Connection, Statement, ResultSet. Práca s výnimkami.

*28. 3. 2006*. Šieste stretnutie
--------------------------------

8 účastníkov. 

Úvod do servletov. Deployment descriptor -- `web.xml`. Práca s databázami pomocou aplikačného rámca Spring. `JdbcTemplate`, mapovanie riadkov na objekty pomocou `RowMappera`, aktualizácie dát. Vytvorenie objektu prístupu k dátam (DAO). Vytvorenie továrne pre DAO. Použitie v servlete.

*4. 4. 2006*. Siedme stretnutie
-------------------------------

8 účastníkov. 

Vytvorenie vzorovej CRUD aplikácie pomocou 4 servletov: servlety vytvorenie, zmazanie, a úpravu záznamu.

*11. 4. 2006*. Ôsme stretnutie. MVC frameworky. Apache Struts ako príklad MVC. Začatie prác na vzorovej CRUD aplikácii.

*18. 4. 2006*. Deviate stretnutie
---------------------------------

Úvod do knižnice tagov Struts. Vytvorenie akcie na čítanie objektov a ich mazanie. Akcia pre vytvorenie objektu. Automatická validácia a jej nevýhody.

*25. 4. 2006*. Desiate stretnutie
---------------------------------

Dokončenie akcie pre vytvorenie objektu. Manuálna validácia. Vytvorenie „edit" akcie.

*2. 4. 2006*. Jedenáste stretnutie
----------------------------------

DispatchAction v Struts. Globálne forwardy. Ošetrovanie výnimiek a presmerovanie na strákny s použitím vlastného ExceptionHandlera. Úvod do XML. Dobrotvárnosť a validnosť. Použitie Xerces-a na DOM a SAX. Dopytovanie XPath.

*9. 4. 2006*. Dvanáste stretnutie
---------------------------------

Vytvorenie vzorovej triedy v Notepade. Kompilácia a spustenie triedy z príkazového riadka. Kompilácia a spustenie triedy z package. Vytvorenie JAR súboru a manifestu. Vytvorenie samospustiteľného JAR súboru. Použitie knižnice Informa na sťahovanie RSS kanálov. Primitívna Swing aplikácia.

*16. 4. 2006*. Trináste stretnutie (Bonus)
-----------------

Jazyk XPath. Použitie nástroja Visual XPath na demonštrovanie dopytov XPath. Transformačný jazyk XSLT - použitie šablón, základné štruktúry. Funkcionálny vs. procedurálny prístup. Ukážka XQuery.

### Odkazy
* [Tutoriál XPath na Zvon.org](http://www.zvon.org/xxl/XPathTutorial/General/examples.html )
* [XSLT Tutorial na Zvon.org](http://www.zvon.org/xxl/XSLTutorial/Output/index.html )
* [Nástroj Visual XPath](http://weblogs.asp.net/nleghari/archive/2003/12/03/40842.aspx ) (vyžadovaný .NET framework ;-))

# Odkazy
* [ZIP](http://s.ics.upjs.sk/~novotnyr/js/sources/jsp | Projekt seminar]] ([[http://s.ics.upjs.sk/~novotnyr/js/sources/jsp.zip ))
* [Inštalácia servera Apache Tomcat 5.5.x na Windowse](http://s.ics.upjs.sk/~novotnyr/js/tomcat/tomcat.html )
* [Vytvorenie a nasadenie webových aplikácií pre Tomcat](http://s.ics.upjs.sk/~novotnyr/js/web-tomcat/web-tomcat.html )
* [Použitie Spring JDBC a DAO objektov](http://s.ics.upjs.sk/~novotnyr/js/spring-jdbc/spring-jdbc.html )

* [Servlety a JSP](http://xdavidek.wz.cz/scripts/get.php?file=bakalarka.pdf.zip ) - bakalárska práca
* [Slajdy o servletoch a JSP](http://nenya.ms.mff.cuni.cz/~hnetynka/vsjava/slides2005/java07.pdf )
* Miniseriál *S Javou na webovém serveru* na Root.cz. [Diel 3](http://www.root.cz/clanky/s-javou-na-webovem-serveru/ | Diel 1]], [[http://www.root.cz/clanky/s-javou-na-webovem-serveru-2/ | Diel 2]], [[http://www.root.cz/clanky/s-javou-na-webovem-serveru-3/ )

* [Eclipse Web Tools Project](http://www.eclipse.org/downloads/download.php?file=/webtools/downloads/drops/R-1.0.1-200602171228/wtp-all-in-one-sdk-R-1.0.1-200602171228-win32.zip ). Eclipse + pluginy pre servlety a JSP (zvýrazňovanie syntaxe, sprievodcovia, editor XML...). Všetko v jednom.
* [Core Servlets and JSP](http://pdf.coreservlets.com/ ). Voľne stiahnuteľná príručka k servletom a JSP (staršieho dáta, ale mnoho vecí platí)
* [Článok o Jave na Wikipedii](http://en.wikipedia.org/wiki/Java_programming_language ). Obsahuje filozofický pokec, prehľad verzií a pod. [english]
* [`seminar.jar`](http://s.ics.upjs.sk/~novotnyr/js/seminar.jar )
* [JDK 1.5.0_6 (Win32)](http://javashoplm.sun.com/ECom/docs/Welcome.jsp?StoreId=22&PartDetailId=jdk-1.5.0_06-oth-JPR&SiteId=JSC&TransactionId=noreg )
* Eclipse 3.1.1 (Win32) - [rázcestník mirrorov na eclipse.org](http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops/R-3.1.2-200601181600/eclipse-SDK-3.1.2-win32.zip )
* [Thinking in Java, 3rd Edition](http://mindview.net/Books/TIJ/DownloadSites )