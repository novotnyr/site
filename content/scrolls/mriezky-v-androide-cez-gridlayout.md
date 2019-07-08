---
title: "Mriežky v Androide cez GridLayout"
date: 2019-02-20T09:09:39+01:00

---

Vlastné piškvorky v Androide si vyžadujú mriežku 3 x 3, ktorá zaberá celú obrazovku. Ako na to v Androide?

Máme viacero možnosti:

- `GridView`: starý dobrý widget, ktorý zobrazí dáta z adaptéra v mriežke. Problémy? Neráta s tým, že widgety sa trafia “presne” do veľkosti obrazovky. Buď ich je málo a dole ostane vzduch, alebo priveľa a potom budeme scrollovať. Ale my nechceme scrollovateľné piškvorky.
- `GridLayout`: layout od čias API 14 (4.0), ktorý naseká údaje do mriežky. Od API 21 (5.0) podporuje aj dynamické veľkosti, aj keď štandardná implementácia máva bugy.
- `TableLayout`: layout v duchu HTML dizajnu roku 1996, kde všetko sa dá nalayoutovať pomocou tabuliek, riadkov a buniek. Funguje spoľahlivo!
- `RecyclerView` s `GridLayoutManager`-om. Moderný prístup pre 21. storočie, ktorý však chce kopec kódenia.
- `LinearLayout`: vnorené lineárne layouty, kde riadky predstavujú vodorovné lineárne layouty v zvislom lineárnom layoute.

GridLayout
----------

Ukážme si `GridLayout`!

```java
<?xml version="1.0" encoding="utf-8"?>
<android.support.v7.widget.GridLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    app:columnCount="3"
    tools:context=".MainActivity">


    <Button android:text="1" app:layout_gravity="fill" app:layout_rowWeight="1" app:layout_columnWeight="1" />
    <Button android:text="2" app:layout_gravity="fill" app:layout_rowWeight="1" app:layout_columnWeight="1"/>

	<!-- sedem ďalších gombíkov -->
</android.support.v7.widget.GridLayout>
```

Ak vyvíjame pre API 21 a novšie, čo je dnes už bežná situácia, môžeme použiť zabudovaný `GridLayout`. Problém je, že na niektorých zariadeniach sú rozkošné bugy — ba dokonca samotný emulátor API 21 layoutuje nesprávne.

Záchranou je knižnica kompatibility.

Závislosti
----------

Medzi modulové závislosti v `build.gradle`, do sekcie `dependencies` pridáme knižnicu pre kompatibilný `GridLayout`:

```
implementation 'com.android.support:gridlayout-v7:28.0.0'
```

Layoutový súbor
---------------

Teraz môžeme použiť koreňový layout `android.support.v7.widget.GridLayout`. Nastavíme mu vlastnosti:

* `layout_width` (šírka layoutu) a `layout_height` (výška layoutu) na celú obrazovku (`match_parent`)
* `columnCount`: počet stĺpcov, v našom prípade 3. Pozor na to, že keďže layout pochádza z knižnice kompatibility, prefix atribútu musí byť `app` a nie `android`!

Následne nasekáme pod seba deväť identických widgetov do mriežky. Pre jednoduchosť si tam nahádžeme gombíky, ale v estetickej appke by sme tam mohli dať `ImageView`:

```xml
<Button android:text="1" app:layout_gravity="fill" app:layout_rowWeight="1" app:layout_columnWeight="1" />
```

Na to, aby sa widgety roztiahli na celú obrazovku, potrebujeme nastaviť váhy:

* `app:layout_columnWeight`: nastaví váhu prvku pre stĺpec, teda veľkostí pri naťahovaní widgetu. Ak budú všetky váhy widgetov rovnaké (1:1:1), prejaví sa to na rovnomernom rozdelení šírky widgetov. Dôležité je nastaviť váhu všetkým komponentom!
* `app:layout_rowWeight`: nastaví váhu prvku pre riadok. Rovnaké váhy v riadku natiahnu widgety na šírku tak, aby rovnomerne vyplnili celú obrazovku.
* `app:layout_gravity` nastaví správanie widgetu pri naťahovaní. Hodnota `fill` vyplní celú “bunku” widgetom vo vodorovnom i zvislom smere.

Rovnaké nastavenie platí aj pre ostatné widgety!

