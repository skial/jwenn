package uhx.select.html;

import uhx.mo.Token;
import uhx.mo.html.Lexer;
import uhx.select.html.Impl;

/**
 * ...
 * @author Skial Bainn
 */
@:access(uhx.select.html.Impl) class Collection {

	// Returns the first element that matches `selector`.
	public static inline function querySelector(elements:Array<Token<HtmlKeywords>>, selector:String):Token<HtmlKeywords> {
		return uhx.select.html.Collection.querySelectorAll(elements, selector)[0];
	}
	
	// Returns any element that matches the `selector`.
	public static function querySelectorAll(elements:Array<Token<HtmlKeywords>>, selector:String):Array<Token<HtmlKeywords>> {
		var results = [];
		var css = Impl.parse( selector );
		var impl = new Impl();
		// Hacky solution for `:nth` or any selector that needs to traverse the parent
		impl.dummyRef.tokens = elements;
		
		for (element in elements) results = results.concat( impl.process( element, css, element ) );
		
		return results;
	}
	
}