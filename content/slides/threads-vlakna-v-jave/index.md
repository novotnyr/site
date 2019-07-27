---
title: Vlákna / Threads v Jave
date: 2009-02-20T16:08:05+01:00
---

>  Prečo paralelne programovať? 

Stiahnuť
========

- [PDF](threads-introduction.pdf)
- [PowerPoint PPT](threads-introduction.ppt)

![](first-slide.png)

Obsah
=====

Úlohy / tasks
-------------

- Ako si vytvoriť úlohu (*task*) a spustiť ju paralelne. 
- Exekútory ako spôsob spúšťania paralelných úloh v Jave. 

Vlákna / threads
----------------

- Vlákna (*Threads*) a ich reprezentácia v Jave. 
- Pozastavenie úlohy (*sleep*). 
- Ukončenie behu (*interrupt*). 

Zdieľané dáta
-------------

- Zdieľanie dát a problémy, ktoré nastanú:
  - interferencia, 
  - nekonzistencia, 
  - deadlock. 
- Ukážky a návod riešenia cez kritické sekcie. 

Thread-safety
-------------

- Thread-safety – zabezpečenie dát proti problémom zdieľania
- Thread-safe triedy a kolekcie. 

Koordinácia vlákien
-------------------

- Ďalšie spôsoby koordinácie vlákien. 
- Obedujúci filozofia ako ukážka ďalších potenciálnych problémov. 
- Deadlock a starvation. 

Producent-knzument
------------------

- Problém producent-konzument a hotové riešenie v Jave. 

Exekútory / executors
---------------------

- Podrobnejšie o exekútoroch – varianty, triedy. 
- Koordinácia úloh v exekútoroch.

Iné zdroje
==========

- [Java theory and practice: Managing volatility](http://www.ibm.com/developerworks/java/library/j-jtp06197.html) – článok o kľúčovom slove `volatile` a príkladoch jeho použitia.
- [The volatile keyword in Java](http://www.javamex.com/tutorials/synchronization_volatile.shtml) – niekoľko informácií o `volatile`