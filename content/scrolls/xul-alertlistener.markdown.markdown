---
title: XUL – Použitie notifikačného okienka v rozšírení
date: 2005-03-17T19:21:56+01:00
---

Niektoré rozšírenia používajú úhľadné notifikačné okienko -- napr. *Download Manager* vyhodí takéto okienko, ak boli dokončené všetky sťahovania, *WeatherFox* ho tiež využíva na ohlásenie aktuálneho počasia pri štarte Firefoxu.

(pozn: vraj táto funkcionalita je dostupná len na Windowse...)

Toto úhľadné okienko možno vyvolať nasledovne.

```java
//ziskame komponent pre sluzbu AlertService
var alerts = Components.classes["@mozilla.org/alerts-service;1"].getService(Components.interfaces.nsIAlertsService);
```

Zavolame metodu na vyvolanie okienka. Parametre su nasledovne

   *   prvy parameter udava adresu obrazka zobrazenenho v okienku
   *   druhy parameter udava titulok okienka
   *   treti parameter udava hlavny text v notifikacii
   *   stvrty booleovsky parameter udava, ci je text zobrazeny ako klikatelny odkaz
   *   piaty zahadny parameter ma nieco do cinenia s cookie (nejak som nenasiel blizsie info)
   * siesty parameter udava instanciu objektu, ktory bude nacuvat udalostiam, ktore sa vykonaju pri kliknuti na odkaz v notifikacii

```
alerts.showAlertNotification("chrome://mozapps/skin/xpinstall/xpinstallItemGeneric.png", alertTitle, alertText, true, "", new AlertListenerImpl()); 
```

## Implementácia AlertListenera

```javascript
/*
  Implements nsIAlertListener;
*/
AlertListenerImpl.prototype = {
    onAlertFinished: function() {},
    onAlertClickCallback: function(aCookie) {				
				//vykona co treba 
		    document.getElementById("txtMain").value = "Alerted";
    }
}

/* 
  Konstruktor pre implementaciu listenera.
*/
function AlertListenerImpl() {
}
```

