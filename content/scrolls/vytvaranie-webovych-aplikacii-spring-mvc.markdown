---
title: Vytváranie webových aplikácií pomocou Spring MVC 2.5 
date: 2008-11-20T17:22:51+01:00
---
# Úvod
Spring MVC je už pomerne zaužívaný aplikačný rámec na vývoj webových aplikácií. Už jeho prvé verzie brali do úvahy skúsenosti a poučenia z iných MVC frameworkov. Navyše, s každou ďalšou verziou boli prezentované možnosti, ktoré prácu s ním ešte viac zjednodušili či uľahčili.

Vo verzii 2.5 je k dispozícii možnosť vytvárať webové aplikácie, ktoré dávajú väčší dôraz na zásadu, že dohoda je niekedy lepšia ako konfigurácia. Dodržiavanie menných konvencií a hojné použitie anotácií umožňuje vytvárať webové aplikácie založené na klasických Java triedach (POJO) s minimálnym množstvom konfigurácie.

Ukážme si príklad použitia na jednoduchej webovej aplikácii, ktorá bude vykonávať štyri základné operácie nad triedou reprezentujúcou študenta. Tieto operácie sú v skratke označované ako CRUD:

* *Create* - vytvorenie objektu a uloženie v databáze
* *Read* - prezeranie objektu
* *Update* - aktualizácia údajov 
* *Delete* - odstránenie objektu.

# Doménové objekty webovej aplikácie
Trieda študenta je klasický Java bean:

```java
public class Student {
  /**
   * Id študenta.
   */
  private Long id;
  /**
   * Krstné meno študenta.
   */
  private String firstName;
  /**
   * Priezvisko študenta. 
   */
  private String lastName;

  private int year;
  /**
   * Dátum narodenia študenta.
   */
  private Date birthDate;


  /* gettre, settre, konštruktory, hashCode() a equals() */
}
```
Každý študent má jednoznačný identifikátor typu `java.lang.Long`. (Použitie objektového typu namiesto primitívu má niekoľko výhod, ktoré sa ukážu neskôr.)

# Stiahnutie knižníc
Základná štruktúra webovej aplikácie sa ničím nelíši od inej webovej aplikácie (základom je adresár `WEB-INF` s podadresármi `classes` a `lib`). Dôležité je získať knižnice pre Spring, ktoré získame zo stránok Springu. Okrem nej budeme potrebovať niektoré ďalšie JAR knižnice.
V adresári `WEB-INF/lib` by sa mal nachádzať:

* z projektu Spring:
  *  `spring.jar`
  * `spring-webmvc.jar`
