package uhx.jwenn;

import haxe.io.Eof;
import utest.Assert;
import uhx.mo.Token;
import byte.ByteData;
import uhx.select.html.Impl;
import uhx.mo.css.Lexer;
import uhx.mo.css.Lexer as CssLexer;
import uhx.mo.html.Lexer;
import uhx.mo.html.Lexer as HtmlLexer;
import uhx.mo.selectors.Parser as SelectorParser;

import uhx.select.Html in HtmlSelector;
import uhx.select.Html.ElementSelector;
import uhx.select.Html.DocumentSelector;
import uhx.select.Html.CollectionSelector;

using StringTools;
#if detox
using Detox;
#end

/**
 * ...
 * @author Skial Bainn
 */
@:keep class HtmlQuerySpec {

	public function new() {
		
	}
	
	private function parse(html:String):Array<Token<HtmlKeywords>> {
		var lexer = new HtmlLexer( ByteData.ofString( html ), 'htmlselectspec' );
		var tokens = [];
		
		try while ( true ) {
			tokens.push( lexer.token( HtmlLexer.root ) );
			
		} catch (_e:Eof) { } catch (_e:Dynamic) {
			
		}
		
		return tokens;
	}
	
	public function cssParse(value:String) {
		return new SelectorParser().toTokens( ByteData.ofString( value ), 'html-css-selector' );
	}
	
	public function testUniversal() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><div class="A"></div><span id="B"></span></html>' )[0], '*' );
		
		//untyped console.log( mo );
		
		Assert.equals( 3, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'html' } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'div' } )) ) );
		Assert.isTrue( mo[2].match( Keyword(Tag( { name:'span' } )) ) );
	}
	
	
	/*public function testSingleID() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><div id="A"></div></html>' )[0], '#A' );
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div' } )) ) );
	}
	
	public function testMultiID() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><div id="A"></div><span id="A"></span></html>' )[0], '#A' );
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div' } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'span' } )) ) );
	}
	
	public function testSingleID_deep() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<a><b><c><d><div></div><div id="A">Some Text</div><div></div></d></c></b></a>' )[0], '#A' );
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div', tokens:[Keyword(HtmlKeywords.Text( { tokens:'Some Text' } ))] } )) ) );
	}
	
	
	public function testSingleClass() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><div class="A"></div><span class="A"></span><pre class="A"></pre></html>' )[0], '.A' );
		
		Assert.equals( 3, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div' } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'span' } )) ) );
		Assert.isTrue( mo[2].match( Keyword(Tag( { name:'pre' } )) ) );
	}
	
	// Css Parser problem
	/*public function testMultiClass() {
		untyped console.log( cssParse( '.A.B.C' ) ); // Find an element that has all these class name
		untyped console.log( cssParse( '.A .B .C' ) ); // Find an ele w/ `C` class name inside an ele w/ class `B` inside ele w/ class name `A`
	}*/
	
	// Even though this is testing the html token structure,
	// it is easier with a css processor.
	/*public function testTagName() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<a><b><c><d></d></c></b></a>' )[0], 'd' );
		
		//untyped console.log( mo );
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'d', parent:p } )): 
				Assert.isTrue( p().match( Keyword(Tag( { name:'c' } )) ) );
				
				switch (p()) {
					case Keyword(Tag( { name:'c', parent:p } )):
						Assert.isTrue( p().match( Keyword(Tag( { name:'b' } )) ) );
						
						switch (p()) {
							case Keyword(Tag( { name:'b', parent:p } )):
								Assert.isTrue( p().match( Keyword(Tag( { name:'a' } )) ) );
								
								// Here I am checking that `<a></a>` parent is itself, which it should be.
								switch (p()) {
									case Keyword(Tag( { name:'a', parent:p } )):
										//Assert.isTrue( p().match( Keyword(Tag( { name:'a' } )) ) );
										Assert.isNull( p() );
										
									case _:
								}
								
							case _:
						}
						
					case _:
				}
				
			case _:
		}
	}
	
	public function testGrouping() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><div class="A"></div><span id="B"></span></html>' )[0], '.A, #B' );
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div' } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'span' } )) ) );
	}
	
	public function testCombinator_General() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><code>abc</code><span>def</span></html>' )[0], 'code ~ span' );
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'span', tokens:[Keyword(HtmlKeywords.Text( { tokens:'def' } ))] } )) ) );
	}
	
	public function testCombinator_Adjacent() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><code>a</code><span>b</span><pre>c</pre></html>' )[0], 'span + pre' );
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'pre', tokens:[Keyword(HtmlKeywords.Text( { tokens:'c' } ))] } )) ) );
	}
	
	public function testCombinator_Descendant() {
		var mo:Tokens = DocumentSelector.querySelectorAll( parse( '<html><code>a</code><span>b</span><pre><pre>c</pre></pre></html>' )[0], 'pre pre' );
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'pre', tokens:[Keyword(HtmlKeywords.Text( { tokens:'c' } ))] } )) ) );
	}
	
	public function testCombinator_Child() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>a</code><span>b</span><pre><pre>c</pre></pre></html>' )[0], 
			'html > pre' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'pre', tokens:[Keyword(Tag( { name:'pre', tokens:[Keyword(HtmlKeywords.Text( { tokens:'c' } ))] } ))] } )) ) );
	}
	
	public function testAttributes_Name_Typeless() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a>b</div><div>c</div></html>' )[0], 
			'[a]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( '', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	
	public function testAttributes_Name() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a>b</div><div>c</div></html>' )[0], 
			'div[a]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( '', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_ExactUnQuoted() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="b">b</div><div>c</div></html>' )[0], 
			'div[a=b]' 
		);
		
		//untyped console.log( mo );
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'b', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_ExactQuoted() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<html><div>a</div><div a="b">b</div><div>c</div></html>' )[0], 
			'div[a="b"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'b', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_Contains() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="xxxaaasssdddbxxxcccvvvyeyq">b</div><div>c</div></html>' )[0], 
			'div[a*="b"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'xxxaaasssdddbxxxcccvvvyeyq', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_Prefix() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="xxxaaasssdddbxxxcccvvvyeyq">b</div><div>c</div></html>' )[0], 
			'div[a^="xxx"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'xxxaaasssdddbxxxcccvvvyeyq', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_Suffix() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse ( '<html><div>a</div><div a="xxxaaasssdddbxxxcccvvvyeyq">b</div><div>c</div></html>' )[0], 
			'div[a$="eyq"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'xxxaaasssdddbxxxcccvvvyeyq', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_List() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="a1 a2 a3 a4 a5 a6">b</div><div>c</div></html>' )[0], 
			'div[a~="a3"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'a1 a2 a3 a4 a5 a6', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_DashedList() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="a1-a2-a3-a4-a5-a6">b</div><div>c</div></html>' )[0], 
			'div[a|="a4"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.equals( 'a1-a2-a3-a4-a5-a6', a.get('a') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testAttributes_Multiple() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><div>a</div><div a="a1-a2-a3-a4-a5-a6" b="123abc456">b</div><div>c</div></html>' )[0], 
			'div[a|="a4"][b*="abc"]' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', attributes:a, tokens:[Keyword(HtmlKeywords.Text( { tokens:'b' } ))] } )):
				Assert.isTrue( a.exists('a') );
				Assert.isTrue( a.exists('b') );
				Assert.equals( 'a1-a2-a3-a4-a5-a6', a.get('a') );
				Assert.equals( '123abc456', a.get('b') );
				
			case _:
				Assert.fail();
		}
	}
	
	/*
	 * LEVEL 2 CSS SELECTORS
	 */
	
	/*public function testPseudo_firstChild_None() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><b>WIN</b><b>FAIL</b><b>FAIL AGAIN</b></a>' )[0], 
			'b:first-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'b', tokens:[Keyword(HtmlKeywords.Text( { tokens:'WIN' } ))] } )) ) );
	}
	
	public function testPseudo_firstChild_Child() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><b><c>WIN</c></b><b>FAIL</b><b>FAIL AGAIN</b></a>' )[0], 
			'b > :first-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'c', tokens:[Keyword(HtmlKeywords.Text( { tokens:'WIN' } ))] } )) ) );
	}
	
	public function testPseudo_firstChild_Descendant() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>abc</code><span>def</span></html>' )[0], 
			'html :first-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'code', tokens:[Keyword(HtmlKeywords.Text( { tokens:'abc' } ))] } )) ) );
	}
	
	public function testPseudo_firstChild_Descendant_Deep() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>abc</code><span><div><p>def</p><div></span></html>' )[0], 
			'div :first-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'p', tokens:[Keyword(HtmlKeywords.Text( { tokens:'def' } ))] } )) ) );
	}
	
	public function testPseudo_firstChild_Adjacent() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><b>FAIL</b><b>FAIL AGAIN</b><b>REALLY?</b></a>' )[0], 
			'b + :first-child' 
		);
		
		Assert.equals( 0, mo.length );
	}
	
	public function testPseudo_firstChild_General() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><b>FAIL</b><b>FAIL AGAIN</b><b>REALLY?</b></a>' )[0], 
			'b ~ :first-child' 
		);
		
		Assert.equals( 0, mo.length );
	}
	
	public function testPseudo_link() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a href="1"><a href="2"><a href="3"><a href="4"></a></a></a></a>' )[0], 
			':link' 
		);
		
		Assert.equals( 4, mo.length );
		for (i in 0...mo.length) switch (mo[i]) {
			case Keyword(Tag( { name:'a', attributes:a, tokens:t } )):
				switch (i) {
					case 0, 1, 2, 3:
						Assert.isTrue( a.exists('href') );
						Assert.equals( '${i+1}', a.get('href') );
						
					case _:
						Assert.fail();
				}
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_typedLink() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a href="1"><a href="2"><a href="3"><a href="4"></a></a></a></a>' )[0], 
			'a:link' 
		);
		
		Assert.equals( 4, mo.length );
		for (i in 0...mo.length) switch (mo[i]) {
			case Keyword(Tag( { name:'a', attributes:a, tokens:t } )):
				switch (i) {
					case 0, 1, 2, 3:
						Assert.isTrue( a.exists('href') );
						Assert.equals( '${i+1}', a.get('href') );
						
					case _:
						Assert.fail();
				}
				
			case _:
				Assert.fail();
		}
	}
	
	// LEVEL 3 CSS SELECTORS
	
	public function testPseudo_enabled() {
		var mo:Tokens = CollectionSelector.querySelectorAll( 
			parse( '<a enabled=enabled></a><b disabled="disabled"></b>' ),
			':enabled'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'a', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('enabled') );
				Assert.equals( 'enabled', a.get('enabled') );
				
			case _:	
				Assert.fail();
		}
	}
	
	public function testPseudo_disabled() {
		var mo:Tokens = CollectionSelector.querySelectorAll( 
			parse( '<a enabled=enabled></a><b disabled="disabled"></b>' ),
			':disabled'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'b', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('disabled') );
				Assert.equals( 'disabled', a.get('disabled') );
				
			case _:	
				Assert.fail();
		}
	}
	
	public function testPseudo_root() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b><c><d><e></e></d></c></b></a>' )[0],
			':root'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'a', tokens:t, parent:p } )):
				Assert.equals( 1, t.length );
				Assert.isNull( p() );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_lastChild_None() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><b>FAIL</b><b>WIN</b></a>' )[0], 
			'b:last-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'b', tokens:[Keyword(HtmlKeywords.Text( { tokens:'WIN' } ))] } )) ) );
	}
	
	/*public function testPseudo_lastChild_Child() {
		var mo = HtmlSelector.find(
			parse( '<a><b>FAIL</b><b>WIN</b></a>' ),
			':last-child > :last-child'
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'b', tokens:[Keyword(HtmlKeywords.Text( { tokens:'WIN' } ))] } )) ) );
	}*/
	
	/*public function testPseudo_lastChild_Descendant() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>abc</code><span>def</span></html>' )[0], 
			'html :last-child' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'span', tokens:[Keyword(HtmlKeywords.Text( { tokens:'def' } ))] } )) ) );
	}
	
	
	
	public function testPseudo_NthChild_Odd() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>abc</code><span>def</span></html>' )[0], 
			'html :nth-child(odd)'
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'code', tokens:[Keyword(HtmlKeywords.Text( { tokens:'abc' } ))] } )) ) );
	}
	
	public function testPseudo_NthChild2() {
		// `:nth-child(-n+2)` selects the first two elements.
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><code>abc</code><span>def</span></html>' )[0], 
			'html :nth-child(-n+2)' 
		);
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'code', tokens:[Keyword(HtmlKeywords.Text( { tokens:'abc' } ))] } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'span', tokens:[Keyword(HtmlKeywords.Text( { tokens:'def' } ))] } )) ) );
	}
	
	public function testPseudo_NthLastChild_single() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><1></1><2></2><3></3><4></4></a>' )[0], 
			'a :nth-last-child(2)' 
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'3', tokens:[] } )) ) );
	}
	
	public function testPseudo_NthLastChild_multiple() {
		// `:nth-last-child(-n+2)` selects the last two elements.
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><1></1><2></2><3></3><4></4></a>' )[0], 
			'a :nth-last-child(-n+2)' 
		);
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'4', tokens:[] } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'3', tokens:[] } )) ) );
	}
	
	public function testPseudo_NthLastChild_odd() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><1></1><2></2><3></3><4></4></a>' )[0], 
			'a :nth-last-child(odd)' 
		);
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'4', tokens:[] } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'2', tokens:[] } )) ) );
	}
	
	public function testPseudo_NthLastChild_even() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<a><1></1><2></2><3></3><4></4></a>' )[0], 
			'a :nth-last-child(even)' 
		);
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'3', tokens:[] } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'1', tokens:[] } )) ) );
	}
	
	public function testPseudo_NthOftype_single() {
		var mo:Tokens = CollectionSelector.querySelectorAll( 
			parse( '<a id=1></a><b id=1></b><a id=2></a><b id=2></b><a id=3></a><b id=3></b><a id=4></a><b id=4></b>' ), 
			'a:nth-of-type(2)' 
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'a', tokens:[], attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_NthLastOfType() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<ul><li>First Item</li><li>Second Item</li><li>Third Item</li><li>Fourth Item</li><li>Fifth Item</li></ul>' )[0],
			'li:nth-last-of-type(2)'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'li', tokens:[Keyword(Text( { tokens:'Fourth Item' } ))] } ) ):
				Assert.isTrue( true );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_FirstofType() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><a>wrong</a><a>wrong</a><ABC>CORRECT</ABC><a>wrong</a><ABC>WRONG</ABC><a>wrong</a></html>' )[0], 
			'ABC:first-of-type' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:n, tokens:[Keyword(HtmlKeywords.Text( { tokens:'CORRECT' } ))] } )):
				Assert.equals( 'ABC', n );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_LastofType() {
		var mo:Tokens = DocumentSelector.querySelectorAll( 
			parse( '<html><a>wrong</a><a>wrong</a><ABC>CORRECT</ABC><a>wrong</a><ABC>WRONG</ABC><a>wrong</a></html>' )[0], 
			'ABC:last-of-type' 
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:n, tokens:[Keyword(HtmlKeywords.Text( { tokens:'WRONG' } ))] } )):
				Assert.equals( 'ABC', n );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_OnlyChild() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<div><p>This paragraph is the only child of its parent</p></div><div><p>This paragraph is the first child of its parent</p><p>This paragraph is the second child of its parent</p></div>' )[0],
			'p:only-child'
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'p', tokens:t, parent:p } )):
				Assert.equals( 1, t.length );
				Assert.isTrue( t[0].match( Keyword(Text( { tokens:'This paragraph is the only child of its parent' } )) ) );
				Assert.isTrue( p().match( Keyword(Tag( { name:'div' } )) ) );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_OnlyOfType() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( "<ul><li>I'm all alone!</li></ul><ul><li>We are together.</li><li>We are together.</li><li>We are together.</li></ul>" )[0],
			'li:only-of-type'
		);
		
		Assert.equals( 1, mo.length );
		
		switch(mo[0]) {
			case Keyword(Tag( { name:'li', tokens:[Keyword(Text( { tokens:"I'm all alone!" } ))] } )):
				Assert.isTrue( true );
				
			case _:
				Assert.fail();
		}
	}
	
	public function testPseudo_Empty() {
		var mo:Tokens = CollectionSelector.querySelectorAll(
			parse( "<div> </div><div><!-- test --></div><div>\r\n</div><div><div>" ),
			'div:empty'
		);
		
		Assert.equals( 2, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'div', tokens:[Keyword(Instruction( { tokens:['--', ' ', 'test', ' ', '--'] } ))] } )) ) );
		Assert.isTrue( mo[1].match( Keyword(Tag( { name:'div', tokens:[] } )) ) );
	}
	
	public function testPseudo_Not_None() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li id=1></li><li class="different"></li><li id=2></li></ul>' )[0],
			'li:not(.different)'
		);
		
		Assert.equals( 2, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'li', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		switch (mo[1]) {
			case Keyword(Tag( { name:'li', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_Child() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li><a id=1></a></li><li class="different"></li><li><b id=2></b></li></ul>' )[0],
			'li > :not(.different)'
		);
		
		Assert.equals( 2, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'a', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		switch (mo[1]) {
			case Keyword(Tag( { name:'b', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_Descendant() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li><a id=1></a></li><li class="different"></li><li><b id=2></b></li></ul>' )[0],
			'li :not(.different)'
		);
		
		Assert.equals( 2, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'a', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		switch (mo[1]) {
			case Keyword(Tag( { name:'b', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_Adjacent() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li><a id=1></a></li><li class="different"></li><li id=2></li></ul>' )[0],
			'li + :not(.different)'
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'li', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_General() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li><a id=1></a></li><li class="different"></li><li id=2></li></ul>' )[0],
			'li ~ :not(.different)'
		);
		
		Assert.equals( 1, mo.length );
		
		switch (mo[0]) {
			case Keyword(Tag( { name:'li', attributes:a, tokens:[] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_Group() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b><c>Fail</c><d>!WIN!</d><c>Fail</c></b></a>' )[0],
			':not(a, b, c)'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'d', tokens:[Keyword(Text( { tokens:'!WIN!' } ))] } )):
				Assert.isTrue( true );
				
			case _:
				Assert.fail();
				
		}
	}
	
	// LEVEL 4 CSS SELECTORS
	
	public function testPseudo_Scope_Stupid() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<ul><li id="scope"><a>abc</a></li><li>def</li><li><a>efg</a></li></ul>' )[0],
			':scope #scope'
		);
		
		Assert.equals( 1, mo.length );
		Assert.isTrue( mo[0].match( Keyword(Tag( { name:'li', tokens:[Keyword(Tag( { name:'a', tokens:[Keyword(Text( { tokens:'abc' } ))] } ))] } )) ) );
	}
	
	public function testPseudo_Has_Simple() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b>F</b><b id=1><c>WIN</c></b><b>F</b></a>' )[0],
			'b:has(c)'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'b', tokens:[Keyword(Tag( { name:'c', tokens:[Keyword(Text( { tokens:'WIN' } ))] } ))], attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Has_Child() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><div><b><div><c>WIN</c></div></b></div></a>' )[0],
			'div:has(> c)'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'div', tokens:[Keyword(Tag( { name:'c', tokens:[Keyword(Text( { tokens:'WIN' } ))] } ))] } )):
				Assert.isTrue( true );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Has_Adjacent() {
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b>WIN</b><c></c></a>' )[0],
			'b:has(+ c)'
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'b', tokens:[Keyword(Text( { tokens:'WIN' } ))] } )):
				Assert.isTrue( true );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testPseudo_Not_Has() {
		trace( 'not has pseudo' );
		var mo:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b id=1><h1></h1></b> <b id=2>WIN</b> <b id=3><h4></h4></b></a>' )[0],
			'b:not(:has(h1, h4))'
		);
		trace( mo.length, mo);
		trace( 'has pseduo' );
		var mo2:Tokens = DocumentSelector.querySelectorAll(
			parse( '<a><b id=1><h1></h1></b> <b id=2>WIN</b> <b id=3><h4></h4></b></a>' )[0],
			'b:has(h1, h4)'
		);
		
		trace( mo2.length, mo2 );
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'b', attributes:a, tokens:[Keyword(Text( { tokens:'WIN' } ))] } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	// Extras - non spec specific
	
	public function testParentless_Simple() {
		var mo:Tokens = CollectionSelector.querySelectorAll( 
			parse( '<a n=1></a><b n=1></b><c n=1></c><d n=1></d><a n=2></a><b n=2></b><c n=2></c><d n=2></d>' ), 
			'c' 
		);
		
		Assert.equals( 2, mo.length );
		for (m in mo) switch (m) {
			case Keyword(Tag( { name:'c', tokens:[], attributes:a } )):
				Assert.isTrue( a.exists( 'n' ) );
				Assert.contains( a.get( 'n' ), ['1', '2'] );
				
			case _:
				Assert.fail();
				
		}
	}
	
	public function testParentless_SemiComplex() {
		var mo:Tokens = CollectionSelector.querySelectorAll( 
			parse( '<head><meta name="og:description" content="Under Construction" /><link rel="import" href="D.html" /></head><body></body>' ), 
			'head' 
		);
		
		Assert.equals( 1, mo.length );
		switch (mo[0]) {
			case Keyword(Tag( { name:'head', tokens:t } )):
				Assert.equals( 2, t.length );
				
			case _:
				Assert.fail();
				
		}
	}
	
	#if (detox && sys)
	public function testParentless_UsingDetox() {
		var tokens:Array<dtx.mo.DOMNode> = parse( '<head><meta name="og:description" content="Under Construction" /><link rel="import" href="D.html" /></head><body></body>' );
		var collection = new DOMCollection( tokens );
		var mo = collection.find( 'head' );
		Assert.equals( 1, mo.length );
		switch ((mo.getNode():Token<HtmlKeywords>)) {
			case Keyword(Tag( { name:'head', tokens:t } )):
				Assert.equals( 2, t.length );
				
			case _:
				Assert.fail();
				
		}
	}
	
	// From Detox Traversing Test file.
	public function testRecursive_UsingDetox() {
		var tokens:Array<dtx.mo.DOMNode> = parse( "<xml><div id='recursive' class='level1'>
				<div class='level2'>
					<div class='level3'>
						<div class='level4'>
						</div>
					</div>
				</div>
			</div></xml>" );
		
		var collection = new DOMCollection( tokens );
		var old_document = Detox.document;
		Detox.setDocument( collection.getNode() );
		var recursive = '#recursive'.find().getNode();
		Assert.equals(1, recursive.find('.level4').length);
		Assert.equals(1, recursive.find('.level4').length);
		Assert.equals(3, recursive.find('div').length);
		Detox.setDocument( old_document );
	}
	
	private static function debugPrettyPrint(tokens:Tokens, tabs:String = ''):String {
		var results = '';
		
		for (token in tokens) {
			results += '\n$tabs';
			switch (token) {
				case Keyword(Tag( { name:n, attributes:a, tokens:t } )):
					results += '<$n>::' + [for (k in a.keys()) '$k=${a.get(k)}'].join(', ');
					if (t.length > 0) {
						tabs += '  ';
						results += '\n$tabs' + debugPrettyPrint( t, tabs );
						tabs = tabs.substring(0, tabs.length - 2);
					}
					
				case Keyword(Text( { tokens:t } )):
					results += 'text::' + t.replace('\n', '\\n').replace('\t', '\\t').replace('\r', '\\r');
					
				case _:
					
			}
			
		}
		
		return results;
	}
	#end
	private function testReplaceSingleNodeWithCollection_UsingDetox() {
		var collection = '<xml><a1></a1><b2><div><span><code></code></span></div></b2><c3></c3></xml>'.parse();
		var b = collection.find( 'b2' );
		Assert.equals( 1, b.length );
		Assert.equals( 'b2', collection.getNode().children().getNode( 1 ).nodeName.toLowerCase() );
		
		// replace with parsed tokens.
		b.replaceWith( b.children() );
		
		b = collection.find( 'b2' );
		// length should be 0
		Assert.equals( 0, b.length );
		Assert.equals( 'div', collection.getNode().children().getNode( 1 ).nodeName.toLowerCase() );
		
		// the contents of <template> will be a string, needing to be parsed.
		collection = '<xml><a1></a1><b2><script><div><span><code></code></span></div></script></b2><c3></c3></xml>'.parse();
		b = collection.find( 'b2' );
		Assert.equals( 1, b.length );
		Assert.equals( 'b2', collection.getNode().children().getNode( 1 ).nodeName.toLowerCase() );
		
		b.replaceWith( b.find('script').text().parse() );
		
		b = collection.find( 'b2' );
		// length should be 0
		Assert.equals( 0, b.length );
		Assert.equals( 'div', collection.getNode().children().getNode( 1 ).nodeName.toLowerCase() );
	}
	
	// Raw method testing
	
	@:access(uhx.select.html.Impl) public function testProcess_Group_Not() {
		var selector = cssParse( 'a, b, c' );
		
		Assert.isTrue( selector.match( Group([ Type('a'), Type('b'), Type('c') ]) ) );
		
		// Manually construct and process elements.
		var html = parse( '<a><b></b><c></c><d>WIN</d><e></e></a>' )[0];
		var positives = [];
		var negatives = [];
		var results = [];
		
		for (s in [ Type('a'), Type('b'), Type('c') ]) {
			positives = positives.concat( Impl.process( html, s, false, false, html ) );
			negatives = negatives.concat( Impl.process( html, s, false, true, html ) );
		}
		
		// Manually filter as if the selector was `:not(a, b, c)` which should return `d` and `e`.
		// Cast `positives` and `results` to `NodeList` to use custom `indexOf` methods.
		for (n in negatives) if ((positives:NodeList).indexOf( n ) == -1 && (results:NodeList).indexOf( n ) == -1) results.push( n );
		
		Assert.equals( '' + ['d', 'e'], '' + results.map( function(r:dtx.mo.DOMNode) return r.nodeName ) );
		
		// Build list using `Impl.process`.
		var impl_positives = Impl.process( html, selector, false, false, html );
		var impl_negatives = Impl.process( html, selector, false, true, html );
		
		Assert.equals( '' + results.map( function(r:dtx.mo.DOMNode) return r.nodeName ), '' + impl_negatives.map( function(r:dtx.mo.DOMNode) return r.nodeName ) );
	}
	
	@:access(uhx.select.html.Impl) public function testProcess_Scope() {
		var selector = cssParse( ':scope > b' );
		
		Assert.isTrue( selector.match( Combinator( Universal, Combinator( Pseudo('scope', ''), Type('b'), Child ), None ) ) );
		
		// Manually construct and process elements. Set as `DOMNode` for simpler element navigation.
		var html:dtx.mo.DOMNode = parse( '<a id=1a><b id=1></b><c id=1c><b id=2></b><d><e id=1e><b id=3></b></e></d></c></a>' )[0];
		
		// The parent of the very first `b` element.
		var a = html;
		// The parent of the second `b` element.
		var c = html.childNodes[1];
		// The parent of the third `b` element.
		var e = c.childNodes[1].childNodes[0];
		
		// Test to make sure my manual selection is correct.
		Assert.isTrue( a.token().match(Keyword(Tag( { name:'a' } ))) );
		Assert.isTrue( c.token().match(Keyword(Tag( { name:'c' } ))) );
		Assert.isTrue( e.token().match(Keyword(Tag( { name:'e' } ))) );
		
		// Select the scope element.
		var as = Impl.process( html, Pseudo('scope', ''), false, false, a );
		var cs = Impl.process( html, Pseudo('scope', ''), false, false, c );
		var es = Impl.process( html, Pseudo('scope', ''), false, false, e );
		
		// There should only be one element returned, the scope element.
		Assert.equals( 1, as.length );
		Assert.equals( 1, cs.length );
		Assert.equals( 1, es.length );
		
		// Make sure the returned scope element is what we think it should be :P
		switch (as[0]) {
			case Keyword(Tag( { name:'a', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1a', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		
		switch (cs[0]) {
			case Keyword(Tag( { name:'c', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1c', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		
		switch (es[0]) {
			case Keyword(Tag( { name:'e', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1e', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		
		// Set parameter `scope` to `a`.
		var a_matches = Impl.process( html, selector, false, false, a );
		// Set parameter `scope` to `c`.
		var c_matches = Impl.process( html, selector, false, false, c );
		// Set parameter `scope` to `e`.
		var e_matches = Impl.process( html, selector, false, false, e );
		
		Assert.equals( 1, a_matches.length );
		Assert.equals( 1, c_matches.length );
		Assert.equals( 1, e_matches.length );
		
		switch (a_matches[0]) {
			case Keyword(Tag( { name:'b', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '1', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		
		switch (c_matches[0]) {
			case Keyword(Tag( { name:'b', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '2', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
		
		switch (e_matches[0]) {
			case Keyword(Tag( { name:'b', attributes:a } )):
				Assert.isTrue( a.exists('id') );
				Assert.equals( '3', a.get('id') );
				
			case _:
				Assert.fail();
				
		}
	}
	
	@:access(uhx.select.html.Impl) public function testProcess_Has_Expression() {
		var selector = cssParse( 'a:has(c)' );
		
		Assert.isTrue( selector.match( Combinator(Type('a'), Pseudo('has', 'c'), None) ) );
		
		// Manually construct and process elements.
		var html = parse( '<a><b></b><c></c><d></d></a>' )[0];
		var matches = Impl.process( html, Type('c'), false, false, html );
		
		Assert.equals( 1, matches.length );
		Assert.isTrue( matches.length > 0 );
		
		// Build list using `Impl.process`.
		// Descendant
		var impl = Impl.process( html, selector, false, false, html );
		
		Assert.equals( 1, impl.length );
		Assert.isTrue( impl[0].match( Keyword(Tag( { name:'a' } )) ) );
		
		// Alternative Descendant
		selector = cssParse( 'a:has( c )' );
		impl = Impl.process( html, selector, false, false, html );
		
		Assert.equals( 1, impl.length );
		Assert.isTrue( impl[0].match( Keyword(Tag( { name:'a' } )) ) );
		
		// Child
		selector = cssParse( 'a:has(> c )' );
		impl = Impl.process( html, selector, false, false, html );
		
		Assert.equals( 1, impl.length );
		Assert.isTrue( impl[0].match( Keyword(Tag( { name:'a' } )) ) );
		
		// Adjacent
		selector = cssParse( 'b:has(+ c )' );
		
		// Manual
		var manual = Impl.process( 
			html, 
			Combinator(
				Universal, 
				Combinator(
					Pseudo('scope', ''), 
					Type('c'), 
					Adjacent
				), 
				None
			), 
			false, 
			false, 
			// This is element `b` which is the scope.
			(html:dtx.mo.DOMNode).childNodes[0] 
		);
		
		Assert.equals( 1, manual.length );
		Assert.isTrue( manual[0].match( 
			Keyword(Tag( { name:'c' } ))
		) );
		
		// Automatic
		impl = Impl.process( html, selector, false, false, html );
		
		Assert.equals( 1, impl.length );
		Assert.isTrue( impl[0].match( Keyword(Tag( { name:'b' } )) ) );
	}*/
	
}