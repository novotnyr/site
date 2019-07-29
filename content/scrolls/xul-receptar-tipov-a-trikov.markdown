---
title: XUL – receptár tipov a trikov
date: 2009-02-08T19:54:37+01:00
---

Ako pridať riadky do stromu?
============================
```xml
<tree id="treeXPaths" flex="1" rows="20" hidecolumnpicker="true">

  <treecols>
    <treecol id="site" label="Site" flex="1"/>
    <treecol id="xpath" label="XPath" flex="2"/>
  </treecols>

  <treechildren />

</tree>
```
Kód

```javascript
var treeXPaths = document.getElementById("treeXPaths");
// extract <treechildren>
var treechildren = treeXPaths.getElementsByTagName("treechildren").item(0);
// hierarchy is: treechildren /  treeitem / treerow / treecell    

var treeitem = document.createElement("treeitem");
treechildren.appendChild(treeitem);

var treerow = document.createElement("treerow");
treeitem.appendChild(treerow);

var treecellUrl = document.createElement("treecell");
treecellUrl.setAttribute("label", url);
treerow.appendChild(treecellUrl);

var treecellXPath = document.createElement("treecell");
treecellXPath.setAttribute("label", xPath);
treerow.appendChild(treecellXPath);
```