* z projektu [Jakarta Commons Logging](http://commons.apache.org/downloads/download_logging.cgi )
  
  *  `commons-logging-1.1.1.jar`
* z projektu [Jakarta Standard Taglibs](http://jakarta.apache.org/site/downloads/downloads_taglibs-standard.cgi )
  * `jstl.jar`
  * `standard.jar` 

  V prípade, že používame Tomcat 6.x, sa tieto dve knižnice nachádzajú v inštalačnom podadresári `webapps/examples/WEB-INF/lib`.
  Tieto knižnice by sme mali dodať aj do `CLASSPATH`u, resp. do projektu v svojom obľúbenom vývojom prostredí.

# Konfigurácia
## Popisovač nasadenia `web.xml`
V ďalšom kroku by sme mali nakonfigurovať popisovač nasadenia webovej aplikácie, konkrétne súbor `web.xml`. Ten sa (v súlade s požiadavkami na webovúaplikáciu) musí nachádzať v adresári `WEB-INF`.

Klasické webové aplikácie založené na servletoch a JSP zvyknú v tomto súbore uviesť a nastaviť viacero servletov. Spring MVC je založený na jedinom centrálnom servlete, cez ktorý putujú všetky užívateľské požiadavky.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app version="2.4" 
  xmlns="http://java.sun.com/xml/ns/j2ee" 
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee
                   http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">
  
  <servlet>
    <servlet-name>springmvc</servlet-name>
    <servlet-class>
      org.springframework.web.servlet.DispatcherServlet
    </servlet-class>
    <load-on-startup>1</load-on-startup>
  </servlet>
  <servlet-mapping>
    <servlet-name>springmvc</servlet-name>
    <url-pattern>*.do</url-pattern>
  </servlet-mapping>
</web-app>
```
V tomto súbore sme definovali jediný servlet `springmvc` a určili, že všetky URL adresy, ktoré sa končia na `*.do` budú spracované týmto servletom.

## Konfigurácia Spring MVC
Ďalšia konfigurácia aplikačného rámca prebieha v súbore `springmvc-servlet.xml`, ktorý sa nachádza v adresári `WEB-INF`. Názov tohto súboru je odvodený od názvu servletu (`springmvc`). Znalci Springu rýchlo zistia, že tento súbor predstavuje definíciu aplikačného kontextu.
```xml
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:context="http://www.springframework.org/schema/context"
  
  xsi:schemaLocation="http://www.springframework.org/schema/beans
  http://www.springframework.org/schema/beans/spring-beans-2.0.xsd
  http://www.springframework.org/schema/context 
  http://www.springframework.org/schema/context/spring-context-2.5.xsd">
  
  <context:component-scan base-package="sk.spring.mvc" />

</beans>
```
Zatiaľ uvedieme jediné nastavenie a to zapnutie automatického vyhľadávania anotovaných tried v `CLASSPATH`, presnejšie v balíčku `sk.spring.mvc`. V našom prípade to znamená, že sa v aplikačnom kontexte zaregistrujú všetky triedy z balíčka `sk.spring.mvc`, ktoré majú anotáciu `@Controller` alebo `@Component` (v skutočnosti sú podporované aj ďalšie anotácie, ale tie nás momentálne nezaujímajú). Spring sa bude o zaregistrované triedy starať, automaticky manažovať závislosti a vzťahy medzi nimi, vytvárať ich inštancie a pod. Takéto Springom manažované inštancie tried sa nazývajú *beany*.

# Návrhový vzor MVC
Spring MVC (ako už hovorí jeho názov) je založený na návrhovom vzore Model-View-Controller. Ten sa snaží oddeliť dáta z aplikačnej domény od prezentačnej vrstvy (teda užívateľského rozhrania) a od udalostí, ktoré svojou interakciou s prezentačnou vrstvou vyvoláva používateľ.

Parafrázujme z [originálneho článku](http://st-www.cs.uiuc.edu/users/smarch/st-docs/mvc.html ) od S. Burbecka:

* **Model** manažuje dáta z aplikačnej domény, zasiela informácie o stave vrstve *view* a upravuje tieto dáta na základe akcií vyvolaných v **controlleri**.
* **View** reprezentuje používateľské rozhranie, ktoré zobrazuje dáta poskytované modelom.
* **Controller** spracováva používateľov vstup a podľa potreby aktualizuje model a odosiela ho do *view* vrstvy.

V prípade springovskej webovej aplikácie zodpovedá týmto pojmom:

* **Modelom** je ľubovoľná trieda s dátami. V našom prípade môžeme ako model používať inštancie triedy `Student`.
* **Viewy** budú tvorené JSP stránkami. 
* **Kontroléry** budú triedy, ktoré spracujú HTTP požiadavku, dáta namapujú na model, vykonajú príslušné akcie a zobrazia príslušný view. Kontrolérov bude v aplikácii viac a každý z nich je jednoznačne namapovaný na danú URL adresu.

Štandardná postupnosť akcií, ktorá sa vyvolá je približne nasledovná:

1.  užívateľ navštíví danú URL adresu.
1.  ak užívateľ odosielal nejaké dáta (napr. z formulára), prebehne ich mapovanie na objekt modelu
1.  vyvolá sa príslušná metóda kontroléra namapovaného na danú adresou
1.  kontrolér aktualizuje model (ak treba) a zobrazí príslušnú JSP stránku s dátami z neho

# Zobrazenie študenta
Ako prvú vec v našej webovej aplikácii vyrobíme stránku, ktorá zobrazí stále rovnakého študenta. Vyrobme si teda triedu s príslušnou metódou:
```java
public class DisplayStudent {
  public Student getStudent() {
    Student student = new Student(1L, "John", "Doe", 1, new Date(87, 4, 2)));
    return student;
  }
}
```
Táto trieda nie je zatiaľ ničím výnimočná. Tú správnu šťavu jej dajú až anotácie, ktorými ju okoreníme.
```java
package sk.spring.mvc;

@Controller
public class DisplayStudent {

  @RequestMapping("/displayStudent.do")
  public Student getStudent() {
    Student student = new Student(1L, "John", "Doe", 1, new Date(87, 4, 2)));
    return student;
  }
}
```
Všimnime si názov balíčka, ktorý je zhodný s deklaráciou v elemente `<context:component-scan>`. Ak použijeme musíme prispôsobiť názov balíčka v tejto deklarácii, v opačnom prípade Spring naše triedy nenájde.

Význam anotácií je nasledovný:

* `@Controller` označuje triedu ako kontrolér, teda triedu, ktorá bude spracovávať HTTP požiadavky.
* `@RequestMapping` nad metódou `getStudent()` a jej hodnota (/`displayStudent.do`) plní trojakú úlohu:
    1. špecifikuje URL adresu, ktorá bude zodpovedať danému kontroléru. V uvedenom príklade to znamená, že náš kontrolér bude prislúchať adrese `http://názovServera/názovWebovejAplikácie/displayStudent.do`.
    2. určuje, že práve táto metóda sa má vykonať pri spracovávaní HTTP požiadavky. Kontrolér môže mať viacero verejných metód a touto anotáciou predídeme nejednoznačnostiam.
    3. špecifikuje názov view, ktorý sa má zobraziť po vykonaní metódy.

