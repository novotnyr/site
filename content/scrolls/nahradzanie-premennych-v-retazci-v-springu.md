

Spring má geniálne vymyslený systém *properties*, kde možno ukladať rozličné konfiguračné nastavenia v *prostredí* (`Environment`) a robiť s tým kdejaké finty. Čo keď však potrebujeme úplne hlúpu vec: nahradiť premenné v reťazci konkrétnymi namapovanými hodnotami?

Zoberme si reťazec:

```
http://${hostname}/${path}
```

Zoberme si dve premenné — **host** s hodnotou `localhost` a **path** s hodnotou `qofola`. 

Po nahradení by sme chceli získať krásnu URL:

```
http://localhost/qofola
```

Spring!
-------

Trieda [`PropertyPlaceholderHelper`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/util/PropertyPlaceholderHelper.html#replacePlaceholders-java.lang.String-org.springframework.util.PropertyPlaceholderHelper.PlaceholderResolver-) síce nemá úplne ideálny názov, ale má dve základné metódy:

* [`replacePlaceholders(String, java.util.Properties)`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/util/PropertyPlaceholderHelper.html#replacePlaceholders-java.lang.String-java.util.Properties-)
* [`replacePlaceholders(String, PlaceholderResolver)`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/util/PropertyPlaceholderHelper.html#replacePlaceholders-java.lang.String-org.springframework.util.PropertyPlaceholderHelper.PlaceholderResolver-)

Obe dokážu zobrať reťazec a mapovanie medzi názvami premenných a ich hodnotami. Mapovanie môže byť buď v podobe starých dobrých javáckych `Properties`, alebo v podobe *resolvera*, čo je prakticky jednometódový interfejs (lambda!) kde zadefinujeme mapovanie.

Okrem toho má aj dva konštruktory, kde môžeme povedať:

- reťazec uvádzajúci premennú (*prefix*). V našom prípade ide o `${`, alebo konštantu [`SystemPropertyUtils.PLACEHOLDER_PREFIX`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/util/SystemPropertyUtils.html#PLACEHOLDER_PREFIX)
- reťazec ukončujúci premennú (*suffix*) — teda o `}`, či konštantu [`SystemPropertyUtils.PLACEHOLDER_SUFFIX`](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/util/SystemPropertyUtils.html#PLACEHOLDER_SUFFIX).

Môžeme si tak vytvoriť helper pre klasický vzhľad `${premennej}`, alebo zadefinovať napríklad mustachovský `{{spôsob}}`.

Klasika známa zo shellu či Mavenu má v Springu už zadefinované konštanty a teda môžeme si helper vytvoriť nasledovne:

```java
PropertyPlaceholderHelper helper 
  = new PropertyPlaceholderHelper(
      SystemPropertyUtils.PLACEHOLDER_PREFIX,
      SystemPropertyUtils.PLACEHOLDER_SUFFIX);
```

Nahrádzanie je potom hračka:

```java
Properties properties = new Properties();
properties.setProperty("host", "localhost");
properties.setProperty("path", "qofola");

String url = helper.replacePlaceholders(urlTemplate, properties);
```

Bonusový konštruktor podporuje aj ďalšie argumenty:

* prefix (zmienený hore)
* suffix (ten sme tiež už videli)
* oddeľovač hodnoty: ak ho nastavíme správne, môžu premenné obsahovať aj implicitné (*default*) hodnoty. Takto môžeme mať: `${host:localhost}`, čo znamená, že `localhost` sa použije, ak nenastavíme žiadne špeciálne mapovanie pre premennú `host`.
* ignorovanie nedefinovaných premenných. Ak sa premenná nenájde v mapovaní, začne *helper* frflať a hádzať výnimky. Ak použijeme **true**, helper jednoducho nechá nedefinované premenné bez zmeny.

*Helper* automaticky podporuje rekurzívne kľúče aj hodnoty. Ak akýkoľvek kľúč či hodnota obsahuje vnorené kľúče, tie sa budú “rozbaľovať”, kým sa celý reťazec nepodarí úspešne ponahrádzať hodnotami.

