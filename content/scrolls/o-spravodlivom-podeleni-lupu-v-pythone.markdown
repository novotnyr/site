---
title: O spravodlivom podelení lupu v Pythone
date: 2010-04-20T00:00:00+01:00
---
Dvom lupičom sa podarilo uchmatnúť si *n* zlatých tehličiek. Tehličky majú rôzne váhy. Váha každej tehličky je kladné nenulové reálne číslo (napr. v kilogramoch). Po akcii majú v pláne spravodlivo sa rozdeliť a potom sa čo najskôr rozísť. Polícia je im však v pätách a tak nemajú
čas krájať tehličky, aby sa podelili presne na polovicu (hmotnosť je priamo úmerná cene). Nájdite čo najspravodlivejšie rozdelenie lupu (s minimálnym rozdielom váh).

# Nápady na riešenie
Brutálne riešenie sa dá určiť generovaním všetkých možností. Keďže máme len 2 zbojníkov, môžeme vygenerovať všetky možné prerozdelenia tehličiek medzi nich a nájsť to s najmenším rozdielom váh.

Využiť sa dá finta s generovaním núl a jednotiek. Postupne vygenerujeme všetky 0-1 postupnosti dĺžky *n*. Napr. 
```
010110
```
znamená, že prvá, tretia a posledná tehlička pôjde prvému zbojníkovi a zvyšné ostanú druhému.

V Pythone je generovanie postupností triviálne, nasledovný kód vygeneruje všetky postupnosti núl a jednotiek dĺžky 5.
```python
from itertools import.product

print product((0, 1), repeat=5)
```

V iných jazykoch možno využiť i na toto špeciálny trik: postupnosti núl a jednotiek sú vlastne binárnym zápisom prirodzeného čísla. Ak chceme generovať všetky postupnosti dĺžky 5, môžeme generovať binárne zápisy čísiel v intervale 0 až 2^5 - 1.
```python
def nulaJedna(dlzka):
    for i in range(2 ** dlzka):
        print list(bin(i)[2:].rjust(dlzka, '0'))
```
* funkcia `bin()` prevedie číslo na reťazcový zápis, pozor ale, ten má prefix `0b`
* prefixu sa zbavíme slice-nutím reťazca (od druhého znaku do konca)
* funkcia `rjust()` zarovná reťazec doprava a zľava ho vyplní nulami na požadovanú dĺžku (napr. číslo 3 má binárny zápis `0b11`, po vypchatí na dĺžku 5 potrebujeme `00011`

Ak sú hmotnosti tehál udržiavané v zozname:
```
[2000, 1500, 750, 200, 560]
```
nuly a jednotky sa priamo mapujú na indexy na toto pole. Pri tomto zozname znamená postupnosť `00011` rozdelenie:
* prvý zbojník: 2000, 1500, 750
* druhý zbojník: 200, 650

Sumár algoritmu je prostý:
* pamätaj si priebežný najmenší rozdiel cien 
* vygeneruj postupnosť 0-1
* zisti sumu tehál pre prvého zbojník a sumu pre druhého
* zisti rozdiel súm, ak je menší než priebežný, aktualizuj priebežný rozdiel a zapamätaj si rozdelenie tehál

Tento prístup sa dá ešte vylepšiť. Nemusíme rátať sumu tehál pre druhého zbojníka: veď to je rozdiel sumy všetkých tehál a sumy pre prvého zbojníka. To sa týka aj rozdelenia konkrétnych tehál: prvý zbojník dostane svoje tehly a druhý zvyšok.

```python
from itertools import product

loot = [2000, 1500, 750, 200, 560]
finalneVeciPre1 = []
sumaVeci = sum(loot)

1.  na zaciatku je rozdiel obrovsky, budeme ho znizovat
najmensiRozdiel = sumaVeci

for rozdelenie in product((0, 1), repeat=len(loot)):
    r = zip(rozdelenie, loot)
    veciPre1 = [item for x, item in r if x == 0]

    sum1 = sum(veciPre1)
    rozdiel = abs((sumaVeci - sum1) - sum1)
    if rozdiel < najmensiRozdiel:
        najmensiRozdiel = rozdiel
        finalneVeciPre1 = veciPre1

print "Prvy dostane ", finalneVeciPre1
print "Druhy dostane ", [item for item in loot if item not in finalneVeciPre1]
print "Rozdiel ", najmensiRozdiel
```

Funkcia `zip()` dokáže elegantne spojiť zoznam núl a jednotiek so zoznamom tehál, čo uľahčí indexovaný prístup. Ak máme dva zoznamy:
```
[2000, 1500, 750, 200, 560]
[0,    0,    0,   1,   1  ]
```
funkcia `zip()` z nich vyrobí jeden zoznam, pričom spáruje prvé, druhé atď položky.
```
priradenie = [[0, 2000], [0, 1500], [0, 750], [1, 200], [1, 560]]
```
Zistiť veci pre prvého (alebo skôr nultého zbojníka) je záležitosťou jednej *list comprehension*:
```python
[hodnota for poradieZbojníka, hodnota in priradenie if poradieZbojníka == 0]
```
-------------------

# Drevorubačský algoritmus
```
from itertools import *

loot = (("mec", 2000),
        ("stit", 1500),
        ("palicka magickej strely", 750),
        ("odvar liecenia", 200),
        ("prsten ochrany", 560),
        )
najlepsieRozdelenie = []
najmensiRozdiel = max([price for name, price in loot])
for rozdelenie in product((1, 2), repeat=5):
    lootPre1 = []
    lootPre2 = []    
    sumaPre1 = sumaPre2 = 0    
    for index, cisloZbojnika in enumerate(rozdelenie):
        if cisloZbojnika == 1:
            sumaPre1 += loot[index][1]
        else:
            sumaPre2 += loot[index][1]
    rozdielSum = abs(sumaPre1 - sumaPre2)
    if rozdielSum < najmensiRozdiel:
        najmensiRozdiel = rozdielSum
        najlepsieRozdelenie = rozdelenie
print najlepsieRozdelenie, najmensiRozdiel
zbojnik1 = []
zbojnik2 = []
for i, cisloZbojnika in enumerate(najlepsieRozdelenie):
    if cisloZbojnika == 1:
        zbojnik1.append(loot[i])
    else:
        zbojnik2.append(loot[i])
print zbojnik1
print zbojnik2
```
# Vylepšenie 1
```
from itertools import *

loot = (("mec", 2000),
        ("stit", 1500),
        ("palicka magickej strely", 750),
        ("odvar liecenia", 200),
        ("prsten ochrany", 560),
        )
gz1 = []
gz2 = []
najmensiRozdiel = max([price for name, price in loot])

for rozdelenie in product((1, 2), repeat=5):
    r = zip(rozdelenie, loot)
    zbojnik1 = [item for x, item in r if x == 1]
    zbojnik2 = [item for x, item in r if x == 2]
    sum1 = sum(price for name, price in zbojnik1)
    sum2 = sum(price for name, price in zbojnik2)
    rozdiel = abs(sum1 - sum2)
    if rozdiel < najmensiRozdiel:
        najmensiRozdiel = rozdiel
        gz1 = zbojnik1
        gz2 = zbojnik2

print "Prvy dostane ", gz1
print "Druhy dostane ", gz2
print "Rozdiel ", najmensiRozdiel
```



