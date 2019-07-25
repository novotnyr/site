---
title: Hibernate – receptár tipov a trikov
date: 2008-02-19T09:24:46+01:00
---

# Interceptory
```java
package sk.annun.davano.dao;

import java.util.Collections;
import java.util.Iterator;

import org.apache.log4j.Logger;
import org.hibernate.EmptyInterceptor;
import org.springframework.jdbc.core.JdbcTemplate;

import sk.annun.davano.Post;

public class FulltextSearchUpdateInterceptor extends EmptyInterceptor {
  
  public static final Logger logger = Logger.getLogger(FulltextSearchUpdateInterceptor.class);

  private JdbcTemplate jdbcTemplate;
  
//  @Override
//  public boolean onFlushDirty(Object entity, Serializable id, Object[] currentState, Object[] previousState, String[] propertyNames, Type[] types) {
//    if(entity instanceof Post) {
//      Object[] params = {getText((Post) entity), id};
//      jdbcTemplate.update("UPDATE post_fulltext SET text = ? WHERE id = ?", params);
//    }
//    return false;
//  }

//  @Override
//  public boolean onSave(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
//    if(entity instanceof Post) {
//      Object[] params = {id, getText((Post) entity)};
//      jdbcTemplate.update("INSERT into post_fulltext VALUES(?, ?)", params);  
//    }
//    return false;
//  }
  
//  @Override
//  public void postFlush(Iterator entities) {
//    synchronized(this) {
//      while(entities.hasNext()) {
//        Object entity = entities.next();
//        System.err.println(entity);
//      }
//    }
//  }
  
  protected String getText(Post post) {
    StringBuilder fulltextData = new StringBuilder();
    fulltextData.append(post.getTitle()).append(" ").append(post.getText());
    fulltextData.append(post.getStory().getTitle()).append(" ").append(post.getStory().getDescription());
    return fulltextData.toString();
  }

  public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }
  
  
}
```
## Problémy:
* `onSave()` sa volá pred uložením objektu. V prípade MySQL nemusí mať entita ešte pridelený primárny kľúč
* `onFlushDirty()` počas behu `flush()`
* `postFlush()` po dobehnutí `flush()`. Problém môže byť v tom, že prechádzanie iterátora entít nie je thread-safe a môže vyvolať `ConcurrentModificationException`, čo znemožňuje dosiahnutie cieľa.


## Deklarácia interceptora v Springu

```xml
<bean id="sessionFactory"              
      class="org.springframework.orm.hibernate3.
                 annotation.AnnotationSessionFactoryBean">
  <property name="entityInterceptor">
    <bean class="dao.FulltextSearchUpdateInterceptor">
      <property name="jdbcTemplate" ref="jdbcTemplate" />           
    </bean>
  </property>
</bean>
```
# Udalosti
```java
public class FulltextSearchUpdateListener implements PostInsertEventListener, PostUpdateEventListener {
  private JdbcTemplate jdbcTemplate;
  
  public void onPostInsert(PostInsertEvent event) {
    if(event.getEntity() instanceof Post) {
      Post post = (Post) event.getEntity();
      Object[] params = {post.getId(), getText(post)};
      jdbcTemplate.update("INSERT into post_fulltext VALUES(?, ?)", 
                          params);
    }
  }

  public void onPostUpdate(PostUpdateEvent event) {
    if(event.getEntity() instanceof Post) {
      Post post = (Post) event.getEntity();

      Object[] params = {getText(post), post.getId()};
      jdbcTemplate.update("UPDATE post_fulltext SET text = ? " +
                          "WHERE id = ?", params);
    }
  }
  
  private String getText(Post post) {
    //..
  }

}
```
## Deklarácia v Springu
```xml
<bean id="sessionFactory"              
      class="org.springframework.orm.hibernate3.
                 annotation.AnnotationSessionFactoryBean">
  <property name="eventListeners">
    <map>
      <entry key="post-update" 
             value-ref="hibernateFulltextListener" />
      <entry key="post-insert" 
             value-ref="hibernateFulltextListener" />
  </map>
</property>
</bean>
```
V mape je treba uviesť aj hibernateovské implicitné listenery, alebo oddediť od defaultných listenerov (`MySaveOrUpdateListener extends DefaultSaveOrUpdateListener`). Inak sa môže odstaviť základná funkcionalita (keďže tá je tiež riešená listenermi).
Kľúče do mapy je možné nájsť v DTD súbore `hibernate-configuration`. Platí pravidlo, že pre stringový kľúč treba namapovať listener s daným interfejsom. Napr. `post-update` -> `PostUpdateEventListener`.
