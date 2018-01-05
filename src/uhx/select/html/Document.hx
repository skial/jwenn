package uhx.select.html;

import uhx.mo.Token;
//import dtx.mo.DOMNode;
import uhx.mo.html.Lexer;
import uhx.select.html.Impl;
//import dtx.mo.DocumentOrElement;

/**
 * ...
 * @author Skial Bainn
 */
@:access(uhx.select.html.Impl) class Document {

	// Returns the first element that matches `selector`.
	public static inline function querySelector(document:Token<HtmlKeywords>, selector:String):Token<HtmlKeywords> {
		return uhx.select.html.Document.querySelectorAll(document, selector)[0];
	}
	
	// Returns any element that matches the `selector`.
	public static function querySelectorAll(document:Token<HtmlKeywords>, selector:String):Array<Token<HtmlKeywords>> {
		var results = [];
		switch ((document:Token<HtmlKeywords>)) {
			case Keyword(Tag(r)):
				var css = Impl.parse( selector );
				if (css != null) results = new Impl().process( document, css, document );
				
			case _:
				
		}
		
		return results;
	}
	
}