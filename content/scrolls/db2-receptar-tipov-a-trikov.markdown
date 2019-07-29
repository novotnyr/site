---
title: DB2 – receptár tipov a trikov
date: 2006-06-11T19:59:44+01:00
---

# Katalogizacia vzdialenej DB do klienta
```
catalog tcpip node ssj_d remote dbserver.ics.upjs.sk server 50000
catalog db slovnikd at node ssj_d
```
SSJ_D je nazov uzla/node - lubovolny. 50000 je port sluzby. Miesto portu je mozne pouzit aj nazov sluzby - ten sa da na Windowse zistit z `etc/services`.

# Restore databazy zo zalohy do inej databazy
```
restore database slovnik from d:\bak\slovnikd into slovnikd
```

# Vytvaranie sekvencii v DB2
```
CREATE SEQUENCE vyznam_seq AS INT 
START WITH 160000 
INCREMENT BY 1 
MINVALUE 1 
NO MAXVALUE 
NO CYCLE 
NO CACHE 
ORDER;
```
Sekvencia mozu byt pouzita ako generator primarnych klucov.
```
INSERT INTO VYZNAM VALUES (next value for vyznam_seq, 'Hura');
```
Zo sekvencie mozeme vySELECTovat pomocou
```
SELECT NEXT VALUE FOR vyznam_seq FROM sysibm.sysdummy1
```

# Zistenie edície DB2
Pouzite `db2licm -l`. Typicky vystup je
```
Product Name                            = "DB2 Universal Database Express Edition"
Product Identifier                      = "DB2EXP"
Version Information                     = "8.2"
Expiry Date                             = "Permanent"
Registered User Policy                  = "Disabled"
Enforcement Policy                      = "Soft Stop"
Number of processors                    = "2"
Number of licensed processors           = "2"
Annotation                              = ""
Other information                       = ""
```

## Zistenie verzie DB2
Použite `db2level`. Typický výstup je
```
C:\IBM\SQLLIB\BIN>db2level
DB21085I  Instance "DB2" uses "32" bits and DB2 code release "SQL08023" with
level identifier "03040106".
Informational tokens are "DB2 v8.1.10.1155", "special_15462", "WR21362_15462",
and FixPak "10".
Product is installed at "C:\IBM\SQLLIB".
```

## Očíslovanie riadkov v SELECTe
```
SELECT id_zakl_tvar, id_autor, text, ROWNUMBER() OVER (ORDER BY id_zakl_tvar)
FROM citat
```

## Squirrel bliaka, ze SQL SQLCODE: -443 SQLSTATE: 38553 pri zistovani metadat.
Podla clanku nazvaneho sarkasticky „[10 minut, ktore vam usetria zbytocnych 100](http://www-128.ibm.com/developerworks/db2/library/techarticle/dm-0509zikopoulos/ )" je pricina v tom, ze treba citat README a upozornenia instalatora a po kazdom aplikovani fixpaku treba rebindnut package.
```
db2 terminate
db2 CONNECT TO <dbname>
db2 BIND <path>/db2schema.bnd BLOCKING ALL GRANT PUBLIC sqlerror continue
db2 terminate 
```
That's all.
