---
title: Pokročilé funkcie v Powershelli
date: 2020-11-17T21:09:01+01:00
---

Funkcie v PowerShelli sa dajú zapisovať rozličnými spôsobmi.
Ukážme si jednoduchú funkciu, ktorá zráta veľkost súborov v aktuálnom adresári:

```powershell
function Get-Size($Unit) {
    Get-ChildItem -File 
    | Measure-Object -Property Length -Sum 
    | Select-Object -ExpandProperty Sum
    | ForEach-Object { $_ / ("1" + $Unit)}
}
```

Funkcia má jeden netypovaný parameter s názvom `$Unit` a vieme ju použiť nasledovne:

```
Get-Size MB
```

Konvencie však odporúčajú zapisovať parametre v sekcii `param`:

```powershell
function Get-Size {
    param (
        [String]
        $Unit = "MB"
    )

    Get-ChildItem -File 
    | Measure-Object -Property Length -Sum 
    | Select-Object -ExpandProperty Sum
    | ForEach-Object { $_ / ("1" + $Unit)}
}
```
Parameter `$Unit` má implicitnú hodnotu `MB` a je typu `String`.

Volať ho môžeme nasledovne:
```
Get-Size 20
```

# Funkcie ako cmdlety cez atribút `CmdletBinding`

Ak chceme, aby sa funkcia tvárila ako cmdlet, dodajme na začiatok atribút `CmdletBinding`:

```powershell
function Get-Size {
    [CmdletBinding(PositionalBinding = $False)]
    param (
        [String]
        $Unit = "MB"
    )

    Get-ChildItem -File 
    | Measure-Object -Property Length -Sum 
    | Select-Object -ExpandProperty Sum
    | ForEach-Object { $_ / ("1" + $Unit)}
}
```



## Vypnutie pozičných argumentov

Vypli sme pozičné argumenty, teda každý argument musí mať meno.
Ak spustíme len `Get-Size GB`, uvidíme chybovú hlášku: `A positional parameter cannot be found that accepts argument 'GB'`
Správne použitie je:

```
Get-Size -Unit GB
```

## Štandardné prepínače
Dostaneme podporu pre štandardné parametre, ako napríklad `$ErrorAction` a `$ErrorVariable`.

Ak teraz zavoláme funkciu s vymyslenou jednotkou "mobobajty", a použijeme ignorovanie chyby, funkcia veselo pobeží ďalej.

```powershell
Get-Size -Unit BB -ErrorAction SilentlyContinue
```    

## Podpora pre ladiace výpisy

Automaticky dostaneme možnosť využívať vypisovacie / logovacie cmdlety:

* `Write-Verbose` pre výpisy, ktoré sa zapnú, ak cmdlet pustíme s parametrom `-Verbose`
* `Write-Debug` pre výpisy, ktoré sa zapnú ak použijeme prepínač `Debug`


## Automatická premenná `$PSCmdlet`

Dostaneme k dispozícii automatickú premennú `$PSCmdlet` (typu ` System.Management.Automation.PSScriptCmdlet`) s prístupom k nastaveniam, napr. k stránkovaniu.

# Validácie

Parametre možno validovať. 

### Validácie pomocou regexu

Napríklad validácia oproti regexu:

```
[Parameter()]
[ValidatePattern("[kKmMtTpP][bB]")]
[String]
$Unit = "MB"
```

V atribúte `ValidatePattern` môžeme uviesť regulárny výraz.


### Validácie pomocou skriptu

Validácie môžu využívať skripty - stačí uviesť atribút `ValidateScript` a vo vnútri uviesť kód, ktorý bud vráti `$true` alebo vyhodí výnimku`

```powershell
[Parameter(ValueFromPipeline = $true)]
[ValidateScript({
    if(-Not ($_ | Test-Path)) {
        throw "File or folder does not exist" 
    }
    $true
})]
[System.IO.FileInfo] $Path
```        

Okrem toho vidíme aj ďalšie pokročilé vlastnosti:

- Skript berie hodnotu z rúry (`ValueFromPipeline`
- Dátový typ je `FileInfo`, čo obmedzí hodnoty len na cesty k adresárom, či súborom

Skript tak môžeme zavolať:

```powershell
Get-Item /tmp | Get-Size -Unit "MB"
```

Ak pošleme do rúry reťazec, ten sa automaticky konvertuje na objekt typu `FileInfo` a validuje. 

Pošlime do rúry neexistujúci priečinok a uvidíme chybu:

```powershell
"/nonexistent" | Get-Size -Unit "MB"
```

Uvidíme:

```
Cannot validate argument on parameter 'Path'. File or folder does not exist
```     

# Ďalšie užitočné vlastnosti

## Povinné parametre

Parameter môžeme označiť ako `Mandatory`, teda povinný:

```powershell
[Parameter(Mandatory=$true)]
```

## Prepínače

Parameter s atribútom `[Switch]` je prepínač, teda má hodnotu `$True` alebo `$False`.