Ak používateľ navštívi adresu končiacu sa na `/displayStudent.do`, Spring MVC prejde všetky kontroléry zaregistrované v aplikačnom kontexte a pozrie sa, ktorý z nich dokáže obslúžiť túto adresu. V našom prípade máme jediný kontrolér, `DisplayStudent`. Ďalej sa Spring MVC pozrie na metódu, ktorá sa má zavolať a to na základe anotácie `@RequestMapping`. Vykoná teda túto metódu, vezme návratovú hodnotu a použije ju pri výslednom zobrazení - inak povedané, zobrazí príslušný view.

## Viewy
Ako bolo spomenuté vyššie, view zodpovedá používateľskému rozhraniu, ktoré zobrazuje dáta získané z modelu. Každý view v Spring MVC má svoje logické označenie, resp. jednoznačný identifikátor. View môže byť implementované rôznymi spôsobmi, ktoré zodpovedajú rôznym výstupným formátom. Zvyčajne je ním JSP stránka, ale k dispozícii sú aj viewy založené na PDF, DOC alebo WML súboroch. 

Spring podporuje ľahkú výmenu implementácií viewov. To je zabezpečené mapovaním identifikátorov viewov na ich konkrétne reprezentácie. 
Ukážeme si len najjednoduchší prípad, kde budeme logické označenie viewu bude zodpovedať názvu súboru JSP stránky. 

Ak kontrolér zobrazí view `displayStudent`, zobrazíme stránku zo súboru `/WEB-INF/jsp/displayStudent.jsp`. Toto mapovanie zabezpečí bean `InternalResourceViewResolver`, ktorý deklarujeme v `springmvc-servlet.xml` dodaním elementu:
```xml
<bean id="viewResolver"     
      <!-- názov triedy musí byť uvedený spolu! -->
      class="org.springframework.web
             .servlet.view.InternalResourceViewResolver">
  <property name="prefix" value="/WEB-INF/jsp/"/>
  <property name="suffix" value=".jsp"/>
</bean>
```
**View resolver** (vyhodnocovač viewov) je trieda mapujúca identifikátory viewov na konkrétne implementácie. V tomto prípade vezme názov viewu, predradí pred neho `/WEB-INF/jsp/` a zaň dodá príponu `.jsp` a výsledný súbor zobrazí klientovi. Inak povedané, pre view `displayStudent` zobrazí súbor s cestou `/WEB-INF/jsp/displayStudent.jsp`.

## Ktorý view zobraziť?
V kontroléri pre zobrazenie študenta sme ešte neurčili, ktorý view sa má zobraziť po vykonaní metódy `getStudent()`. Štandardne sa názov viewu odvodí z URL adresy nastavenej v anotácii `@RequestMapping`. Z URL adresy `/displayStudent.do` sa odsekne predpona s cestou a prípona, čo zodpovedá viewu `displayStudent`. Na základe view resolvera sa teda zobrazí JSP stránka zo súboru `/WEB-INF/jsp/displayStudent.jsp`.

## JSP stránka
Ako konkrétne však má vyzerať stránka asociovaná s viewom? Založme si súbor `displayStudent.jsp` v adresári `WEB-INF/jsp` a dajme doň nasledovný obsah.

```html
<h1>Detaily o studentovi</h1>
<b>ID:</b> ${student.id} <br />
<b>Meno:</b> ${student.firstName} <br />
<b>Priezvisko:</b> ${student.lastName} <br />
<b>Rocnik:</b> ${student.year} <br />
```

Táto stránka obsahuje zvyčajný HTML kód (aj keď, napísaný viac než šlendriánsky) a niekoľko *premenných*, ktoré sa začínajú dolárom a ich názov je v kučeravých zátvorkách. Na tieto premenné sa naviažu hodnoty získané z kontroléra.

V rámci premenných môžeme používať bodkovú notáciu. Ak v premennej `student` je objekt typu `Student`, notácia `student.firstName` je ekvivalentná zavolaniu metódy `getFirstName()` na objekte študenta.

