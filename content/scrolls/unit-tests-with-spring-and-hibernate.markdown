---
title: Unit Tests with Spring and Hibernate
date: 2008-04-22T00:00:00+01:00
---

```xml
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:aop="http://www.springframework.org/schema/aop"
  xmlns:tx="http://www.springframework.org/schema/tx"
  xmlns:context="http://www.springframework.org/schema/context"
  xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans-2.0.xsd
                           http://www.springframework.org/schema/aop
                           http://www.springframework.org/schema/aop/spring-aop-2.0.xsd
                           http://www.springframework.org/schema/tx
                           http://www.springframework.org/schema/tx/spring-tx-2.0.xsd
                           http://www.springframework.org/schema/context
                           http://www.springframework.org/schema/context/spring-context-2.5.xsd">

  <bean name="dataSource"
    class="com.mysql.jdbc.jdbc2.optional.MysqlDataSource">
    <property name="user" value="js" />
    <property name="password" value="js" />
    <property name="serverName" value="158.197.31.35" />
    <property name="databaseName" value="js" />
    <property name="port" value="80" />
  </bean>

  <bean id="transactionManager"
    class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource" ref="dataSource" />
  </bean>

  <tx:annotation-driven transaction-manager="transactionManager" />

  <context:component-scan base-package="sk.upjs.js" />

  <bean id="hibernateTemplate"
    class="org.springframework.orm.hibernate3.HibernateTemplate">
    <property name="sessionFactory" ref="sessionFactory" />
  </bean>

  <bean id="sessionFactory"
    class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean">
    <property name="dataSource" ref="dataSource" />

    <property name="annotatedClasses">
      <list>
        <value>sk.upjs.js.Student</value>
        <value>sk.upjs.js.Predmet</value>
      </list>
    </property>

    <property name="hibernateProperties">
      <props>
        <prop key="hibernate.dialect">
          org.hibernate.dialect.MySQLDialect
        </prop>
        <prop key="hibernate.hibernate.format_sql">true</prop>
        <prop key="hibernate.hibernate.show_sql">true</prop>
        <prop key="hibernate.hbm2ddl.auto">update</prop>
      </props>
    </property>
  </bean>

</beans>
```
```java
package sk.upjs.js;

import java.util.List;

import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.orm.hibernate3.HibernateTemplate;
import org.springframework.test.annotation.AbstractAnnotationAwareTransactionalTests;

public class JUnitTest extends AbstractAnnotationAwareTransactionalTests {
  private HibernateTemplate hibernateTemplate;
  
  public JUnitTest() {
    super();
    applicationContext = new ClassPathXmlApplicationContext("applicationContext.xml");
    this.hibernateTemplate = (HibernateTemplate) applicationContext.getBean("hibernateTemplate");
  }
  
  public void testStudentiPredmetu() {
    Predmet p = (Predmet) hibernateTemplate.get(Predmet.class, 8);
    
    System.out.println(p.getNazov());
    for (Student s : p.getStudenti()) {
      System.out.println(s);
    }   
  }
  
  public void testDatabase() {
    Database db = (Database) applicationContext.getBean("database");
    List<Student> studenti = db.listStudents();
    for (Student student : studenti) {
      System.out.println(student);
      System.out.println(student.getPredmety().size());
    }
  }
}
```

