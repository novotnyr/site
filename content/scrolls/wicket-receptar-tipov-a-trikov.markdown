---
title: Wicket – receptár tipov a trikov 
date: 2006-05-25T22:47:44+01:00
---

# Ako vyrobit nieco ako frame v Delphi?
Staci pouzit kombinaciu <span> a k nemu vyrobit WebMarkupContainer. Naozaj netreba pouzivat Panely.

# Pouzivanie `setVisible`
Skryty komponent sa vo vyrenderovanom HTML nezobrazi. To je prirodzena vlastnost. Pre skryte panely vsak plati, ze sa vobec nenacitava im zodpovedajuci HTML popis. To sa udeje az pri prvom zobrazeni.

# Modifikacia poloziek v ListView
Ak sa planuju zmeny poloziek v ListView (pridavanie, uberanie), je potrebne nastavit na tomto komponente `setReuseItems(true)`. V opacnom pripade sa zmena v ListView neprejavi v UI.
