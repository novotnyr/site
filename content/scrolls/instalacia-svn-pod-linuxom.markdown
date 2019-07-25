---
title: Inštalácia SVN pod Linuxom
date: 2010-03-18T23:54:45+01:00
---
# Inštalácia pod Linuxom [svnserve]
* Pridat do `/etc/services`:
```
svnserve 3690/tcp # Subversion svnserve
svnserve 3690/udp # Subversion svnserve 
```
* pridat do `/etc/xinetd.d/svnserve`
```
1.  default: on
1.  Subversion server

service svnserve
{
        socket_type     = stream
        protocol        = tcp
        user            = svn
        wait            = no
        disable         = no
        server          = /usr/local/bin/svnserve
        server_args     = -i
        port            = 3690
}
```
* nastavit firewall (vo Fedore): v subore `/etc/rc.d/rc.firewall` uviest 
```
1. open SVN port
/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 3690
```
Pozor na pravidla, ktore sa vyhodnocuju zhora nadol!

* restartnut `xinetd`:
```
service xinetd restart
```
* kontrola, ci server bezi
```
> telnet localhost 3690
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
( success ( 1 2 ( ANONYMOUS ) ( edit-pipeline ) ) )
```

# Ďalšie príkazy
## Vytvorenie repository
```
svnadmin create /home/svn/svnroot
```
## Import dát z projektu
```
svn import . file:///home/svn/svnroot -m "Initial import"
```
# Spustenie servera ako démona
```
svnserve -d -r /home/svn/svnroot
```
----
# Ako vykopat zo SVN zmazany subor?
Treba zistit cislo revizie, v ktorej bol subor naposledy zmazany. Obnovenie suboru je potom mozne dosiahnut zavolanim prikazu na revizii o jedna mensej:
```
D:\project-ui\src\tools\core2>svn up -r 859 RatedJobOffer.java

A    RatedJobOffer.java
Updated to revision 859.
```

# Autentifikácia používateľov
## Použitím `authz`
Do `svnserve.conf` dodať:
```
[general]
authz-db=authz
```
Upraviť súbor `authz`
```
[groups]
google2devs = john,joe,george
keymasterdevs = peter,juraj
admins = jose

[/]
* = r
@admins = rw

[repository:/projects/google2]
@google2devs = rw

[repository:/projects/keymasterdevs]
@keymasterdevs = rw
```

## Cez `pre-commit`
1.  V úložisku v adresári `/hooks` premenovať `pre-commit.tmpl` na `pre-commmit` a poeditovať ho tak, aby sa udávali absolútne cesty k súborom (viď nižšie).
```
1.  Check that the author of this commit has the rights to perform
1.  the commit on the files and directories being modified.
/home/svn/svnroot/hooks/commit-access-control.pl "$REPOS" "$TXN" /home/svn/svnroot/hooks/commit-access-control.cfg || exit 1
```

1.  Skopírovať do adresára `/hooks` súbor `commit-access-control.pl` a chmodnúť ho na executable.
1.  Skopírovať do adresára `/hooks` súbor `commit-access-control.cfg`
```
[Projekty]
match = ^projects
users = joe
access = read-write

[Projekty - google2]
match = ^projects/google2
users = john,joe,george
access = read-write
```
### Hlási to `IniFiles.pm`
Ak to hlási nemožnosť nájsť `IniFiles.pm`
```
Can't locate Config/IniFiles.pm in @INC
```
* Exportnite premennú prostredia aby sťahovač Perlu z CPANu podporoval pasívne FTP:
```
export FTP_PASSIVE=1
```
* Doinštalujte `perl-CPAN`
```
> yum install perl-CPAN
```
* Spustite CPAN, upgradnite ho a doinštalujte príslušný package `IniFiles`
```
> cpan
> install Bundle::CPAN
> install Config::IniFiles
```

# Inštalácia pod Linuxom [http]
Stiahnuť `mod_dav_svn` a uviesť do `LoadModule` za klauzulu `LoadModule mod_dav`. Niektoré distribúcie to robia automaticky.

Do `httpd.conf` dodať:
```
<Location />
  DAV svn
  SVNPath /svn # cesta vo filesysteme k ulozisku

  AuthType Basic
  AuthName "UINF PF UPJS Subversion repository"
  AuthUserFile /etc/svn/http-passwd
  Require valid-user

  AuthzSVNAccessFile /etc/svn/authz
</Location>
```

## Klauzula `AuthUserFile`
Udáva mená a heslá v apachovskom formáte. Používateľa možno založiť cez:
```
htpasswd -cm /etc/http-passwd harry
```

## Klauzula `AuthzSVNAccessFile`
Obsahuje špecifikáciu `authz` (viď príklady vyššie)

## Inštalácia pod Fedorou, autentifikácia cez MySQL
### Skontrolovať prítomnosť `apr-mysql` s podporou MySQL pre httpd
```
yum install apr-util-mysql
```
### Načítať do httpd príslušné moduly:
```
LoadModule dbd_module modules/mod_dbd.so
LoadModule authn_dbd_module modules/mod_authn_dbd.so
```
### Vytvoriť databázu
* prihlásiť sa do MySQL
```
mysql -u root
```
* vytvoriť databázu
```
CREATE DATABASE apacheauth;
create user 'apache'@'localhost' IDENTIFIED BY 'XXXXXX';
grant all privileges on apacheauth.* to 'apache'@'localhost';
use apacheauth
create table authn (user varchar(20) not null, password varchar(255) not null);
```
* dokonfigurovať moduly v `httpd.conf`
```
1.  mod_dbd configuration
DBDriver mysql
DBDParams "host=localhost dbname=apacheauth user=apache pass=XXXXXXX"

DBDMin  4
DBDKeep 8
DBDMax  20
DBDExptime 300
```
Dokonfigurovať adresár:
```
<Location /svn>
  DAV svn
  SVNPath /var/svn/repositoryroot

  AuthType Basic
  AuthName "UINF PF UPJS Subversion repository"
  Require valid-user

  AuthBasicProvider dbd
  AuthDBDUserPWQuery "SELECT password FROM authn WHERE user = %s"
</Location>
```
Meniť heslá je dobré:
```sql
update authn set password=encrypt('mocneheslo', 'salt') where user='chuck';
```
Nezabudnite na to, že salt musí byť rovnaká ako v prípade ručnej kontroly v PHP skripte, ktorý porovnáva zadané a uložené heslo.

