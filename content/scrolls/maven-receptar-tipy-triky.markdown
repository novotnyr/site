---
title: Maven – receptár, tipy a triky
date: 2006-01-09T00:00:00+01:00
---

# Generovanie projektovych stranok pomocou Mavenu 1

* Nastavime 
```
maven.docs.outputencoding=utf-8
```
v `project.properties`. Inak sa dockame dokumentacie v iso-8859-1, pripadne otaznikov vo vygenerovanych dokumentoch
* Stiahneme plugin `sdocbook`
```
maven plugin:download -DgroupId=maven-plugins -DartifactId=maven-sdocbook-plugin -Dversion=1.4.1
```
* Do `maven.xml` v projektovom adresari pridame / vytvorime
```xml
<project xmlns:j="jelly:core" xmlns:ant="jelly:ant" xmlns:util="jelly:util" xmlns:maven="jelly:maven">
    <goal name="docbook2xdoc">
        <maven:get var="maven.sdocbook.generated.html"
            plugin="maven-sdocbook-plugin"
            property="maven.sdocbook.generated.html"/>
        <mkdir dir="${maven.gen.docs}/docbook2xdoc"/>

        <j:set var="maven.html2xdoc.dir.bak" value="${maven.html2xdoc.dir}"/>
        <j:set var="maven.gen.docs.bak" value="${maven.gen.docs}"/>

        <j:set var="maven.html2xdoc.dir" value="${maven.sdocbook.generated.html}"/>
        <j:set var="maven.gen.docs" value="${maven.gen.docs}"/>
        <attainGoal name="html2xdoc:transform"/>

        <j:set var="maven.html2xdoc.dir" value="${maven.html2xdoc.dir.bak}"/>
        <j:set var="maven.gen.docs" value="${maven.gen.docs.bak}"/>
    </goal>
</project>    
```
* Generujeme taskom 
```
maven clean sdocbook:generate-html docbook2xdoc xdoc`
```

# Kopírovanie konfigurákov v prípade viacerých profilov
```xml
<profiles>
  <profile>
    <id>production</id>
    <build>
      <plugins>
        <plugin>
          <artifactId>maven-antrun-plugin</artifactId>
          <executions>
            <execution>
              <phase>test</phase>
              <goals>
                <goal>run</goal>
              </goals>
              <configuration>
                <tasks>
                  <delete
                    file="${project.build.outputDirectory}/database.properties" />
                  <copy file="src/main/resources/database.production.properties"
                    tofile="${project.build.outputDirectory}/database.properties" />
                </tasks>
              </configuration>
            </execution>
          </executions>
        </plugin>
      </plugins>
    </build>
  </profile>
</profiles>
```

Release potom cez
```
mvn clean package -Pproduction -Dmaven.test.skip=true
```
