---
title: iBatis – receptár tipov a trikov
date: 2007-09-06T00:00:00+01:00
---



# Používanie bodkočiarok

Zvážte používanie bodkočiarok v dopytoch - môže to pôsobiť veľa problémov. Napr. ovládač typu NET pre DB2 spokojne skonzumuje dopyt ukončený bodkočiarkou. Žiaľ, JCC verzia ovládača sa zakusne a vyhlási syntaktickú chybu.
# Vzťahy 1:1 s použitím ResultMapy a explicitné vzťahy
Majme
```xml
<resultMap class="libris.Book" id="bookRM" groupBy="id" >
  <result property="id" column="id_book"/>
  <result property="title" column="title"/>   

  <result property="status.requestsCount" column="request_count"/>
  <result property="status.borrowedTo" column="borrowee"/>    

  <result property="series" resultMap="Book.seriesRM"/>       
</resultMap>
```
a triedu
```java
public class Book implements Serializable {
  protected Integer id;
  
  protected String title = new String();

  private BookStatus status;

  private SimpleSeries series = SimpleSeries.EMPTY_SERIES;
```

Všimnime si dve situácie:

1.  premenná `status` je v `Book`u nastavená na `null` a v mapovaní je reprezentovaná pomocou explicitného stĺpcového mapovania. iBatis v tomto prípade vytvorí novú inštanciu `BookStatus`u a nastaví jej `requestCount` a `borrowedTo` zo stĺpcov `request_count` a `borrowee`.
1.  premenná `series` nie je v `Book`u nastavená na `null`. Ak by sme mapovali pomocou explicitného stĺpcového mapovania, iBatis podľa všetkého nevie nastaviť hodnoty z príslušných stĺpcov na už existujúcej inštancii triedy `SimpleSeries`.
Obísť to možno pomocou použitia ďalšej `resultMap`y, čiže pomocou

```xml
  <result property="series" resultMap="Book.seriesRM"/>       
```

