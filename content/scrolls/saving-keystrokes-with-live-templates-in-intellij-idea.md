---
title: "Saving Keystrokes with Live Templates in IntelliJ IDEA"
date: 2019-01-21T12:31:44+01:00
---

Typing Code Over and Over?
==========================

In one of the projects, we had to create many customized enumerations. Something like this:

```
public class Status {
    ONLINE("on"), OFFLINE("off");
}
```

Each of this `enum` was supposed to have a `findByCode` method that would resolve `“on”` to `ONLINE` and `“off”` to offline. Something like this:

```
public enum Status {
    ONLINE("on"), OFFLINE("off");

    private final String code;

    Status(String code) {
        this.code = code;
    }

    public static Status findByCode(String code) throws IllegalArgumentException {
        for (Status value : Status.values()) {
            if (value.code.equals(code)) {
                return value;
            }
        }
        throw new IllegalArgumentException("No Status: '" + code + "'");
    }
}
```

Instead of superboring typing it over and over, let’s create a **Live Template** in the IntelliJ IDEA!

Live Template
-------------

Live templates in the IntelliJ IDEA are easy: they work like a supercharged Tab-completion.

Let’s create a custom one!

All Live Templates are available in the **Preferences > Editor > Live Templates**. 

First, let’s add a **New Template Group** to the table, with the **Java** name, to keep things organized. Then, let’s create a new **Live Template**.

The properties that need to be configured are as follow:

* **Abbreviation:** the shortcode that will be Tab-expanded. Let’s use `enumfind` .
* **Description**: a human readable description of the Live Template

The template is defined by the [Apache Velocity](http://velocity.apache.org/) syntax. Essentially, any Java syntax is allowed, while **variables** are indicated via `$VARIABLENAME$` declaration (with dollars both in prefix and in suffix).

```
public static $ENUM$ findByCode(String $CODE$) throws IllegalArgumentException {
	for ($ENUM$ $ENUM_ELEMENT$ : $ENUM$.values()) {
		if ($ENUM_ELEMENT$.$CODE$.$EQUALS$($CODE$)) {
			return $ENUM_ELEMENT$;
		}
	}
	throw new IllegalArgumentException("No $ENUM$: '" + $CODE$ + "'");
}
```

Variables
---------

The template code uses multiple variables. We can customize the suggestions or the actual values for these variables via **Edit variables button**. In the dialog, we can assign the following semantics:

* `ENUM`: contains the name of the enclosing `enum`. Assign `className()` that encloses a place where the Live Template has been invoked.
* `ENUM_ELEMENT`: name of the variable which contains the iterated enum members. Assign `suggestVariableName()` which will autosuggest a variable name according to the context.
* `EQUALS`: an option to choose the method name that is used for comparison: either `equals` or `equalsIgnoreCase`. Assign `enumCode("code")` to suggest a multiple variable names. We specify just a single suggestion, but the user can freely specify his own variable name. We specify `code`  as the default value.
* `CODE`: the name of the local variable and the name of the instance variable used to compare descriptive codes in the enum. Assign `enum("equals", "equalsIgnoreCase”)` to suggest one of the two method names. Again, the user can freely use any reasonable method, if necessary. We specify `equals` as the default value.

The semantics and available methods are specified in the [JetBrains  Live Template documentation](https://www.jetbrains.com/help/idea/template-variables.html).

Contexts
--------

Next, we need to assign one of the **contexts**, i. e. places where the Live Template is applicable. For the sake of the simplicity, let’s use **Java / Declarations.**

Customizations
--------------

Finally, we can finetune the customizations: let’s setup **Reformat According to Style** to make the expanded method honor the Java code formatting preferences.

Using the Live Template
=======================

Now, let’s use the freshly created Live Template. We can place a cursor on a reasonable place in the `Status` source, type `enumfind` and expand with **TAB**!

```
public class Status {
    ONLINE("on"), OFFLINE("off");

    enumfind<TAB>
}
```

IntelliJ will automagically complete the whole source code.