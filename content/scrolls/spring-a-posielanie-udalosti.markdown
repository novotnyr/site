---
title: Spring a posielanie udalostí
date: 2007-09-25T10:46:19+01:00
---
# Úvod
Aplikačný kontext v Springu zjednodušuje podporu implementácie návrhového vzoru *[Observer](http://sern.ucalgary.ca/courses/SENG/609.04/W98/lamsh/observerLib.html )* (alias *listener* alias *publish/subscribe*). K dispozícii je niekoľko rozhraní a pomocných tried, ktoré uľahčujú častokrát opakované písanie tried pre registráciu listenerov a poskytuje priamu podporu pre synchrónne i asynchrónne vyvolávanie udalostí.

# Základné objekty a triedy
Pri implementácii uvedeného návrhového vzoru sa využívajú nasledovné koncepty:

* **udalosť** – dátový typ reprezentuje druh udalosti. Objekt môže niesť dáta späté s udalosťou.
* **poslucháč** – v prípade, že nastane udalosť, sú mu zasielané príslušné objekty udalostí
* **vysielač udalostí** – predstavuje objekt, do ktorého sa zaregistrujú poslucháči. Vysielač zasiela pozorovateľom objekty udalostí.

## Udalosť / Event

Je reprezentovaný triedou `org.springframework.context.ApplicationEvent`. Príkladom môže byť napr.
```java
public class FileDownloadedEvent extends ApplicationEvent {
  private File file;

  public FileDownloadedEvent(Object source) {
    super(source);
  }

  public FileDownloadedEvent(Object source, File file) {
    super(source);
    this.file = file;
  }

  public File getFile() {
    return file;
  }

  public void setFile(File file) {
    this.file = file;
  } 
  
}
```
Táto trieda reprezentuje udalosť „stiahol sa súbor". V udalosti môžeme evidovať zdroj *source* (štandardne objekt, na ktorom nastala udalosť a prípadne ďalšie užitočné dáta. 

## Poslucháč / Listener
Registruje sa vo vysielači a v prípade, že nastane udalosť, môže na ňu reagovať. V Springu je reprezentovaný rozhraním `org.springframework.context.ApplicationListener`, ktoré môže poslucháč implementovať.

`ApplicationListener` má jedinú metódu, `onApplicationEvent()` s jediným parametrom `ApplicationEvent`. Táto metóda je zavolaná vysielačom v prípade, že nastala udalosť a v parametri je poskytnutý objekt udalosti. Poslucháč môže reagovať buď na všetky udalosti, alebo vhodným testom na typ niektoré z nich ignorovať.

```java
public class SystemOutPrintlnListener implements ApplicationListener {

  /**
   * @see org.springframework.context.ApplicationListener#onApplicationEvent(org.springframework.context.ApplicationEvent)
   */
  public void onApplicationEvent(ApplicationEvent anEvent) {
    if(anEvent instanceof FileDownloadedEvent) {
      FileDownloadedEvent event = (FileDownloadedEvent) anEvent;
      System.out.println(event.getFile());
    }
  }   
}
```
## Vysielač udalostí
Vysielača udalostí obsahuje v sebe zoznam poslucháčov. Vo vysielači je možné metódou vyvolať udalosť. Následne sa prejde zoznam poslucháčov a na každom z nich sa zavolá metóda `onApplicationEvent` s príslušným parametrom.

Triedou na vysielanie udalostí v Springu je `org.springframework.context.event.SimpleApplicationEventMulticaster`.
Tá má metódu `addApplicationListener()`, pomocou ktorej je možné pridať poslucháča. 

Samotné vysielanie udalostí sa realizuje zavolaním metódy `multicastEvent()`, kde sa v parametri poskytne objekt udalosti.

```java
SimpleApplicationEventMulticaster multicaster = new SimpleApplicationEventMulticaster();
multicaster.addApplicationListener(new SystemOutPrintlnListener());
//udalosť nastala v samotnom multicasteri, takže ho použijeme ako zdroj. Nie je to však nutné
multicaster.multicastEvent(new FileDownloadedEvent(multicaster, new File("C:/autoexec.bat")));
```

# Asynchrónne vyvolávanie metód
`SimpleApplicationEventMulticaster` vyvoláva metódy `onApplicationEvent()` postupne. Problém však môže vzniknúť v prípade, ak niektorý spracovávateľ udalostí je príliš pomalý (napr. vykonáva zložité operácie, prípadne čaká na nejaký zdroj), pretože tým zadržiava celý rad zvyšných poslucháčov. 

Tento problém je možné vyriešiť nastavením odlišnej implementácie vykonávateľa úloh (`TaskExecutor`a). Najjednoduchšou implementáciou je `org.springframework.core.task.SimpleAsyncTaskExecutor`, ktorý volá metódy na poslucháčoch v samostatných vláknach.

Nastavenie poslucháča je možné urobiť pomocou metódy `setTaskExecutor()` na vysielači:
```java
multicaster.setTaskExecutor(new SimpleAsyncTaskExecutor());
```

Môžeme napr. vyrobiť zámerne pomalého poslucháča:
```java
public class SlowListener implements ApplicationListener  {
  public void onApplicationEvent(ApplicationEvent anEvent) {
    if(anEvent instanceof FileDownloadedEvent) {
      try {
        System.out.println("Slow event start: " + new Date());
        Thread.sleep(5000);
        System.out.println("Slow event end: " + new Date());
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  } 
}
```
pridať ho do zoznamu poslucháčov
```java
multicaster.addApplicationListener(new SlowListener());
```
a porovnať spustenie so štandardným vykonávateľom úloh a s jeho asynchrónnou verziou.

# Aplikačný kontext Springu ako vysielač udalostí
Samotný aplikačný kontext Springu implementuje rozhrania pre vysielanie udalostí. To je možné využiť na rozposielanie udalostí beanom, ktoré sú v ňom deklarované.

Stačí zabezpečiť, aby beany deklarované v aplikačnom kontexte implementovali rozhranie `ApplicationListener`.

```xml
<?xml version="1.0" ?>

<!DOCTYPE beans PUBLIC "-//SPRING//DTD BEAN//EN"
        "http://www.springframework.org/dtd/spring-beans.dtd">

<beans>
  <bean class="sk.novotnyr.spring2.broadcast.SlowListener" />
  <bean class="sk.novotnyr.spring2.broadcast.SystemOutPrintlnListener" /> 
</beans>
```

Objekt aplikačného kontextu implementuje rozhranie, pomocou ktorého je možné odoslať všetkým poslucháčom danú udalosť. Slúži na to metóda `publishEvent()`.
```java
ClassPathXmlApplicationContext ctx = new ClassPathXmlApplicationContext("appContext.xml");
ctx.publishEvent(new FileDownloadedEvent(ctx, new File("C:")));
```
Udalosti sa v štandardnej implementácii posielajú synchrónne (pomocou triedy `ApplicationEventMulticaster`. Zmeniť implementáciu odosielateľa je možné deklarovaním beanu s identifikátorom `applicationEventMulticaster` v kontexte.
```xml
<bean id="applicationEventMulticaster" 
      class="org.springframework.context.event.SimpleApplicationEventMulticaster">
  <property name="taskExecutor">
    <bean class="org.springframework.core.task.SimpleAsyncTaskExecutor" />
  </property>
</bean>
```
