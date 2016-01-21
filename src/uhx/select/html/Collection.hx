package uhx.select.html;

import uhx.mo.Token;
import dtx.mo.DOMNode;
import uhx.lexer.Html;
import uhx.select.html.Impl;
import dtx.mo.DocumentOrElement;

/**
 * ...
 * @author Skial Bainn
 */
@:access(uhx.select.html.Impl) class Collection {

	// Returns the first element that matches `selector`.
	public static inline function querySelector(elements:Array<DOMNode>, selector:String):DOMNode {
		return uhx.select.html.Collection.querySelectorAll(elements, selector)[0];
	}
	
	// Returns any element that matches the `selector`.
	public static function querySelectorAll(elements:Array<DOMNode>, selector:String):Array<DOMNode> {
		var results = [];
		var css = Impl.parse( selector );
		var impl = new Impl();
		// Hacky solution for `:nth` or any selector that needs to traverse the parent
		impl.dummyRef.tokens = elements;
		
		for (element in elements) results = results.concat( impl.process( element, css, element ) );
		
		return results;
	}
	
}