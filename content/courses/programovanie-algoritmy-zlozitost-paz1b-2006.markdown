---
title: Programovanie, algoritmy, zložitosť (UINF/PAZ1b) 2006
date: 2006-06-11T19:59:44+01:00
year: 2006/2007
course: UINF/PAZ1b
---

## Uloha c. 1 (19. 4. 2006)

Vytvorte *unit* s nazvom `stats`. V tomto unite budu vytvorene dalsie triedy.

Vytvorte dalsiu triedu `Zaznam`, ktora bude reprezentovat jednu *k*ticu realnych cisiel. Trieda ma mat dva datove cleny, oba v *private* sekcii:

* dlzku zaznamu (pocet clenov). 
* pole realnych cisiel obsahujucich data (predpokladajte, ze zaznam moze obsahovat maximalne 30 poloziek).
V triede vytvorte nasledovne metody, vsetky v *public* sekcii:
* `sucet` bez argumentov, ktora spocita sucet vsetkych hodnot.
* `dlzka` bez argumentov, ktora vrati pocet prvkov v zazname (t. j. dlzku).
* `dajPrvok` s jednym celociselnym argumentom *i*, ktora vrati *i*ty prvok zaznamu.


## Uloha c. 2 (19. 4. 2006)
Je dany textovy subor nasledovneho tvaru:

* prvy riadok obsahuje pocet riadkov tvoriacich data (*n*)
* druhy riadok obsahuje pocet stlpcov v kazdom riadku (pocet stlpcov je rovnaky pre vsetky riadky) - *k*
* zvysok textoveho suboru reprezentuju data: *n* riadkov obsahujucich *k*tice nahodnych cisiel

Vytvorte triedu `Statistik`, ktora bude nacitavat *n* usporiadanych *k*tic nahodnych cisiel z textoveho suboru. Vytvorte konstruktor tejto triedy s troma parametrami:

* dlzkou *k*-tice
* poctom *k*-tic (*n*).
* nazvom textoveho suboru
V triede vytvorte nasledovne metody, vsetky v *public* sekcii:
* `dajZaznam` s jednym celociselnym parametrom *i*. Tato metoda vrati novu instanciu triedy `Zaznam` naplnenu datami z *i*-teho riadku textoveho suboru.
* `priemer` s jednym celociselnym parametrom *stlpec*. Tato metoda spocita aritmeticky priemer hodnot v *stlpec*-tom stlpci.
* `priemer` ako pretazenu metodu bez argumentov, ktora spocita aritmeticky priemer vsetkych hodnot.


