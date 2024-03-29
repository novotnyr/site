---
title: Jednoduchý príklad použitia Hibernate 
date: 2005-04-17T17:26:10+01:00
---

# Úvod
Hibernate (http://www.hibernate.org) je nástroj podporujúci objektovú perzistenciu -- v preklade: umožňuje ukladať objekty do databázy a následne ich z nej vyberať (často sa možno stretnúť so pojmom *ORM -- Object Relational Mapping*). Výhodou je jeho ľahké používanie, stabilita a rozšírenosť.

# Príklad
Uvažujme niekoľko jednoduchých tried, ktoré sa zaoberajú mačkami. Majme koncept mačky: mačka má meno a deti. Teda môžeme ju reprezentovať triedou `Cat`.

```java
package catology;

import java.util.HashSet;
import java.util.Set;

public class Cat {
  private String name;
  
  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }
 
  
  protected Set children = new HashSet();

  public Set getChildren() {
    return this.children;
  }

  private void setChildren(Set children) {
    this.children = children;
  } 
  
  public void addChild(Cat child) {   
    this.children.add(child);   
  }
}
```

Táto trieda je veľmi jednoduchá, vidíme, že neimplementuje žiadny špeciálny interfejs. Jej použitie je tiež priamočiare.

```java
Cat parent = new Cat();
parent.setName("Pigislav");

Cat child = new Cat();
child.setName("Poldo");   

parent.addChild(child);
```

Teraz by sme chceli uložiť mačku do databázy. Mohli by sme to urobiť dvoma spôsobmi: buď jednoducho vytvoriť pomocnú triedu, ktorá by z objektu typu `Cat` vytiahla príslušné vlastnosti, spojila sa s databázou a odoslala zodpovedajúci SQL dopyt typu `INSERT`.

Hibernate tento proces v prípade komplikovaných tried, alebo ich veľkého počtu, značne uľahčuje. 

## Základ
Majme teda uvedenú triedu `Cat`. 

## Konfiguračný súbor
Predovšetkým potrebujeme nakonfigurovať základné vlastnosti: použitú databázu, jej JDBC ovládač a podobne. Na to slúži súbor `hibernate.cfg.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE hibernate-configuration
  PUBLIC "-//Hibernate/Hibernate Configuration DTD//EN" 
  http://hibernate.sourceforge.net/hibernate-configuration-2.0.dtd">

<hibernate-configuration>
  <session-factory >
    <!-- local connection properties -->
    <property name="hibernate.connection.url">jdbc:mysql://localhost:3306/macky</property>
    <property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
    <property name="hibernate.connection.username">root</property>
    <property name="hibernate.connection.password">root</property>
    <!-- dialect for MySQL -->
    <property name="dialect">net.sf.hibernate.dialect.MySQLDialect</property>

    <property name="hibernate.show_sql">true</property>
    <property name="hibernate.use_outer_join">false</property>
    <property name="hibernate.transaction.factory_class">net.sf.hibernate.transaction.JDBCTransactionFactory</property>

    <property name="jta.UserTransaction">java:comp/UserTransaction</property>

    <mapping resource="catology/Cat.hbm.xml"/>

  </session-factory>
</hibernate-configuration>
```

V súbore sú uvedené základné konfiguračné vlastnosti (adresa databázy, ovládač, meno a heslo). Vlastnosť `dialect` udáva typ použitého dialektu SQL databázy -- Hibernate na základe neho vykonáva isté optimalizácie. Tu je zjavná ďalšia výhoda: jednoduchá migrácia medzi rôznymi databázami.


## Tabuľky v DB
Budeme potrebovať dve tabuľky: `CAT` a `PARENT_CHILD` (predpokladáme, že každá mačka môže mať viac detí a každé dieťa môže mať viac rodičov). Pre jednoduchosť sa nebudeme zaoberať cudzími kľúčmi.

```sql
CREATE TABLE cat (ID INTEGER NOT NULL, MENO VARCHAR(20) NOT NULL, PRIMARY KEY(ID))

CREATE TABLE parent_child (ID_PARENT INTEGER NOT NULL, ID_PARENT INTEGER NOT NULL)
```

## Mapovacie súbory
Problémom je, ako namapovať triedy na databázové tabuľky. Každá hibernovaná trieda má svoj vlastný konfiguračný XML súbor s príponou `hbm.xml` -- tzv. mapovací súbor. Napr. uvedenej triede `Cat.java` zodpovedá nasledovný súbor `Cat.hbm.xml`.

```xml
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC
        "-//Hibernate/Hibernate Mapping DTD 2.0//EN"
        "http://hibernate.sourceforge.net/hibernate-mapping-2.0.dtd">

<hibernate-mapping>

  <class name="catology.Cat" table="cat">
  
    <id name="id" column="id" type="java.lang.Long">
      <generator class="increment"/>
    </id>
  
    <property name="name" column="meno" type="string"/>     

    <set name="children" table="parent_child" cascade="save-update">
    
      <key column="parent"/>
    
      <many-to-many column="child" class="catology.Cat"/>
    </set>
  
  </class>

</hibernate-mapping>
```

### Popis elementov mapovacieho súboru
#### Element class
```xml
<class name="catology.Cat" table="cat">
```
Tento element určuje, že javovská trieda (`name`) sa mapuje na danú tabuľku (`table`).

#### Element id
```xml
<id name="id" column="id" type="java.lang.Long">
  <generator class="increment"/>
</id>
```
Pri konštrukcii triedy `Cat.java` sme zatajili jeden detail -- každá hibernovaná trieda by mala mať špeciálny dátový člen, tzv. identifikátor. Preto definíciu `Cat.java` doplníme o privátny dátový člen `Long id`, s príslušnými metódami `get()` a `set()`. Tento identifikátor využíva Hibernate na rôzne účely (napr. na detekciu, či už bol daný objekt hibernovaný, alebo nie).
Element `id` špecifikuje názov dátového člena (`name`), stĺpec v tabuľke, na ktorý sa identifikátor mapuje (`column`) a javovský dátový typ (`type`) identifikátora. Element `generator` identifikuje algoritmus, pomocou ktorého bude Hibernate identifikátory pre danú triedu generovať -- v princípe nás to ale nemusí zaujímať. Jediné čo potrebujeme urobiť, je špecifikovať v triede jeden špeciálny dátový člen pre identifikátor a príslušné mapovanie. Identifikátor nemusíme pri tvorení inštancie triedy vôbec nastavovať.

#### Elementárne členy
```xml
<property name="name" column="meno" type="string"/>
```
Tento element predstavuje mapovanie jednoduchého dátového člena (napr. reťazca, čísla a pod.) V našom prípade sa dátový člen `name` (`name`) mapuje na tabuľkový stĺpec `meno` (`column`), pričom je dátového typu `java.lang.String`)

