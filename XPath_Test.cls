/**
 * Unit tests for XPath.cls
 *
 * @author     Jennifer Simonds <jennysimonds@gmail.com>
 * @version    1.0.0
 * @copyright  2015 Jennifer Simonds
 * @license    MIT License http://opensource.org/licenses/MIT
 */
@isTest
private class XPath_Test {

	/* ************************************************************************
	 * TESTING THE CONSTRUCTORS
	 *************************************************************************/

	// Construct an XPath object from XML source.
	@isTest static void test_constructor_xml() {
		String xml = '<a>hello</a>';

		XPath xp = new XPath(xml);

		System.assertNotEquals(null, xp);
	}


	// Construct an XPath object from a Dom.Document.
	@isTest static void test_constructor_dom() {
		Dom.Document doc = new Dom.Document();

		XPath xp = new XPath(doc);

		System.assertNotEquals(null, doc);
	}


	/* ************************************************************************
	 * TESTING find() & XPATH SYNTAX
	 *************************************************************************/

	// find() returns an array of nodes that match the xpath expression.
	@isTest static void test_tagname_single() {
		String xml = '<a>hello</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('a', actualNodes[0].getName());
		System.assertEquals('hello', actualNodes[0].getText());
	}


	// find() should find nodes that are more than just 1 level deep from the starting element.
	@isTest static void test_tagname_2levels() {
		String xml = '<a><b>child 1</b></a>';

		XPath xp = new XPath(xml);
		Dom.XmlNode root = xp.doc.getRootElement();

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b', actualNodes[0].getName());
		System.assertEquals('child 1', actualNodes[0].getText());
	}


