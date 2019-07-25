---
title: Tomcat – receptár tipov a trikov
date: 2008-04-10T15:40:10+01:00
---
# Zmena implicitnej uvítacej stránky
## Tomcat 4.1.x
Do `web.xml` stačí vložiť nový kontext
```xml
<Context docBase="C:\Java\Tomcat\webapps\ROOT" path="" workDir="work\Standalone\localhost\_" />
```
## Tomcat 5.5.x
Podľa odporúčaní je vhodné popisy kontextov ukladať do adresára `%CATALINA_HOME%\conf\Catalina\localhost` (a nie upravovať `web.xml`). Koreňový kontext zmeníme vytvorením súboru `%CATALINA_HOME%\conf\Catalina\localhost\ROOT.xml` s obsahom
```xml
<Context docBase="C:/projects/tomcat-root" />
```

# Kompilácia `jsvc` na 64bitovej Fedore
Do `configure` pre `jsvc` treba okolo riadku 2630 (tam, kde sa detekuje architektúra) pridať do `case` vetvenia riadok
```
x86_64)
    CFLAGS="$CFLAGS -DCPU=\\\"i686\\\"" ;;
```
Potom sa pokračuje v inštalácii normálne (`./configure`, `make`...).

# Tomcat 5.5.x ako service bez `jsvc`
```
#!/bin/bash

# This is the init script for starting up the 
# Jakarta Tomcat server
#
#  chkconfig: 345 91 10 
#  description: Starts and stops the Tomcat daemon.
#
#
#  Source function library.
. /etc/rc.d/init.d/functions

#  Get config.
. /etc/sysconfig/network

#  Check that networking is up.
[ "${NETWORKING}" = "no" ] && exit 0

CATALINA_HOME=/opt/tomcat
startup=$CATALINA_HOME/bin/startup.sh
shutdown=$CATALINA_HOME/bin/shutdown.sh
JAVA_HOME=/usr/java/jdk

export CATALINA_HOME JAVA_HOME

start(){
    echo -n $"Starting tomcat service: " 
    echo
    $startup
    RETVAL=$?
    echo
}

stop(){
    action $"Stopping tomcat service: " $shutdown   
    RETVAL=$?
    echo
}

restart(){
    stop
    start
}


#  See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    numproc=`ps -ef | grep catalina | grep -v "grep catalina" | wc -l`
    if [ $numproc -gt 0 ]; then
      echo "Tomcat is running..."
    else
      echo "Tomcat is stopped..."
    fi
    ;;
  restart)
    restart
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|restart}"
    exit 1
esac

exit 0
```

# Tomcat 5.5 a mod_jk

Súbor `mod_jk.conf`:

```
<IfModule !mod_jk.c>
  LoadModule jk_module "/usr/share/tomcat-connector/mod_jk.so"
</IfModule>


JkWorkersFile /usr/share/tomcat/conf/workers.properties
JkLogFile     /var/log/httpd/mod_jk.log
JkLogLevel    debug

JkMount /jorge worker1
JkMount /jorge/* worker1

Alias /jorge /home/jorge/webapp
```
Súbor `mod_jk.conf` includeneme do hlavneho konfiguraku Apache HTTPD. V `httpd.conf` uvedieme direktivu
```
Include cesta_k_mod_jk/mod_jk.conf
```
Alternatívne môžeme vyššie uvedený obsah rovno vložiť do `httpd.conf`.

Riadky
```
JkMount /jorge worker1
JkMount /jorge/* worker1

Alias /jorge /home/jorge/webapp
```
sa vzťahujú na konkrétnu webovú aplikáciu, ktorá sa má obsluhovať Apacheom. V príklade máme skonfigurovanú webovú aplikáciu `jorge`.

### Súbor `workers.properties`
```
%
# Define 1 real worker using ajp13
worker.list=worker1
# Set properties for worker1 (ajp13)
worker.worker1.type=ajp13
worker.worker1.host=localhost
worker.worker1.port=8009
worker.worker1.cachesize=10
worker.worker1.cache_timeout=600
worker.worker1.socket_keepalive=1
worker.worker1.recycle_timeout=300
```

### Tomcatovsky `server.xml`
```xml
<Listener className="org.apache.jk.config.ApacheConfig" modJk="/usr/share/tomcat-connector/mod_jk.so" />
```
pod `Engine` element.

