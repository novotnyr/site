---
title: Jednoduchý príklad použitia Velocity
date: 2005-04-17T09:45:12+01:00
---
Podľa prehľadu na stránkach [tohto projektu](http://jakarta.apache.org ) je Velocity ''šablónový „stroj" založený na Jave. Umožňuje využívať jednoduchý, ale zato mocný jazyk'' na využívanie objektov definovaných v javovskom kóde.

Šablóny môžu byť používané na generovanie HTML stránok, hromadnej korešpondencie alebo na ľubovoľnú podobnú činnosť.

Príkladom šablóny je napr. súbor `knights.vm`
```
Rytieri okrúhleho stola sa dnes zišli v počte $knightsList.size().

Tu je ich presný zoznam:

  #foreach( $knight in $knightList )
    $knight.name
  #end
```

V šablóne sa používajú direktívy (začínajúce na `#`), možno využívať premenné (začínajúce `$`), s premennými možno vykonávať rôzne operácie (bodková notácia ako v Jave).

Pri parsovaní a vyhodnocovaní šablóny sa Velocity spolieha na kontext -- ten obsahuje objekty, na ktoré sa v šablóne odkazujeme.

```java
public static void main( String[] args ) throws Exception {
  /*  inicializujeme motor  */

  VelocityEngine ve = new VelocityEngine();
  ve.init();

  /*  vytvorime data, na ktore sa budeme v kontexte odkazovat  */

  List list = new ArrayList();
  list.add("Arthur");
  list.add("Lancelot");
  list.add("Galahad");
  list.add("Robin");

  /*  vytvorime kontext  */

  VelocityContext context = new VelocityContext();

  /*  vytvoreny zoznam ulozime do kontextu pod prislusnym menom  */
  context.put("knightList", list);

  /*  otvorme sablonu  */

  Template t = ve.getTemplate("knights.vm");

  /*  spracujme sablonu a vypisme ju na standardny vystup  */

  StringWriter writer = new StringWriter();
  t.merge(context, writer);
  System.out.println(writer.toString());
}
```

## Použitie v servletoch
Velocity sa dá učelne využiť ako vrstva View pri práci s webovými aplikáciami -- napr. namiesto JSP. Každej stránke zodpovedá jedna šablóna (v podstate HTML stránka obsahujúca príkazy jazyka Velocity) a jeden Velocity servlet (trieda dediaca od `VelocityServlet`).

```java
public class FirstVelocityServlet extends VelocityServlet {
  /* potrebujeme prekryt nasledovnu metodu */
  public Template handleRequest(HttpServletRequest request, HttpServletResponse response, Context context ) {  
    /* vytvorime data, na ktore sa budeme v kontexte odkazovat  */

    ArrayList list = new ArrayList();
    list.add("Arthur");
    list.add("Lancelot");
    list.add("Galahad");
    list.add("Robin");

    /* vytvoreny ArrayList ulozime do kontextu 
       (kontext je datovym clenom servletu) pod prislusnym menom  
    */
    context.put("knightList", list);

    /*  otvorme sablonu (getTemplate je metoda servletu) */
    Template template = null;  
    try {
      template = getTemplate("knights.vm");
    } catch( Exception e ) {
      System.out.println("Nastala chyba pri tvorbe sablony " + e);
    }

    /*  vratime z metody ziskanu sablonu */
    return template;
  }
}
```
Stránka je potom jednoduchá šablóna
```java
<html>
<h1>Oznam</h1>
<p>Rytieri okrúhleho stola sa dnes zišli v počte $knightsList.size().</p>
<p>Tu je ich presný zoznam:</p>
  <ol>
  #foreach( $knight in $knightList )
    <li>$knight.name</li>
  #end
  </ol>
</html>
```

