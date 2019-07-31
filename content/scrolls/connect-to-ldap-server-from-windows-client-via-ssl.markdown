---
title: Connect to LDAP server from Windows client via SSL
date: 2015-09-14T16:20:00+01:00
wpid: 2706
categories:
- infraštruktúra
tags:
- LDAP
---

Connecting to LDAP server with SSL via client side may be difficult due to Windows
peculiarities. How to `ldapmodify` the data?

Retrieve server certificate
---------------------------
Locate the server certificate on the server in:

    secure/certs/server.pem 

Extract the parts between and including 

    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----

Store the certificate to the client machine to the `c:/etc/ldap/server.pem`.

Prepare client certificate
---------------------------
Create `c:/etc/ldap/ldap.conf` with the following contents:

    TLS_CACERT c:/etc/ldap/server.pem

Set the location of client configuration file

    SET LDAPCONF=c:/etc/ldap/ldap.conf

Fixing CN and hostname mismatch
-------------------------------
Connection to the LDAP server will positively fail due to certificate mismatch:

    ldap_start_tls: Can't contact LDAP server (-1)
            additional info: TLS: hostname does not match CN in peer certificate
    ldap_sasl_bind(SIMPLE): Can't contact LDAP server (-1)

Analyzing certificate in `server.pem` leads to:

*   Common Name: development
*   Organization: Internet
*   Organization Unit: dc=maxcrc,dc=com
*   Locality: Langen
*   State: Germany
*   Country: DE

Either recreate server certificates to match the host name or resolve hostname 
to `development` on the client machine.

Add the following line to `c:\Windows\System32\drivers\etc\hosts`: 

    127.0.0.1 development

Setup is now complete.

Import data
----------- 
Import the data 

    ldapmodify.exe -a -f sample.ldif -d 1 -x -D "cn=root,dc=mydomain,dc=com" -w iamroot -Z -H ldaps://development

*   `-a` add the data to the LDAP database
*   `-f sample.ldif` the data source file
*   `-d 1` enable some logging
*   `-x` use login+password authentication
*   `-D` DN of the administrator user
*   `-w iamroot` administrator password
*   `-Z` use TLS
*   `-H ldaps://development` the LDAP server host. Note that we are using `development` that matches the CN in the server certificate.