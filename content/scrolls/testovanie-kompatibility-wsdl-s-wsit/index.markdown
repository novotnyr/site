---
title: Testovanie kompatibility WSDL voči WS-IT
date: 2019-10-07T15:16:53+01:00
draft: true
---

Na testovanie kompatibility existuje Java nástroj. Pôvodne bol k dispozícii na webe `ws-i.org`, ale tento portál má dlhodobé problémy so stabilitou.

Na stiahnutie použime radšej poslednú archivovanú verziu

```
curl https://web.archive.org/web/20170307052202/http://www.ws-i.org/Testing/Tools/2005/06/WSI_Test_Java_Final_1.1.zip
```

Následne ju odZIPujme:

```
unzip WSI_Test_Java_Final_1.1.zip
```

Linux/MacOS shellskripty majú zle nastavený *executable bit*, takže sa nedajú spustiť. Opravme to:

```
chmod +x wsi-test-tools/java/bin/*.sh
```

Okrem toho majú skripty zlé konce riadkov. Opravme ich napríklad pomocou [`dos2unix`](https://formulae.brew.sh/formula/dos2unix):

```
dos2unix wsi-test-tools/java/bin/*.sh
```

Nastavme premennú prostredia `WSIT_HOME`:

```
export WSI_HOME=$PWD/wsi-test-tools
```

Spustime analyzátor

```
$WSI_HOME/java/bin/Analyzer.sh
```

Konfiguračný súbor pre validáciu
--------------------------------

```
<configuration xmlns="http://www.ws-i.org/testing/2003/03/analyzerConfig/">
  <verbose>true</verbose>
  <assertionResults type="all" messageEntry="true" failureMessage="true" assertionDescription="true"/>
  <testAssertionsFile>/tmp/wsi-test-tools/common/profiles/SSBP10_BP11_TAD.xml</testAssertionsFile>
  <wsdlReference>
    <wsdlElement type="binding" namespace="urn:example:calendar:api">binding</wsdlElement>
    <wsdlURI>/Users/novotnyr/eclipse-ws-2019/calendar-ee/calendar.wsdl</wsdlURI>
  </wsdlReference>
</configuration>
```

