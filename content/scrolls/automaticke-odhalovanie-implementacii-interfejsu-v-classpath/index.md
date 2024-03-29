---
title: Automatické odhaľovanie implementácii interfejsu v CLASSPATH 
date: 2007-11-11T01:34:57+01:00
---
# Zadanie
Máte zadanú aplikáciu, ktorá má vykonávať nejakú činnosť nad rôznymi geometrickými útvarmi (pre jednoduchosť: štvorce, kruhy a pod.) Nové geometrické útvary však môžu byť pridávané do aplikácie za behu (napr. dopracujeme meňavku a chceme ju zaviesť do systému).

# Riešenie
Predpokladajme, že všetky geometrické útvary implementujú rozhranie `Shape`, ktoré poskytuje jedinú možnú činnosť - výpočet obsahu.
```java
package sk.novotnyr.shapes;

public interface Shape {
  public double getArea(); 
}
```

Príklady ostatných geometrických útvarov môžu byť napr.
```java
package sk.novotnyr.shapes;

public class Square implements Shape {
  private double size = 1;

  public double getArea() {
    return size * size;
  } 
}
```
alebo 
```java
package sk.novotnyr.shapes;

public class Circle implements Shape {
  private double diameter = 1;
  
  public double getArea() {
    return Math.PI * (diameter * diameter);
  }  
}
```

Dohodneme sa, že všetky nové geometrické útvary musia implementovať rozhranie `Shape` a že sa budú nachádzať v pevne danom balíčku `sk.novotnyr.shapes`. Ak budeme chcieť pridať do bežiacej aplikácie nový útvar, budeme musieť skopírovať do `CLASSPATH` skompilovaný `.class` súbor s implementáciou nového útvaru. Tu využijeme dôležitú vlastnosť Javy -- načítavanie skompilovanej triedy sa vykonáva až s vytvorením prvej inštancie triedy. 

Základná idea na odhaľovanie implementácii je založená na premennej `java.class.path`, ktorá obsahuje obsah systémovej premennej prostredia `CLASSPATH`. K tejto premennej môžeme pristupovať pomocou `System.getProperty("java.class.path")`.

Obsah tejto premennej môže obsahovať viacero adresárov. Každý z týchto adresárov prelezieme, vyhľadáme v ňom `CLASS` súbory z podadresára zodpovedajúcemu dohodnutému balíčku a pokúsime sa na základe ich názvu získať objekt `Class`.

Ak `CLASSPATH` vyzerá napr. nasledovne:
```
d:\Projects\classloading\bin\sk\novotnyr\shapes;.;C:\PROGRA~1\IBM\SQLLIB\java\db2java.zip;
```
tak sa postupne prehľadá:

* adresár `d:\Projects\classloading\bin\sk\novotnyr\shapes`. Hľadajú sa teda súbory `d:/Projects/classloading/bin/sk/novotnyr/shapes/sk/novotnyr/shapes/*.class`. Ak daná trieda implementuje interfejs `Shape`, môžeme ju zaradiť medzi potenciálnych kandidátov na vytvorenie inštancie.
* adresár `.`, čiže aktuálny adresár. Hľadajú sa teda súbory `./sk/novotnyr/shapes/*.class`.
* súbor `C:\PROGRA~1\IBM\SQLLIB\java\db2java.zip`. Neadresárové súbory automaticky preskočíme.

Trieda na odhaľovanie môže vyzerať nasledovne:
```java
package sk.novotnyr.shapes;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Logger;

public class ShapeDiscoverer {
  public static final Logger logger = Logger.getLogger(ShapeDiscoverer.class.getName());
  
  public static final String PROPERTY_KEY = "java.class.path";

  public static final String CLASS_EXTENSION = ".class";
  
  public static final String PACKAGE_NAME = "sk.novotnyr.shapes";
  
  public static final String PACKAGE_DIRECTORY_NAME = PACKAGE_NAME.replace(".", "/");
  
  /**
   * Vrati nazov triedy zo suboru ukazujuceho na CLASS subor.
   * <p>
   * Priklad: Pre <tt>D:\projects\java\classez\bin\sk\novotnyr\shapes\Circle.class</tt> 
   * vrati <tt>Circle</tt>
   * @param file subor obsahujuci nazov a cestu ku CLASS suboru
   * @return nazov triedy
   */
  protected String getClassNameFromFile(File file) {
    if(file.getName().endsWith(CLASS_EXTENSION)) {
      return PACKAGE_NAME + "." + file.getName().substring(0, file.getName().length() - CLASS_EXTENSION.length());
    } else {
      return null;
    }
  }
  
  /**
   * Zisti vsetky triedy implementujuce dane rozhranie
   * v strukture balickov zacinajucej v adresari zadanom v parametri.
   * <p>
   *  
   * @param aPath cesta k adresaru v ktorom zacina balickova struktura. Musi 
   * to byt adresar (JAR subory a pod su ignorovane). 
   */
  protected List<Class> findClassNames(String aPath) {
    if(aPath == null || aPath.trim().length() == 0) {
      return new ArrayList<Class>();
    }
    List<Class> classes = new ArrayList<Class>();
    
    File path = new File(aPath);
    if(path.isDirectory()) {
      File packageFile = new File(path, PACKAGE_DIRECTORY_NAME);
      for (File f : packageFile.listFiles()) {
        String className = getClassNameFromFile(f);
        if(className != null) {
          try {
            Class clazz = Class.forName(className);
            if(Shape.class.isAssignableFrom(clazz)) {
              classes.add(clazz);
            }
          } catch (ClassNotFoundException e) {
            logger.severe("Cannot instantiate " + className);
          }
        }
      }
    }
    return classes;
  }
  
  /**
   * Vrati zoznam tried implementujucich Shape z CLASSPATH.
   * <p>
   * Prelezie sa zoznam z hodnoty systemovej premennej v {@link ShapeDiscoverer#PROPERTY_KEY}
   * a kazda polozka reprezentujuca adresar sa prehlada pre triedy.
   * 
   */
  public List<Class> discover() {
    String javaClasspath = System.getProperty(PROPERTY_KEY);
    if(javaClasspath == null) {
      throw new IllegalArgumentException(PROPERTY_KEY + " not found in system properties.");
    }
    String[] paths = javaClasspath.split(File.pathSeparator);
    
    List<Class> classes = new ArrayList<Class>();
    for (String path : paths) {     
      classes.addAll(findClassNames(path));
    }
    return classes;
  }
  
}
```
# Grafické rozhranie a riešenie automatického obnovovania
Vytvoríme grafickú aplikáciu, v ktorej sa bude periodicky vyhľadávať zoznam tried. 

