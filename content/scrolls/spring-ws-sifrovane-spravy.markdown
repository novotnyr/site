---
title: Spring WS a šifrované správy
date: 2008-08-25T17:22:51+01:00
---

# Keystore

## Vygenerovanie dvojice privátny kľúč-verejný kľúč pre server
```
keytool -genkey 
        -alias ais-ws-server 
        -keystore ais-ws-server.jks 
        -keyalg RSA
```
Pozn. treba explicitne zvoliť algoritmus RSA, pretože implicitný algoritmus DSA vedie na klientskej strane k chybe:
```
Can't use DSA for encryption
```
## Export serverovského certifikátu
export verejného kľúča (= serverovského certifikátu), ktorým bude klient šifrovať správy
```
keytool -export 
        -alias ais-ws-server 
        -file ais-ws-server-public-key.crt 
        -keystore ais-ws-server.jks
```
Súbor `ais-ws-server-public-key.crt` obsahuje certifikát servera, ktorý importneme do keystoru u klienta.
## Import certifikátu do keystoru klienta
```
keytool -import -keystore ais-ws-client.jks 
        -file ais-ws-server-public-key.crt 
        -alias spring-ws-server-pubkey
```
# Server
JARy:

- commons-logging.jar 
- log4j-1.2.15.jar 
- opensaml-1.1.jar 
- spring.jar 
- spring-webmvc.jar 
- spring-ws-1.5.4.jar 
- wsdl4j-1.6.1.jar 
- wss4j-1.5.4.jar
- xalan-2.7.0.jar
- xmlsec-1.4.0.jar 

Endpoint:
```java
package movie.ws;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

public class RegistrationEndPoint {
  public void handleMovieReservationRequest(MovieReservationRequest) {
    try {
      Transformer transformer = TransformerFactory.newInstance().newTransformer();
      transformer.transform(messageSource, new StreamResult(System.out));
    } catch (Exception e) {
      e.printStackTrace();
    } 
  }
}
```
Endpoint je klasické POJO. Ak môžeme používať anotácie, máme dve možnosti:

* anotovať endpoint cez `@Endpoint` a príslušnú metódu pomocou `@PayloadRoot`
* anotovať endpoint cez `@Endpoint` a príslušnú metódu pomocou `@SoapAction`, kde sa volaná metóda určí na základe hlavičky SoapAction v požiadavke.

Možnosť s `@PayloadRoot` je však v prípade šifrovaných správ nepoužiteľná, keďže vyhodnocovanie volanej metódy sa určí ešte pred aplikáciou interceptorov. Inak povedané, mapovanie endpointov pracuje ešte nad šifrovanou správou, kde ešte nevidíme do pôvodnej nešifrovanej správy.
```java
@Endpoint
public class RegistrationEndPoint {
  @SoapAction("http://movies/movieReservation")
  public void handleMovieReservationRequest(MovieReservationRequest request) {
    try {
      Transformer transformer = TransformerFactory.newInstance().newTransformer();
      transformer.transform(messageSource, new StreamResult(System.out));
    } catch (Exception e) {
      e.printStackTrace();
    } 
  }
}
```

# Aplikačný kontext
Predovšetkým zapneme autodetekciu endpointov:
```xml
<context:component-scan base-package="movie.ws"/>
```
Ďalej dodáme endpoint adaptér, ktorý povolí objektové typy v parametroch metód a návratových hodnotách. Zároveň dodáme marshaller a unmarshaller:
```xml
<bean class="org.springframework.ws.server.endpoint.adapter.GenericMarshallingMethodEndpointAdapter">
  <property name="marshaller" ref="marshaller" />
  <property name="unmarshaller" ref="unmarshaller" />
</bean>

<bean name="marshaller" class="org.springframework.oxm.jaxb.Jaxb2Marshaller">
  <property name="contextPath" value="ais.ws.types" />
</bean>

<alias name="marshaller" alias="unmarshaller"/>
```

Ďalej potrebujeme definovať:

* požiadaviek na endpointy
* **security interceptor**.
V security interceptore potrebujeme definovať akcie, ktoré sa udejú nad prichádzajúcimi požiadavkami, teda validujúce akcie. Definujeme dve: overovanie hesla (`UsernameToken`) a dešifrovanie (`Encrypt`).
Ku každej akcii definujeme callback handler, ktorý obslúži príslušnú validujúcu akciu.
* **keystoreCallbackHandler** dešifruje správy privátnym kľúčom servera. Ten sa zoberie z keystoru, ktorý je reprezentovaný implementáciou triedy `Crypto`
* **callbackHandler** overí mená a heslá podľa vopred definovanej mapy mien a hesiel

```xml
<!--  support @Endpoint and @SoapAction annotations -->
<bean class="org.springframework.ws.soap.server.endpoint.mapping.SoapActionAnnotationMethodEndpointMapping">
<property name="interceptors">
  <list>
    <ref local="securityInterceptor"/>
  </list>
</property>
</bean>

<bean id="securityInterceptor" class="org.springframework.ws.soap.security.wss4j.Wss4jSecurityInterceptor">
  <property name="validationCallbackHandlers">
    <list>
      <ref local="keystoreCallbackHandler"/>
      <ref local="callbackHandler"/>          
    </list>
  </property>
  <property name="validationActions" value="UsernameToken Encrypt"/>
  <property name="validationDecryptionCrypto">
      <bean class="org.springframework.ws.soap.security.wss4j.support.CryptoFactoryBean">
          <property name="keyStorePassword" value="hesloheslo"/>
          <property name="keyStoreLocation" value="file:/d:/AIS/ais-ws-spring-security/ais-ws-server.jks" />
      </bean>
  </property>
</bean>

<bean id="callbackHandler" class="org.springframework.ws.soap.security.wss4j.callback.SimplePasswordValidationCallbackHandler">
  <property name="users">
      <props>
          <prop key="Bert">Ernie</prop>
      </props>
  </property>
</bean>

<bean id="keystoreCallbackHandler" class="org.springframework.ws.soap.security.wss4j.callback.KeyStoreCallbackHandler">
    <property name="privateKeyPassword" value="hesloheslo"/>
</bean>
```
# Klient
V klientovi potrebujeme definovať security interceptor, marshaller a akcie určené pre zabezpečenie správy.

