---
title: "Enforcing Spring Cloud Contracts Over AMQP"
date: 2019-01-18T09:09:39+01:00
---

Why Spring Cloud and CDC?
=========================

The **Spring Cloud Contract** enforces Consumer Driven Contracts (CDC) in the services. While there are various examples of the HTTP integration, let’s focus on another scenario — enforcing contracts on messages in the AMQP protocol.

We will create a simple example where a **producer** will send a **user presence** message to a **consumer**. This message will be in the JSON format, send via pre-aggreed exchange. 

The roadmap is as follows:

1. **Create a contract.** It will be owned by the producer-side.
2. **Create a consumer-side implementation** of an AMQP queue that will adhere to the contract.
3. **Create consumer-side integration tests** to make sure that client adheres to the contract.
4. Create **Producer implementation** to send AMQP messages that follow contract requirements.
5. Prepare and **autogenerate producer-side integration tests** to make sure that the producer agrees with the contract as well.

All of these steps are completely independent from the actual RabbitMQ broker. In other words, we can establish, enforce and test the contract without a running instance of the RabbitMQ!

### Source Code

The final source code is available on GitHub, in the [`novotnyr/spring-cloud-contract-amqp-demo`](https://github.com/novotnyr/spring-cloud-contract-amqp-demo) repository.

Setting Up the Producer Project
===============================

As a first step, let’s create a **producer** project, corresponding to a message sending service. This project will send a simple message: it will indicate an availability of a user in some kind of chat service.

This project will be Maven-based, with the following properties:

* inherit from `spring-boot-starter-parent` of the 2.x Spring Boot line
* use the following dependencies:
  * `spring-boot-starter-amqp`: to send AMQP messages
  * `spring-boot-starter-json`: to serialize AMQP messages to JSON
  * `spring-boot-starter-test` (in *test* scope) to enable testing facilities in Spring

Most importantly, we need to depend on the Spring Cloud Contract libraries. We will import the libraries via `dependencyManagement`:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
        <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Finchley.SR2</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

 Then, let’s add additional `<dependency>` :

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-contract-verifier</artifactId>
    <scope>test</scope>
</dependency>
```

In addition, this will allow us to add the most important component: Maven plugin that will handle contract management, publishing and upload.

```
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>2.0.2.RELEASE</version>
    <extensions>true</extensions>
</plugin>
```

The final `pom.xml` that can be used as a reference is available in [Github `producer` project](https://github.com/novotnyr/spring-cloud-contract-amqp-demo/tree/master/producer).

Creating a Contract
===================

The actual contract in the *Spring Cloud Contract* can be written either in Groovy DSL or in YAML. Let’s use YAML now. 

The contract file `user-presence.yaml` should be put into `src/test/resources/contracts`, where it would be automatically picked up by Maven plugin.

```yaml
label: user-goes-online
input:
  triggeredBy: onUserIsOnline()
outputMessage:
  sentTo: user-presence
  body:
    user: amadeus
  headers:
    contentType: application/json
```

We declare a contract where the message will be triggered by a method call. 

To be specific, on a `onUserIsOnline()` method call, an AQMP message will be sent to the `user-presence` exchange. The body will be in the JSON format `{ “user” : “amadeus” }` and the message will contain a necessary JSON content-type header.

Additionally, we need to put a label to this contract statement, so we can reference that particular contract stanza in the integration tests.

Publishing a Contract
---------------------

Now that the contract has been completed, we can publish that to the local Maven repository:

```
mvn install -DskipTests
```

This command will build, package and deploy the contract files to the local Maven repository. These files will be published in an artifact with the dedicated Maven classifier —  `stubs` — in order not to interfere with the main module artifact.

We will intentionally skip tests, as there are no reasonable tests to execute. However, we will fix that later.

Setting Up the Consumer Project
===============================

Initializing Consumer Project
-----------------------------

Time to move on to the opposite side of the contract, which will consume AMQP messages. Since we have our contract ready, we will prepare a consumer-side project. 

Let’s create another Maven-based project, with the following setup:

* inherit from `spring-boot-starter-parent` of the 2.0 Spring Boot line

* import *Spring Cloud Contract* dependencies via `dependencyManagement` in the same vein as in the *Producer* project.

  ```xml
  <dependencyManagement>
      <dependencies>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-dependencies</artifactId>
              <version>Finchley.SR2</version>
              <type>pom</type>
              <scope>import</scope>
          </dependency>
      </dependencies>
  </dependencyManagement>
  ```

  

* use the following dependencies:

  * `spring-boot-starter-amqp`: to send AMQP messages
  * `spring-boot-starter-json`: to serialize AMQP messages to JSON
  * `spring-boot-starter-test` (in *test* scope) to enable testing facilities in Spring
  * `org.springframework.cloud:spring-cloud-starter-contract-stub-runner` (in *test* scope) to handle remote contracts

  In this *Consumer* project we can omit the `spring-cloud-contract-maven-plugin` , as we will not need to upload contracts to the remote repo.

  The final stage of the `pom.xml` in the [Consumer](https://github.com/novotnyr/spring-cloud-contract-amqp-demo/blob/master/consumer/pom.xml) project is available on Github.

Preparing Consumer Codebase
---------------------------

Now, let’s create a proper consumer project infrastructure. In other words, let’s create a proper *Spring AMQP*-based project that will handle AMQP messages as if they were sent by RabbitMQ broker. 

This is a process that is completely independent from the Spring Cloud Contract classes!

### Message Class

The inbound message will be mapped to a proper domain object:

```java
  public class UserGoesOnlineMessage {
      private String user;
  	/* ..getters and setters */
  }
```

### Message Listener

Inbound AMQP message will be handled by a usual `@RabbitListener`-annotated method in a `@Component`:

```
  @Component
  public class UserPresenceListener {
      private List<String> availableUsers = new ArrayList<>();
  
      @RabbitListener(queues = "user-presence")
      public void handle(UserGoesOnlineMessage userGoesOnlineMessage) {
          this.availableUsers.add(userGoesOnlineMessage.getUser());
      }
  
      public List<String> getAvailableUsers() {
          return availableUsers;
      }
  }
```

Obviously, this is a very stupid mechanism: the listener will just take any incoming available user and it will put it into the “log”, or list of available users. This is just to have something testable.

### Main Class

Now it’s time to code the main application class. 

* We will create a usual **main** method to launch our application.
* We will declare a `Jackson2JsonMessageConverter` to handle message conversion from JSON to domain object.
* And finally, we will configure AMQP infrastructure: 
  * Create an **exchange** `user-presence` (used by the Producer to send messages.)
  * Create a message **queue** `user-presence` to receive AMQP messages. This is the queue that is referenced in the `UserPresenceListener`, namely in the `@RabbitListener` annotation.
  * Create a **binding** between declared exchange and the queue. The binding is very important, as it is used by *Spring Cloud Contract Stub Runner* to discover message routes used in the integration tests.

```java
@SpringBootApplication
public class ConsumerApplication {
    @Bean
    public Binding binding() {
        return BindingBuilder
                .bind(userPresenceQueue())
                .to(userPresenceExchange())
                .with("#");
    }

    private DirectExchange userPresenceExchange() {
        return new DirectExchange("user-presence");
    }

    @Bean
    Queue userPresenceQueue() {
        return new Queue("user-presence");
    }

    @Bean
    public MessageConverter jackson2JsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }

}
```

Obviously, we might be tempted to run this application. This is okay, however, this won’t help us in the verification of the contract that we created.

Let’s create a proper integration test instead!

Consumer-Side Integration Tests
===============================

In this stage we are ready to create the integration tests. But wait, there is no running RabbitMQ to integrate! That is not a problem, since we *do* have the contract that describes all messages that our consumer should receive. 

The **Stub Runner** will mimic the RabbitMQ broker message flow in memory, being guided by the Contract.

To prepare the integration tests, we will need two things:

* configuration of the Stub Runner
* the actual integration test

Configuring the Stub Runner
---------------------------

Let’s configure the Stub Runner in the traditional Spring-Boot way: let’s create an `application.properties` file. Since this file is test-specific, it should go to `src/test/resources`.

In this file, we will explicitly enable the Stub Runner for AMQP protocol. To be on the safe side, we will disable the *Cloud Stream Stub Runner*, which might be enabled by default for Stream-Based AMQP integration.

```
stubrunner.amqp.enabled=true
stubrunner.stream.enabled=false
```

Creating the Consumer-Side Integration Test
-------------------------------------------

The integration test is basically a standard cookie-cutter Spring-Boot integration test, with additional features.

```
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE)
@AutoConfigureStubRunner(ids = {"com.github.novotnyr:spring-cloud-contract-server:+"}, stubsMode = StubRunnerProperties.StubsMode.LOCAL)
public class ListenerTest {
    @Autowired
    StubTrigger stubTrigger;

