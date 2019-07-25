---
title: Mule – receptár tipov a trikov
date: 2010-06-04T10:49:10+01:00
---

Práca s payloadom
=================

* expressiony typu jxpath a bean pracujú štandardne nad samotným payloadom, vyhodnocovanie sa deje nad payloadom
* terminológia: Mule: message property, HTTP: message header

## Pridanie CRLF

Al chceme pridať do správy CR-LF pomocou StringAppenderTransformera, stačí do XML použiť `&#010;`

## Získanie obsahu payloadu

V `MessagePayloadExpressionEvaluator`: ak sa vynecha expression

```
#[payload:] 
```
(pozor na dvojbodku!) vrati sa obsah payloadu

## Outbound HTTP a telo správy

### GET HTTP
Ak používame HTTP outbound, telo správy sa pridá za GET parameter `body`:
```
www.google.com?body=HELLO
```

## Inbound HTTP
Ak pri inbound HTTP parametri neexistuje telo správy, do payloadu sa vloží prípona URL adresy, ktorú voláme. Ak mám
```
<http:inbound-endpoint path="search" .../>
```
a zavolám bez tela

```
http://localhost/search
```
Do payloadu sa vloží String `/search`.

# Mule 2.2.x a HTTP outbound konektory idú len POSTom!
Riešenie: dodať vlastnosť správy
```xml
    <inbound>
      <stdio:inbound-endpoint system="IN">
        <message-properties-transformer>
          <add-message-property key="query" value="#[payload:]"/>            
          <add-message-property key="http.method" value="GET"/>
        </message-properties-transformer>
      </stdio:inbound-endpoint>
      
    </inbound>
```

# Príklad parametrickej outbound HTTP požiadavky
```xml
<model name="echoSample">
  <service name="retrieve">
    <inbound>
      <stdio:inbound-endpoint system="IN">
        <message-properties-transformer>
          <add-message-property key="query" value="#[payload:]"/>            
          <add-message-property key="http.method" value="GET"/>
        </message-properties-transformer>
      </stdio:inbound-endpoint>
      
    </inbound>
    <outbound>
      <template-endpoint-router>
        <http:outbound-endpoint address="http://www.google.sk/search?q=[query]" method="GET" />
      </template-endpoint-router>
      
    </outbound>
  </service>
</model>
```

# Parametrický názov súboru
* nad `<model>`om definovať globálny parameter konektora `file`
```xml
<file:connector name="FileConnector">
  <file:expression-filename-parser/>
</file:connector>
```
a potom
```xml
<file:outbound-endpoint path="./" outputPattern="SNAPSHOT-#[function:dateStamp]" />
```

# Transformer, ktorý zahodí payload správy
```xml
<expression-transformer name="DiscardBodyTransformer" 
                        returnSourceIfNull="false">
  <return-argument expression="null" evaluator="groovy"/>
</expression-transformer>
```