## Dodanie hodnôt z kontroléra do viewu
Kontrolér odovzdá stránke model, čo je, voľne povedané, mapovanie reťazcov (názvov premenných) na objekty (hodnoty premenných). Po zavolaní metódy `getStudent()` sa Spring MVC automaticky pozrie na návratový typ metódy. Keďže metóda vracia objekt typu `Student`, vytvorí sa premenná `student` (jej názov sa odvodí od názvu triedy, pričom prvé písmeno bude malé), ktorej hodnotou bude vrátený objekt.

Model bude vyzerať približne takto
```
model
  |"student" => sk.upjs.students.Student@23242ae
```
Tým sme teda dokončili náš prvý kontrolér spolu s príslušným view. Aplikácia je pripravená na nasadenie do servletového kontajnera. Spustíme ju a navštívime príslušnú adresu (končiacu sa na `/displayStudent.do`). Mali by sme vidieť zobrazené detaily o našom študentovi.

# Zobrazenie študenta s použitím databázy
V ďalšom kroku si upravíme kontrolér tak, aby umožňoval zobrazenie študenta na základe užívateľom dodaného identifikátora. Ešte predtým si však vytvorme triedu, ktorá bude simulovať relačnú databázu, v ktorej budú uložení študenti.

```java
@Component
public class Database {
  private List<Student> students = new ArrayList<Student>();
  
  public Database() {
    students.add(
      new Student(1L, "John", "Doe", 1, new Date(87, 4, 2)));
    students.add(
      new Student(2L, "Michael", "Jackson", 1, new Date(86, 1, 2)));
    students.add(
      new Student(3L, "Jane", "Greengroces", 2, new Date(83, 4, 3)));
    students.add(
      new Student(4L, "Arthur", "Pewtey", 4, new Date(84, 12, 12)));
    students.add(
      new Student(5L, "Sidney", "Pollack", 3, new Date(78, 10, 4)));
    students.add(
      new Student(6L, "Andrew", "Mordon", 5, new Date(12, 5, 8)));   
  }
  
  /**
   * Vráti zoznam všetkých študentov v databáze. Zoznam
   * je nemeniteľný.
   */
  public List<Student> listStudents() {
    return Collections.unmodifiableList(students);
  }
  
  /**
   * Nájde v databáze študenta s daným identifikátorom. Ak
   * sa taký študent nenájde, vráti <code>null</code>.
   */
  public Student findById(Long id) {
    for (Student student : students) {
      if(student.getId().equals(id)) {
        return student;
      }
    }
    return null;
  }
  
  /**
   * Uloží alebo aktualizuje objekt študenta. Ak má študent
   * identifikátor rovný <code>null</code>, znamená
   * to inštanciu, ktorá v databáze ešte nie je. V opačnom 
   * prípade sa existujúca inštancia s takým ID nahradí
   * novou inštanciou s aktualizovanými dátami. 
   * 
   * @param student
   */
  public void saveOrUpdate(Student student) {
    if(student.getId() == null) {
      student.setId(new Date().getTime());
      students.add(student);
      return;
    }
    Student dbStudent = findById(student.getId());
    students.remove(dbStudent);
    students.add(student);
  }
  
  /**
   * Odstráni z databázy študenta s daným identifikátorom.
   * Inštancia v parametri nemusí mať vyplnené všetky údaje, stačí,
   * keď má vyplnený identifikátor.
   */ 
  public void removeStudent(Student student) {
    Student dbStudent = findById(student.getId());
    if(dbStudent != null) {
      students.remove(dbStudent);
    }
  }
}
```
Všimnime si, že trieda má anotáciu `@Component`, čo zaručí jej automatickú registráciu v aplikačnom kontexte Springu. Triedy, ktoré budú potrebovať prístup k databáze, sa na ňu budú môcť odkazovať pomocou špeciálnej anotácie, ktorú si ukážeme o niečo nižšie.

Upravme si teraz kontrolér tak, aby jeho metóda mala medzi parametrami identifikátor a vracala príslušného študenta.
```java
@Controller
public class DisplayStudent {
  @Autowired
  private Database database;

  @RequestMapping("/displayStudent.do")
  public Student getStudent(Long id) {
    return database.findById(id);
  }
}
```
Vykonali sme dve zmeny: pridali sme inštančnú premennú `database` s anotáciou `@Autowired`. To naznačí Springu, že do nej má vložiť inštanciu beanu pre databázu, ktorá sa nachádza v aplikačnom kontexte. (Taká inštancia existuje, keďže trieda `Database` bola anotovaná ako komponent). Okrem toho sme do metódy `getStudent()` dodali parameter s identifikátorom. 

