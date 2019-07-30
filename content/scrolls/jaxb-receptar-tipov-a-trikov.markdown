---
title: JAXB – receptár tipov a trikov
date: 2008-09-04T09:10:43+01:00
---

Pri kompilácii XML schémy pomocou JAXB sú niektoré XML typy namapované na „neštandardné" Java triedy. Napríklad typy pre dátum a čas (`xsd:date`, `xsd:time`) nie sú mapované na `java.util.Date()`, ale na špeciálnu triedu `javax.xml.datatype.XMLGregorianCalendar` (dôvodom je vraj rozličný rozsah platnosti tried). V JAXB je však možné prispôsobiť mapovania tried pomocou `XJB` súboru. Na [blogu jedného z autorov](http://weblogs.java.net/blog/kohsuke/archive/2006/03/how_do_i_map_xs.html |) JAXB sa udáva možnosť priameho mapovania na `java.util.Date`.

V jednom z projektov sme potrebovali mapovanie na `java.sql.Date.` Súbor prispôsobenia `binding.xjb` vyzerá nasledovne:
```xml
<jaxb:bindings version="2.0" 
	xmlns:jaxb="http://java.sun.com/xml/ns/jaxb"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/jaxb http://java.sun.com/xml/ns/jaxb/bindingschema_2_0.xsd"
	xmlns:xjc="http://java.sun.com/xml/ns/jaxb/xjc"
	schemaLocation="studijneProgramy.xsd"
    jaxb:extensionBindingPrefixes="xjc"
>

    <jaxb:globalBindings>
      <jaxb:javaType name="java.sql.Date" xmlType="xs:date"
         parseMethod="ws.util.JavaSqlDateAdapter.parseDate"
         printMethod="ws.util.JavaSqlDateAdapter.printDate"
      />
    </jaxb:globalBindings>
</jaxb:bindings>
```
Typ `xsd:date` bude mapovaný na `java.sql.Date`. Na konverziu sa použije trieda `ws.util.JavaSqlDateAdapter` a jej metódy `parseDate()`, resp. `printDate()`. Tried vyzerá nasledovne:
```java
public class JavaSqlDateAdapter {
  public static Date parseDate(String s) {
    Calendar calendar = DatatypeConverter.parseDate(s);
    Date date = new Date(calendar.getTimeInMillis());
    
    return date;
  }

  public static String printDate(Date date) {
    Calendar cal = new GregorianCalendar();
    cal.setTime(date);
    return DatatypeConverter.printDate(cal);
  }
}
```
Pri spúšťaní `xjc` nesmieme zabudnúť na parameter `classpath`, ktorému dodáme cestu k binárkam tejto triedy.
```
xjc -classpath web/WEB-INF/classes [...]
```
Po vygenerovaní uvidíme, že `xjc` vytvoril prapodivnú triedu 
`org.w3/_2001.xmlschema.Adapter1.java`, ktorá vyzerá nasledovne:
```java
public class Adapter1 extends XmlAdapter<String, Date> {

    public Date unmarshal(String value) {
        return (ais.ws.util.JavaSqlDateAdapter.parseDate(value));
    }

    public String marshal(Date value) {
        return (ais.ws.util.JavaSqlDateAdapter.printDate(value));
    }

}
```
Ide o implementáciu klasickej JAXB triedy `XmlAdapter`, ktorá priamo volá našu konverznú triedu. Ak nám tento postup prekáža a nechcem mať jednu zbytočnú triedu (navyše s pochybným názvom), môžeme sa jej zbaviť. 

Namiesto prispôsobenia cez `jaxb:javaType` môžeme použiť rozšírenia od dodávateľov (*vendor extensions*) režim pri kompilovaní cez `xjc`.

Namiesto elementu `jaxb:javaType` uvedieme element `xjc:javaType`
```xml
<jaxb:globalBindings>
  <xjc:javaType name="java.sql.Date" 
                xmlType="xsd:date"
                adapter="ais.ws.util.JavaSqlDateAdapter" />
</jaxb:globalBindings>
```
(V koreňovom elemente musíme mať deklarovaný menný priestor `xmlns:xjc="http://java.sun.com/xml/ns/jaxb/xjc"` a `jaxb:extensionBindingPrefixes="xjc"`.)
Pri spúšťaní `xjc` musíme dodať parameter `-extension`, ktorý zapne používanie rozšírení.

