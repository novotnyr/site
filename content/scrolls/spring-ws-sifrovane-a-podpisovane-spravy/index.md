---
title: Spring WS – šifrované a podpisované správy
date: 2008-09-01T00:00:00+01:00
---

# Aplikačný kontext na strane servera
## Endpoint
Predovšetkým definujeme bean endpointu
```xml
<bean id="movieReservationEndpoint" class="sk.novotnyr.movies.ws.MovieReservationEndPoint" />
```
## Mapovanie endpointov
Ďalej definujeme mapovanie požiadaviek na endpointy. Mapovanie podľa koreňového elementu nie je možné, keďže budeme prijímať šifrované správy, kde ešte nebudeme mať prístup k payloadu. (Payload je dešifrovaný interceptormi a tie sa použijú až vtedy, keď sa vyhodnotí endpoint, ktorý požiadavku spracuje.) V našom prípade použijeme mapovanie podľa hlavičky `SoapAction`. Akcia `http://movies/movieReservation` bude spracovaná endpointom `movieReservationEndpoint`. 

Rovnako definujeme interceptory, ktoré budú pracovať nad požiadavkou a budú ju dešifrovať, overovať podpisy atď.
```xml
<bean class="org.springframework.ws.soap.server.endpoint.mapping.SoapActionEndpointMapping">
    <property name="interceptors">
        <ref local="securityInterceptor"/>
    </property>
    <property name="mappings">
      <props>
        <prop key="http://movies/movieReservation">
          movieReservationEndpoint
        </prop>
    </props>
  </property>
</bean>
```
## Úložiská kľúčov -- keystore
Pri všetkých kryptografických operáciách je potrebné mať k dispozícii úložisko certifikátov, teda privátnych a verejných kľúčov. Operácie nad úložiskom kľúčov zabezpečuje trieda [Crypto](http://ws.apache.org/wss4j/apidocs/org/apache/ws/security/components/crypto/Crypto.html ) z projektu WSS4J. Inštanciu tejto triedy získame springovskou továrňou `CryptoFactoryBean`, ktorej ukážeme cestu k súboru úložiska kľúčov a heslu k nemu.
```xml
<bean id="crypto" class="org.springframework.ws.soap.security.wss4j.support.CryptoFactoryBean">
    <property name="keyStorePassword" value="kezstore"/>
    <property name="keyStoreLocation" value="classpath:movie-service.jks" />
</bean> 
```
V úložisku musíme mať dvojicu *verejný kľúč*-*privátny kľúč servera*. Tú vygenerujeme:
```
keytool -genkey -alias movie-service 
        -keystore movie-service.jks -keyalg RSA
```
## Interceptor
Základnou triedou riešiacou bezpečnosť je `Wss4jSecurityInterceptor`. Ten odchytáva prichádzajúce a odchádzajúce správy a vykonáva nad nimi operácie týkajúce sa zabezpečenia.

Základné dve kategórie sú:

* `securement` - ošetrovanie odchádzajúcich správ (klientovi)
* `validation` - ošetrovanie prichádzajúcich správ (od klienta)

### Spracovávanie prichádzajúcich správ
Postavme službu tak, že budeme očakávať od klienta šifrované správy, ktoré budú zároveň podpisované klientom. V úložisku kľúčov musíme mať privátny kľúč servera a verejné kľúče (certifikáty) klientov. 
Definujeme bean `securityInterceptor`
```xml
<bean id="securityInterceptor" 
      class="org.springframework.ws.soap.security.wss4j.Wss4jSecurityInterceptor">
  <property name="validationActions" value="Encrypt Signature"/>

  <property name="validationDecryptionCrypto" ref="crypto" />

  <property name="validationSignatureCrypto" ref="crypto" />

  <property name="validationCallbackHandler" 
            ref="keystoreCallbackHandler" />
</bean>
```
V prípade prichádzajúcich správ môže interceptor vykonať viacero bezpečnostných akcií: overiť prihlasovacie meno, dešifrovať, overiť podpis, atď. (Zoznam povolených akcií je v JavaDocu pre [Wss4jSecurityinterceptor](http://static.springframework.org/spring-ws/sites/1.5/apidocs/index.html?org/springframework/ws/soap/security/wss4j/Wss4jSecurityInterceptor.html )a.

V našom príklade definujeme dve akcie:

* **Encrypt** pre dešifrovanie správy.
* **Signature** pre overenie integrity správy.

#### Encrypt
Táto akcia dešifruje správu. Na to použije privátny kľúč servera, ktorý sa nachádza v úložisku špecifikovanom cryptom nastavenom v `validationDecryptionCrypto`. Heslo k privátnemu kľúču sa získa pomocou beanu `KeystoreCallbackHandler`, ktorý zadefinujeme nasledovne:

        <bean id="keystoreCallbackHandler" class="org.springframework.ws.soap.security.wss4j.callback.KeyStoreCallbackHandler">
        <!-- heslo pre privatny kluc, ktorym sa bude overovat podpis -->
          <property name="privateKeyPassword" value="kezkezkez"/>
          </bean>

Tento callback handler zapojíme do interceptora pomocou atribútu 	`validationCallbackHandler`.

#### Signature
Tu overíme integritu správy a podpis. Certifikát overí pomocou crypta špecifikovanom vo `validationSignatureCrypto`. V úložisku kľúčov sa musí nachádzať certifikát klienta (teda verejný kľúč, ktorým bola správa podpísaná).

### Spracovávanie odchádzajúcich správ
Pre odchádzajúce správy zvolíme len šifrovanie (podpisovanie pôjde analogickým spôsobom). Do interceptora dodáme nasledovné atribúty:
```xml
<property name="securementActions" value="Encrypt"/>
<property name="securementEncryptionUser" value="useReqSigCert" />
```
Definujeme akciu `Encrypt`, ktorá určí šifrovanie správ. Pre šifrovanie potrebujeme mať k dispozícii verejný kľúč klienta. Tu existuje viacero možností. Klient môže poslať identifikáciu svojho verejného kľúča (napr. tým, že nastaví v správe [ISSUER_SERIAL](http://ws.apache.org/wss4j/apidocs/org/apache/ws/security/WSConstants.html#ISSUER_SERIAL )), ktorou sa potom odkážeme do úložiska kľúčov na serveri (úložisko pre šifrovanie nastavíme cez `<property name="securementEncryptionCrypto" ref="crypto"/>`). 

Druhou možnosťou je poslať v požiadavke kompletný certifikát (DIRECT_REFERENCE). Server vie z požiadavky extrahovať certifikát a hneď ním podpísať správu idúcu klientovi. Na to je však potrebné nastaviť atribút `securementEncryptionUser` na špeciálnu hodnotu `useReqSigCert` (pozri tiež [WSHandlerConstants#USE_REQ_SIG_CERT](http://ws.apache.org/wss4j/apidocs/org/apache/ws/security/handler/WSHandlerConstants.html#USE_REQ_SIG_CERT )). 

# Aplikačný kontext na strane klienta
Klient sa bude riadiť nezávislým aplikačným kontextom, ktorý je možné definovať v súbore `spring-ws-client.xml`. 
## WebServiceTemplate
Jadrom klienta je trieda `WebServiceTemplate`, ktorú deklarujeme nasledovne:
```xml
<bean id="webServiceTemplate" class="org.springframework.ws.client.core.WebServiceTemplate">
  <property name="interceptors" ref="securityInterceptor" />
</bean>
```
V šablóne bude definovaný interceptor, ktorý bude plniť rovnakú úlohu ako na serveri: šifrovať, dešifrovať, podpisovať a overovať certifikáty.
## Crypto
Opäť budeme potrebovať inštanciu triedy `Crypto`, ktorá bude pracovať nad klientským úložiskom kľúčov. V tomto úložisku bude privátny a verejný kľúč klienta a certifikát servera. Certifikátom servera sa budú šifrovať požiadavky na server. Privátnym kľúčom klienta sa budú podpisovať požiadavky. Certifikát klienta sa bude prikladať k požiadavke, aby ním mohol server zašifrovať odpoveď.
```xml
<bean id="crypto" 
class="org.springframework.ws.soap.security.wss4j.support.CryptoFactoryBean">
  <property name="keyStoreLocation" 
            value="classpath:robert-novotny-upjs-sk.jks" />
  <property name="keyStorePassword" 
            value="clientkezstore" />
</bean>
```
Opäť špecifikujeme cestu k úložisku a heslo k nemu.

V úložisku musíme mať dvojicu *verejný kľúč*-*privátny kľúč klienta*. Tú vygenerujeme:
```
keytool -genkey -alias robert.novotny@upjs.sk 
        -keystore robert-novotny-upjs-sk.jks -keyalg RSA
```
Rovnako musí byť v úložisku certifikát servera. Z úložiska servera exportneme certifikát nasledovne:
```
keytool -export -alias movie-service -keystore movie-service.jks 
        -file movie-service.crt
```
Do úložiska klienta ho importneme:
```
keytool -import -keystore robert-novotny-upjs-sk.jks 
        -file movie-service.crt
```
## Interceptor
Teraz definujeme interceptor:
```xml
<bean id="securityInterceptor" class="org.springframework.ws.soap.security.wss4j.Wss4jSecurityInterceptor">
  <property name="securementActions" value="Encrypt Signature" />
</bean>
```
Opäť rozpoznávame dve kategórie akcií: **securement** pre zabezpečenie požiadaviek a **validation** pre overovanie odpovedí.

### Zabezpečenie požiadaviek
Pre požiadavky definujeme dve akcie:

* **Encrypt** pre šifrovanie
* **Signature** pre podpisovanie

#### Encrypt pre šifrovanie správ
`Encrypt` ich bude šifrovať. Na to potrebujeme odkaz na crypto s certifikátom servera (`securementEncryptionCrypto`) a alias ku verejnému kľúču servera v tomto úložisku.
```xml
<property name="securementEncryptionCrypto" ref="crypto" />
<property name="securementEncryptionUser" value="mykey" />
```

#### Signature pre podpisovanie správ
`Signature` ich bude podpisovať. Na to potrebujeme odkaz na crypto s privátnym kľúčom klienta (`securementSignatureCrypto`), alias ku privátnemu kľúču klienta v tomto úložisku a heslo k tomuto privátnemu kľúču (`securementPassword`).
```xml
<property name="securementSignatureCrypto" ref="crypto" />
<property name="securementUsername" value="robert.novotny@upjs.sk"/>
<property name="securementPassword" value="clientkez" />
```

Okrem toho budeme chcieť prikladať k požiadavkam kompletný klientský certifikát, ktorým bude server šifrovať odpovede. To vykonáme nastavením `DirectReference`:
```xml
<property name="securementSignatureKeyIdentifier"  
          value="DirectReference"/>
```
### Zabezpečenie odpovedí
Zabezpečenie odpovedí bude spočívať v ich dešifrovaní. Definujeme teda akcie pre validáciu `validationAction`. Ďalej definujeme `crypto`, v ktorom bude privátny kľúč klienta, ktorým dešifrujeme správu a `validationCallbackHandler`, ktorý poskytne heslo k privátnemu kľúču.
```xml
<property name="validationActions" value="Encrypt"/>

<property name="validationDecryptionCrypto" ref="crypto"/>  

<property name="validationCallbackHandler" 
          ref="keyStoreCallbackHandler" />
```
`KeystoreCallbackHandler` bude rovnaký ako v prípade servera, odlišné bude len heslo:
```xml
<bean id="keyStoreCallbackHandler" 
      class="org.springframework.ws.soap.security.wss4j.callback.KeyStoreCallbackHandler">
  <property name="privateKeyPassword" value="clientkez"/>
</bean>
```

# Hotová aplikácia
[Stiahnite si hotovú aplikáciu](secure-ws.zip).