Je známe, že URL adresy môžu v sebe obsahovať parametre dopytu. Príkladom môže byť adresa `http://localhost:8080/students/displayStudent.do?id=2&displayAll=true`. Za otáznikom nasledujú dvojice *názov parametra*=*hodnota parametra* oddelené ampersandom. V našom prípade máme dva parametre: *id*=*2* a *displayAll* = *true*. Spring MVC vie namapovať tieto parametre z URL adresy na parametre metódy. Parameter *id* sa namapuje na parameter `Long id`. Keďže parametre v URL adrese sú len reťazcové, je potrebné previesť konverziu hodnôt. Spring MVC však tieto prevody rieši automaticky.

Inými slovami, po navštívení adresy `http://localhost:8080/students/displayStudent.do?id=2&displayAll=true` sa v rámci metódy `getStudent()` vloží do parametra `id` hodnota 2. Parameter `displayAll` sa nedá namapovať na žiadny parameter metódy a preto sa ignoruje.

Parametre metódy, ktoré nemajú svoj protipól v URL adrese, budú nastavené na `null`. Adresa `http://localhost:8080/students/displayStudent.do` teda vloží do parametra `Long id` hodnotu `null`.

# Zobrazenie zoznamu študentov
Ďalším príkladom v našej webovej aplikácii bude stránka, ktorá zobrazí zoznam študentov v databáze v prehľadnej tabuľke. Na to budeme opäť potrebovať:

1.  JSP stránku
1.  triedu kontroléra

JSP stránka
-----------

V adresári `WEB-INF/jsp` vytvorme stránku `listStudents.jsp` s nasledovným obsahom:
```
<%@ taglib prefix="c" 
           uri="http://java.sun.com/jsp/jstl/core" %>
<table>
  <tr><th>Name</th><th>Surname</th><th>Year</th>

  <c:forEach items="${studentList}" var="student">
    <tr>
      <td>${student.firstName}</td>
      <td>${student.lastName}</td>
      <td>${student.year}</td>
    </tr>
  </c:forEach>
</table>
```
V JSP stránke používame špeciálnu značku špecifikácie JSTL: `<c:foreach>` vie iterovať cez zoznam alebo pole obsiahnutom v premennej `${studentList}`. Každý prvok vloží do premennej `${student}`, ku ktorej môžeme pristupovať v rámci iterácie.
## Kontrolér
Kontrolér sa nebude líšiť od toho predošlého - rozdielom bude návratová hodnota.
```java
@Controller
public class ListStudents {
  @Autowired
  private Database database;
  
  @RequestMapping("/listStudents.do")
  public List<Student> listStudents() {
    List<Student> students = database.listStudents();
    return students;
  }
}
```
V tomto prípade vracia metóda zoznam študentov `List<Student>`. Do mapovania premenných stránky sa vloží premenná `studentList` (predpona sa odvodí z dátového typu zoznamu, prípona `list` zodpovedá kolekcii) s výsledným zoznamom.


# Vytvorenie študenta
## JSP stránka
V ďalšom kroku si vytvoríme stránku, pomocou ktorej vieme vytvoriť nového študenta a uložiť ho do databázy. Opäť budeme potrebovať triedu kontroléra a JSP, ktorá bude oproti predošlému príkladu zložitejšia - bude obsahovať HTML formulár.

Založíme súbor `createStudent.jsp` v adresári `WEB-INF/jsp`:
```xml
<%@ taglib prefix="c" 
           uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" 
           uri="http://www.springframework.org/tags/form" %>

<h1>Upraviť študenta</h1>

<form:form commandName="student">
  <table>
    <tr>
      <th>Meno:</th>
      <td><form:input path="firstName"/></td>
    </tr>
    <tr>
      <th>Priezvisko:</th>
      <td><form:input path="lastName"/></td>
    </tr>
    <tr>
      <th>Ročník:</th>
      <td><form:input path="year"/></td>
    </tr>
    <tr>
      <td colspan="2"> <input type="submit" /> </td>
    </tr>
  </table>
</form:form>
```
Na rozdiel od predošlej stránky tu používame špeciálnu sadu tagov poskytovaných Springom. Túto sadu sme zaviedli v hlavičke stránky deklaráciou
```
<%@ taglib prefix="form" 
           uri="http://www.springframework.org/tags/form" %>
```
Tag `<form:form>` zodpovedá HTML tagu `<form>`. Poskytuje však podporu pre automatické mapovanie hodnôt z modelu na ovládacie prvky. Premenná, v ktorej sa model nachádza, je nastavená v atribúte `commandName`.
Ostatné tagy `<form:input>` zodpovedajú tagom `<input>` z HTML. Majú však špeciálny atribút `path`, ktorý špecifikuje názov inštančnej premennej, na ktorú sa má hodnota prvku namapovať.
V našom prípade je modelový objekt uložený v premennej `student`. Ak je v nej objekt typu `Student`, potom ovládací prvok s `path="firstName"` bude získavať hodnotu z metódy `getFirstName()` a po odoslaní formulára sa na modelovom objekte zavolá `setFirstName()`, kde v parametri bude hodnota z tohto ovládacieho prvku.
## Kontrolér
Postup činností, ktoré sa vykonávajú pri práci s týmto kontrolérom pozostáva z dvoch fáz:

