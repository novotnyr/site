---
title: Letná škola sieťovania 2012
date: 2012-07-04T12:56:00+01:00
---

Júl 2012, Danišovce, pre UINF PF UPJŠ

Prípravné práce
===============

### Maven proxy settings

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

<proxies>
   <proxy>
      <active>true</active>
      <protocol>http</protocol>
      <host>localhost</host>
      <port>8787</port>
    </proxy>
  </proxies> 
</settings>
```

### Konfigurácia Jetty
```xml
<build>
	<plugins>
		<plugin>
			<groupId>org.mortbay.jetty</groupId>
			<artifactId>jetty-maven-plugin</artifactId>
			<version>8.1.4.v20120524</version>
		</plugin>
	</plugins>
</build>
```

### Závislosť pre servlety

```xml
<dependency>
	<groupId>javax.servlet</groupId>
	<artifactId>javax.servlet-api</artifactId>
	<version>3.0.1</version>
	<scope>provided</scope>
</dependency>
```

### WAR
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-war-plugin</artifactId>
    <version>2.2</version>
    <configuration>
      <failOnMissingWebXml>false</failOnMissingWebXml>
    </configuration>
</plugin>
```
## Ukážkové JSP
```xml
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```


