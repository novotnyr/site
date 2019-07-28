---
title:  Inštalácia LaTeX2HTML vo Windows
date: 2004-11-24T16:08:05+01:00
---

LaTeX2HTML-2002-2-1, Windows XP SP1, MikTeX 2.4.1461

Na pripravu potrebujeme:

* [LaTeX2HTML](http://saftsack.fs.uni-bayreuth.de/~latex2ht/current/ )

* Perl (napr. ActiveState Perl)

* [netpbm](http://gnuwin32.sourceforge.net/downlinks/netpbm-bin.php ) -- binarky (pouzita verzia 10.8.14)

* Odbalime LaTeX2HTML do docasneho adresara

* Nainstalujeme netpbm

* Zeditujeme prefs.pm v adresari, kam sa odbalil LaTeX2HTML.

  * `$prefs{'PREFIX'}` udava cestu, kam sa to nainstaluje
  *  `$prefs{'EXTRAPATH'}]` treba nastavit na cestu k nainstalovanemu ghostscriptu a netpbm. 

  Pravdepodobne kvoli chybe v parsovani cesty (asi vadia dvojbodky) mi fungovalo len toto riesenie -- netpbm, ghostscript na rovnakom disku ako instalacky LaTeX2HTML, cesty bez uvedenia pismena jednotky: 
  `$prefs{'EXTRAPATH'} = '\\Utility\\Alladin\\GS\\gs7.03\\bin;\\MikTeX\\texmf-local\\netpbm\\bin';`)
  Alternativne mozno cesty upravit rucne v konfiguraku `l2hconf.pm`.

* pridat cestu k `bin` adresaru kniznic `netpbm` do `PATH`

* v distribucii netpbm bolo treba premenovat subory bez pripony na subory EXE (binarne) a rozkopirovat perl.exe pod prislusnymi nazvami (perlove skripty). Napr. pre subor `pnmfile` bolo treba skopirovat do adresara `perl.exe` pod nazvom `pnmfile.exe`.

* v adresari instalaciek spustime `config.bat`
  

  * ak sa konfiguracia zastavi pri detekcii verzie dvipsu, treba viackrat stlacit Enter...

* spustime `test.bat`

* spustime `install.bat`

[to be continued]
------
Dalsie rady z Usenetu:

Ok. Now I know what version of NetPBM you have and it is the same as
mine. Also I have to take back some of what I said: I tried deleting
and reinstalling both `latex2html` and `netpbm` and the error I thought
went away came back. Aparently, I did something I can't remember doing.

Anyway, the following finally worked for me:

(I deleted all of `latex2html` and restored it from the archive.
Same with netpbm. You don't necessarily need to do these, but
  I had made a bunch of changes and wanted to start from scratch.)

Then:
- I changed 'gray85' to '#D9D9D9' on or about line 1511 in pstoimg.pin
- I edited prefs.pm. I changed only EXTRAPATH and PREFIX.
- I renamed the netpbm file pnmfile to pnmfile.exe
- I made sure the netpbm files were in my PATH variable
- I ran config.bat
- I ran test.bat

That worked here. (I don't understand why the change to gray85 is
necessary. It seemed unnecessary at one point, but now I can't get
things to work without it.)

As to your confusion: I hope the above is clear enough.

You might also want the following:

In the version of netpbm we both have, the following are actually
executable programs, but do not have the .exe extension. I renamed
them all, adding the `.exe` extension:

- bmptoppm, 
- gemtopbm, 
- pgmedge, 
- pgmnorm, 
- pgmoil, 
- pgmslice,
- pnmarith, 
- pnmfile, 
- pnminterp, 
- pnmnoraw, 
- ppmnorm, 
- ppmtojpeg,

- and ppmtouil

The following are perl scripts. I added the `.pl` extension to them:

- manweb, 
- pnmflip, 
- pnmquant,
- ppmfade, 
- ppmrainbow,
- ppmshadow

The following are shell scripts, requiring some incarnation of
`sh` to interpret:

- anytopnm, 
- hpcdtoppm, 
- pamstretch-gen, 
- pcdovtoppm, 
- pnmindex,

- pnmmargin, 
- ppmquantall,
- ppmtomap

If you run `latex2html` inside a `sh` shell, you may not need to do
any renaming.