1.  v prvej fáze sa zobrazí view s formulárom - teda prázdny formulár (metódou HTTP GET). Používateľ ho vyplní a odošle.
1.  v druhej fáze sa prevezmú odoslané dáta (metódou POST), namapujú na modelový objekt, spracujú a zobrazí sa výsledný view.

Vytvorme teraz prvú verziu triedy kontroléra:
```java
@Controller
@RequestMapping("/createStudent.do")
public class CreateStudent {
 
  @RequestMapping(method = RequestMethod.GET)
  public Student displayStudent() {
    Student student = new Student();
    return student;
  }
}
```
Anotáciu `@RequestMapping` teraz odsunieme nad triedu. Vytvoríme metódu `displayStudent()`, ktorú anotujeme samostatným `@RequestMapping`om indikujúcim, že táto metóda sa má vykonať pri GET požiadavke. V nej vytvoríme prázdneho študenta, ktorý bude slúžiť ako modelový objekt. Dôvodom je to, že potrebujeme pre prázdny formulár potrebujeme nejaký modelový objekt. Prázdny študent s nevyplnenými dátami bude tým objektom, ktorý sa vo formulári vyplní. Metóda vracia mapovanie, kde sa premennej `"student"` priradí inštancia prázdneho študenta. Po jej vykonaní sa zobrazí view `createStudent`, kde sa vo formulári pracuje nad daným študentom.

Teraz dodajme metódu, ktorá bude spracovávať odoslané dáta.

```java
@Autowired
private Database database;

@RequestMapping(method = RequestMethod.POST)
public String updateStudent(Student student) {
  database.saveOrUpdate(student);
  return "redirect:listStudents.do";
}  
```
Metóda `updateStudent()` sa zavolá pri odoslaní formulára, teda pri požiadavke POST (viď anotácia). Má jeden parameter typu `Student`, na ktorý sa namapujú dáta z formulára (na základe atribútu `path` v ovládacích prvkoch formulára). Objekt typu `Student` len uložíme do databázy a zobrazíme nový view. 

V tomto prípade budeme chcieť po odoslaní formulára zobraziť zoznam študentov, teda stránku na adrese `/listStudents.do`. V metódach kontroléra, ktoré sú anotované pomocou `@RequestMapping` platí, že ak je návratovou hodnotou reťazec, tak ten sa zinterpretuje ako názov viewu, ktorý sa má zobraziť.

View so špeciálnym názvom `redirect:listStudents.do` presmeruje používateľa na adresu končiacu sa na `listStudents.do`. Na takúto adresu už máme namapovaný predošlý kontrolér `ListStudents`, na ktorom sa automaticky zavolá príslušná metóda a zobrazí sa nový zoznam (aj s čerstvo pridaným študentom).

### Validácia
Náš kontrolér má jednu chybu - uloží aj študenta, ktorý nemá žiadne vyplnené údaje, čo zrejme nie je ideálny prípad. Validácia by mala zaistiť kontrolu korektnosti a konzistencie dát a v prípade nesúladu na ne používateľa upozorniť.

V Spring MVC existuje užitočný interfejs `Validator`, ktoré reprezentuje triedu schopnú zvalidovať daný objekt. Vytvorme si triedu `StudentValidator`:
```java
public class StudentValidator implements Validator {
  public void validate(Object target, Errors errors) {
    Student student = (Student) target;
    ValidationUtils.rejectIfEmptyOrWhitespace(
      errors, "firstName", "", "Name cannot be empty.");
    ValidationUtils.rejectIfEmptyOrWhitespace(
      errors, "lastName", "", "Last name cannot be empty.");
    if(student.getYear() < 1 || student.getYear() > 5) {
      errors.rejectValue("year", "", 
                         "Year must be between 1 and 5!");
    }
  }
  
  public boolean supports(Class clazz) {
    return Student.class.isAssignableFrom(clazz);
  }  
}
```
V metóde `supports()` určíme aké dátové typy vie validátor spracovať - je zrejmé, že `Student`ov. Filozofia metódy `validate()` je nasledovná: v `target` máme objekt, ktorý chceme zvalidovať a `errors` predstavuje objekt, do ktorého pridávame chybové hlášky. V ukážke máme dva prístupy k validácii:

* `ValidationUtils.rejectIfEmptyOrWhitespace()` skontroluje neprázdnosť danej inštančnej premennej. 
* `errors.rejectValue()` umožňuje zamietnuť inštančnú premennú v prípade, že je kontrola zložitejšia kontrola.

