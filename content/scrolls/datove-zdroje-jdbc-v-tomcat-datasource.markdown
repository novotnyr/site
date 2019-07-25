---
title: Dátové zdroje JDBC v Tomcate 
date: 2007-09-27T10:44:11+01:00
---
Predpokladajme, že chceme sprístupniť v Tomcate globálny dátový zdroj JDBC dostupný cez JNDI vyhľadávanie. Globálnosť v tomto prípade znamená, že ho definujeme v Tomcate ako globálny JNDI zdroj.

# Zadefinovanie globálneho JNDI zdroja.
V Tomcate 5.5.x zadefinujeme globálny dátový zdroj buď pomocou administrátorského panela, alebo manuálne. V prípade manuálnej konfigurácie vložíme do `server.xml` do elementu `<GlobalNamingResources>`
```xml
<Resource 
 auth="Container" 
 name="jdbc/MyDataSource" 
 type="javax.sql.DataSource" 
 url="jdbc:db2://dbserver:50000/mydb"
 driverClassName="com.p6spy.engine.spy.P6SpyDriver"
 username="xxx"
 password="xxx"
 maxActive="20"
 maxIdle="10"
 maxWait="-1"    
/>
```
# Zadefinovanie odkazu na globálny zdroj v deskriptore kontextu.
(Tento krok je, zdá sa, voliteľný.) Do deskriptora kontextu (typicky v adresári `%CATALINA_HOME%/conf/Catalina/localhost/nazovKontextu.xml`) pridáme odkaz na globálny JNDI zdroj. 
```xml
<ResourceLink name="jdbc/MyDataSource" global="jdbc/MyDataSource" type="javax.sql.DataSource" />
```
# Zadefinovanie odkazu na globálny zdroj vo `web.xml`
V deskriptore nasadenia (`web.xml`) pridáme odkaz na globálny zdroj.
```xml
<resource-ref>
  <res-ref-name>jdbc/MyDataSource</res-ref-name>
  <res-type>javax.sql.DataSource</res-type>
  <res-auth>Container</res-auth>
</resource-ref>
```