    @Autowired
    UserPresenceListener userPresenceListener;

    @Test
    public void shouldReceiveNotification() {
        stubTrigger.trigger("user-goes-online");

        assertTrue(this.userPresenceListener.getAvailableUsers().size() > 0);
    }
}
```

Mainly, we will use the `@AutoConfigureStubRunner` to declare the location of contract files. We are using:

* `ids` that indicate Ivy/Gradle-like coordinates of the published artifact that holds the contract files. In our cases, we indicate the most recent version with the `+` character.
* `stubsMode` denotes the location of the artifacts, specifically being available in our local Maven repository.

Now, we need to emulate the following scenario: a message will be sent to the RabbitMQ broker, then routed to a queue, and finally processed by the Consumer. We can autowire an `StubTrigger` that is able to emulate other-party message interactions.

Via `trigger` method we launch the required contract scenario. We will refer to the particular part of the scenario via `label` that was specified way back in the YAML.

Within this integration test, the *StubRunner* will find the proper AMQP binding, configure in-memory RabbitMQ mock and create the necessary RabbitMQ client infrastructure behind the scenes. Shortly, this will allow the `UserPresenceListener` to handle AMQP messages as if they were routed by the proper RabbitMQ broker.

To test the listener, we just `trigger` the message, and make sure that the number of the available users is not empty, thus indicating a delivered message.

Server-Side Implementation and Tests
====================================

Having completed consumer-side tests, we can return to the producer side. Let’s code two remaining features:

1. Implement a proper server-side code which dispatches messages to AMQP exchanges and queues.
2. Create integration tests that verify the contract on the producer side.

Producer-Side Implementation
----------------------------

Let’s create a minimalistic all-in-one class that handles both Spring Boot configuration and message dispatch:

```java
@SpringBootApplication
public class Application {
    @Autowired
    AmqpTemplate amqpTemplate;

