---
title: Reactome WebService a SOAP API
date: 2008-07-05T00:00:00+01:00
---

Reactome WS API dava k dispozicii [XSD schemu prenasanych dat](http://www.reactome.org:8080/caBIOWebApp/services/caBIOService?wsdl | WSDL subor]], ktory sa odkazuje na [[http://www.reactome.org:8080/caBIOWebApp/docs/caBIOExtensionsXMLSchema.xsd ).

Problem s publikovanym WSDL je v pouzivanom bindingu. WSDL vzniklo zjavne automatickym generovanim z Java tried publikovanych v stacku Axis1. Tento stack je vsak prastary a jediny styl sprav, ktory podporuje, je RPC/encoded.

Kamenom urazu je to, ze ziadny z modernych frameworkov uz nepodporuje tento binding a ak podporuje (prikladom je Metro), tak len velmi limitovane.

Dalsim problemom tohto WSDL je divne definovana schema - komplexne typy su prapodivne a CXF aj Metro na nich zlyhaju.

Tretou nevyhodou je zapnutie sendMultiRefs v Axis2, ktora posiela spravy v kvazi „efektivnom tvare" - data, ktore sa opakuju, su posielane len raz a namiesto nich je v SOAP sprave len odkaz na prislusny jedinecny element (atribut `href`). Tento mechanizmus je umozneny v pripade stylu rpc/encoded. Problem je, ze ziadny z frameworkov (okrem Axis1) nepodporuje odkazy na elementy. 

Jedinym riesenim, ako spracovavat odpovede na Reactome WS, je pouzit stary Axis1 a vygenerovat z neho klienta automaticky.

* stiahneme si Axis1 (vo verzii 1.4 z aprila 2006)
* pridame si kniznice do CLASSPATH
* klienta vygenerujeme nasledovnym BATkom:
```
java -cp axis.jar;axis-ant.jar;commons-discovery-0.2.jar;commons-logging-1.0.4.jar;jaxrpc.jar;log4j-1.2.8.jar;saaj.jar;wsdl4j-1.5.1.jar org.apache.axis.wsdl.WSDL2Java http://www.reactome.org:8080/caBIOWebApp/services/caBIOService?wsdl
```
Vysledkom bude velky pocet `.java` suborov, ktore tvoria zdrojaky klienta. Tu sa vsak prejavi dalsia nekompatibilita WSDL suboru. Vacsina tried dedi od `Object[]` (ano, od pola objektov), co je zjavna hlupost. V [dokumentacii](http://www.reactome.org:8080/caBIOWebApp/docs/caBIG_Reactome_User_Guide.pdf ) k Reactome WS sa odporuca urobit hromadny search-and-replace, kde sa pole objektov nahradi `ArrayList`om. Inak povedane, treba urobit replace `extends java.lang.Object[]` na `extends java.util.ArrayList`. Pouzitie klienta je potom priamociare:
```
public class Reactome {
	public static void main(String[] args) throws Exception {
		CaBioDomainWSEndPointServiceLocator locator = new CaBioDomainWSEndPointServiceLocator();
		CaBioDomainWSEndPoint service = locator.getcaBIOService();
		Reaction reaction = (Reaction) service.queryById(114263L);
		System.out.println(reaction.getName());
	}
}
```