Validátor potom pridáme do kontroléra jednoducho: napr. ako inštančnú premennú:
```java
private static StudentValidator studentValidator 
  = new StudentValidator();
```
Jeho použitie bude nasledovné - upravíme si metódu volanú pri POST požiadavke:
```java
@RequestMapping(method = RequestMethod.POST)
public String updateStudent(Student student, Errors errors) {
  studentValidator.validate(student, errors);
  if(errors.hasErrors()) {
    return "createStudent";
  }
  database.saveOrUpdate(student);

  return "redirect:listStudents.do";
}
```
Do metódy `updateStudent()` sme dodali nový parameter typu `Errors`, do ktorého môžeme vkladať chybové hlášky. Modelový objekt zvalidujeme a v prípade, že nastala nejaká chyba zobrazíme pôvodnú stránku (teda view `createStudent`). V prípade úspešnej validácie objekt uložíme a zobrazíme zoznam študentov.

Náš kontrolér je nedokonalý - v prípade, že validácia neprejde, sa používateľovi zobrazí pôvodný formulár bez akejkoľvek chybovej hlášky či upozornenia. Tie je možné zobraziť pomocou tagu `<form:errors>`, ktorý dodáme do formulára:
```
...
<form:form commandName="student">
  <form:errors path="*" />
  ...
</form:form>
```
Hviezdička v atribúte `path` hovorí, že sa majú zobraziť všetky validačné chyby týkajúce sa všetkých inštančných premenných modelového objektu. Ak chceme zobraziť len chyby týkajúce sa ovládacieho prvku pre zadanie mena, môžeme vyšpecifikovať `path="firstName"`. Tagov `<form:errors>` môže byť v rámci formulára aj viac.

# Úprava študenta
Prejdime teraz k ďalšiemu kroku - k stránke pomocou ktorej môžeme upraviť dáta existujúceho študenta.
## JSP stránka
JSP stránku nemusíme vyrábať - môžeme totiž použiť stránku `createStudent.jsp`.
## Kontrolér
Kontrolér `EditStudent` anotovaný ako `@RequestMapping("/editStudent.do")` bude veľmi podobný kontroléru pre vytvorenie študenta. Jedinou odlišnosťou bude kód v metóde `displayStudent()`:
```java
@RequestMapping(method = RequestMethod.GET)
public String displayStudent(Long studentId, ModelMap model) {
  Student student = database.findById(studentId);
  if(student == null) {
    throw new IllegalArgumentException();
  } 
  model.addAttribute(student);

  return "createStudent";
}
```
V tomto prípade je situácia o niečo odlišnejšia. Dosiaľ sme totiž vracali view odvodený od URL adresy. V tomto prípade však potrebujeme zobraziť view `createStudent` a navyše doň chceme odovzdať model obsahujúci objekt študenta. Ako na to? Do metódy sme dodali nový parameter - modelovú mapu. To je presne mapa, do ktorej môžeme pridávať názvy premenných a ich hodnoty. Údaje v tejto mape zodpovedajú modelu, ktorý sa použije pri zobrazovaní stránky. Metóda `addAttribute(student)` pridá do modelovej mapy premennú student` (odvodenú od názvu triedy) s hodnotou zodpovedajúcemu objektu v parametri.

Metóda `displayStudent()` vracia reťazec, ktorý sa interpretuje ako názov viewu, ktorý sa má zobraziť. Súhrnne sa po zavolaní metódy zobrazí view `createStudent`, pričom dáta doň sa prevezmú z modelovej mapy `model`.

## Ošetrovanie výnimiek
Metóda `displayStudent()` vyhodí v prípade, že sa snažíme nájsť študenta s neexistujúcim identifikátorom, výnimku `IllegalArgumentException`. Užívateľ sa asi takejto chybovej hláške neveľmi poteší (taký *stack trace* nie je veľmi príjemné čítanie). Namiesto toho je lepšie zobraziť nejakú prítulnejšiu stránku s rozumným popisom.

Vytvorme stránku `unknownEntity.jsp` v adresári `WEB-INF/jsp`, do ktorej uveďme nejaký prívetivý oznam o tom, že požadovaný objekt sa nenašiel.

Následne môžeme zadefinovať mapovanie medzi výnimkami a viewmi, ktoré sa majú zobraziť. V našom prípade môžeme namapovať výnimku `IllegalArgumentException` na view `unknownEntity`. Do súboru `springmvc-servlet.xml` dodáme deklaráciu beanu:
```xml
<bean id="exceptionHandler" 
      <!-- názov triedy bol zalomený -->
      class="org.springframework.
             web.servlet.handler.SimpleMappingExceptionResolver">
  <property name="exceptionMappings">
    <props>
      <prop key="IllegalArgumentException">unknownEntity</prop>
    </props>
  </property>