Definujeme XML aplikačného kontextu `springws-client.xml`, do ktorého uvedieme nasledovné beany:
```xml
<bean id="securityInterceptor" class="org.springframework.ws.soap.security.wss4j.Wss4jSecurityInterceptor">
  <!-- akcie pre zabezpečenie sú presne také isté ako na strane servera -->
  <property name="securementActions" value="UsernameToken Encrypt" />
  <!-- login pri autentifikácii -->
  <property name="securementUsername" value="Bert"/>
  <!-- heslo pri autentifikácii -->
  <property name="securementPassword" value="Ernie"/>
  <!-- spôsob prepravy hesla - použijeme hashovanú formu -->
  <property name="securementPasswordType" value="PasswordDigest" />
  <!-- referencia na bean sprístupňujúci klientský keystore -->
  <property name="securementEncryptionCrypto" ref="cryptoFactoryBean" />
  <!-- alias pre certifikat v keystore -->
  <property name="securementEncryptionUser" value="spring-ws-server-pubkey" />
</bean>

<bean id="cryptoFactoryBean" class="org.springframework.ws.soap.security.wss4j.support.CryptoFactoryBean">
  <property name="keyStoreLocation" value="file:/d:/AIS/ais-ws-spring-security/ais-ws-client.jks" />
  <property name="keyStorePassword" value="hesloheslo" />   
</bean>
```
Ďalej dokonfigurujeme šablónu `WebServiceTemplate` a prepojíme ju s interceptorom a marshallerom:
```xml
<bean id="webServiceTemplate" class="org.springframework.ws.client.core.WebServiceTemplate">
  <property name="marshaller" ref="marshaller" />
  <property name="unmarshaller" ref="marshaller" />
  <property name="interceptors" ref="securityInterceptor" />
</bean>

<bean id="marshaller" class="org.springframework.oxm.jaxb.Jaxb2Marshaller">
  <property name="contextPath" value="movie.ws.types" />
</bean>
```
Kód klienta:
```java
ClassPathXmlApplicationContext ctx
 = new ClassPathXmlApplicationContext("ais/web/springws-client.xml");
WebServiceTemplate webServiceTemplate 
  = (WebServiceTemplate) ctx.getBean("webServiceTemplate");
webServiceTemplate.setDefaultUri("http://localhost:8080/movie-ws/");

MovieReservation reservation = new MovieReservation(4, "Godzilla");

// callback, ktorý nastaví správe hlavičku SoapAction
SoapActionCallback soapActionCallback 
  = new SoapActionCallback("http://movies/movieReservation");

webServiceTemplate.marshalSendAndReceive(reservation, soapActionCallback);
```

# Workflow šifrovaných správ medzi serverom a klientom
## Komunikácia klient->server
1.  Klient vlastní verejný kľúč servera
1.  Zašifruje ním správu
1.  Odošle ju serveru
1.  Server ju dešifruje svojim privátnym kľúčom.

## Komunikácia klient-server
1.  Klient podpíše správu svojim privátnym kľúčom
1.  Spolu so správou odošle svoj X.509 certifikát (teda verejný kľúč)
1.  Server overí správu verejným kľúčom od klienta
1.  Zašifruje odpoveď verejným kľúčom zo servera
1.  Odošle ju klientovi.
1.  Klient ju odšifruje svojim privátnym kľúčom

# Literatúra
http://msdn.microsoft.com/en-us/library/ms977327(printer).aspx

Shared key encryption is very fast, scalable to any size message, and, consequently, is always used for encrypting the XML text of a message. Public key encryption has beneficial key management characteristics because a public key, typically wrapped in an X.509 certificate issued by a certificate authority, can be published publicly in a registry or even in the WSDL. The recipient's public key can then be used to encrypt the shared key, and the shared key can be used to encrypt the different parts of the message itself.

Let's go over that again but in a different order. First, the message itself, or perhaps multiple individual parts of the message, are encrypted using a generated arbitrary shared key. Second, this shared key is then encrypted using the recipient's public key. Because the recipient is the holder of the solitary matching and highly protected private key, theoretically, the recipient is the only one who can decrypt the shared key and then proceed to decrypt the rest of the message.

The technique is often called key wrapping or digital enveloping because the shared key is wrapped by the recipient's public key. Although we tend to emphasize using a public key for key wrapping, it is equally possible to use a shared key to wrap a shared key.

Troubleshooting
===============

## An unsupported signature or encryption algorithm was used (unsupported key transport encryption algorithm: No such algorithm: http://www.w3.org/2001/04/xmlenc#rsa-1_5

Nainštalujte BouncyCastle, napr. z http://www.bouncycastle.org/download/bcprov-jdk16-140.jar
