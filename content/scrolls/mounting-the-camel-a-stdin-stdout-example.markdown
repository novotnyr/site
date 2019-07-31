---
title: "Mounting the Camel: A stdin-stdout example"
date: 2012-02-14T15:24:00+01:00
wpid: 248
categories:
- programovanie
tags:
- Camel
- Java
- Maven
---

# Setting up Camel via Maven

## Create a new project

Within shell, move to your Eclipse workspace and create a new project.

```shell
mvn archetype:generate
```

In the interactive mode, use the default archetype (press `Enter`) with latest version (press `Enter`), fill in the group ID (`sk.upjs.ics.novotnyr`), artifact ID (`camel-xmpp-example`) and use the default values for version and package.

A directory `camel-xmpp-example`·is created with a conventional subdirectory structure and a `pom.xml`.

## Upgrade to JDK6

Camel is built upon JDK6. However, Maven uses JDK5 by default and therefore the default target is JDK5. Upgrade your configuration to create JDK6 compatible files.

```xml
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>2.3.2</version>
        <configuration>
            <source>1.6</source>
            <target>1.6</target>
        </configuration>
    </plugin>
</plugins>
```

## Camel dependencies

Add the following Camel dependency into `pom.xml`

```xml
<dependency>
  <groupId>org.apache.camel</groupId>
  <artifactId>camel-core</artifactId>
  <version>2.9.0</version>
</dependency>
```

and compile project.

```bash
mvn compile
```

Maven will download dependencies from Maven Central repository.

# Testing a simple route

For test, we will use a simple stdin-stdout route according to the example code on [the Camel website](http://camel.apache.org/walk-through-an-example.html). We will type into the console, thus generating messages and Camel will route via [Stream Component](http://camel.apache.org/stream.html) and print them to the `System.out`.

## Add a Stream Component dependency

Add a dependendy into your `pom.xml`

    <dependency>
        <groupId>org.apache.camel</groupId>
        <artifactId>camel-stream</artifactId>
        <version>2.9.0</version>
    </dependency>

## Code the client

Instead of `DefaultCamelContext`, we use the utility class `org.apache.camel.main.Main`, which allows us to spawn a Camel context and keep it running, while receiving our messages from stdin,.

    package sk.upjs.ics.novotnyr;
    import org.apache.camel.builder.RouteBuilder;
    import org.apache.camel.main.Main;
    public class CamelTest {
        public static void main(String[] args) throws Exception {
            Main camelMain = new Main();
            camelMain.enableHangupSupport();
            camelMain.addRouteBuilder(new RouteBuilder() {
                @Override
                public void configure() throws Exception {
                    from("stream:in").to("stream:out");
                }
            });
            camelMain.run();
        }
    }

Running the code produces a strange logging error:

    SLF4J: Failed to load class "org.slf4j.impl.StaticLoggerBinder".
    SLF4J: Defaulting to no-operation (NOP) logger implementation
    SLF4J: See http://www.slf4j.org/codes.html#StaticLoggerBinder for further details.

Resolve it by adding a proper SLF4J logging implementation, for example [`logback`](http://logback.qos.ch/).

```xml
<dependency>
    <groupId>ch.qos.logback</groupId>
    <artifactId>logback-classic</artifactId>
    <version>1.0.0</version>
</dependency>
```

Running the example once again launches a context. Now we can submit messages by typing into the console. Camel will log each message delivery.

Typing

    Hello World

will log

    14:20:13.356 [Camel (camel-1) thread #1 - stream://in] DEBUG o.a.camel.processor.SendProcessor - >>>> Endpoint[stream://out] Exchange[Message: Hello World]
    14:20:13.356 [Camel (camel-1) thread #1 - stream://in] DEBUG o.a.c.c.stream.StreamProducer - Writing as text: Hello World to java.io.PrintStream@1ee29820 using encoding: UTF-8
    Hello World
