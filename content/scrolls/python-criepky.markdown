---
title: Python – čriepky
date: 2010-04-15T19:59:44+01:00
---

# Kalkulačka

```
2 + 2
```
```
4
```

# Kalkulačka - celočíselné delenie
```
3 / 2
```
```
1
```

# Kalkulačka - delenie reálnych čísiel
```
3.0 / 2
```
```
1.5
```

# Kalkulačka - mocnina
```
10 ** 2
```
```
pow(10, 2)
```
```
100
```

# Maximum čísiel
```
max(4, 5, 3, 5, 7, 20)
```
```
20
```

# Minimum čísiel
```
min(4, 5, 3, 5, 7, 20)
```
```
20
```

# Premenné
Python je dynamicky typovaný: dátové typy netreba uvádzať, každá premenná má však exaktný typ
```
dph = 19
1000 * (dph / 100.0)
```
```
190
```

# Zoznamy
Zoznam je kontajner/kolekcia viacerých prvkov v danom poradí.
```python
parne_cisla = [2, 4, 6, 8, 10]
```

## Súčet prvkov v zozname
Funkcia `sum()` berie zoznam prvkov.
```python
sum([2, 4, 6, 8, 10])
```
```python
parne_cisla = [2, 4, 6, 8, 10]
sum(parne_cisla)
```
```
30
```

## Dĺžka zoznamu
```python
parne_cisla = [2, 4, 6, 8, 10]
len(parne_cisla)
```
```
5
```


## Párujúca funkcia `zip()`
Funkcia `[zip()](http://docs.python.org/library/functions.html#zip )` páruje elementy z viacerých zoznamov. Vráti zoznam, ktorého *i*-ty prvok je zoznam obsahujúci *i*-te prvky zo zoznamov v parametri:

```python
vektor1 = [5, 20]
vektor2 = [15, 2]
print zip(vektor1, vektor2)
```
```python
[[5, 15], [20, 2]]
```

# Vektorový súčet
```python
vec1 = [5, 20]
vec2 = [15, 2]

print [x + y for x, y in zip(vec1, vec2)];
print map(sum, zip(vec1, vec2))
(:pyend:)


```

