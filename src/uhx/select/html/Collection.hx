package uhx.select.html;

import uhx.ne.Node;
import uhx.mo.Token;
import uhx.ne.NodeList;
import uhx.mo.html.Lexer;
import uhx.select.html.Impl;

/**
 * ...
 * @author Skial Bainn
 */
@:access(uhx.select.html.Impl) class Collection {

	// Returns the first element that matches `selector`.
	public static inline function querySelector(elements:NodeList<Token<HtmlKeywords>>, selector:String):Node {
		return uhx.select.html.Collection.querySelectorAll(elements, selector)[0];
	}
	
	// Returns any element that matches the `selector`.
	public static function querySelectorAll(elements:NodeList<Token<HtmlKeywords>>, selector:String):NodeList<Token<HtmlKeywords>> {
		var results = [];
		var css = Impl.parse( selector );
		var impl = new Impl();
		// Hacky solution for `:nth` or any selector that needs to traverse the parent
		impl.dummyRef.tokens = elements.self;
		
		for (element in elements) results = results.concat( impl.process( element, css, element ) );
		
		return results;
	}
	
}