    public void sendNotification() {
        amqpTemplate.convertAndSend("user-presence", "" , new Notification("amadeus"));
    }

    @Bean
    public MessageConverter jackson2JsonMessageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

We configure a `MessageConverter` that will automatically convert payloads to JSON format. 

Then, we create a `sendNotification()` method that will send an AMQP message via autowired `AmqpTemplate`. This message is represented by a simple domain object:

```java
package com.github.novotnyr.contract;

public class Notification {
    private String user;
    /* ... */
}
```

Finally, since this is a standalone Spring Boot app, we provide a `main` method.

Producer-Side Integration Tests
-------------------------------

Having completed consumer-side tests, we can return to the producer side and implement contract-based integration tests as well. We should make sure that producer-side is honoring the established contract in the same way as the consumer does.

The plan for this part is as follows:

* Configure the *Cloud Contract Maven Plugin* with autogenerated integration tests.
* Implement a base class for contract-based tests.
* Configure mock RabbitMQ *Stub Runner* for the server side.

Configuring Maven Plugin
------------------------

We will do that via integration tests, but these tests will be partially autogenerated by the Maven plugin. To achieve this, we will need to adjust the plugin configuration. We need to introduce the `configuration` section where we state the base parent class for contract-based tests.

### Adding base classes `pom.xml`

```
<plugin>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-contract-maven-plugin</artifactId>
    <version>${spring-cloud-contract.version}</version>
    <extensions>true</extensions>
    <configuration>
        <baseClassForTests>com.github.novotnyr.contract.TestBase</baseClassForTests>
    </configuration>
</plugin>
```

### Configuring StubRunner

Additionally, we need to configure the *StubRunner*. Specifically, we need to enable AMQP-based StubRunner for integration tests. Let’s create `src/test/resources/application.properties` with the following content:

```properties
stubrunner.amqp.enabled=true
```

Configuring Base Test Class
---------------------------

We will now declare the base class `TestBase` that we specified in the `pom.xml`. This is an *abstract* class which covers:

* an annotation `@AutoConfigureMessageVerifier` denoting a base class for integration tests
* the usual `@RunWith` and `@SpringBootTest` annotations indicating a usual Spring Boot-based test class
* an implementation of the method that is triggering the message. Since the contract specifies `triggeredBy: onUserIsOnline()`, we need to provide the implementation of this method. We will use the `Application` instance and its `sendNotification` method to dispatch a message to the AMQP exchange. 

```
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMessageVerifier
public abstract class TestBase {
    @Autowired Application application;

    protected void onUserIsOnline() {
        application.sendNotification();
    }
}
```

Now that we have prepared the base class `TestBase`, we can launch Maven `install` goal. Since our integration tests are ready, we can install the producer artifact properly, without disabled unit tests!

```
mvn install
```

*Spring Cloud Contract Maven Plugin* will autogenerate integration tests according to the Contract. These tests will be compiled and ran along the other unit tests.

The following code shows an autogenerated test class:

```
public class ContractVerifierTest extends TestBase {

	@Inject ContractVerifierMessaging contractVerifierMessaging;
	@Inject ContractVerifierObjectMapper contractVerifierObjectMapper;

	@Test
	public void validate_user_presence() throws Exception {
		// when:
			onUserIsOnline();

		// then:
			ContractVerifierMessage response = contractVerifierMessaging.receive("user-presence");
			assertThat(response).isNotNull();
			assertThat(response.getHeader("contentType")).isNotNull();
			assertThat(response.getHeader("contentType").toString()).isEqualTo("application/json");
		// and:
			DocumentContext parsedJson = JsonPath.parse(contractVerifierObjectMapper.writeValueAsString(response.getPayload()));
			assertThatJson(parsedJson).field("['user']").isEqualTo("amadeus");
	}

}
```

The Contract Maven plugin has created a `validate_user_presence` method. First, the `onUserOnline()` method is called to trigger the AMQP message. Since the plugin does not now, how the implementation of this method should look like, he have to provide it in the `TestBase` class.

Then, the RabbitMQ message processing is done via *Spring Cloud Contract* `ContractVerifierMessaging` object that is able to emulate message reception.

Finally, the assertions are acquired via static methods of `SpringCloudContractAssertions` class, in the same spirit as the assertions on the traditional JUnit classes.

Launching Integration Tests
---------------------------

When we `mvn install` the producer-side project, all integration tests will be generated and launched. 

As we have seen in the Consumer-side project, we have configured AMQP StubRunner. Behind the scenes, this stub runner will essentially mock the RabbitMQ broker and verify that the proper messages, with the proper JSON structure, are sent.

Summary
=======

Now we have successfully covered both sides of the queue:

* **producer** that owns the contract and autogenerates integration tests.
* **consumer** that downloads the contract from the Maven repo.

Both sides rely on the **StubRunner**, implemented as an essential **RabbitMQ** mock that will verify that the contract is properly honored!

Sources
=======

* [Spring Cloud Contract Verifier Messaging Documentation](https://cloud.spring.io/spring-cloud-contract/multi/multi__spring_cloud_contract_verifier_messaging.html) in the **Spring Cloud Contract** project documentation
* [Spring Cloud Contract Samples](https://github.com/spring-cloud-samples/spring-cloud-contract-samples), especially `producer` and `consumer` project
* Additional [Stub Runner Documentation](https://github.com/spring-cloud/spring-cloud-contract/tree/master/tests/spring-cloud-contract-stub-runner-amqp) in the Spring Cloud Contract project sources.

