---
title: Menné priestory XML – XML Namespaces
date: 2008-01-31T00:00:00+01:00
---
# Úvod
Menné priestory (**namespaces**) v XML sú súčasťou špecifikácie [Namespaces in XML 1.0](http://www.w3.org/TR/REC-xml-names/ ) a jej cieľom je vyriešiť situácie, keď sa v jednom dokumente vyskytnú elementy, ktoré majú rovnaký názov, ale rôznu sémantiku (napr. pochádzajú z rôznych špecifikácií od viacerých výrobcov). Klasickým príkladom je použitie elementov z XHTML v rámci vytvárania šablóny v jazyku XSLT. Oba jazyky používajú zápis v XML, ale množiny povolených elementov sú rôzne. Menné priestory si kladú za cieľ vyriešiť problémy vyplývajúce z takýchto situácií.

Približnou analógiou menných priestorov sú balíčky (**packages**) v Jave, ktoré riešia situácie, v ktorých sa vyskytnú dve triedy s rovnakým menom, ale s inou funkcionalitou.

# XML bez menných priestorov
Príklad jednoduchého XML bez použitia menného priestoru je nasledovný:
```xml
<stylesheet version='1.0' >

  <template match="/">
    <apply-templates/>
  </template> 

</stylesheet>
```

Na tomto príklade nie je nič špeciálne - každý z elementov a atribútov má svoj názov, napr. `stylesheet`.

# XML s mennými priestormi

Pri použití menných priestorov je každý element charakterizovaný názvom menného priestoru a lokálnym názvom. Tieto dva prvky tvoria **expandovaný názov** ([*expanded name*](http://www.w3.org/TR/REC-xml-names/#dt-expname )) elementu.  

Samotný menný priestor je identifikovaný URI reťazcom. Prázdny reťazec reprezentuje nedefinovaný menný priestor. To je prípad predošlého príkladu, v ktorom máme elementy nepatria do žiadneho menného priestoru a ich expandované názvy sú `"":stylesheet`, `"":template` a `"":apply-templates`.

Predošlý príklad predstavuje v skutočnosti program v jazyku XSLT. Elementy z tejto špecikácie patria do menného priestoru, ktorý je identifikovaný URI reťazcom `http://www.w3.org/1999/XSL/Transform`. V tom prípade budú expandované názvy:
* `<http://www.w3.org/1999/XSL/Transform:stylesheet>`, 
* `<http://www.w3.org/1999/XSL/Transform:template>`,
* `<http://www.w3.org/1999/XSL/Transform:apply-templates>`

Vieme si zrejme predstaviť, čo by sa stalo, keby sme takýto expandovaný zápis museli uvádzať pre každý element zvlášť – veľmi rýchlo by sme sa v zdrojovom kóde XML stratili. Preto sa pre každý názov menného priestoru môže zaviesť skratka, resp. **prefix**. Môžeme sa napríklad dohodnúť, že menný priestor `http://www.w3.org/1999/XSL/Transform` bude mať prefix `xsl`.

Elementy budú mať potom **prefixový názov** pozostávajúci z prefixu menného priestoru a zo svojho lokálneho názvu. Príkladom je `<xsl:stylesheet>`. 

Ukážme si teraz úplný príklad XML používajúceho menné priestory:
```xml
<xsl:stylesheet version='1.0' 
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

</xsl:stylesheet>
```

V rámci koreňového elementu `stylesheet` sme zaviedli menný priestor `http://www.w3.org/1999/XSL/Transform` s prefixom `xsl`. To sme zapísali ako atribút

```
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
```

Všetky elementy a atribúty pod elementom `stylesheet`, ktoré majú prefix `xsl`, budú patriť do menného priestoru `http://www.w3.org/1999/XSL/Transform`.

Možno sa pýtate, čo znamená prefix `xmlns` v názve atribútu. Patrí implicitnému mennému priestoru `http://www.w3.org/2000/xmlns`.

Iným príkladom je jednoduchý dokument zodpovedajúci XHTML špecifikácii:
```xml
<html:html xmlns:html="http://www.w3.org/1999/xhtml">
  <html:body>
    <html:p>Lorem ipsum dolor sit amet.</html:p>
  </html:body>
</html:html>
```
V ňom používame elementy patriace do menného priestoru `http://www.w3.org/1999/xhtml`, ktorému sme priradili prefix `html`.

# Atribúty a menné priestory
Deklarácia menného priestoru platí pre všetky elementy a názvy atribútov, ktoré majú príslušný prefix.
```xml
<html:html xmlns:html="http://www.w3.org/1999/xhtml">
  <html:body>
    <html:p>
      <html:a href="http://lipsum.org">Lorem ipsum</html:a>
      dolor sit amet.
    </html:p>
  </html:body>
</html:html>
```
Menný priestor `html` neplatí pre atribút `href`, ten totiž nemá príslušný prefix. Tento atribút nepatrí do žiadneho menného priestoru (názov menného priestoru je tvorený prázdnym reťazcom).

V nasledovnom príklade máme atribút `taxclass` s menným priestorom `edi`:
```xml
<x xmlns:edi='http://ecommerce.example.org/schema'>
  <!-- menný priestor atribútu 'taxClass' je
  http://ecommerce.example.org/schema -->
  <lineItem edi:taxClass="exempt">Baby food</lineItem>
</x>
```
Všimnime si, že elementy `<x>` a `<lineitem>` nepatria do žiadneho menného priestoru (nemajú totiž prefix).

# Použitie viacerých menných priestorov
V jednom dokumente môžeme samozrejme deklarovať aj viacero menných priestorov. Stačí ich jednoducho uviesť do viacerých atribútoch s prefixom `xmlns`.
```xml
<?xml version="1.0"?>
<!-- oba menné priestory uvedieme do atribútov -->
<bk:book xmlns:bk='urn:loc.gov:books'
         xmlns:isbn='urn:ISBN:0-395-36341-6'>
    <bk:title>Cheaper by the Dozen</bk:title>
    <isbn:number>1568491379</isbn:number>
</bk:book>
```

# Implicitné menné priestory
V prípade, že v danom dokumente používame elementy z jediného menného priestoru, môžeme zápis ešte viac zjednodušiť. Elementy bez prefixu vieme zaradiť do konkrétneho menného priestoru tým, že ho vyhlásime za implicitný. **Implicitný menný priestor** sa vzťahuje na element, v ktorom bol definovaný a na všetky jeho podelementy. 

Je treba mať na pamäti dôležité pravidlo: *Implicitný menný priestor sa nevzťahuje na atribúty.* Inak povedané, atribúty bez prefixu nikdy nepatria do menného priestoru.

Na deklaráciu implicitného menného priestoru použijeme atribút `xmlns`. Príkladom deklarácie je:

```
<html:html xmlns="http://www.w3.org/1999/xhtml">
```

Všimnime si, že v atribúte `xmlns` sme vynechali deklaráciu prefixu.

Všetky elementy z nasledovného dokumentu patria do implicitného menného priestoru `http://www.w3.org/1999/xhtml`.
```xml
<html xmlns="http://www.w3.org/1999/xhtml">
  <body>
    <p>
      <a href="http://lipsum.org">Lorem ipsum</a>
      dolor sit amet.
    </p>
  </body>
</html>
```
Atribút `href` na základe vyššie zmieneného pravidla nepatrí do žiadneho menného priestoru.

Nasledovný príklad ukazuje kombináciu implicitného a explicitného menného priestoru.
```xml
<?xml version="1.0"?>
<!-- elementy bez prefixu sú z menného priestoru "books" -->
<book xmlns='urn:loc.gov:books'
      xmlns:isbn='urn:ISBN:0-395-36341-6'>
    <title>Cheaper by the Dozen</title>
    <isbn:number>1568491379</isbn:number>
</book>
```
Elementy `book` a `title` patria do implicitného menného priestoru `urn:loc.gov:books`, element `isbn:number` do priestoru `urn:ISBN:0-395-36341-6`.

Ako už bolo spomenuté, menný priestor sa vzťahuje na element, v ktorom bol zavedený a na všetky jeho podelementy a atribúty, ktoré majú daný prefix. Nasledovný príklad ukazuje situáciu, keď v koreňovom elemente deklarujeme jeden implicitný menný priestor a v elemente `p` a jeho podelementoch budeme používať odlišný implicitný menný priestor.
```xml
<?xml version="1.0"?>
<!-- deklarujeme implicitný menný priestor kníh -->
<book xmlns='urn:loc.gov:books'
      xmlns:isbn='urn:ISBN:0-395-36341-6'>
    <title>Cheaper by the Dozen</title> <!-- knihy -->
    <isbn:number>1568491379</isbn:number>  <!-- isbn -->
    <notes>  <!-- knihy -->
      <!-- element "p" a podelementy majú iný implicitný menný priestor -->
      <p xmlns='http://www.w3.org/1999/xhtml'>
          This is a <i>funny</i> book!
      </p>
    </notes>
</book>
```
Implicitný menný priestor je možné zakázať pomocou deklarácie `xmlns=""`. Takýto atribút nastaví na daný element a jeho podelementy nedefinovaný menný priestor.
```xml
<Beers>
  <!-- implicitný menný priestor pre tabuľku je HTML -->
  <table xmlns='http://www.w3.org/1999/xhtml'>
   <th><td>Name</td><td>Origin</td><td>Description</td></th>
   <tr> 
     <!-- v bunkách nemáme žiaden implicitný MP -->
     <td><brandName xmlns="">Huntsman</brandName></td>
     <td><origin xmlns="">Bath, UK</origin></td>
     <td>
       <details xmlns=""><class>Bitter</class><hop>Fuggles</hop>
         <pro>Wonderful hop, light alcohol, good summer beer</pro>
         <con>Fragile; excessive variance pub to pub</con>
       </details>
     </td>
   </tr>
 </table>
</Beers>
```
Element nesmie obsahovať dva atribúty s rovnakým expandovaným názvom. Nasledovný príklad obsahuje nesprávne deklarácie:
```xml
<!-- http://www.w3.org naviažeme má dva rôzne prefixy -->
<x xmlns:n1="http://www.w3.org" 
   xmlns:n2="http://www.w3.org" >
   
  <!-- máme dvakrát rovnaký atribút `a` --> 
  <nespravne a="1" a="2" />
  <!-- expandovaný názov oboch atribútov `a` je rovnaký -->
  <nespravne n1:a="1" n2:a="2" />
</x>
```

```xml
<!-- http://www.w3.org naviažeme na prefix n1 
     a vyhlásime ho za implicitný menný priestor
-->
<x xmlns:n1="http://www.w3.org" 
   xmlns="http://www.w3.org" >
  <spravne a="1" b="2" />

  <!-- úplné mená sú rôzne! prvý atribút
  má úplné meno "":a, 
  druhý má http://www.w3.org:a
  -->
  <spravne a="1" n1:a="2" />
</x>
```

# Odkazy
* [Špecifikácia Namespaces In XML 1.0](http://www.w3.org/TR/REC-xml-names/ )
* [Tutoriál k menným priestorom](http://www.zvon.org/xxl/NamespaceTutorial/Output_cze/index.html ) na Zvon.org