</bean>
```
Ak ľubovoľný z kontrolérov vyhodí výnimku `IllegalArgumentException`, zobrazí sa view `unknownEntity`.

# Ďalšie ovládacie prvky
Upravme si formulár pre editáciu študenta tak, aby používateľ nemusel zadávať ročník ako číslo do textového políčka, ale aby si ho pohodlne vybral z rozbaľovacieho zoznamu. V príslušnej JSP stránke môžeme nahradiť:
```html
<form:input path="year"/>
```
špeciálnou značkou, ktorá automaticky vygeneruje rozbaľovací zoznam:
```html
<form:select path="year" items="${allYears}"/>
```
Položky v zozname sa naplnia z premennej `allYears`, ktorú prirodzene musíme naplniť v kontroléri. 
```java
@ModelAttribute("allYears")
public Map<Integer, String> getAllYears() {
  Map<Integer, String> hodnoty = new TreeMap<Integer, String>();
  hodnoty.put(1, "prvák");
  hodnoty.put(2, "druhák");
  hodnoty.put(3, "tretiak");
  hodnoty.put(4, "štvrták");
  hodnoty.put(5, "piatak");

  return hodnoty;
}
```
V kontroléri stačí vytvoriť metódu, ktorá vracia buď zoznam objektov alebo mapu. Metódu treba anotovať pomocou `@ModelAttribute`, kde
určíme názov premennej v modeli, na ktorú sa namapuje výsledný zoznam. Keďže ju chceme namapovať na premennú `allYears`, jej názov
dodáme do anotácie. V našej metóde vytvoríme klasickú mapu (`TreeMap` preto, aby sa nám zachovalo poradie kľúčov), kde každej položke
dáme celočíselná identifikátor a reťazcový názov, ktorý sa zobrazí používateľovi. 

Táto metóda sa zavolá vždy – aj pred GET požiadavkou, aj pred POST požiadavkou a aj v prípade, že validácia objektu zlyhá. 
Ak by sme totiž modelovú mapu napĺňali len v metóde obsluhujúcej GET požiadavku a pri zadávaní dát do formulára by nastala chyba, vo formulári by sa hodnoty v zozname nezobrazili. Použitím takejto špeciálnej metódy však zaistíme korektné naplnenie zoznamu vo všetkých prípadoch.

# Kontroléry pre viacero akcií
Jeden kontrolér môže obsluhovať aj viacero akcií. Predstavme si, že by sme chceli v zozname študentov dodať položky pre vymazanie študenta a jeho postup do ďalšieho ročníka. Prvým nápadom by bolo vytvorenie dvoch kontrolérov (jedného pre mazanie a druhého pre postup) a ich namapovanie na dve URL adresy. Spring MVC však ponúka kontroléry, ktoré môžu mať každú metódu namapovanú na samostatnú URL adresu.

Príkladom je nasledovný kontrolér:
```java
@Controller
public class StudentActions {
  @Autowired
  private Database database;
  
  @RequestMapping("/deleteStudent.do")
  public String delete(Long studentId) {
    database.removeStudent(new Student(studentId));
    return "redirect:listStudents.do";
  }
  
  @RequestMapping("/advanceStudent.do")
  public String advance(Long studentId) {
    Student student = database.findById(studentId);
    student.setYear(student.getYear() + 1);
    return "redirect:listStudents.do";
  }
}
```
Metóda `delete()` je namapovaná na URL končiacu sa na `/deleteStudent.do` a očakáva parameter `studentId`. Druhá metóda sa vykoná analogicky pri zavolaní URL adresy typu `http://.../advanceStudent.do?studentId=2`.

Odkaz na tento kontrolér môžeme zaviesť do JSP stránky so zoznamom študentov, stačí do tabuľky dodať nové bunky:
```xml
<!-- hodnota atribútu href nesmie byť na viacerých riadkoch! -->
<td><a href='deleteStudent.do?studentId=
  <c:out value="${student.id}" />'>[ Delete ]</a></td>
<!-- hodnota atribútu href nesmie byť na viacerých riadkoch! -->
<td><a href='advanceStudent.do?studentId=
  <c:out value="${student.id}" />'>[ Advance to next year ]</a></td>
```

# Literatúra
* [Spring MVC Framework](http://static.springframework.org/spring/docs/2.5.x/reference/mvc.html ) - dokumentácia
* [Annotated Web MVC Controllers in Spring 2.5](http://blog.springsource.com/main/2007/11/14/annotated-web-mvc-controllers-in-spring-25/ )
