---
title: Bedáky nad XML Security
date: 2008-09-05T15:30:40+01:00
---

[XML-Security 1.4.0](http://santuario.apache.org/index.html ) má problémy s kódovaním diakritických znakov.

*Xml canonization - UTF-8 encoding issue in Xml security 1.4.0. Committed by RB. Thanks to Karol Rewera. See Issue 41462*

XML-Security 1.4.1 funguje, ale v Spring-WS prestane fungovať šifrovanie správ certifikátom, ktorý odošle klient (WSHandler z WSS4J začne overovať certifikát, čo nemá robiť). Pomôže import certifikátu klienta do serverovského trust storu.

XML-Security 1.4.2 funguje, ale hádže výnimky, keď digest uvedený v požiadavke nesedí s vypočítaným digestom.
