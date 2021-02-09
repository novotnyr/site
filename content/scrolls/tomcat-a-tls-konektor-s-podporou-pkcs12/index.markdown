---
title: Tomcat a TLS konektor s podporou PKCS#12
date: 2021-02-09T22:40:41+01:00
---

Tomcat 8.5 a novší už obsahujú vysokovýkonné konektory založené na neblokujúcim API Java.NIO. Výhodou je výkon porovnateľný s použitím natívnej knižnice APR (ktorú využíva hlavne Apache HTTPD server).

Ak používame SSL/TLS, máme ďalšiu výhodu. Certifikáty a privátne kľúče nemusíme ukladať do ťarbavých JKS keystorov, ale vieme použiť univerzálny formát známy z OpenSSL (PEM) vo formáte PKCS#12. Inými slovami, súbory typu `-----BEGIN CERTIFICATE` a `-----BEGIN PRIVATE KEY` vieme použiť priamo.

# Konfigurácia

V Tomcate, v súbore `server.xml` definujeme dva konektory pre komunikáciu nad HTTP.

* konektor pre otvorenú (_plaintext_) komunikáciu na porte 8080
* zabezpečený konektor nad TLS na porte 8443.

Plaintextový konektor je jednoduchý:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

Zabezpečený konektor používa nový zápis s využitím elementu `SSLHostConfig`, ktorý nahrádza obvyklý mix atribútov SSL/TLS definovaných v elemente `<Connector>`:

```xml
<Connector port="8443"
           protocol="org.apache.coyote.http11.Http11Nio2Protocol"
           maxThreads="150"
           SSLEnabled="true">
    <SSLHostConfig>
        <Certificate
            certificateFile="conf/tls/localhost.crt"
            certificateKeyFile="conf/tls/localhost.key" />
    </SSLHostConfig>
</Connector>
```    
    
Konektor využíva neblokujúci protokol NIO implementovaný v Jave. 
Ak je zapnutá podpora pre knižnicu APR (pomocou [`AprLifecycleListener`](https://tomcat.apache.org/tomcat-9.0-doc/api/org/apache/catalina/core/AprLifecycleListener.html), použije sa implementácia OpenSSL. 
Ak APR nie je k dispozícii, alebo je zakázaná, použije sa Java implementácia (JSSE), ktorá však bez problémov podporuje certifikáty a privátne kľúče vo formáte PKCS#12.

# Minimalistický `server.xml`

Takto si vieme definovať úplne minimalistický konfiguračný súbor `server.xml`. Má nasledovné vlastnosti:

- natívna podpora pre APR je úplne vypnutá
- používame rýdzu Java implementáciu protokolu HTTP i TLS
- certifikáty a privátne kľúče sú v tvare PKCS#12
- integrácia s `mod_proxy` cez protokol AJP je zakázaná.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
    <Listener className="org.apache.catalina.startup.VersionLoggerListener"/>
    <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener"/>
    <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener"/>
    <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener"/>

    <Service name="Catalina">
        <Connector port="8080" protocol="HTTP/1.1"
                   connectionTimeout="20000"
                   redirectPort="8443"/>
        <Connector port="8443"
                   protocol="org.apache.coyote.http11.Http11Nio2Protocol"
                   maxThreads="150"
                   SSLEnabled="true">
            <SSLHostConfig>
                <Certificate certificateFile="conf/tls/localhost.crt"
                             certificateKeyFile="conf/tls/localhost.key"/>
            </SSLHostConfig>
        </Connector>

        <Engine name="Catalina" defaultHost="localhost">
            <Host name="localhost"
                  appBase="webapps"
                  unpackWARs="true"
                  autoDeploy="true">
                <Valve className="org.apache.catalina.valves.AccessLogValve"
                       directory="logs"
                       prefix="localhost_access_log" suffix=".txt"
                       pattern="%h %l %u %t &quot;%r&quot; %s %b"/>
            </Host>
        </Engine>
    </Service>
</Server>
```
    