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

##Submitting Pull Requests
If you've fixed a bug or came up with a great addition to the API, I welcome your code submissions! To make things smoother, please follow these guidelines:

- Create an Issue for the bug you're fixing or feature you're adding, if there isn't one already. This is especially important if you're adding a new feature or changing the API - the userbase needs to be able to discuss it first!
- If someone is proposing a new feature or a change to the existing API, please chime in in the comments for that issue. It's important that the library evolves in a way that the userbase feels is useful and straightforward to use.
- The default branch to submit pull requests to will normally be the current version under development. We'll try to release updates to Master in a controlled manner.
- So far the project's coding conventions are rather straightforward: K&R bracing (only because it's so ubiquitous, not because it's any good!). Use the short form when declaring Lists. For each new method, write a comment block with a short description of what it does, what its parameters mean and their defaults, what it returns, and any caveats/gotchas/assumptions that the caller should know about. If you're updating a method please review the comment block & update it if appropriate.
