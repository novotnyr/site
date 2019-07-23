---
title: Rýchly sprievodca Stripes
date: 2007-09-07T10:45:21+01:00
---

# Úvod 
[Stripes](http://mc4j.org/confluence/display/stripes/Home ) je aplikačný rámec na tvorbu webových aplikácii založený na návrhovom vzorec MVC. Medzi základné vlastnosti patrí:

* zameranie na najnovšie vymoženosti poskytované Javou 5
* žiadne konfiguračné súbory
* konfigurácia sa deje pomocou anotácií.
* kontroléry sa konfigurujú a mapujú na URL automaticky na základe mennej konvencie. 
* snaha vyriešiť niektoré problémy Struts (modelom môže byť ľubovoľný objekt, podpora komplexného mapovania parametrov z URL na objekty, predvypĺňanie objektov)
* snaha o nezávislosť view vrstvy na JSP
* vlastná knižnica tagov pre použitie v JSP (a Freemarkeri)
* kontrolér je zároveň modelom, pri každej požiadavke sa vytvára jeho nová inštancia. Na jeho inštančné premenné je možné namapovať parametre z požiadavky.

## Iné aspekty
* riedka dokumentácia. Pre úvodné oboznámenie je takmer nutné študovať zdrojový kód vzorovej aplikácie a študovať JavaDoc. 
* stredne aktívny mailing-list (do 5-10 príspevkov denne)
* zatiaľ žiadna publikovaná súhrnná kniha
* priemerná doba medzi vydaniami: 4 mesiace

# Porovnanie so Struts
* žiadne konfiguračné súbory (namiesto nich menné konvencie a anotácie)
* kontrolér nededí od triedy `ActionForm`, ale implementuje interfejs `ActionBean`.
* model nemusí dediť od `ActionBeanu`
* priama podpora kontrolérov s viacerými akciami (v Struts nutné oddediť od `DispatchController`a)

# Porovnanie so Spring MVC
* menší repertoár možných kontrolérov
* kontrolér je zároveň modelom, filozofia je podobná `ThrowawayController`u (s každou požiadavkou sa vytvorí nová inštancia, ktorá sa po jej spracovaní zahodí)
* menej striktné oddelenie logických názvov viewov a samotných JSP súborov
* metódy kontroléra vracajú `Resolution`, čo analógiou springovského `ModelAndView` bez možnosti špecifikovať model (určuje sa len kontrolér/výsledný súbor, ktorý sa zobrazí po spracovaní).

# Stiahnutie a inštalácia
ZIP súbor je možné stiahnuť zo [SourceForge](http://sourceforge.net/projects/stripes/ ).

Samotný Stripes pozostáva z hlavného JAR súboru a z dvoch závislostí - `commons-logging` a `com.oreilly.servlet`.
Tie je možné skopírovať do adresára `WEB-INF/lib` svojej webovej aplikácie.

Okrem toho je nutné skopírovať `StripesResources.properties` do adresára `WEB-INF/classes`.

# CRUD aplikácia
Vytvorme si jednoduchú aplikáciu predstavujúcu pivný bar.
## Zobrazenie pív v ponuke
Zobrazenie pív v ponuke je pekným príkladom `read` aspektu.

V tomto prípade si však vystačíme s klasickým JSP (bez akýchkoľvek komponentov Stripes).

Vytvorme bean, ktorý bude poskytovať dáta stránke:
```java
package sk.beer.web;

import java.util.ArrayList;
import java.util.List;

import sk.beer.Beer;

public class ListBeersBean {
  public List<Beer> getAllBeers() {
    List<Beer> beers = new ArrayList<Beer>();
    beers.add(new Beer("Saris"));
    beers.add(new Beer("Hoegaarden"));
    beers.add(new Beer("Bazant"));
    
    return beers;
  }
}
```
Samotná stránka bude klasické JSP využívajúce JSTL tagy

```
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:useBean id="beerBean" scope="page" class="sk.beer.web.ListBeersBean" />

<table class="display">
	<tr>
		<th>ID</th>
		<th>Title</th>
		<th></th>
	</tr>
	<c:forEach items="${beerBean.allBeers}" var="beer">
		<tr>
			<td>${beer.id}</td>
			<td>${beer.name}</td>
			<td></td>
		</tr>
	</c:forEach>
</table>
```

Značka `jsp:useBean` vloží do kontextu stránky novú inštanciu triedy `ListBeersBean`. Pomocou `c:forEach` sa získa zoznam pív a v iteráciách sa vytvorí tabuľka.

## Pridanie piva
Na pridanie piva budeme potrebovať dve veci:

* formulár, do ktorého vložíme údaje
* kontrolér, ktorý spracuje dáta z formulára

### Formulár - addBeer.jsp
Formulár bude predstavovať JSP stránka využívajúca špeciálne značky Stripes.

```
<%@ taglib prefix="stripes" uri="http://stripes.sourceforge.net/stripes.tld" %>

<stripes:errors />
<stripes:form beanclass="sk.beer.web.AddBeerAction">
	Beer ID: <stripes:text name="beer.id" /><br />
	Beer Name: <stripes:text name="beer.name" />
	<stripes:submit name="addBeer" value="Pridat pivo"/>
</stripes:form>
```

* Prvým riadkom zavedieme knižnicu Stripes značiek.
* Značka `<stripes:errors />` služí na zobrazenie validačných chýb, teda chýb, ktoré nastanú pri vypĺňaní formulára (nevyplnené položky, nesprávne typy...)
* Značka `<stripes:form>` je analógiou formulára z klasického HTML. Názov triedy špecifikuje kontrolér, ktorý bude spracovávať dáta z formulára.
* Značka `<stripes:text>` je analógiou `input type="text"`. Parameter `name` špecifikuje cestu k objektu, ktorého hodnota sa má nastaviť na základe tohto ovládacieho prvku (v tomto prípade sa na objekte kontroléru zavolá `getBeer().setId(..)`, resp. `getBeer().setName(..)`.
* Značka `<stripes:submit>` je analógiou ovládacieho prvku `input type="submit"`, pomocou ktorého sa odošle formulár. Meno špecifikuje názov ''udalosti'', ktorá sa zavolá. (O udalostiach sa zmienime neskôr).

### Kontrolér - trieda `AddBeerActionBean`
Kontrolér je objekt, ktorý spracuje dáta z formulára, zavolá objekty bussiness logiky a v prípade potreby vykoná presmerovanie na ďalší view.

V Stripes je kontrolérom trieda, ktorá implementuje interfejs `ActionBean`.

```java
package sk.beer.web;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;
import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import sk.beer.Beer;

public class AddBeerAction implements ActionBean {
  private Beer beer;

  private ActionBeanContext context;
  
  @DefaultHandler
  public Resolution displayForm() {
    System.out.println("Displaying form");
    return new ForwardResolution("/addBeer.jsp");
  }
  
  public Resolution addBeer() {
    System.out.println("Adding beer: " + beer);
    return new RedirectResolution("/listBeers.jsp");
  }
  
  public ActionBeanContext getContext() {
    return context;
  }

  public Beer getBeer() {
    return beer;
  }

  public void setBeer(Beer beer) {
    this.beer = beer;
  }

  public void setContext(ActionBeanContext context) {
    this.context = context;
  }

}
```
Implementácia interfejsu vynucuje prekrytie dvoch metód: `getContext()` a `setContext()`, pomocou ktorých je možné získať prístup k objektu typu `ActionBeanContext` (tento kontext umožňuje prístup k objektu HTTP session a pod). V našich metódach si nastavený objekt kontextu uložíme do inštančnej premennej a v metóde `getContext()` ho vrátime.

Ďalšie dve významné metódy sú metódy vracajúce objekt `Resolution`. Obe tieto metódy predstavujú reakciu na udalosti (udalosť môže byť vyvolaná formulárom alebo parametrom v URL).

Anotácia `DefaultHandler` špecifikuje metódu, ktorá sa zavolá v prípade, že nebola vyvolaná žiadna udalosť. V tomto jednoduchom prípade vypíšeme na štandardný výstup správu a vrátime `ForwardResolution`, ktorý predstavuje presmerovanie na danú stránku (forward-presmerovanie znamená presmerovanie na strane servera, takže klient nespozoruje zmenu URL adresy v prehliadači).

Druhá metóda predstavuje reakciu na udalosť `addBeer` (tá je vyvolávaná tlačidlom formulára). V tomto prípade vykonáme `RedirectResolution` na danú stránku. Presmerovanie sa udeje u klienta, takže klientova nová adresa bude `listBeers.jsp`.

Inštančná premenná `beer` predstavuje objekt, na ktorý budú mapované parametre formulára. Stripes po odoslaní formulára vytvorí nový objekt typu `Beer` a na jeho inštančné premenné namapuje pomocou getterov a setterov príslušné údaje. (Používa sa bodková notácia - `beer.name` znamená nastavenie premennej `name` na objekte `beer`). Getter (`getBeer()`) a setter (`setBeer`) slúži na zabezpečenie prístupu k objektu `beer`.

