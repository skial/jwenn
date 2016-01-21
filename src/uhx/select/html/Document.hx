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
@:access(uhx.select.html.Impl) class Document {

	// Returns the first element that matches `selector`.
	public static inline function querySelector(document:DocumentOrElement, selector:String):DOMNode {
		return uhx.select.html.Document.querySelectorAll(document, selector)[0];
	}
	
	// Returns any element that matches the `selector`.
	public static function querySelectorAll(document:DocumentOrElement, selector:String):Array<DOMNode> {
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