---
title: nLite Status Report
date: 2005-05-16T09:10:43+01:00
---

* nLite aktualizoval Windows XP SP1 slipstreamnutim Service Packu 2. Nasledovne bol zruseny IE (komponenty IE Core, aj IE additional). Ako bonusova volba bol zvoleny klasicky vzhlad instalatora.
* nastalo instalovanie vo VMWare. Instalacia prebehla OK, akurat som bol ochudobneny o pestre modre pozadie pri instalatore (jednoducho Win2K style)
* Okna sa otvorili. V klasickom ,,ye olde" vzhlade, a la Windows 2000. Po prestaveni plochy na ,,klasicky vzhlad" mi kupodivu chyba ikonka IE.
* po instalacii bolo nacim rozbehat, presnejsie nainstalovat VMTools, ale nastala chyba lavky: instalator nevedel najst Sluzbu Instalator systemu Windows. Povodne som si myslel, ze je treba doinstalovat instalator (sic!), ale pPo chvilke laborovania a uvazovania (a riesenia problemov, typu ,,na nainstalovanie VMTools potrebujem VMTools) som zistil, ze staci spusit sluzbu Windows Installer.
* moralne ponaucenie: nLite povypina takmer vsetky sluzby (implicitne necha spustenych len 5 sluzieb). To ma netrivialne dosledky: treba si ,,spomenut", ze treba zapnut napr. zmieneny Windows Installer (inak toho asi vela nenainstalujete), ale aj napr. Prohledavani pocitacu (lebo bez toho sa daleko nedostanete). Na druhej strane, Windows v takomto stave zabera na disku nieco malo cez 1GB a v RAMke prijemnych 55MB.
* niektore sluzby sa implicitne nespustaju pri starte (opat onen Windows Installer).
* Instalacia Office 2003 zbehla v pohode. Akurat Pomocnik/Napoveda akosi nefunguje (zrejme kvoli tomu, ze HTML sa nema cim zobrazit ;-). Wordovske dokumenty sa pri otvoreni predstavia hlaskou, ze ,,tento dokument nemozno zaregistrovat", ale inak sa tvaria OK.

...(pokracovanie)