#### Kompozitné dátové členy
```xml
<set name="children" table="parent_child" cascade="save-update">    
  <key column="parent"/>    
  <many-to-many column="child" class="catology.Cat"/>
</set>
```
Toto je prípad jedného typu kompozitného člena -- napr. množiny, zoznamu či podobnej štruktúry. V Hibernate možno týmto spôsobom reprezentovať viacero asociácií medzi triedami, typicky vzťahy 1-1, 1:m, m:n (rodič-dieťa, agregácia). V našom prípade máme asociáciu rodič-dieťa typu m:n.
Element `set` reprezentuje množinu. Dátový člen `children` je „rozbitý" v tabuľke `parent_child`, pričom stĺpcom identifikujúcim rodiča je `parent`. Element `many-to-many` indikuje, že máme asociáciu m:n, pričom deti sú v stĺpci `child` a sú daného javovského typu.

Atribút `cascade="save-update"` upovedomí Hibernate, že pri hibernácii danej triedy má zároveň hibernovať aj asociované triedy: v našom prípade sa pri hibernovaní rodiča automaticky hibernujú aj jeho deti.

Na mapovanie ostatných typov odkazujeme do dokumentácie, prípadne do stránok s prehľadom asociácií a ich mapovaní (http://www.xylax.net/hibernate/index.html).

## Proces hibernácie a dehibernácie
Proces hibernácie je potom pomerne priamočiary (neuvádzame odchytávanie výnimiek)
```java
//nakonfigujueme tovaren, ktora nam bude davat sessiony s Hibernate
sessionFactory = new Configuration()
  .configure(new java.io.File("/home/user/catology/bin/hibernate.cfg.xml"))
  .buildSessionFactory();

//vytvorime triedy, ktore chceme hibernovat
Cat parent = new Cat();
parent.setName("Pigislav");
Cat child = new Cat();
child.setName("Poldo"); 
parent.addChild(child);

//vyziadame si session
Session session = sessionFactory.openSession();
//zacneme transakciu (v duchu transakcii v DB)
Transaction tx = session.beginTransaction();

//hibernujeme triedu (to je vsetko!)
session.save(parent);

//commitneme transakciu
tx.commit();         

//skoncime session 
session.close();
```

Analogicky môžeme jednoducho dehibernovať triedy. Na získavanie tried z databázy jestvuje mnoho metód a Hibernate dokonca definuje vlastný jazyk jemne rozširujúci SQL o objektové črty.

```java
//nakonfigujueme tovaren, ktora nam bude davat sessiony s Hibernate
sessionFactory = new Configuration()
  .configure(new java.io.File("/home/user/catology/bin/hibernate.cfg.xml"))
  .buildSessionFactory();

//vyziadame si session
Session session = sessionFactory.openSession();
//zacneme transakciu (v duchu transakcii v DB)
Transaction tx = session.beginTransaction();

//chcem vsetky macky! ("from Cat") je vyraz dopytovacieho jazyka
List result = session.find("from Cat");         

Cat c = null;
Cat kitten = null;

//iterujeme zoznam maciek
for(int i = 0; i < result.size(); i++) {
  c = (Cat) result.get(i);            
  System.out.println(c.getName());

  //iterujeme cez deti macky a vypisujeme ich
  Iterator it = c.getChildren().iterator(); 
  while(it.hasNext()) {
    kitten = (Cat)it.next();
    System.out.println("  " + kitten.getName());
  }           
}

//commitneme transakciu
tx.commit();         

//skoncime session 
session.close();
```

# Odkazy

* http://www.xylax.net/hibernate/index.html
* http://www.gloegl.de/14.html

# Riešenie problémov

## `No appenders could be found...`
Vypisuje to chybu `log4j:WARN No appenders could be found for logger (net.sf.hibernate.cfg.Environment)`

**Riešenie:** v koreňovom adresári aplikácie chýba `log4.properties`.

## `Unable to configure...`
Vypisuje to `unable to configure "/hibernate.cfg.xml"`

**Riešenie:** na konfiguráciu použite absolútnu cestu ku konfiguračnému súboru

```
sessionFactory = new Configuration().configure(new java.io.File("D:\\Projects\\catology\\bin\\catology\\hibernate.cfg.xml")).buildSessionFactory();
```
## `Transaction not found..`

V tutoriáli na Gloegl.de sa používa `net.sf.hibernate.transaction.JTATransactionFactory` a nejde to! `Transaction not found`!

**Riešenie:** Továreň v tutoriáli treba v mapovacom subore `*.cfg.xml` nahradiť továrňou `net.sf.hibernate.transaction.JDBCTransactionFactory`,
podrobnosti napr. na http://www.eclipseplugincentral.com/PNphpBB2+file-viewtopic-t-682-sid-f85fed51a0dc5f6ca54b34c7817d63b4.html .

## Identifikátor bol zmenený z 5 na 5
Hádže to výnimku s popisom, že identifikátor bol zmenený z 5 na 5!

**Riešenie:** Skontrolujte dátové typy, na IDcka je vhodne pouzivat primitivny datovy typ `long`, alebo este lepsie `java.lang.Long`. Hibernate vam chce naznacit, ze datovy typ 5 sa zmenil, ale na konzole to nie je vidiet ;-)

