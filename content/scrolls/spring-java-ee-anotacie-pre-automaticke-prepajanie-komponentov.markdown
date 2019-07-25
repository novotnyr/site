---
title: Spring 3.0, JEE 6 a anotácie pre automatické prepájanie komponentov 
date: 2010-01-11T22:50:33+01:00
---

Od čias Springu 2.5 je k dispozícii sada anotácií, ktoré riešia *dependency injection*. (Viď [existujúci článok](Java/AnotacieVSpring25 ).) V nej boli dané k dispozícii jednak springovské anotácie (`@Component` a pod.) a jednak anotácie z JSR-250 (najmä `@Resource`).

Od tých čias sa situácia ešte „skomplikovala". Medzičasom totiž vyšla finálna špecifikácia JEE6, ktorá rieši dependency injection v rámci dvoch JSR.

* **JSR-330**: Dependency Injection for Java vznikla z potrieb DI frameworkov Spring a Google Guice, kde dali hlavy dohromady Rod Johnson a Crazy Bob Lee.
* **JSR-299**: Contexts and Dependency Injection for the Java EE platform (alias Web Beans, pod vedením Gavina Kinga z JBossu), ktoré stavajú na JSR-330, a obohacujú DI o ďalšie vlastnosti. Táto JSR je v podstate abstrakciou funkcionality, ktorú poskytuje JBoss Seam.

Spočiatku to vyzeralo tak, že špecifikácie vznikli vzájomne „na truc". Vo úvodnej fáze *review* Red Hat (teda JBoss) vyjadril hlboké pochybnosti o zmysle JSR-330 (niet divu, veď sa to isté snažil riešiť po svojom). Po troche politických bojov sa však obe špecifikácie zladili, a Red Hat ju odsúhlasil s dodatkom, že očakáva ďalšiu spoluprácu medzi oboma štandardmi. Ako tvrdí viacero článkov, oba treba chápať ako vzťah známy JDBC a JPA. Existuje v nich prienik, ale jedna (299) je nadstavbou druhej (330). (Je len zaujímavé, že [IBM neskôr zmenila svoj názor](http://jcp.org/en/jsr/results?id=4992 ), pretože vidí v JSR-330 značné technické nedostatky a nesplnenie zámeru.)

# JSR-330
Táto špecifikácia definuje päť anotácií a jeden interfejs, ktorými možno dosiahnuť DI. Samotnú implementáciu a spôsob prepájania však ponecháva na konkrétnu implementáciu prislušného DI frameworku.

Všetky anotácie sú z balíčka `javax.inject`.

* `@Inject` – anotuje konštruktory, metódy či inštančné premenné, do ktorých majú byť injektnuté inštancie beanov.
* `@Qualifier` – anotácia anotácií, ktorými možno bližšie obmedziť / špecifikovať injektovanie. 
* `@Scope` – metaanotácia, ktorá definuje anotácie zodpovedajúce §§scope§§om, teda rozsahom platnosti. V prípade injektovania sa implicitne (ak chýba anotácia) predpokladá `prototype` scope (teda non-singleton), čiže s každým injektovaním sa vytvára nová inštancia injektovaného beanu
* `@Singleton` – anotácia typu `@Scope`, ktorá indikuje, že anotovaný typ bude pri injektovaní používaný ako singleton.
* `@Named` – umožní bližšie špecifikovať injektovaný bean. Odporúča sa používať len v prípade kontajnerov, ktoré označujú beany identifikátorom (čo je prípad Springu). V špecifikácii JEE6 má ešte jeden význam: ak je ňou anotovaná trieda, možno k nej pristupovať v rámci expression language (napr. v JSF šablónach). 

Ukážme si jednoduchý príklad v ktorom sa používajú anotácie.

# Springovské anotácie
Majme interfejs na generovanie citátov:
```java
package sk.novotnyr.quotes;

public interface QuoteGenerator {
  public String getQuote();
}
```
a jeho jednoduchú implementáciu:
```java
package sk.novotnyr.quotes;

public class HardwiredQuoteGenerator implements QuoteGenerator {

  public String getQuote() {
    return "Spring is gr8";
  }

}
```
A okrem toho majme triedu, ktorá bude vypisovať citáty na štandardný výstup:
```java
public class QuotePrinter {
  private QuoteGenerator quoteGenerator;
  
  public void print() {
    String quote = quoteGenerator.getQuote();
    System.out.println(quote);
  }

  // gettre a settre
}
```

