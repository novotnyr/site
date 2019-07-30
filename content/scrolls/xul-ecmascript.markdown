---
title: XUL – EcmaScript
date: 2005-03-16T18:04:46+01:00
---

EcmaScript je vlastne normovanou verziou jazyka, ktory vznikol z JavaScriptu. Mozilla podporuje [EcmaScript verzie 3](http://www.ecma-international.org/publications/standards/Ecma-262.htm ).

# Objektový model v EcmaScripte (262).

V EcmaScripte neexistuje koncept triedy.

## Tvorba novych instancii
### Explicitne vytvaranie objektov
```javascript
var person = new Object;
person.firstName = "John";
person.secondName = "Doe";
```

### „Inline" ci pristup cez literal 
```javascript
var obj = { foreground:"red", background:"blue" }
```

Vsimnime si syntax:

* datove cleny su uvedene bez `var`
* hodnota sa im priraduje cez dvojbodku (nie cez „rovna sa")

## Prototypy v ulohe tried
Na vytvaranie kvazi-tried sa pouzivaju „prototypy". Protyp specifikuje implicitne hodnoty pre metody a datove cleny novych instancii.

```javascript
// tato funkcia je vlastne konstruktorom triedy Person
function Person() {
  print('Constructing new person...');
}

// Objekt.prototyp je vlastne kvazi-trieda
Person.prototype = {
  firstName: "John",
  secondName: "Doe"
}

// vytvorenie novej instancie
var p = new Person();
// print the default data field values
print(p.firstName);
print(p.secondName);

// set a value for data field
p.firstName = "Michael";
print(p.firstName);

// make a new instance, its data fields have default values specified in prototype
var q = new Person();
print(q.firstName);
print(q.secondName);
```

