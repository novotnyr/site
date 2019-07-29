---
title: Netbeans, Ubuntu a GTK vývoj
date: 2011-03-19T19:59:44+01:00
---

* nainštalovať vývojárske knižnice
```
apt-get install libgtk2.0-dev
```
* nastaviť projekt: **Project Properties | Build | C Compiler**. V sekcii **General** uviesť do **Additional Options**:
```
`pkg-config --cflags gtk+-2.0` `pkg-config --libs gtk+-2.0`
```
Nezabudnúť na spätné apostrofy (backticks). V prípade chyby skontrolujte, či `pkg-config` funguje z terminálu. Na Ubuntu 10.10 vráti napr.
```
-pthread -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include \
-I/usr/include/atk-1.0 -I/usr/include/cairo \ 
-I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 \ 
-I/usr/include/gio-unix-2.0/ \ -I/usr/include/glib-2.0 \ 
-I/usr/lib/glib-2.0/include \ 
-I/usr/include/pixman-1 -I/usr/include/freetype2 \ 
-I/usr/include/libpng12  
```
* V **Tools | Options | C/C++** na karte *Code Assistance* nastaviť pre vhodnú *Tool Collection* (štandardne GNU) na karte C Compiler bonusový Include adresár:
```
/usr/include
```

