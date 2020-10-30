---
title: Ako zmeniť `SHELL` v súboroch `Makefile`?
date: 2020-10-30T21:11:50+01:00
---

Makefile prevezme použitý shell zo svojej internej premennej `SHELL` (pozri [sekcia 5.3.2 v dokumentácii GNU Make](https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html#Choosing-the-Shell)). Štandardná hodnota je `/bin/sh`.

Premennú môžeme zmeniť klasickým spôsobom:

```make
export SHELL = /bin/bash

.PHONY: all
all:
        echo ${SHELL}
```

Použitie klauzuly `export` je nutné, pretože bez neho sa premenná neexportuje do externých skriptov, ani do sub-makeov.

## Načo vlastne predefinovávať?

Nápad zmeniť shell je málokedy dobrý. Moderné distribúcie očakávajú, že skripty budú implementované v norme POSIX a nebudú používať žiadne špeciality bashizmy, ani konštrukcie zo `zsh` či nebodaj `fish.`


## Skúška

Premenná sa však neexportuje do externých skriptov.
Vytvorme si skúšobný shellskript `echoshell.sh`:

```
#!/bin/sh
echo "$SHELL"
```

Dodajme target:

```
all:
    echo ${SHELL}
    ./echoshell.sh
```

Ak spustíme `make`, vypíšu sa analogické shelly. To len vďaka tomu že premennú `SHELL` sme exportli! Ak by premennú len predefinovali -- `SHELL = /bin/bash`, interný shellskript by si išiel svojou cestou a prevzal by premennú `SHELL` z prostredia.