V JSR-330 je k dispozícii anotácia `@Inject`, ktorá indikuje nutnosť injektovania inštancie. Keďže `QuotePrinter` vyžaduje inštanciu `QuoteGenerator`a, injektovanie označíme anotáciou.
```java
public class QuotePrinter {
  @Inject
  private QuoteGenerator quoteGenerator;
  
  public void print() {
    String quote = quoteGenerator.getQuote();
    System.out.println(quote);
  }
}
```
Do `quoteGeneratora` sa automaticky nawireuje implementácia príslušného rozhrania (prebieha detekcia podľa typu, v kontexte sa musí nájsť práve jedna implementácia, inak nastane výnimka). Ak použijeme `@Inject` na inštančnej premennej, nemusíme dokonca poskytnúť gettre a settre.

Ostáva ešte jedna „drobnosť: ako zaregistrovať beany v aplikačnom kontexte? Klasických možností je viac:

* buď ich uvedieme do XML deskriptora aplikačného kontextu
* alebo ich anotujeme pomocou springovskej anotácie `@Component`
Treťou možnosťou je využitie JSR-330 anotácie `Named`. Ak je ňou anotovaný typ, Spring ho automaticky odhalí a zaradí do aplikačného kontextu.
```java
@Named
public class QuotePrinter {
```
a
```java
@Named
public class QuoteGenerator {
```

Teraz už môžeme vytvoriť aplikačný kontext. V tomto prípade môžeme s výhodou využiť triedu `AnnotationConfigApplicationContext`:
```java
AnnotationConfigApplicationContext context 
   = new AnnotationConfigApplicationContext("sk.novotnyr.quotes");
QuotePrinter printer = context.getBean(QuotePrinter.class);
for (int i = 0; i < 3; i++) {
  printer.print();
}
```
Trieda automaticky vyhľadá v balíčku `sk.novotnyr.quote` nielen triedy anotované ako `Named`, ale aj všetky triedy so springovským stereotypom `@Component` (teda všetky triedy anotované ako `@Component`, `@Repository`, `@Service` a `@Controller`).

Anotácia `@Named` môže byť použitá v prípade, že chceme pri injektovaní presnejšie vyšpecifikovať použitý bean (napr. v prípade, že sa v aplikačnom kontexte nachádza viacero implementácií daného interfejsu):
```java
@Inject
@Named("HardwiredQuoteGenerator")
private QuoteGenerator quoteGenerator;
```
V tomto prípade sa injektne ten bean, ktorý má v triede anotáciu `@Named("HardwiredQuoteGenerator")`.

Nezabúdajme na to, že v tomto prípade prebehne §§prototype§§ injektovanie. Vytvorí sa teda toľko inštancií `QuoteGeneratora`, koľko je inštancií `QuotePrintera`. Ak chceme mať `QuoteGenerator` ako singleton, musíme ho tak označiť.
```java
@Named("HardwiredQuoteGenerator")
@Singleton
public class HardwiredQuoteGenerator
```

# Vzťah k JSR-250
Z predošlého článku si pamätáme, že injektovanie možno dosiahnuť aj pomocou anotácií `javax.annotation.Resource` a `javax.annotation.WebServiceRef`, kde prvá z nich slúžila jednak v úlohe anotovania beanu, ktorý sa má zaviesť do kontextu, jednak v úlohe anotácie `@Inject` a zároveň v nej bolo možné pomenovávať beany a bližšie špecifikovať odkaz na ne (teda obe úlohy `@Named`).

Špecifikácia JSR-250 však uvádza, že *„The `@Resource` annotation is used to declare a reference to a resource such as a data source, an enterprise bean, or an environment entry,"* teda anotácia `@Resource` deklaruje odkaz na zdroj/prostriedok, ako napr. dátový zdroj enterprise bean či premenná prostredia.

Podľa dokumentácie (*The Java EE 6 Tutorial, Volume I*) a špecifikácie JSR-250 je úloha tejto anotácie skôr spätá s JNDI. V prípade jej použitia na triede sa z atribútu `name` odvodí JNDI meno, pod ktorým sa inštancia zaregistruje do JNDI kontextu. Ak je použitá na mene, z názvu premennej sa odvodí kľúč do JNDI kontextu, z ktorého sa inštancia vytiahne. 

# Vzťah k Springu
| Spring                                         | JSR-330              |
| ---------------------------------------------- | -------------------- |
| `@Component`                                   | `@Named` nad triedou |
| `@Autowire`                                    | `@Inject`            |
| `@Qualifier` na inštančnej premennej či metóde | `@Named`             |

# Referencie

* [Introduction to Contexts and Dependency Injection for the Java EE Platform](http://docs.sun.com/app/docs/doc/820-7627/gjbnr?a=view )
* [Announcing @javax.inject.Inject](http://crazybob.org/2009/05/announcing-javaxinjectinject.html ) -- pôvodné oznámenie Crazy Bob Leeho
* [What Is The Relation Between JSR-299 and JSR-330 In Java EE 6? Do We Need Two DI APIs? ](http://java.dzone.com/articles/what-relation-betwe-there )

