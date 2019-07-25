---
title: Securing Spring Web Services with XWSS
date: 2008-08-14T08:18:51+01:00
---
# Server
Predpokladajme, že máme hotovú kostru pre serverovskú časť Spring-WS.
Majme bežný endpoint, ktorý je klasickým POJOm. Endpoint predstavuje metódu, ktorá nevracia nič a dokument na vstupe pošle na štandardný výstup na serveri.
## Endpoint
```java
package ais.ws;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;

public class RegistrationEndPoint {
  public void handleMovieReservationRequest(Source messageSource) {
    try {
      Transformer transformer = TransformerFactory.newInstance().newTransformer();
      transformer.transform(messageSource, new StreamResult(System.out));
    } catch (Exception e) {
      e.printStackTrace();
    } 
  }
}
```
Bean zadeklarujeme v aplikačnom kontexte Springu:
```xml
<bean id="registrationEndpoint" class="ais.ws.RegistrationEndPoint" />
```
## Mapovanie endpointu
Ďalej zadefinujeme mapovanie endpointu. Pre jednoduchosť použijeme `SimpleEndpointMapping`. Ten vie určiť prefix a sufix metód, ktoré budú obsluhovať požiadavky. Ďalej v ňom definujeme zoznam endpointov, ktoré budú pri vyhľadávaní brané do úvahy.

V našom prípade budeme uvažovať bean endpointu `registrationEndpoint` a v ňom metódy začínajúce na `handle`. Metóda `handleMovieReservationRequest` bude obsluhovať dokumenty, ktorých koreňový element má lokálny názov `MovieReservationRequest`.
```xml
<bean class="org.springframework.ws.server.endpoint.mapping.SimpleMethodEndpointMapping">
  <property name="methodPrefix" value="handle"/>
  <property name="endpoints" ref="registrationEndpoint" />
</bean>
```
## Interceptor
Na riešenie zabezpečenia sa používajú interceptory. Tie si možno predstaviť ako analógiu filtrov v špecifikácii servletov. Pri použití XWSS je k dispozícii hotový interceptor `XwsSecurityInterceptor`. K nemu potrebujeme:

* konfiguračný súbor
* zoznam callback handlerov, ktoré budú riešiť autorizáciu

### Konfiguračný súbor
Konfiguračný súbor sa riadi špecifikáciu umiestnenou [na stránkach Sun-u](http://java.sun.com/webservices/docs/1.6/tutorial/doc/XWS-SecurityIntro4.html#wp565210 ). Žiaľ, k dispozícii nie je XML schéma, takže budeme si musieť dať pozor.
```xml
<xwss:JAXRPCSecurity xmlns:xwss="http://java.sun.com/xml/ns/xwss/config">
    <xwss:Service>
      <xwss:SecurityConfiguration>
          <xwss:RequireUsernameToken passwordDigestRequired="false" nonceRequired="false"/>
      </xwss:SecurityConfiguration>
  </xwss:Service>
</xwss:JAXRPCSecurity>
```
Samotný bean potom deklarujeme:
```xml
<bean id="securityInterceptor" class="org.springframework.ws.soap.security.xwss.XwsSecurityInterceptor">
    <property name="policyConfiguration" value="classpath:xwss-config.xml"/>
    <property name="callbackHandlers">
        <list>
            <ref bean="passwordValidationHandler"/>
        </list>
    </property>
</bean>
```
Callback handler na overovanie hesiel:
```xml
<bean id="passwordValidationHandler" class="org.springframework.ws.soap.security.xwss.callback.SimplePasswordValidationCallbackHandler">
  <property name="users">
    <props>
      <prop key="Bert">Ernie</prop>
    </props>
  </property>
</bean>
```

Interceptor ešte musíme uviesť v mapovaní endpointov v rámci property `interceptors`:
```xml
	<bean class="org.springframework.ws.server.endpoint.mapping.SimpleMethodEndpointMapping">
		<property name="methodPrefix" value="handle"/>
		<property name="endpoints" ref="registrationEndpoint" />
		<property name="interceptors">
			<list><ref local="securityInterceptor"/></list>
		</property>
	</bean>
```

# Klient
Konfigurácia pre klientskú stranu XWSS (súbor `xwss-client-config.xml`)
```xml
<xwss:SecurityConfiguration dumpMessages="true" xmlns:xwss="http://java.sun.com/xml/ns/xwss/config">
    <xwss:UsernameToken name="Bert" password="Ernie" digestPassword="false" useNonce="false"/>
</xwss:SecurityConfiguration>
```

Kód klienta:
```java
public class Client {
  public static void main(String[] args) throws Exception {
    WebServiceTemplate webServiceTemplate = new WebServiceTemplate();
    webServiceTemplate.setDefaultUri("http://localhost:8080/movie-ws/");
    
    XwsSecurityInterceptor securityInterceptor = new XwsSecurityInterceptor();
    securityInterceptor.setPolicyConfiguration(new ClassPathResource("xwss-client-config.xml"));
    securityInterceptor.setCallbackHandler(new CallbackHandler() {
      @Override
      public void handle(Callback[] callbacks) throws IOException, UnsupportedCallbackException {
        //do nothing
      }     
    });
    securityInterceptor.afterPropertiesSet();
    
    
    ClientInterceptor[] interceptors = {securityInterceptor};
    
    webServiceTemplate.setInterceptors(interceptors);
    
    StreamSource source = new StreamSource(new FileReader("MovieReservationRequest.xml"));
    webServiceTemplate.sendSourceAndReceiveToResult(source, new StreamResult(System.out));

  }
}
```
Vyššie uvedený prázdny *callbackhandler* je obídenie situácie, v ktorej XWSS interceptor požaduje mať definovaného aspoň jeden *callbackhandler*. Vytvoríme teda jeden prázdny.
