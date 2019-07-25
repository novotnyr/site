---
title: Maven, Jetty plug-in a spustenie SSL konektora
date: 2011-11-25T08:20:57+01:00
---

Problém
=======

Cieľ `maven jetty:run` v Mavene je veľmi užitočný na rýchle nasadenie
webovej aplikácie do servletového kontajnera Jetty. V štandardom
nastavení počúva Jetty na porte 8080\... ale nepodporuje SSL.

Ako nastaviť pom.xml?
=====================

Jetty v Mavene používa štandardne klasický konektor určený pre bežné
nezabezpečené HTTP a SSL konektor ponecháva vypnutý. Ak chceme používať
SSL, musíme v `pom.xml` explicitne zapnúť SSL konektor.

``` {.myxml}
<plugin>
  <groupId>org.mortbay.jetty</groupId>
  <artifactId>jetty-maven-plugin</artifactId>
  <version>7.4.2.v20110526</version>
    <configuration>
        <connectors>
            <connector implementation="org.eclipse.jetty.server.ssl.SslSocketConnector">
                <port>8443</port>
                <maxIdleTime>60000</maxIdleTime>
                <keystore>etc/jetty-ssl.keystore</keystore>
                <password>jetty6</password>
                <keyPassword>jetty6</keyPassword>
            </connector>
        </connectors>
    </configuration>        
</plugin>
```

Na to, aby sme mohli používať SSL, potrebujeme definovať úložisko
(*keystore*) pre certifikáty a kľúče používané v komunikácii. Vytvoríme
ho klasickým Java nástrojom `keytool`.

    keytool -genkey -alias jetty6 -keyalg RSA -keystore etc/jetty-ssl.keystore -storepass jetty6 -keypass jetty6 -dname "CN=vaša doména"

Záverečné poznámky
==================

Tieto nastavenia platia pre \"novú\" verziu Jetty pluginu, ktorá
zodpovedá implementácii Jetty z projektu Eclipse. Návod pre staršie
verzie možno nájsť na
[http://mrhaki.blogspot.com/2009/05/configure-maven-jetty-plugin-for-ssl.html]().

V tejto ukážke sme explicitne zakázali bežný HTTP konektor.
