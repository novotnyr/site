---
title: Ako Maťko s Kubkom seržanta po Pavučine naháňali (Debian Sarge)
date: 2006-02-19T00:00:00+01:00
---

Inštalácia
==========

* sarge-i386-netinst.iso nahodene do VMWaru. Bolo treba nastavit siet z Bridged na NAT (inak sa instalator stazoval na nepritomne DHCP)
* po chvilke laborovania `nano /etc/apt/sources.list` dovolilo pridat 
`deb http://ftp.tuke.sk/debian stable main contrib non-free`
`deb http://ftp.tuke.sk/debian testing main contrib non-free`
(`deb server typ_releaseu vetva1 vetva2...}
* cerstvo nainstalovany serzant ma okolo 200MB.
* `apt-get install mc` (ruky)
* `apt-get install apache2`
* `apt-get install links2`
* `apt-get install php4`
* `apt-get install ssh4` (openSSH, vratane demona sshd)

XServer
=======

Zakazanie prihlasovania sa rovno do Xov:

* premenovat /etc/rc2.d/S99?dm na /etc/rc2.d/K99?dm (? = x, k, w)

VMWare Tools
============

* bolo treba doinstalovat `gcc` (`apt-get install gcc`) hlavickove subory ku kernelu (podla `uname -a`) -- `apt-get install kernel-headers-*cislo kernelu*`
* ak sa XServer po instalacii stazuje, ze nevie najst pointer, skuste zmenit nastavenia mysi v `/etc/X11/XF86Config-4`: menovite 
** `Option "Protocol" "ps/2"`
** `Option "Device" "/dev/psaux"`
