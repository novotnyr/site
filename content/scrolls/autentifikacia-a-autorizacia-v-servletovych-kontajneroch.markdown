---
title: Autentifikácia a autorizácia v servletových kontajneroch
date: 2008-03-27T23:22:28+01:00
---
# Úvod
Autentifikácia a autorizácia je súčasťou skoro každej významnej webovej aplikácie. Každý vývojar si tieto prvky zavádza do systému viacerými spôsobmi - buď vyvinutím vlastnej verzie alebo použitím niektorých z existujúcich riešení (napr. [Acegi Security](http://www.acegisecurity.org/ )). 

Jestvujú však prípady, keď si vystačíme s autentifikáciou a autorizáciou, ktorú poskytuje priamo špecifikácia servletov a implementujú ich jednotlivé servletové kontajnery.

V článku si ukážeme príklad jednoduchej aplikácie, ktorú zabezpečíme a nasadíme v kontajneroch Tomcat a Jetty.

# Vytvorenie servletov
Webová aplikácia bude minimalistická. Budú ju totiž tvoriť len dva servlety: jeden reprezentujúci verejne dostupnú zónu a iný predstavujúci zónu určenú len pre správcov.

```java
package webapp;
/* .. importy .. */
public class PublicServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request,  
                       HttpServletResponse response) 
  throws ServletException, IOException
  {
    PrintWriter out = response.getWriter();
    out.println("<h1>Public zone</h1>");
    out.println("<p>This is a public servlet</p>");
    out.flush();
  }  
}
```
a
```java
package webapp;
/* .. importy .. */

public class PrivateServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest request, 
                       HttpServletResponse response) 
  throws ServletException, IOException 
  {
    PrintWriter out = response.getWriter();
    out.println("<h1>Private zone</h1>");
    out.println("<p>This is a servlet in a private zone</p>");
    out.flush();
  }  
}
```
Oba servlety namapujeme klasickým spôsobom vo `web.xml`. Dohodneme sa, že všetky URL pod „adresárom" `/private` budú mapované na `PrivateServlet` a adresy pod `/public` bude obsluhovať `PublicServlet`.

Do `web.xml` teda pridáme:
```xml
<servlet>
  <servlet-name>PublicServlet</servlet-name>
  <servlet-class>webapp.PublicServlet</servlet-class>
</servlet>

<servlet>
  <servlet-name>PrivateServlet</servlet-name>
  <servlet-class>webapp.PrivateServlet</servlet-class>
</servlet>  

<servlet-mapping>
  <servlet-name>PublicServlet</servlet-name>
  <url-pattern>/public/*</url-pattern>
</servlet-mapping>


<servlet-mapping>
  <servlet-name>PrivateServlet</servlet-name>
  <url-pattern>/private/*</url-pattern>
</servlet-mapping>  
```

Základná idea spočíva:

* **v určení URL**, ktoré je treba zabezpečiť
* **v určení používateľských rolí**, ktoré majú právo pristupovať k zabezpečeným častiam
* **v určení spôsobu autentifikácie**, teda tým, ako bude používateľ zadávať meno a heslo

Všetky tieto náležitosti možno nakonfigurovať v súbore `web.xml`.

## Deklarácia používateľských rolí
V každej webovej aplikácii potrebujeme predovšetkým nadeklarovať všetky používateľské roly, ktoré sa budú používať. Na to slúži element `<security-role>`:
```xml
<security-role>
  <role-name>ADMIN</role-name>
</security-role>
```
Tento element zavedie rolu `ADMIN`. V prípade, že chceme zaviesť aj ďalšie roly, musíme ich uviesť vo viacerých elementoch `<security-role>` idúcich po sebe.
```xml
<security-role>
  <role-name>ADMIN</role-name>
</security-role>
<security-role>
  <role-name>MANAGER</role-name>
</security-role>
```
## Určenie zabezpečených častí aplikácie a oprávnené roly
Na vymedzenie zabezpečených častí webovej aplikácie slúži element `<security-constraint>` a jeho podelementy. Do `web.xml` dodáme nasledovný element:
```xml
<security-constraint>
  <web-resource-collection>
    <web-resource-name>Private Zone</web-resource-name>
    <url-pattern>/private/*</url-pattern>
  </web-resource-collection>
  <auth-constraint>
    <role-name>ADMIN</role-name>
  </auth-constraint>        
</security-constraint>
```
V ňom sme určili, že:

* zabezpečujeme URL adresy začínajúce sa na `/private/*`. Určili sme to v `<url-pattern>`e
* tie súhrnne označíme ako ``Private Zone`` (toto označenie však nemá hlbší zmysel) a to elementom `<web-resource-name>`.
* k týmto URL adresám bude mať prístup len autentifikovaný používateľ v role `ADMIN`.
## Spôsob autentifikácie
Už vieme, ktoré zóny webaplikácie sú bezpečné a vieme, ktorých používateľov do nich môžeme vpustiť. Chýba nám však nastavenie spôsobu, ktorým sa môžu používatelia do systému autentifikovať. V servletových kontajneroch máme k dispozícii 4 spôsoby:

* *HTTP Basic* autentifikácia. Klient zadá meno a heslo do dialógového okna, ktoré mu ponúkne prehliadač. (Nevýhodou je to, že okno vyzerá na každej platforme/prehliadači inak a môže používateľov zmiasť.) Heslo sa posiela v otvorenej forme, zakódované pomocou Base64.
* *HTTP Digest*. Analogické k *basic* autentifikácii, heslo sa posiela v hashovanej forme. Podľa špecifikácie to kontajner môže, ale nemusí podporovať.
* *Autentifikácia klientským certifikátom cez HTTPS*.
* *Autentifikácia HTML formulárom*. Do webovej aplikácie môžeme dodať vlastnú stránku s formulárom, pomocou ktorého sa môže klient autentifikovať.

### *HTTP Basic* autentifikácia
Pre jednoduchosť si uvedieme príklad najjednoduchšej *Basic* autentifikácie. Tú možno dosiahnuť dodaním elementu `<login-config>` do `web.xml`, pričom v podelemente `<auth-method>` uvedieme `BASIC`.
```xml
<login-config>
  <auth-method>BASIC</auth-method>	
  <realm-name>Admin</realm-name>	
</login-config>
```
Element `<realm-name>` určuje názov zóny, do ktorej sa chceme autentifikovať. Môže byť ľubovoľný, ale vzhľadom na to, že sa zobrazí v prihlasovacom okne v prehliadači, je vhodné ho nastaviť na nejaký prehľadný text.

# Konfigurácia mien a hesiel
Uvedením predošlých krokov sme ukončili konfiguráciu vo `web.xml`. Natíska sa však otázka, že kde vlastne nastavíme zoznam používateľov a ich heslá? To je však oblasť, ktorú špecifikácia servletov už nerieši a ponecháva ju na jednotlivých implementátorov servletových kontajnerov.

## Konfigurácia mien a hesiel v Jetty

V kontajneri Jetty to dosiahneme výberom vhodnej implementácie zóny (*realm*). K dispozícii máme tri zabudované:

* `HashUserRealm` ukladajúci dáta do textového súboru. Heslá môžu byť voliteľne zakryptované alebo uložené v hashovanej podobe.
* `JAASUserRealm` podporujúci autentifikáciu oproti modulu JAAS
* `JDBCUserRealm` pracujúci nad tabuľkou v SQL databáze.

Voľbu implementácie uvedieme do konfiguračného súboru príslušnej webovej aplikácie. Štandardne je to XML súbor v adresári `contexts` v inštalačnom adresári Jetty. V najjednoduchšom prípade vyzerá súbor nasledovne:
```xml
<?xml version="1.0"  encoding="ISO-8859-1"?>
<!DOCTYPE Configure 
  PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" 
  "http://jetty.mortbay.org/configure.dtd">

<Configure class="org.mortbay.jetty.webapp.WebAppContext">
  <Set name="contextPath">/secureapp</Set>
  <Set name="resourceBase">c:/java/secureapp/web</Set>
</Configure> 
```
### Načítavanie mien a hesiel zo súboru
Ak sa rozhodneme pre `HashUserRealm`, do elementu `<Configure>` dodáme element:
```xml
<Get name="securityHandler">
  <Set name="userRealm">
    <New class="org.mortbay.jetty.security.HashUserRealm">
      <Set name="name">Admin</Set>
      <Set name="config">
        c:/java/secureapp/web/WEB-INF/realm.properties
      </Set>
    </New>
  </Set>
</Get>
```
Vytvorili sme teda zónu, ktorá načítava mená a heslá z textového súboru `realm.properties` v danom adresári. Podotknime, že názov zóny (teda `Admin`) v atribúte `name` sa musí zhodovať s názvom zóny (`realm-name`) z `web.xml`.

 Súbor obsahuje položky v tvare
```
login:heslo,rola1,rola2,...
```
Ak chceme pridať používateľa `turing25` s heslo `tm` a priradiť mu rolu `ADMIN`, dodáme riadok:
```
turing25: tm,ADMIN
```
Reštartneme servletový kontajner a môžeme si vyskúšať zabezpečenú webovú aplikáciu.
### Načítavanie mien a hesiel z relačnej databázy
Mená a heslá môžeme tiež načítavať z relačnej databázy. Predstavme si jednoduchú dátovú štruktúru:

* `USER` obsahuje dáta používateľov
  : 

  ```
  CREATE TABLE user (
    id integer NOT NULL
    username varchar(64) NOT NULL,
    password varchar(45) NOT NULL,
    PRIMARY KEY  (id)
    )
  ```

* `ROLE` má zoznam rolí: 

  ```
  CREATE TABLE role (
  name varchar(64) NOT NULL,
  PRIMARY KEY  (name)
  )
  ```

* `USER_ROLE` predstavuje medzitabuľku v relácii M:N obsahujúcu vzťahy medzi používateľmi a rolami:

  ```
  CREATE TABLE user_roles (
  user_id integer NOT NULL,
  role varchar(45) NOT NULL
  )
  ```

  Do elementu `<Configure>` dodáme príslušný element konfigurujúci zónu:
```xml
<Get name="securityHandler">
  <Set name="userRealm">
    <New class="org.mortbay.jetty.security.JDBCUserRealm">
      <Set name="name">Admin</Set>
      <Set name="config">
          c:/java/secureapp/web/WEB-INF/jdbcRealm.properties
      </Set>
    </New>
  </Set>
</Get>
```
Oproti `HashUserRealm` sme zmenili len názov triedy a cestu ku konfiguračnému súboru. V ňom uvedieme nastavenia pre pripojenie k databáze:

1.  názov triedy ovládača

    ```
    jdbcdriver = com.mysql.jdbc.Driver
    ```

1.  URL k ovládaču

    ```
    url = jdbc:mysql://localhost/security
    ```

1.  prihlasovacie meno k databáze

    ```
    username = root
    ```

1.  heslo k databáze

    ```
    password = root
    ```

1.  názov tabuľky s používateľmi

    ```
    usertable = user
    ```

1.  primárny kľúč

    ```
    usertablekey = id
    ```

1.  stĺpec s menom používateľa

    ```
    usertableuserfield = username
    ```

1.  stĺpec s heslom

    ```
    usertablepasswordfield = password
    ```

1.  názov tabuľky s rolami

    ```
    roletable = role
    ```

1.  primárny kľúč

    ```
    roletablekey = name
    ```

1.  stĺpec s názvom roly

    ```
    roletablerolefield = name
    ```

1.  názov medzitabuľky používatelia-roly

    ```
    userroletable = user_roles
    ```

1.  cudzí kľúč s používateľom

    ```
    userroletableuserkey = user_id
    userroletablerolekey = role
    ```

1.  počet sekúnd, počas ktorých cacheovať načítané údaje

    ```
    cachetime = 300
    ```

Potrebujeme ešte získať JDBC driver k príslušnej databáze. V našom prípade používame MySQL ovládač. JAR knižnicu skopírujeme do adresára `lib` v inštalačnom adresári Jetty.

## Konfigurácia mien a hesiel v Tomcate
Podobne ako Jetty sú v Tomcate k dispozícii viaceré implementácie pre zónu (*realm*):

* *MemoryRealm* načítava mená a heslá z XML súboru
* *JDBCRealm* ich načítava z SQL databázy, pričom k nej pristupuje pomocou JDBC Drivera
* *DataSourceRealm* načítava dáta rovnako z SQL databázy, ale na pripojenie k nej používa JDBC DataSource.
* *JNDIRealm* používa ako zdroj dát LDAP server.
* *JAASRealm* je založený na štandarde JAAS.

Používanú implementáciu zóny nastavíme v konfiguračnom súbore webovej aplikácie. Štandardne je to súbor `názovAplikácie.xml` umiestnený v adresári `Catalina/localhost` v inštalačnom adresári Tomcatu. Minimalistický konfiguračný súbor vyzerá nasledovne:
```xml
<Context docBase="D:/projects/tomcat-security/web">
</Context>
```
Použitú implementáciu zóny dodáme pomocou elementu `<Realm>`.

### Načítavanie mien a hesiel zo súboru
```xml
<Context docBase="D:/projects/tomcat-security/web">
  <Realm className="org.apache.catalina.realm.MemoryRealm" 
         pathname="c:/java/secureapp/web/WEB-INF/users.xml" />
</Context>
```
Zadeklarovali sme teda zónu načítavajúcu používateľov z XML súboru, ktorého cestu sme uviedli do atribútu `pathname`. Ako vyzerá daný súbor `users.xml`? Jednoducho:
```xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <user username="turing25" password="tm" roles="ADMIN"/>
</tomcat-users>
```
V nej sme pridelili používateľovi `turing25` s heslom `25` rolu `ADMIN`. Ak má používateľ viacero rol, oddelíme ich čiarkou.

Následne reštartujeme server a naša aplikácia bude opäť zabezpečená.

Poznamenajme, že element `<Realm>` môžeme uviesť aj v rámci elementu `<Engine>`. V tom prípade budú nastavenia zóny platné pre všetkých virtuálnych hostiteľov a všetky webové aplikácie. Ak ho uvedieme v rámci `<Host>`, bude to platiť pre webaplikácie v rámci virtuálneho hostiteľa. Nastavenia na špecifickejšej úrovni prekrývajú globálnejšie nastavenia.

### Načítavanie mien a hesiel zo relačnej databázy
Podobne ako v prípade Jetty je možnosť načítavať mená a heslá z relačnej databázy. Tomcat však vyžaduje inú štruktúru databázy:

* `USER` obsahujúca používateľov

* `ROLE` s rolami

* `USER_ROLE` mapujúca mená používateľov na roly
  V prípade Jetty obsahovala medzitabuľka `USER_ROLE` celočíselné kľúče používateľov a názvy rol. V Tomcate musí obsahovať mená používateľov a názvy rol. Nekonzistenciu môžeme vyriešiť vytvorením SQL pohľadu:

  ```
  CREATE VIEW user_roles2 (username, role) AS
  (
  SELECT user.username, role.name
  FROM user_roles
  JOIN user ON user.id = user_roles.user_id
  JOIN role ON role.name = user_roles.role
  )
  ```

  Pre zónu použijeme implementáciu `JDBCRealm`, ktorú zadeklarujeme nasledovne:
```xml
<Realm className="org.apache.catalina.realm.JDBCRealm" debug="99"
       driverName="com.mysql.jdbc.Driver"
       connectionURL="jdbc:mysql://localhost/security"
       connectionName="root"
       connectionPassword="root"
       userTable="user" 
       userNameCol="username" 
       userCredCol="password"
         
       userRoleTable="user_roles2" 
       roleNameCol="role"
/>
```
* `userTable` obsahuje názov tabuľky s používateľmi
* `userNameCol` je názvom stĺpca s používateľskými menami
* `userCredCol` je názov stĺpca s heslami
* `userRoleTable` predstavuje názov medzitabuľky s mapovaním používateľských mien na roly
* `roleNameCol` je názov stĺpca s menom roly v medzitabuľke. 
* Názov stĺpca s menom používateľa v medzitabuľke sa prevezme z hodnoty `userNameCol`.

Pred reštartovaním servera vložíme JAR s JDBC ovládačom do adresára `lib` v inštalačnom adresári Tomcatu.

Nevýhodou Tomcatu v tomto prípade je absencia chybových hlášok v prípade, že sa niečo pokazilo (napr. že chýba JDBC ovládač). To nie je veľmi prívetivé chovanie, ale dúfajme, že v ďalších verziách sa zlepší.

# Autentifikácia pomocou HTML formulára

V príklade sme spomenuli autentifikáciu pomocou *HTTP Basic*. Ako alternatívu je možné použiť spôsob, v ktorom používateľ bude zadávať údaje do HTML formulára. Výhodou je možnosť prispôsobiť vzhľad prihlasovacej obrazovky zvyšku aplikácie.

Správanie v aplikácii bude nasledovné:
1.  používateľ navštívi stránku, ktorá požaduje autentifikáciu
1.  server presmeruje používateľa na prihlasovaciu stránku. URL stránky, ktorá požaduje prihlásenie si zapamätá.
1.  použivateľ sa prihlási vyplnením dát vo formulári
1.  ak sú prihlasovacie údaje správne, server ho presmeruje na pôvodnú stránku
1.  v opačnom prípade ho server presmeruje na chybovú stránku

## Vytvorenie prihlasovacej stránky

Prihlasovacia stránka je klasická HTML stránka so špeciálnym formulárom:
(:source lang=html:)

```html
<h1>Prihlásenie do systému</h1>
<form method="POST" action="j_security_check">
  Meno: <input type="text" name="j_username"> <br />
  Heslo: <input type="password" name="j_password"> <br />
  <input type="submit" value="Prihlásiť sa" />
</form>
```

Na tejto stránke nie je nič význačné. Do pozornosti dávame akurát názvy políčok. Meno používateľa musí byť uvádzané do ovládacieho prvku s názvom `j_username`, heslo do prvku s názvom `j_password`. Formulár musí byť namapovaný na akciu `j_security_check` (po spustení sem server dosadí vhodnú URL adresu).

## Nastavenie formulárovej autentifikácie
Ďalším krokom je zmena druhu autentifikácie vo `web.xml`. Element `<login-config>` upravíme nasledovne:
```xml
<login-config>
  <auth-method>FORM</auth-method>	
  <realm-name>Admin</realm-name>	
  <form-login-config>
    <form-login-page>/login.html</form-login-page>
  </form-login-config>
</login-config>
```
Zmenili sme teda `auth-method` na `FORM` a dodali sme element `<form-login-config>`. V ňom sme nastavili adresu k stránke, ktorá bude slúžiť na prihlásenie.

Ak sa prihlásiť nepodarí, zobrazí sa chybová stránka, ktorej vzhľad je závislý na serveri (a teda je často neprívetivý). Preto je lepšie nastaviť si vlastnú chybovú stránku, čo dosiahneme dodaním elementu `<form-error-page>` pod `<form-login-config>`:
```xml
<form-login-config>
  <form-login-page>/login.html</form-login-page>
  <form-error-page>/error.html</form-error-page>
</form-login-config>
```
Ostáva si vytvoriť príslušnú HTML stránku. Uložíme ju `error.html` do adresára `web` v adresári webaplikácie.
```
<h1>Chyba pri prihlásení!</h1>
Zadali ste nesprávne meno alebo heslo.
```

# Programová kontrola autorizácie
Niekedy je potrebné, aby sme pristupovali k prihlasovacím informáciám priamo zo servletu. Chceli by sme napríklad vedieť, či je používateľ prihlásený a pod akým menom a prípadne rolu, v ktorej vystupuje. Trieda [`HttpServletRequest`](http://java.sun.com/j2ee/1.4/docs/api/javax/servlet/http/HttpServletRequest.html ) dáva k dispozícii dve významné metódy:

* [`getUserPrincipal()`](http://java.sun.com/j2ee/1.4/docs/api/javax/servlet/http/HttpServletRequest.html#getUserPrincipal() ) vráti objekt `Principal` obsahujúci meno aktuálne prihláseného používateľa. V prípade, že používateľ nie je prihlásený, vráti `null`. Použiť ho teda môžeme napr. takto:

  ```java
  Principal principal = request.getUserPrincipal();
  if(principal != null) {
  		out.println("Prihlásený používateľ: " + principal.getName());
  }
  ```
* [`isUserInRole()`](http://java.sun.com/j2ee/1.4/docs/api/javax/servlet/http/HttpServletRequest.html#isUserInRole(java.lang.String) ) vráti `true` ak vystupuje používateľ pod danou rolou. (Názvy rolí musia byť nadeklarované vo `web.xml`.)

# Referencie
* [Jetty a Realms](http://docs.codehaus.org/display/JETTY/Realms )
* [Konfigurácia zón v Tomcat 6.0](http://tomcat.apache.org/tomcat-6.0-doc/realm-howto.html ) (dokumentácia)
* [Web FORM-based authentication](http://www.onjava.com/pub/a/onjava/2001/08/06/webform.html ) (O'Reilly)
* [J2EE Form Based Authentication](http://www.onjava.com/pub/a/onjava/2002/06/12/form.html ) (O'Reilly) - nastavenie pre Tomcat a Oracle
* Kapitola SRV.12 (Security) v špecifikácii [Java Servlet 2.4 Specification](http://jcp.org/aboutJava/communityprocess/final/jsr154/index.html ) (JSR-154)
* Root.cz – [Bezpečnost aplikačního serveru JBoss](http://www.root.cz/clanky/bezpecnost-aplikacniho-serveru-jboss/ ) - opis toho, ako je možné analogickým spôsobom zabezpečiť webovú aplikáciu v JBosse.
* [Pepa Cacek – Zabezpečení webových aplikací](http://javlog.cacek.cz/2007/10/zabezpeen-webovch-aplikac.html)
