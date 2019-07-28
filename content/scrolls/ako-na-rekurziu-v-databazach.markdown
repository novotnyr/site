---
title: Ako na rekurziu v databázach
date: 2008-08-07T16:08:05+01:00
---

Čísla od 1 po *n*
=================

Vytvorte tabulku, ktora obsahuje v riadkoch cisla od 1 po N.

V Pascale by to bol `for`:
```
for i:=1 to N do begin
  writeln(i)
end
```
Lenze my nemame `for`. Mame len rekurziu. My vsak vieme kazdy prvok v postupnosti odvodit z predosleho prvku. 

- Prvy prvok je 0, 
- dalsi prvok je predosly prvok + 1. 

```
s_0 = 0
s_i = s_i-1 + 1
```

Napisane vseobecne
```
s(i) = 0, ak i = 0
s(i) = s(i-1) + 1
```

```
s(x) = 0, ak x = 0
s(x) = s(x-1) + 1
```

Toto vieme mechanicky previest na SELECT

```sql
WITH s(x) as
(
SELECT 0 FROM SYSIBM.SYSDUMMY1
  UNION ALL
SELECT x + 1 FROM s
WHERE x < 1000
)
SELECT * FROM s
```

Fibonacci
=========

Fibonacciho postupnosť je definované rekurzívne:

```
F(0) = 0
F(1) = 1
F(x) = F(x - 2) + F(x - 1)
...
F(x + 1) = F(x - 1) + F(x)
F(x + 2) = F(x) + F(x + 1)
F(x + 3) = F(x + 1) + F(x + 2)
```

Ak sa na to pozrieme z iného uhla, tak:

- ak sčítame *aktuálny prvok* a *nasledovný prvok* v *i*-tom kroku, dostaneme *nasledovný prvok* v *i+1* kroku
- *nasledovný prvok* v *i*-tom kroku sa stane *aktuálnym prvkom* pre *i + 1* krok

Pamätajme si teda dva stĺpce, čo bude vyzerať takto:

| Poradie | Aktuálny prvok | Nasledovný prvok |
| ------- | -------------- | ---------------- |
| 0       | 0              | 1                |
| 1       | 1              | 1                |
| 2       | 1              | 2                |
| 3       | 2              | 3                |
| 4       | 3              | 5                |
| 5       | 5              | 8                |

Toto vieme mechanicky previesť na dopyt:

```
WITH RECURSIVE FIBONACCI(`current`, `next`) AS
(
  SELECT 0, 1
    UNION ALL
  SELECT `next`, `current` + `next`
  FROM FIBONACCI
  WHERE `next` < 10
)
SELECT * FROM FIBONACCI
```

Podmienka `next < 10` len obmedzuje hĺbku rekurzie, predsa len nemôžeme mať nekonečné tabuľky.

Hierarchie
==========

Majme tabuľku súborového systému s hierarchiou:

```sql
CREATE TABLE filesystem (
  id INTEGER NOT NULL,
  name VARCHAR(255) NOT NULL,
  parent_id INTEGER
);
```

A hodnoty:

```sql
INSERT INTO filesystem VALUES
(0, '/', NULL),
(1, 'home', 0),
(2, 'novotnyr', 1),
(3, 'armstrong', 1),
(4, 'public_html', 2),
(5, 'tmp', 0);
```

Chceme vypísať pre každý adresár celú jeho cestu:

```
/home/
/home/armstrong/
/home/novotnyr/
/home/novotnyr/public_html/
/tmp/
```

Idea je nasledovná: 

- hierarchia koreňa je lomka `/`
- hierarchiu k položke zistíme cez hierarchiu rodiča položky, ku ktorej prilepíme názov položky.

Pa-matematický zápis by vyzeral:

```
fullpath(0) = '/'
fullpath(x) = x.`name` + '/' + fullpath(resolvefile(x).parent_id)  
```

V databázovom prípade však musíme byť presnejší: funkcia musí brať viacero parametrov:

- identifikátor položky v strome.
- jej názov
- a celú cestu až ku koreňu

Funkcia `resolvefile` sa však v databázovom svete preloží na `join`-om tabuľky na budovanú hierarchiu.

```
WITH RECURSIVE fullpath (id, name, path) AS
(
  SELECT id, name, CAST('/' AS CHAR(200))
    FROM filesystem
    WHERE parent_id IS NULL
  UNION ALL
  SELECT filesystem.id, filesystem.name, CONCAT(fullpath.path, filesystem.name, '/')
    FROM filesystem
	JOIN fullpath ON fullpath.id = filesystem.parent_id
)
SELECT * FROM fullpath ORDER BY path;
```

