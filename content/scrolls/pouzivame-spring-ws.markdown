---
title: Používame Spring Web Services
date: 2009-06-23T00:00:00+01:00
---

```java
package sk.novotnyr.movie;

import java.util.Date;

public class MovieReservation {

  protected String title;
  protected Date date;
  protected int numberOfTickets;

  // gettre a settre
}
```

Stiahneme Spring-WS. Do classpath:

* activation.jar
* commons-logging-1.1.1.jar
* log4j-1.2.15.jar
* saaj-api-1.3.jar
* saaj-impl-1.3.jar
* spring-web.jar
* spring-webmvc.jar
* spring-ws-1.5.2.jar
* spring.jar
* stax-api-1.0.1.jar
* xstream-1.3.jar

Kostra webovej aplikácie:
`web.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://java.sun.com/xml/ns/j2ee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
         version="2.4">

    <servlet>
        <servlet-name>spring-ws</servlet-name>
        <servlet-class>org.springframework.ws.transport.http.MessageDispatcherServlet</servlet-class>
    </servlet>

    <servlet-mapping>
        <servlet-name>spring-ws</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>

</web-app>
```
`spring-ws-servlet.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.0.xsd">
 	<bean id="movieReservationEndpoint" class="sk.novotnyr.movie.ws.XStreamMovieReservationEndpoint" />
 	
	<bean id="endpointMapping" class="org.springframework.ws.server.endpoint.mapping.UriEndpointMapping">
		<property name="mappings">
			<props>
				<prop key="http://localhost:8080/movie/ws/reservation">movieReservationEndpoint</prop>
			</props>
		</property>
	</bean>
    
</beans>
```

# Dokument pre požiadavku
```xml
<?xml version="1.0" encoding="UTF-8"?>

<movieReservationRequest>
  <title>Battlestar Galactica</title>
  <date>2008-12-24</date>
  <numberOfTickets>4</numberOfTickets>  
</movieReservationRequest>
```

# `log4j.properties`
```
log4j.rootCategory=INFO, stdout
log4j.logger.org.springframework.ws=DEBUG
log4j.logger.org.springframework.ws.client.MessageTracing.sent=TRACE
log4j.logger.org.springframework.ws.client.MessageTracing.received=TRACE

log4j.logger.org.springframework.ws.server.MessageTracing=TRACE

log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%p [%c{3}] %m%n
```

# Endpoint
```java
package sk.novotnyr.movie.ws;

import org.springframework.oxm.xstream.XStreamMarshaller;
import org.springframework.ws.server.endpoint.AbstractMarshallingPayloadEndpoint;

import sk.novotnyr.movie.MovieReservation;

import com.thoughtworks.xstream.converters.basic.DateConverter;

public class XStreamMovieReservationEndpoint extends AbstractMarshallingPayloadEndpoint {
  
  @Override
  protected Object invokeInternal(Object object) throws Exception {

    MovieReservation movieReservationRequest = (MovieReservation) object;
    System.out.println(movieReservationRequest.getTitle());
    System.out.println(movieReservationRequest.getDate());
    System.out.println(movieReservationRequest.getNumberOfTickets());

    // one-way messages return null
    return null;
  }

  @Override
  public void afterPropertiesSet() throws Exception {
    super.afterPropertiesSet();

    XStreamMarshaller marshaller = new XStreamMarshaller();
    marshaller.addAlias("movieReservationRequest", MovieReservation.class);
    marshaller.getXStream().registerConverter(new DateConverter("yyyy-DD-mm", new String[]{}));
    
    setMarshaller(marshaller);
    setUnmarshaller(marshaller);

  }
  
}
```

# Klient
```java
package sk.novotnyr.movie.ws;

import java.io.FileReader;

import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.springframework.ws.client.core.WebServiceTemplate;

public class Client {
  
  public static void main(String[] args) throws Exception {
    WebServiceTemplate webServiceTemplate = new WebServiceTemplate();
    webServiceTemplate.setDefaultUri("http://localhost:8080/movie/ws/reservation");
    
   
    StreamSource source = new StreamSource(new FileReader("D:\\Projects\\movie-ws\\web\\WEB-INF\\xml\\movieReservationRequest.xml"));
    StreamResult result = new StreamResult(System.out);
    webServiceTemplate.sendSourceAndReceiveToResult(source, result);        

  }
}
```