	// The fact that the XML source is nicely formatted shouldn't make a difference.
	@isTest static void test_tagname_2levels_pretty() {
		String xml =
'<a>\n' +
'	<b>child 2</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b', actualNodes[0].getName());
		System.assertEquals('child 2', actualNodes[0].getText());
	}


	// Calling find() with default start should start from the root.
	@isTest static void test_find_default_start() {
		String xml =
'<a>\n' +
'	<b>child 2</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find('/a/b');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b', actualNodes[0].getName());
		System.assertEquals('child 2', actualNodes[0].getText());
	}


	// The simplest xpath expression is a bare tagname, meaning a relative path from the specified 
	// element that matches the immediate children by tagname.
	@isTest static void test_tagname_relpath_short() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] bNodes = xp.find(xp.root, '/a/b');
		Dom.XmlNode start = bNodes[0];

		Dom.XmlNode[] actualNodes = xp.find(start, 'c');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('c', actualNodes[0].getName());
	}


	// Relative paths should handle multiple levels, same as an absolute path does.
	@isTest static void test_tagname_relpath_long() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] bNodes = xp.find(xp.root, '/a/b');
		Dom.XmlNode start = bNodes[0];

		Dom.XmlNode[] actualNodes = xp.find(start, 'c/d');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('d', actualNodes[0].getName());
	}


	// Calling find() with default start & a relative path should start from the root.
	@isTest static void test_find_default_start_relpath() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find('b/c/d');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('d', actualNodes[0].getName());
	}


	// You can start a relative path with ".".
	@isTest static void test_tagname_relpath_dot() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] bNodes = xp.find(xp.root, '/a/b');
		Dom.XmlNode start = bNodes[0];

		Dom.XmlNode[] actualNodes = xp.find(start, './c/d');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('d', actualNodes[0].getName());
		System.assertEquals('great-grandchild 1', actualNodes[0].getText());
	}


	// A "." inside a path shouldn't have any effect, since it refers to the current "folder" in the path.
	@isTest static void test_tagname_relpath_dot_inside() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] bNodes = xp.find(xp.root, '/a/b');
		Dom.XmlNode start = bNodes[0];

		Dom.XmlNode[] actualNodes = xp.find(start, 'c/./d');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('d', actualNodes[0].getName());
		System.assertEquals('great-grandchild 1', actualNodes[0].getText());
	}


	// You can start a relative path with "..".
	@isTest static void test_tagname_relpath_doubledot() {
		String xml =
'<a>\n' +
'	<b1>B 1</b1>\n' +
'	<b1>B 2</b1>\n' +
'	<b2>B 1</b2>\n' +
'	<b2>B 2</b2>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] b1Nodes = xp.find(xp.root, '/a/b1');
		Dom.XmlNode start = b1Nodes[0];

		Dom.XmlNode[] actualNodes = xp.find(start, '../b2');

		System.assertEquals(2, actualNodes.size());
		System.assertEquals('b2', actualNodes[0].getName());
		System.assertEquals('b2', actualNodes[1].getName());
		System.assertEquals('B 1', actualNodes[0].getText());
		System.assertEquals('B 2', actualNodes[1].getText());
	}


	// A ".." inside a path should go up one level to the parent.
	@isTest static void test_tagname_relpath_doubledot_inside1() {
		String xml =
'<a>\n' +
'	<b1>B 1</b1>\n' +
'	<b1>B 2</b1>\n' +
'	<b2>B 1</b2>\n' +
'	<b2>B 2</b2>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b1/..');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals('a', actualNodes[0].getName());
	}


	// A ".." inside a path should go up one level to the parent.
	@isTest static void test_tagname_relpath_doubledot_inside2() {
		String xml =
'<a>\n' +
'	<b1>B 1</b1>\n' +
'	<b1>B 2</b1>\n' +
'	<b2>B 1</b2>\n' +
'	<b2>B 2</b2>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b1/../b2');

		System.assertEquals(2, actualNodes.size());
		System.assertEquals('B 1', actualNodes[0].getText());
		System.assertEquals('B 2', actualNodes[1].getText());
	}


	@isTest static void test_multiple_matches() {
		String xml =
'<a>\n' +
'	<b1>child 1</b1>\n' +
'	<b2>odd man out</b2>\n' +
'	<b1>child 2</b1>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b1');

		System.assertEquals(2, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b1', actualNodes[0].getName());
		System.assertEquals('child 1', actualNodes[0].getText());
		System.assertEquals('child 2', actualNodes[1].getText());
	}


	// If you use an xpath more than once, it should take the compiled path from the cache.
	@isTest static void test_cache() {
		String xml =
'<a>\n' +
'	<b>child 1.1</b>\n' +
'	<b>child 1.2\n' +
'		<c>grandchild 2.1</c>\n' +
'		<c>grandchild 2.2\n' +
'			<d>great-grandchild 3.1</d>\n' +
'			<d>great-grandchild 3.2</d>\n' +
'			<d>great-grandchild 3.3</d>\n' +
'		</c>\n' +
'		<c>grandchild 2.3</c>\n' +
'	</b>\n' +
'	<b>child 1.3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);
		String path = '/a/b/c';

		System.assertEquals(false, xp.isPathCached(path));
		Dom.XmlNode[] actualNodes1 = xp.find(xp.root, path);

		System.assertEquals(true, xp.isPathCached(path));
		Dom.XmlNode[] actualNodes2 = xp.find(xp.root, path);

		System.assertEquals(3, actualNodes1.size());
		System.assertEquals(3, actualNodes2.size());
		System.assertEquals('c', actualNodes1[0].getName());
		System.assertEquals('c', actualNodes2[0].getName());
	}


	@isTest static void test_findFirst_0_matches() {
		String xml =
'<a>\n' +
'	<b1>child 1</b1>\n' +
'	<b2>odd man out</b2>\n' +
'	<b1>child 2</b1>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode actualNode = xp.findFirst(xp.root, '/a/xxx');

		System.assertEquals(null, actualNode);
	}


	@isTest static void test_findFirst_1_match() {
		String xml =
'<a>\n' +
'	<b1>child 1</b1>\n' +
'	<b2>odd man out</b2>\n' +
'	<b1>child 2</b1>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode actualNode = xp.findFirst(xp.root, '/a/b2');

		System.assertNotEquals(null, actualNode);
		System.assertEquals('b2', actualNode.getName());
	}


	@isTest static void test_findFirst_multiple_matches() {
		String xml =
'<a>\n' +
'	<b1>child 1</b1>\n' +
'	<b2>odd man out</b2>\n' +
'	<b1>child 2</b1>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode actualNode = xp.findFirst(xp.root, '/a/b1');

		System.assertNotEquals(null, actualNode);
		System.assertEquals('b1', actualNode.getName());
	}


	// Calling findFirst() with default start should always start from the root.
	@isTest static void test_findFirst_default_start() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'			<d>great-grandchild 2</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode actualNodeRel = xp.findFirst('b/c/d');
		Dom.XmlNode actualNodeAbs = xp.findFirst('/a/b/c/d');

		System.assertEquals('great-grandchild 1', actualNodeRel.getText());
		System.assertEquals('great-grandchild 1', actualNodeAbs.getText());
	}


	// A wildcard tagname should pick up all immediate child elements.
	@isTest static void test_tagname_star() {
		String xml =
'<a>\n' +
'	<b1>child 1</b1>\n' +
'	<b2>odd man out</b2>\n' +
'	<!-- a comment -->\n' +
'	<b1>child 2</b1>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/*');

		System.assertEquals(3, actualNodes.size());
		System.assertEquals('b1', actualNodes[0].getName());
		System.assertEquals('b2', actualNodes[1].getName());
		System.assertEquals('b1', actualNodes[2].getName());
	}


	@isTest static void test_namespace_tagname() {
		String xml = 
'<a xmlns:myNs="urn:myNs">\n' +
'	<myNs:b>hello</myNs:b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/myNs:b');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b', actualNodes[0].getName());
		System.assertEquals('hello', actualNodes[0].getText());
	}


	@isTest static void test_ignore_namespace_tagname() {
		String xml = 
'<a xmlns:myNs="urn:myNs">\n' +
'	<myNs:b>hello</myNs:b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('b', actualNodes[0].getName());
		System.assertEquals('hello', actualNodes[0].getText());
	}


	/* ************************************************************************
	 * TESTING THE PREDICATES
	 *************************************************************************/

	@isTest static void test_predicate_index_true() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[2]');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('child 2', actualNodes[0].getText());
	}
	

	@isTest static void test_predicate_index_false() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[4]');

		System.assertEquals(0, actualNodes.size());
	}
	

	@isTest static void test_predicate_index_bad_0_index() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[0]');

		System.assertEquals(0, actualNodes.size());
	}


	// Looking for existence of a specific attribute that is found in 2 elements should
	// return 2 elements.
	@isTest static void test_predicate_has_attr_true() {
		String xml =
'<a>\n' +
'	<b id="1">child 1</b>\n' +
'	<b id="2">child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[@id]');

		System.assertEquals(2, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('child 1', actualNodes[0].getText());
		System.assertEquals('child 2', actualNodes[1].getText());
	}


	// Looking for existence of a specific attribute that isn't in any of the elements should
	// return 0 elements.
	@isTest static void test_predicate_has_attr_false() {
		String xml =
'<a>\n' +
'	<b id="1">child 1</b>\n' +
'	<b id="2">child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[@xxx]');

		System.assertEquals(0, actualNodes.size());
	}


	@isTest static void test_predicate_attr_value_true() {
		String xml =
'<a>\n' +
'	<b id="1">child 1</b>\n' +
'	<b id="2">child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[@id="1"]');

		System.assertEquals(1, actualNodes.size());
		System.assertEquals(Dom.XmlNodeType.ELEMENT, actualNodes[0].getNodeType());
		System.assertEquals('child 1', actualNodes[0].getText());
	}


	@isTest static void test_predicate_attr_value_false() {
		String xml =
'<a>\n' +
'	<b id="1">child 1</b>\n' +
'	<b id="2">child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[@id="3"]');

		System.assertEquals(0, actualNodes.size());
	}
	

	@isTest static void test_predicate_empty() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[]');

		System.assertEquals(0, actualNodes.size());
	}


	@isTest static void test_predicate_invalid() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		Dom.XmlNode[] actualNodes = xp.find(xp.root, '/a/b[xxx]');

		System.assertEquals(0, actualNodes.size());
	}


	/* ************************************************************************
	 * TESTING getText & ITS VARIANTS
	 *************************************************************************/

	// getText is like find except it then gets the innerText of each result element.
	@isTest static void test_getText_single() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String actualText = xp.getText(xp.root, '/a/b');

		System.assertEquals('child 1', actualText);
	}


	// getText is like find except it then gets the innerText of each result element.
	@isTest static void test_getText_multiple() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String actualText = xp.getText(xp.root, '/a/b');

		System.assertEquals('child 1', actualText);
	}


	// Calling getText() with default start should always start from the root.
	@isTest static void test_getText_default_start() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'			<d>great-grandchild 2</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String actualTextRel = xp.getText('b/c/d');
		String actualTextAbs = xp.getText('/a/b/c/d');

		System.assertEquals('great-grandchild 1', actualTextRel);
		System.assertEquals('great-grandchild 1', actualTextAbs);
	}


	// getTextList should return a List of Strings.
	@isTest static void test_getText_multiple_list() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String[] actualText = xp.getTextList(xp.root, '/a/b');

		System.assert(actualText.size() == 3);
		System.assertEquals('child 1', actualText[0]);
		System.assertEquals('child 2', actualText[1]);
		System.assertEquals('child 3', actualText[2]);
	}


	// Calling getTextList() with default start should always start from the root.
	@isTest static void test_getTextList_default_start() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'			<d>great-grandchild 2</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String[] actualTextRel = xp.getTextList('b/c/d');
		String[] actualTextAbs = xp.getTextList('/a/b/c/d');

		System.assert(actualTextRel.size() == 2);
		System.assertEquals('great-grandchild 1', actualTextRel[0]);
		System.assert(actualTextAbs.size() == 2);
		System.assertEquals('great-grandchild 1', actualTextAbs[0]);
	}


	// getTextList with no matches should return an empty List of Strings.
	@isTest static void test_getText_multiple_list_empty() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String[] actualText = xp.getTextList(xp.root, '/a/xxx');

		System.assert(actualText.size() == 0);
	}


	// getText with 3 parameters should return a delimited list.
	@isTest static void test_getText_multiple_delimiter() {
		String xml =
'<a>\n' +
'	<b>child 1</b>\n' +
'	<b>child 2</b>\n' +
'	<b>child 3</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String actualText = xp.getText(xp.root, '-', '/a/b');

		System.assert(actualText.length() > 0);
		System.assertEquals('child 1-child 2-child 3', actualText);
	}


	// Calling getText() with 2 String parameters (default start) should always start from the root.
	@isTest static void test_getText_CSV_default_start() {
		String xml =
'<a>\n' +
'	<b>\n' +
'		<c>\n' +
'			<d>great-grandchild 1</d>\n' +
'			<d>great-grandchild 2</d>\n' +
'		</c>\n' +
'	</b>\n' +
'</a>';

		XPath xp = new XPath(xml);

		String actualTextRel = xp.getText(',', 'b/c/d');
		String actualTextAbs = xp.getText(',', '/a/b/c/d');

		System.assertEquals('great-grandchild 1,great-grandchild 2', actualTextRel);
		System.assertEquals('great-grandchild 1,great-grandchild 2', actualTextAbs);
	}
}
