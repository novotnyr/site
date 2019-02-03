---
title: "Mocking AMQP Integration tests with Apache Qpid"
date: 2019-01-23T19:01:38+01:00
---

AMQP protocol is a useful mechanism to tackle cross-component integration features. When running integration tests, sometimes it’s useful to run integration tests without a full-fledged broker at hand. Especially, when RabbitMQ is an Erlang-based binary expected to run besides a Java-powered application.

Let’s use an alternative solution. [Apache Qpid](https://qpid.apache.org/index.html) is a messaging solution and broker that is implemented in Java. In addition, it supports the following features:

- Supports the AMQP 0.9.1 provided by RabbitMQ,
- It’s embeddable,
- It’s able to run fully in RAM.

Creating Embeddable In Memory QPid
==================================

There are multiple examples that embed an in-memory instance of Qpid. However, most of them are focused on the older 6.x line. More recent Qpid 7.x has changed the API rather dramatically.

The roadmap will be as follows:

1. Add the necessary Maven dependencies,
2. Add the configuration file,
3. Add the *runner* code that will launch an embedded instance of Qpid.

Maven Dependencies
------------------

Apache Qpid consists of multiple modules, that are to be added as `pom.xml` dependencies. All dependencies belong to the `org.apache.qpid` group ID.

* `qpid-broker-core` with the core classes of the broker
* `qpid-broker-plugins-amqp-0-8-protocol` . Despite the misleading name, this module adds support for the ancient AMQP 0.8, but also for AMQP 0.9 and AMQP 0.9.1 that are supported by RabbitMQ.
* `qpid-broker-plugins-memory-store` add support for in-memory message handling.

```
<dependency>
    <groupId>org.apache.qpid</groupId>
    <artifactId>qpid-broker-core</artifactId>
    <version>7.1.0</version>
</dependency>
<dependency>
    <groupId>org.apache.qpid</groupId>
    <artifactId>qpid-broker-plugins-amqp-0-8-protocol</artifactId>
    <version>7.1.0</version>
</dependency>
<dependency>
    <groupId>org.apache.qpid</groupId>
    <artifactId>qpid-broker-plugins-memory-store</artifactId>
    <version>7.1.0</version>
</dependency>
```

Broker Configuration
--------------------

Qpid is configured from a JSON file. This file provides a configuration for three basic components:

* **authentication providers** indicating a security mechanism for client authentication.
* **virtual hosts**, indicating independent and isolated environments for exchanges, queues and bindings.
* **ports** denoting network specific configuration, such as TCP/IP port, supported protocols. Each port is associated with a specific set of virtual hosts. Additionally, a port indicates an authentication provider that will be used.

Let’s create a configuration file, such as `qpid-embedded-inmemory-configuration.json` and let’s put it into `CLASSPATH` root.

Aside from the descriptive `name` and the Qpid Model Version, there are three blocks that we have just described: authentication providers, ports and virtual host nodes.

```json
{
  "name": "Embedded Broker",
  "modelVersion": "7.0",
  "authenticationproviders": [
    {
      "name": "hardcoded",
      "type": "Plain",
      "secureOnlyMechanisms": [],
      "users": [
        {
          "name": "guest",
          "password": "guest",
          "type": "managed"
        }
      ]
    }
  ],
  "ports": [
    {
      "name": "AMQP",
      "port": "${qpid.amqp_port}",
      "bindingAddress": "127.0.0.1",
      "protocols": [
        "AMQP_0_9_1"
      ],
      "authenticationProvider": "hardcoded",
      "virtualhostaliases": [
        {
          "name": "defaultAlias",
          "type": "defaultAlias"
        }
      ]
    }
  ],
  "virtualhostnodes": [
    {
      "name": "default",
      "type": "Memory",
      "defaultVirtualHostNode": "true",
      "virtualHostInitialConfiguration": "{\"type\": \"Memory\"}"
    }
  ]
}
```

Let’s dissect this rather large configuration.

### Authentication Provider

We declare a `Plain` authentication provider, while specifying hardcoded `users`. This provider will be identified by a logical name `hardcoded` (we can pick any name we want).

We will provide just a single user, with dedicated name (`guest`) and a plaintext password (`guest`).

Finally, we declare an empty set of `secureOnlyMechanisms`, essentially disabling any advanced security mechanism, such as SASL.

### Port

We declare a single port, running on a default port number provided by Qpid. We will assign an explicit **binding address**, thus limiting the broker to listen on the localhost only.

Then, let’s enumerate a list of supported protocols. Since we need to emulate the RabbitMQ, we declare just the AMQP 0.9.1 protocol.

As seen above, we need to associate a port with an authentication provider. By providing a `authenticationProvider`, we will provide a reference to our `hardcoded` plain provider.

Finally, we need to declare mapping between virtual hosts provided in the connection string to the virtual host that will be used. By declaring a *virtual host alias* of type `defaultAlias`, the empty virtual host of the connection string the will be mapped to the default virtual host of the broker.

### Virtual Host

Let’s configure a single Virtual Host. We’ll add a **name**, declare the type as `Memory`, and we will treat it as a **default virtual host** (`defaultVirtualHostNode`).  Finally, let’s add an **initial configuration**, by embedding a JSON into String (doh!) with in-memory specification for this virtualhost.

Creating an Embedded Broker Runner
----------------------------------

Let’s code the Qpid Wrapper or Runner that will allow easy-starting of the Broker.

```java
public class EmbeddedInMemoryQpidBroker {
    public static final Logger logger = getLogger(EmbeddedInMemoryQpidBroker.class);

    private static final String DEFAULT_INITIAL_CONFIGURATION_LOCATION = "qpid-embedded-inmemory-configuration.json";

    private SystemLauncher systemLauncher;

    public EmbeddedInMemoryQpidBroker() {
        this.systemLauncher = new SystemLauncher();
    }

    public void start() throws Exception {
        this.systemLauncher.startup(createSystemConfig());
    }

    public void shutdown() {
        this.systemLauncher.shutdown();
    }

    private Map<String, Object> createSystemConfig() throws IllegalConfigurationException {
        Map<String, Object> attributes = new HashMap<>();
        URL initialConfigUrl = EmbeddedInMemoryQpidBroker.class.getClassLoader().getResource(DEFAULT_INITIAL_CONFIGURATION_LOCATION);
        }
        if (initialConfigUrl == null) {
            throw new IllegalConfigurationException("Configuration location '" + DEFAULT_INITIAL_CONFIGURATION_LOCATION + "' not found");
        }
        attributes.put(SystemConfig.TYPE, "Memory");
        attributes.put(SystemConfig.INITIAL_CONFIGURATION_LOCATION, initialConfigUrl.toExternalForm());
        attributes.put(SystemConfig.STARTUP_LOGGED_TO_SYSTEM_OUT, true);
        return attributes;
    }
}
```

Essentially, we provide two methods: `start` and `shutdown`. The former method will initialize Qpid `SystemLauncher`, provide the system configuration as a `HashMap` and launch it.

In the configuration map, we provide the following configuration options:

* **type**, indicating an in-memory `Memory` broker
* **initial configuration location**, providing an URL of the JSON config file. We will resolve this URL from the `CLASSPATH` resource.
* **startup logged to stdout**, improving logging messages on startup.

For the future reference, the full and enhanced code for this class is available in the [Git Repository](https://github.com/novotnyr/qpid-embedded-junit4-rule/blob/master/src/main/java/com/github/novotnyr/qpid/junit4/EmbeddedInMemoryQpidBroker.java).

Embedded Broker in a JUnit 4 Rule
=================================

Creating a JUnit 4 Rule
-----------------------

To make our lives easier in the integration tests, let’s create a JUnit 4 Rule that will manage a broker lifecycle. Thus, we can start a broker when a unit test launches, and shutdown the same broker when the unit tests terminates.

```java
import org.junit.rules.ExternalResource;

public class EmbeddedInMemoryQpidBrokerRule extends ExternalResource {
    private EmbeddedInMemoryQpidBroker broker;

    @Override
    protected void before() throws Throwable {
        this.broker = new EmbeddedInMemoryQpidBroker();
        this.broker.start();
    }

    @Override
    protected void after() {
        this.broker.shutdown();
    }
}

```

Using a Rule In the Integration Tests
-------------------------------------

Now, we can easily add this rule as a `ClassRule`. This will allow us to launch a broker in the `@BeforeClass` manner and terminate it in the `@AfterClass` style.

```
public class Test {
    @ClassRule
    public static EmbeddedInMemoryQpidBrokerRule qpidBrokerRule = new EmbeddedInMemoryQpidBrokerRule();

    ...
}
```

Resources
=========

* [GitHub repository with the implementation](https://github.com/novotnyr/qpid-embedded-junit4-rule). The full implementation of the concept in the `novotnyr/qpid-embedded-junit4-rule` repository.
* [Gist](https://gist.github.com/AlejandroRivera/34235c35bb62ab572932b373444420a0) by AlejandroRivera with an alternative implementation.
* [How To Embed Qpid Broker](https://cwiki.apache.org/confluence/display/qpid/How+to+embed+Qpid+Broker-J) from the Qpid Wiki
* [RabbitMQ and Qpid Interoperability](https://www.rabbitmq.com/interoperability.html) on the RabbitMQ Website
* [Virtual Host Configuration](http://qpid.2158936.n2.nabble.com/unknown-virtual-host-td7637861.html) from the Mailing List
* [Security Provider Configuration](https://qpid.apache.org/releases/qpid-java-6.0.2/java-broker/book/Java-Broker-Security.html#Java-Broker-Security-Authentication-Providers) from the Qpid Documentation