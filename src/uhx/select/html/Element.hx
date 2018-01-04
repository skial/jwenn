package uhx.select.html;

import uhx.mo.Token;
//import dtx.mo.DOMNode;
import uhx.ne.Node;
import uhx.ne.NodeList;
import uhx.mo.html.Lexer;
import uhx.select.html.Impl;

/**
 * ...
 * @author Skial Bainn
 */
@:access(uhx.select.html.Impl) class Element {

	// Returns the first descendant of `element` that matches `selector`.
	public static function querySelector(element:Node, selector:String):Node {
		var results = [];
		switch element.toToken() {
			case Keyword(Tag(r)) if (r.tokens.length > 0):
				var css = Impl.parse( selector );
				for (child in r.tokens) {
					results = new Impl().process( child, css, child );
					// No need to continue searching HTML if a result exists, quit as soon as possible.
					if (results.length > 0) break;
					
				}
				
			case _:
				
		}
		
		return results[0];
	}
	
	// Returns all the descendants of `element` that match `selector`.
	public static function querySelectorAll(element:Node, selector:String):NodeList<Token<HtmlKeywords>> {
		var results = [];
		switch element.toToken() {
			case Keyword(Tag(r)) if (r.tokens.length > 0):
				var css = Impl.parse( selector );
				for (child in r.tokens) {
					results = results.concat( new Impl().process( child, css, child ) );
					
				}
				
			case _:
				
		}
		
		return results;
	}
	
}