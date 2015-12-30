# apex-xpath
A utility class for Salesforce Apex that lets you easily query an XML DOM structure using a simple subset of XPath syntax.

## To Use
1. Create a new XPath object from an XML string, or if you've already created a Dom.Document then pass that to the constructor.

1. Call find, findFirst, getText, or getTextList, passing it an XPath expression and optionally a node from the DOM to start the search. (The default is to start the search at the root element).

## XPath Syntax Supported
Apex-xpath supports a simple subset of XPath 1.0 "abbreviated" syntax.

An xpath consists of one or more location steps. Each location step starts with a "/" (except the initial step, if it's a relative path), a "node test", and an optional "predicate":

A **node test** is the part that specifies which tagnames to look for at a given point in the path:
* `/tagname`            The most common test is a plain tagname.
* `/*`	                A tagname can be "*", meaning any immediate child.
* `/namespace:tagname`	You can include a namespace in the node test.
* `/tagname/tagname`    Paths can be up to 50 levels deep. (Limitation of Dom.Document class)
* `./child/grandchild`	A tagname of "." refers to the current element.
* `../sibling/nephew`, `../../aunt/cousin`   A tagname of ".." refers to the current element's parent. Useful for getting siblings, cousins, etc.

A **predicate** is a filter expression inside "[ ]":
* `/tagname[1]`            Filter the results of the node test by "nth-result" (using 1-relative index)
* `/tagname[@id]`          Filter by "has this attribute"
* `/tagname[@id=12345]`    Filter by "attribute x = value"
* `/tagname[@id="12345"]`  Filter by "attribute x = value"

## Example
    String xml = some huge SOAP response containing orders;
    XPath xp = new XPath(xml);
    Dom.XmlNode[] orders = xp.find('/soapenv:Envelope/soapenv:Body/searchOrdersResponse/orders/order');

    // If an order contains line items, here are a couple different ways to get their SKUs...
    for (Dom.XmlNode order : orders) {
        String[] Skus = xp.getTextList(order, 'lineitem/id');
        String SkuCsv = xp.getText(order, ',', 'lineItem/id');
    }

## The Properties
**`Dom.Document doc`**

The Dom.Document that was passed in or that we created from the XML source.

**`Dom.XmlNode root`**

The root node in the Dom.Document.

## The Methods
In all the methods below that take an optional `start` parameter, the default is to start the search at the root node.

**`XPath (String xmlsrc)`**

Creates an XPath object from a snippet of XML.

**`XPath (Dom.Document doc)`**

Creates an XPath object from a Dom.Document object that you've already created.

**`Dom.XmlNode[] find (String path)`**

**`Dom.XmlNode[] find (Dom.XmlNode start, String path)`**

Returns a List of all the nodes that are described by the path. 

**`Dom.XmlNode findFirst (String path)`**

**`Dom.XmlNode findFirst (Dom.XmlNode start, String path)`**

Returns the first node in the DOM that is described by the path.

**`String getText (String path)`**

**`String getText (Dom.XmlNode start, String path)`**

Returns the string content of the first node in the DOM that is described by the path.

**`String getText (String delimiter, String path)`**

**`String getText (Dom.XmlNode start, String delimiter, String path)`**

Returns the string contents of all the nodes that are described by the path, separated by the delimiter.

**`String[] getTextList (String path)`**

**`String[] getTextList (Dom.XmlNode start, String path)`**

Returns the string contents of all the nodes that are described by the path, in a List.
