---
title: RMI - vzdialené volanie metód 
date: 2007-08-24T00:00:00+01:00
---

Od verzie Java 5 sa vzdialené volanie metód značne zjednodušilo. Uvedieme jednoduchý príklad servera a klienta, ktorý získa aktuálny dátum na serveri.

# Základné interfejsy
Predovšetkým budeme potrebovať interfejs, ktorý bude obsahovať vzdialené volateľné metódy.
```java
package rmi2;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.Date;

public interface RemoteDateService extends Remote {
  public Date getDate() throws RemoteException;
}
```
Následne dodáme jeho implementáciu:
```java
package rmi2;

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.Date;

public class RemoteDateServiceImpl extends UnicastRemoteObject 
                                   implements RemoteDateService 
{
  public RemoteDateServiceImpl() throws RemoteException {
    super();
  }
	
  public Date getDate() throws RemoteException {
    return new Date();
  }
}
```
Trieda implementuje `UnicastRemoteObject`, to znamená, že pri vytvorení jej inštancie sa vykoná jej automatická registrácia v RMI registroch (teda bude automaticky pripravená na zverejnenie).

Samotná trieda spustiteľného servera je jednoduchá:
```java
package rmi2;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class Server {
  public static void main(String[] args) throws Exception {
    // Start RMI registry
    Registry registry 
      = LocateRegistry.createRegistry(Registry.REGISTRY_PORT);

    RemoteDateService dateService = new RemoteDateServiceImpl();
		
    registry.rebind("DateService", dateService);
    System.out.println("Server running...");
  }
}
```
V nej spustíme RMI registre (je to analógia programu `rmiregistry` z predošlých verzií), vytvoríme inštanciu samotnej služby a tú zaregistrujeme v RMI registroch pod daným logickým označením (tu: `DateService`).

Po spustení začne server načúvať požiadavkám klientov.

# Klient
Klient je analogicky jednoduchý:
```java
package rmi2;

import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

public class Client {
  public static void main(String[] args) throws Exception {
    try {
      Registry registry = LocateRegistry.getRegistry("localhost");
      RemoteDateService stub = 
        (RemoteDateService) registry.lookup("DateService");
      System.out.println(stub.getDate());
    } catch (Exception e) {
      System.err.println("Client exception: " + e.toString());
      e.printStackTrace();
    }
  }
}
```
V prvom rade získame objekt RMI registrov pre daný server (v tomto prípade `localhost`, zvyčajne to však bude nejaký vzdialený server). Z registrov získame interfejs so vzdialene volateľnými metódami zodpovedajúci danému logickému názvu.

Pomocou interfejsu potom môžeme priamočiaro vzdialene volať metódy.

# Alternatívny klient s využitím `Naming`
Alternatívne je možné použiť na získanie vzdialeného interfejsu aj triedu `java.rmi.Naming`. Klient bude vyzerať nasledovne:
```java
package rmi2;

import java.rmi.Naming;
import java.util.Date;

public class DateServiceClient {
  public static void main(String[] args) throws Exception {
    String host = "localhost";
    int portNumber = 1099;
    String lookupName = 
      "//" + host + ":" + portNumber + "/" + "DateService";
    RemoteDateService service 
      = (RemoteDateService) Naming.lookup(lookupName);

    Date date = service.getDate();
      
    System.out.println(date);     
  }
}
```
Namiesto získania objektu registrov zadáme priamo URL adresu pre server.

# Poznámky
* v starých verziách bolo treba generovať stuby a skeletony pomocou `rmic`. Od Javy 5 je to možné tento krok vynechať, keďže stuby a skeletony sa môžu získať použitím automatických proxy tried.
* v starých verziách bolo tiež treba štartovať `rmiregistry` ako samostatný proces. V novej verzii je možné registre naštartovať priamo v kóde (viď príklad servera).
* treba dávať pozor na triedy v `CLASSPATH`-e. V prípade, že sa v `CLASSPATH`-e klienta nenájdu triedy vzdialených metód, bude ich chcieť RMI doťahovať zo servera, čo vyústi v potrebu používať security manager v záplavu vzdialených `ClassNotFoundException`.

# Odkazy
* http://www.comp.hkbu.edu.hk/~jng/comp3320/rmi.html
* http://java.sun.com/j2se/1.5.0/docs/guide/rmi/relnotes.html
* http://java.sun.com/docs/books/tutorial/rmi/overview.html
* http://fragments.turtlemeat.com/rmi.php
* [Súbory politík v Jave](http://java.sun.com/j2se/1.4.2/docs/guide/security/PolicyFiles.html ) - používané v Security Manageri
* [Hello World v RMI](http://java.sun.com/j2se/1.5.0/docs/guide/rmi/hello/hello-world.html )
* http://www.comp.lancs.ac.uk/~weerasin/csc253/tutorials/week8.html
* http://www.cs.man.ac.uk/~fellowsd/work/usingRMI.html
* [RMI a parameter `codebase`](http://java.sun.com/j2se/1.4.2/docs/guide/rmi/codebase.html ) pre automatické sťahovanie tried
* http://www.javacoffeebreak.com/articles/javarmi/javarmi.html
* [New RMI](http://today.java.net/pub/a/today/2005/10/06/the-new-rmi.html?page=1 ) - popis nového RMI v Jave 5