## Hierarchia sa neukladá
Moja nadherna hierarchia rodicov a deti sa neuklada do databazy!

**Riešenie:** Treba uviest atribut `cascade` s prislusnou hodnotou. Ak nie je atribut uvedeny, podradene objekty treba ukladat do DB rucne. Priklad pre automaticke ukladanie hierarchie:
```xml
<set name="children" table="parent_child" cascade="save-update">
```

## `Batch update row count wrong`
Bliaka to, ze `Batch update row count wrong`!

**Riešenie:** Atribut `unsaved-value` nie je nastaveny. Ak identifikacny atribut nema implicitnu hodnotu `null` (to je v pripade primitivnych typov ako napr. `long`), je potrebné uviesť implicitnu hodnotu. 

**Riešenie 2:** Alternativne je uzitocne pouzivate neprimitivne typy:
```java
public class Cat {
  private Long id;
  
  public Long getId() {
     return id;
  }
  
  public void setId(Long id) {
     this.id = id;
  }
}
```
```xml
<id name="id" column="id" type="java.lang.Long">
```

## Triedy sa neukladajú
Moje inštancie sa neukladajú do databázy! Vypíše sa, že prebehol `INSERT`, ale v databáze sa nič nezmenilo!

**Riešenie:** Skontrolujte, či ukladanie prebieha v rámci transakcie. Ak nepoužívate transakcie, je stále možné použiť najprimitívnejší spôsob a to vypnutím autocommitu JDBC pripojení. Dodajte konfiguračné nastaveniee

```
hibernate.connection.autocommit = true
```

a pred uzatvorením sessionu ho flushnite (Hibernate totiž kvôli optimalizácii zoskupuje dopyty a odošle ich až v prípade potreby)

```java
Session session = factory.openSession();
try {
  Hotel hotel = new Hotel("Plaza", "Main Street 1", 4);
  session.saveOrUpdate(hotel);
			
  Hotel hotel2 = new Hotel("Continental", "Turing Street 1", 5);
  session.saveOrUpdate(hotel2);
} finally {
  session.flush();
  session.close();
}
```

# FAQ

## Aký je rozdiel medzi `get()` a `load()`?
* load nacita proxy, nastavi len jej id, zvysok dotahuje lazy
* get natiahne komplet objekt



