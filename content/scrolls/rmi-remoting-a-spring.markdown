---
title: RMI remoting a Spring 
date: 2007-07-24T00:11:57+01:00
---

Spring podporuje automatické publikovanie zvoleného interfaceu v podobe RMI triedy.

Majme jednoduchý interface:

```java
package spring.rmi;

import java.util.Date;

public interface DateService {
  public Date getDate();
}
```

a jeho implementáciu, ktorá vracia aktuálny dátum

```java
package spring.rmi;

import java.util.Date;

public class DateServiceImpl implements DateService {
  public Date getDate() {
    return new Date();
  }
}
(:sourceend:)
```

Všimnime si, že ani interfejs ani jeho implementácia nemajú v sebe nič špeciálne. Sú to klasické triedy, ktoré dokonca nepoužívajú nič z technológie RMI. Na rozdiel od klasického prístupu tak nemusíme vytvárať vzdialený interfejs (teda interfejs dediaci od `java.rmi.Remote`).

Všimnime si, že ani interfejs ani jeho implementácia nemajú v sebe nič špeciálne. Sú to klasické triedy, ktoré dokonca nepoužívajú nič z technológie RMI. Na rozdiel od klasického prístupu tak nemusíme vytvárať vzdialený interfejs (teda interfejs dediaci od `java.rmi.Remote`).

Vytvoríme aplikačný kontext pre klienta, ktorý bude obsahovať nasledovné beany:

```xml
<bean id="dateService" class="spring.rmi.DateServiceImpl" />

<bean class="org.springframework.remoting.rmi.RmiServiceExporter">
  <property name="serviceName" value="DateService" />
  <property name="service" ref="dateService" />
  <property name="serviceInterface" value="spring.rmi.DateService" />
</bean>
```


Prvý bean reprezentuje deklaráciu implementácie interfaceu pre službu. Druhý bean predstavuje automatický exportér interfaceu v podobe RMI serveru.

* `serviceName` určuje názov služby. Má vplyv na URL endpointu a nemusí mať nič spoločné s názvom interfaceov alebo implementačných tried.
* `service` predstavuje odkaz na bean obsahujúci samotnú aplikačnú logiku
* `serviceInterface` predstavuje meno interfaceu, ktorý implementuje bean v `service` a ktorý bude publikovaný ako vzdialený.

## Kód pre server
Samotný kód pre server je jednoduchý - stačí naštartovať aplikačný kontext.

```java
package spring.rmi;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class Server {
  public static void main(String[] args) {
    ClassPathXmlApplicationContext ctx 
      = new ClassPathXmlApplicationContext("applicationContext.xml");
  }
}
```

Aplikačný kontext sa naštartuje spolu so serverom:
```
INFO Refreshing org.springframework.context.support.ClassPathXmlApplicationContext@14693c7: display name [org.springframework.context.support.ClassPathXmlApplicationContext@14693c7]; startup date [Fri Aug 24 13:07:17 CEST 2007]; root of context hierarchy
INFO Loading XML bean definitions from class path resource [applicationContext.xml]
INFO Bean factory for application context [org.springframework.context.support.ClassPathXmlApplicationContext@14693c7]: org.springframework.beans.factory.support.DefaultListableBeanFactory@291aff
INFO Pre-instantiating singletons in org.springframework.beans.factory.support.DefaultListableBeanFactory@291aff: defining beans [dateService,org.springframework.remoting.rmi.RmiServiceExporter]; root of factory hierarchy
INFO Looking for RMI registry at port '1099'
INFO Could not detect RMI registry - creating new one
INFO Binding service 'DateService' to RMI registry: RegistryImpl[UnicastServerRef [liveRef: [endpoint:[158.197.31.35:1099](local),objID:[0:0:0, 0]]]]

```

# Klient
Na strane klienta budeme potrebovať len tri súbory: interface `DateService`, triedu pripájajúcu sa na server a aplikačný kontext. RMI totiž podporuje automatické načítavanie tried (classloading) zo servera.

Aplikačný kontext bude špecifikovaný nasledovne (napr. v súbore `clientContext.xml`):

```xml
<beans>
  <bean id="dateService"    
        class="org.springframework.remoting.rmi.RmiProxyFactoryBean">
     <property name="serviceUrl" 
               value="rmi://localhost:1099/DateService" />
     <property name="serviceInterface" 
               value="spring.rmi.DateService" />
  </bean>
</beans>
```

Potrebujeme vhodne nastaviť názov servera v `serviceUrl` a názov interfaceu, ktorý zodpovedá vzdialene volateľným metódam `serviceInterface`.

Samotný klient je potom priamočiary:

```java
package spring.rmi;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class Client {
  public static void main(String[] args) {
    ClassPathXmlApplicationContext ctx 
      = new ClassPathXmlApplicationContext("clientContext.xml");
    DateService dateService = (DateService) appContext.getBean("dateService");
    System.out.println(dateService.getDate());
  }	
}
```

Spring sa postará o automatické vytvorenie stubov a skeletonov a o ich správne prepojenie.
