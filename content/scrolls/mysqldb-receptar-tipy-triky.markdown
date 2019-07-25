---
title: MySQL – receptár, tipy a triky
date: 2009-07-26T00:00:00+01:00
---



# Zmena znakovej sady pre databazu

```
alter database xxxxx character set cp1250
```

# Pripojenie k databaze so specifikovanim znakovej sady pre klienta
```
"c:\Program Files\MySQL\MySQL Server 4.1\bin\mysql" -u oldelfinnphpBB -p --default-character-set=cp1250
```

# Import CSV súboru z Excelu
```
mysqlimport.exe -u root -p --fields-terminated-by=; --fields-optionally-enclosed-by=\" davano post.txt
```

Dátumy by mali byť v tvare akceptovateľnom funkciou `DATETIME()`, napr. `YYYY-MM-DD HH:mm`)

# Zistenie znakovej sady tabuľky
```
show table status from hotels like 'hotel_reservations'
```
Vypíše info o tabuľke `hotel_reservations` v databáze `hotels`.

# Ako zistiť zoznam tabuliek a počty ich riadkov

```
SELECT table_name, table_rows FROM information_schema.TABLES T 
where table_schema = 'olympus'
order by table_name
```


# Ako exportovať dáta z jedinej tabuľky?
```
mysqldump -B --tables --skip-extended-insert --order-by-primary -u root -proot phpbb phpbb_posts > olympus-phpbb_posts-simpleinserts.sql
```