## Periodické vykonávanie akcií
Na periodické vykonávanie akcií môžeme použiť kombináciu tried `java.util.Timer` a `java.util.TimerTask`. Prvá trieda umožňuje periodické spúštanie akcií, ktoré sú reprezentované `TimerTask`ami. Naša úloha bude jednoduchá -- po jej spustení zavolá metódu `discover` na odhaľovači implementácií a vrátený zoznam tried zobrazí v danom swingovskom komponente `JList`.

```java
package sk.novotnyr.shapes;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.TimerTask;

import javax.swing.JList;

public class RefreshClassesAction extends TimerTask {
  /**
   * Komponent Zoznam, ktory bude aktualizovany
   */
  private JList jList;

  /**
   * Odhalovac implementacii
   */
  private ShapeDiscoverer discoverer = new ShapeDiscoverer();
  
  public RefreshClassesAction(JList list) {
    super();
    this.jList = list;
  }

  /**
   * Aktualizuje zoznam na zaklade novonajdenych tried
   */
  public void run() {
    jList.setListData(discoverer.discover().toArray());
  }
}
```
Samotnú akciu môžeme naplánovať vytvorením inštancie `Timer`a:
```java
Timer timer = new Timer();
RefreshClassesAction action = new RefreshClassesAction(list);
timer.schedule(action, 0, 3000);
```
Každé tri sekundy počnúc súčasnosťou sa zavolá metóda `run()` na inštancii nášho odhaľovača.

## Grafické rozhranie
Na záver vytvoríme jednoduché grafické rozhranie s jedným zoznamom JList a jedným tlačidlom JButton, po ktorého stlačení sa zavolá metóda `getArea()` na novovytvorenej inštancii triedy, ktorá je vybratá zo zoznamu.

```java
package sk.novotnyr.shapes;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Timer;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JList;

public class Gui {
  public static void main(String[] args) {
    JFrame frame = new JFrame("GUI");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    
    Container cp = frame.getContentPane();
    
    final JList list = new JList();
    cp.add(list, BorderLayout.CENTER);
    
    JButton button = new JButton("Go!");
    button.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        Class clazz = (Class) list.getSelectedValue();
        try {
          Shape shape = (Shape) clazz.newInstance();
          System.out.println(shape.getArea());
        } catch (Exception e1) {
          System.out.println("Cannot instantiate the selected class " + clazz);
        } 
      }     
    });
    cp.add(button, BorderLayout.SOUTH);
    
    frame.pack();
    frame.setVisible(true);
    
    Timer timer = new Timer();
    RefreshClassesAction action = new RefreshClassesAction(list);
    timer.schedule(action, 0, 3000);
    
  }
}
```

Ak do adresára v `CLASSPATH` skopírujeme napríklad triedu `Point`, po krátkej chvíli sa zjaví v zozname a môžeme vytvárať jej inštancie.

# Potenciálne problémy
Tento prístup zrejme nebude fungovať vo webových aplikáciách. Napr. servletový kontajner [Tomcat](http://tomcat.apache.org) ignoruje systémovú premennú `CLASSPATH` a triedy bežiace v ňom vidia v premennej `java.class.path` len niekoľko málo JAR archívov z útrob Tomcata. V takom prípade je zrejme nutné použiť nejaký zložitejší prístup - napr. vyhľadávaním súborov pomocou metódy `Class#getResources()`, ktorá na to používa aktuálne používaný classloader.

Alternatívnou metódou je použitie niektorej z knižníc na podporu plug-inov v Jave.

# Zdrojové kódy
- [Ukážkový projekt (ZIP)](classloading.zip)

