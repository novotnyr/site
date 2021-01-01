---
title: "Spracovanie argumentov v shelli cez `getopts`"
date: 2019-01-07T07:44:08+01:00
---

# Načo je dobrý `getops`?

`getopts`  je posixový nástroj na spracovávanie prepínačov z príkazového riadka v rámci shellového skriptu. Vezmime si príklad:

```shell
./ffind.sh -s -t d java xml
```
Príkaz `ffind.sh` dostal päť argumentov, ktoré v skutočnosti reprezentujú tri rozličné druhy “vstupov”:

* `-s` teda prepínač
* `-t`  reprezentujúci prepínač s parametrom (`d`)
* dva nepomenované argumenty `java` a `xml`

Ak by sme mali takéto argumenty spracovávať ručne, bolo by to šialené. Príkaz `getopts` sa s tým vysporiada veľmi jednoducho.

## Zápis prepínačov

Príkaz `getopts` sa riadi nasledovnými pravidlami:

* prepínače majú jednopísmenové označenia, napr. `-s` alebo `-t`. Dlhé parametre (long options) v duchu GNU (`—all`) nie sú podporované. (To je doménou vylepšeného príkazu `getopt`, ktorý ale nie je posixový).
* prepínače možno zoskupovať. Nasledovný zápis je rovnaký ako z úvodnej ukážky: 

    ```shell
     ./ffind.sh -st d java xml
    ```
* prepínače možno uvádzať v ľubovoľnom poradí:

    ```shell
    ./ffind.sh -t d -s java xml
    ```

## Použitie `getopts`
Príkaz `getopts` spracováva argument za argumentov z príkazového riadka (teda premenné `1`, `2` atď)  a sám si poradí so všetkými troma druhmi “vstupov”.
Samotný príkaz `getopts` má dva základné argumenty:

* špecifikáciu podporovaných argumentov
* premennú, do ktorej postupne priraďuje jednotlivé prepínače.

### Špecifikácia parametrov
V našom príklade bude špecifikácia vyzerať nasledovne:

	:st:


Rozoberme si to znak po znaku:

* `:` Dvojbodka na začiatku vypne automatické vypisovanie chybových hlášok pre parametre, ktoré nedokážeme spracovať. Túto obsluhu si však veľmi jednoducho vieme urobiť sami.
* `s`:  Prepínač `s` neberie parametre, preto ho uvedieme len názvom. 
* `t:` Prepínač `t`, ktorý berie parameter, uvedieme s dvojbodkou.
Dvojbodka tu má dva významy: jednak vypína chybové hlášky (ak je na začiatku) a jednak špecifikuje prepínač s argumentami (ak je uvedená za ním).

### Špecifikácia premennej so vstupom
Premennú, ktorá bude obsahovať práve spracovávaný prepínač alebo argument, si môžeme nazvať ľubovoľne, napr. `OPT`. 

### Použitie v kóde
Každé zavolanie `getopts` spracuje nasledovnú premennú z príkazového riadka. Pri prvom volaní sa spracuje premenná `1`, pri druhom volaní premenná `2`. Ak sa všetky premenné spracovali, `getopts` skončí  s nenulovým návratovým kódom.

To je presne situácia, keď sa oplatí použiť cyklus `while`:

```shell
while getopts :st: OPT
do
...
done
```

Jednotlivé prepínače spracujeme v rámci príkazu `case` (ekvivalent `switch` z iných jazykov).

```bash
SILENT=''
TYPE=''
while getopts :st: OPT
do
  case "$OPT" in
      s) SILENT=1
         ;;
      t) TYPE="$OPTARG"
         ;;
      ?) echo "Neznamy parameter $OPT"
         ;;
  esac
done
```

V rozhodovaní sa pýtame na obsah premennej `OPT`, a podľa toho zistíme, ktorý prepínač chceme spracovať. V ukážke si podľa prepínača nastavíme príslušnú premennú.

Ak ide o prepínač s parametrom, v premennej `OPTARG` sa ocitne parameter tohto prepínača. V prípade prepínača `-t d` sa v premennej `OPTARG` objaví reťazec `d`.

Špeciálny prípad tvorí situácia, keď používateľ použije nepodporovaný prepínač (napr. `-x`). V takom prípade sa v premennej `OPT` ocitne otáznik. To je presne situácia na ručnú obsluhu nepodporovaných parametrov, čo zrealizujeme výpisom chybovej hlášky s názvom neznámeho parametra.

## Použitie `getopts` a pozičných parametrov
V príklade sme mali dva parametre, ktoré neprislúchali žiadnemu prepínaču. Ide o parametre `java` a `xml`:

```shell
./ffind.sh -s -t d java xml
```

I na toto dokáže `getopts` myslieť. Príkaz si totiž počíta jednotlivé spracované parametre v špeciálnej číselnej premennej `OPTIND` a to môžeme použiť v skripte na zahodenie tých argumentov príkazového riadka, ktoré sa už spracovali.

Príklad? Pre parametre z ukážky si `getopts` naráta do premennej `OPTIND` štyri spracované položky.

| shell    | `$0`         | `$1` | `$2` | `$3` | `$4` | `$5` |
| -------- | ------------ | ---- | ---- | ---- | ---- | ---- |
|          | `./ffind.sh` | `-s` | `-t` | d    | java | xml  |
| `OPTIND` | 1            | 2    | 3    | 4    |      |      |

Ak odčítame od `OPTIND` jednotku, získame akýsi index, o ktorý môžeme posunúť, teda `shift`núť premenné “doľava” a tým ich sprístupniť do shellových premenných `1`, `2` atď.

V tomto prípade máme `OPTIND` rovný 4, a po posunutí o tri pozície, teda po použití príkazu `shift $((OPTIND - 1))`, získame nasledovný stav:

| shell            | `$0`         | `$1` | `$2` | `$3` | `$4` | `$5` |
| ---------------- | ------------ | ---- | ---- | ---- | ---- | ---- |
| shell po `shift` |              |      |      |      | `$1` | `$2` |
|                  | `./ffind.sh` | `-s` | `-t` | d    | java | xml  |
| `OPTIND`         | 1            | 2    | 3    | 4    |      |      |

Tento trik funguje pre ľubovoľný počet parametrov. Po shifte o príslušný počet miest sa indexované premenné nastavia na správne miesta.
Zrazu budeme mať prvý pozičný parameter v premennej `1`, druhý v premennej `2` atď, ba dokonca v univerzálnej premennej `@` budeme mať všetky parametre pohromade a môžeme cez ne iterovať cyklom `for`, prípadne ich použiť ako parametrický vstup pre iné príkazy.

# Celý skript
Výsledný skript so všetkými možnosťami vyzerá nasledovne:

```bash
SILENT=0
TYPE='unknown'
while getopts :st: OPT
do
  case "$OPT" in
          s) SILENT=1
             ;;
          t) TYPE="$OPTARG"
             ;;
          ?) echo "Unsupported parameter $OPT"
             ;;
  esac
done

shift $((OPTIND - 1))

echo "Silent mode: $SILENT"
echo "Type: $TYPE"
echo "Files:"

for FILE
do
  echo "$FILE"
done
```