# Prepojenie Tomcat a Apache HTTPD prepojenie cez `mod_proxy_ajp`
Tomcat 5.5 vo Fedore 6 automaticky podporuje na porte 8009 protokol AJP. Stačí nakonfigurovať `mod_proxy_ajp`:
```
[root@server] cat /etc/httpd/conf.d/proxy_ajp.conf
LoadModule proxy_ajp_module modules/mod_proxy_ajp.so
ProxyPass /blog ajp://localhost:8009/blog
```

# Tomcat 6 na Fedore Core 6, manualna instalacia
http://www.2nrds.com/installing-and-running-apache-tomcat-in-linux

# `ServletContextListener` nenájdený?
Máte chybovú hlášku typu
```
org.apache.catalina.core.StandardContext listenerStart
SEVERE: Error configuring application listener of class org.springframework.web.context.ContextLoaderListener
java.lang.NoClassDefFoundError: javax/servlet/ServletContextListener
```
Príčinou je zmätočná dokumentácia Tomcatu. Niekedy medzi podverziami verzie 5.5.x sa prepracovala trieda `Loader`. Automatické načítavanie kontextu je možné nastaviť nasledovne. Pôvodnú verziu (platnú u mňa ešte vo verzii 5.5.17)
```xml
<Context docBase="D:/projects/libris/web" reloadable="true">
  <Loader checkInterval="3" />
</Context>
```
je potrebné nahradiť verziou
```xml
<Context docBase="D:/projects/libris/web" reloadable="true" 
         backgroundProcessorDelay="3" />
```

# Logovanie cez log4j pre každú webaplikáciu zvlášť.
[Dokumentácia](http://tomcat.apache.org/tomcat-5.5-doc/logging.html ) Tomcatu uvádza spôsob, ako zaviesť logovanie pre každú webaplikáciu zvlášť.

1.  Vytvoriť `log4j.properties` a uložiť ho do `common/classes`
1.  Vložiť JAR pre log4j do `common/lib`
1.  Vložiť `commons-logging.jar` do `common/lib`
1.  Vložiť JAR pre log4j a JAR pre commons-logging do `lib` adresára webovej aplikácie
1.  Vytvoriť `log4j.properties` a uložiť ho do `classes` adresára webovej aplikácie

Dokumentácia zabudla spomenúť, že do LIB adresára treba popri JARe pre log4j skopírovať aj JAR pre commons-logging.

# Tomcat a SSL
## Povolenie SSL
Instalacia SSL do Tomcata je [pekne popisana v jeho dokumentacii](http://tomcat.apache.org/tomcat-5.5-doc/ssl-howto.html ). Prikazom
```
%JAVA_HOME%\bin\keytool -genkey -alias tomcat -keyalg RSA
```
sa vytvori novy subor `.keystore` v domovskom adresari uzivatela.

V tomcatovskom `server.xml` staci potom odkomentovat SSL Connector pre HTTP/1.1.

## Klientska aplikacia na pripojenie k Tomcatu.
### Export certifikatu zo servera
* Pomocou Internet Explorera sa pripojime k Tomcatu. Objavi sa varovanie o neplatnom certifikate. Nechame si ho zobrazit a exportujeme ho v tvare Base64 napr. do `certifikat.cer`. Tento certifikat importneme do klientskeho truststore (vid dalsia sekcia)

### Importovanie selfsigned certifikatu do klientskej aplikacie
Z prikazoveho riadku spustime (cely prikaz je na jednom riadku!)
```
keytool -import -trustcacerts -file d:\certifikat.cer 
        -keystore c:\java\jdk-1.5.0_04\jre\lib\security\cacerts 
        -alias tomkat 
```

### Ladenie SSL
```java
System.setProperty("javax.net.debug", "ssl");
```
zapne ladiace vypisy na standardny vystup.

### Testovacia aplikacia
```java
public class SSLTest {
  public static void main(String[] args) throws Exception {
    System.setProperty("javax.net.debug", "all");
    System.out.println(new URL("https://localhost:8443/").getContent());
  }
}
```

### Tomcat 6 a `mod_jk` na Fedore 64-bit

* stiahnut Tomcat Connector (http://tomcat.apache.org/connectors-doc/)
* yum search apxs
* yum install httpd-devel.x86_64
* cd native
* ./configure --with-apxs=/usr/sbin/apxs
* make
* make install
```
Libraries have been installed in:
   /usr/lib64/httpd/modules
```
* konfiguraky ako v pripade Tomcat 5.5
