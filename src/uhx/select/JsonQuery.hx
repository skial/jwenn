package uhx.select;

import byte.ByteData;
import uhx.lexer.Css as CssLexer;
import uhx.lexer.Css.CssSelectors;
import uhx.parser.Selector as SelectorParser;

using Std;
using Type;
using Reflect;
using StringTools;
using uhx.select.JsonQuery;

private typedef Method = Dynamic->Dynamic->Array<Dynamic>->Void;

class JsonQuery {
	
	private static var engine:JsonQuery = new JsonQuery();
	
	private static inline function parse(selector:String):CssSelectors {
		return new SelectorParser().toTokens( ByteData.ofString( selector ), 'json-selector' );
	}
	
	private static function exact(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		results.push( child );
	}
	
	private static function matched(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		if (results.indexOf( parent ) == -1) {
			results.push( parent );
		}
	}
	
	private static function found(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		results.push( child );
	}
	
	private static function filter(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		//untyped console.log( results );
	}
	
	public static function find(object:Dynamic, selector:String):Array<Dynamic> {
		var selectors = selector.parse();
		var results:Array<Dynamic> = [];
		
		results = engine.process( [object], selectors, found, object );
		
		// This doesnt seem right...
		if (results.length == 1 && Std.is(results[0], Array)) {
			results = results[0];
		}
		
		return results;
	}
	
	public function new() {
		
	}
	
	private function process(objects:Array<Dynamic>, token:CssSelectors, method:Method, ?parent:Dynamic = null):Array<Dynamic> {
		var results = [];
		
		for (object in objects) {
			var isObject = object.typeof().match(TObject);
			
			switch(token) {
				case Universal:
					results.push( object );
					//method( object, object, results );
					
				case CssSelectors.Type(_.toLowerCase() => name):
					trace( name );
					
				case CssSelectors.Class(names):
					var name = names[0];
					var value:Dynamic = null;
					var obj:haxe.DynamicAccess<Dynamic> = object;
					
					for (key in obj.keys()) {
						value = obj.get( key );
						
						if (key == name) method( parent, value, results );
						
						if (value.typeof().match(TObject) || value.is(Array)) {
							var isObj = !value.is(Array);
							for (o in process((isObj) ? [value] : value, token, method, (isObj) ? obj: parent)) results.push( o );
							
						}
						
						
					}
					
				case Group(selectors): 
				
				for (selector in selectors) {
					for (o in process( [object], selector, JsonQuery.found, parent )) results.push( o );
					
				}
					
				case Combinator(current, next, type):
					// Browser css selectors are read from `right` to `left`, but this isnt a browser.
					var part1 = process( [object], current, JsonQuery.found, parent );
					
					if (part1.length == 0) continue;
					
					var part2 = switch (type) {
						case None: // Used in `type.class`, `type:pseudo` and `type[attribute]`
							process( part1, next, JsonQuery.exact, parent );
							
						case Child: //	`>`
							var results = [];
							var parents = process( [object], next, JsonQuery.matched, parent );
							
							for (parent in parents) {
								for (o in childCombinator( parent, part1 )) results.push( o );
								
							}
							
							results;
							
						case Descendant: //	` `
							//process( part1, next, method );
							//process( part1, current, method, parent );
							process( part1, next, method, parent );
							
						case Adjacent, General: //	`+`, //	`~`
							//throw 'The adjacent operator `+` is not supported on dynamic (json) objects. Use the general `~` operator instead.';
							var objs = [];
							var values = [];
							var results = [];
							
							process( [object], next, function(p, c, r) {
								objs.push( p );
								values.push( c );
							}, parent );
							
							
							for (i in 0...objs.length) {
								var fields = Reflect.fields( objs[i] );
								
								for (j in 0...fields.length-1) {
									var a = Reflect.field( objs[i], fields[j] );
									var b = Reflect.field( objs[i], fields[j + 1] );
									
									if (a == values[i] && b == part1[i]) {
										results.push( part1[i] );
									}
								}
							}
							
							results;
							
						case _:
							results;
							
					}
					
					results = results.concat( part2 );
					
				case Pseudo(_.toLowerCase() => name, _.toLowerCase() => expression):
					switch(name) {
						case 'root':
							var array = (object.is(Array)?object:[object]);
							for (a in array) method( a, a, results );
							
						case 'first-child':
							results = results.concat( nthChild( object, 0, 1 ) );
							
						case 'last-child':
							results = results.concat( nthChild( object, 0, 1, true ) );
							
						case 'nth-child':
							var a = 0;
							var b = 0;
							var n = false;
							
							switch (expression) {
								case 'odd':
									a = 2;
									b = 1;
									
								case 'even':
									a = 2;
									
								case _:
									var ab = nthValues( expression );
									a = ab[0];
									b = ab[1];
									n = expression.indexOf('-n') > -1;
									
							}
							
							var values = nthChild( object, a, b, false, n );
							results = results.concat( values );
							
						case 'has':
							var r = [];
							var e = expression.parse();
							var m = function(p, c, r) {
								r.push(p);
								
							};
							
							if (object.is(Array)) {
								r = r.concat( 
									process( object, e, m, parent )
								);
								
								if (r.length > 0) {
									results.push( parent );
								}
							}
							
							if (object.typeof().match(TObject)) for (name in object.fields()) {
								var d:Dynamic = { };
								var obj:Dynamic = object.field( name );
								Reflect.setField( d, name, obj );
								
								r = process( [obj], e, m, d );
								
								if (r.length > 0) {
									results.push( obj.typeof().match(TObject)? obj : d );
								}
							}
							
						case _:
					}
					
				case Attribute(name, type, value):
					var access:haxe.DynamicAccess<Dynamic> = object;
					trace( name, type, value );
					if (access.exists( name )) {
						var val = access.get( name );
						
						switch (type) {
							// Assume its just matching against an attribute name, not the value.
							case Unknown:
								method( object, object, results );
								
							case Exact: //	att=val
								if (value == val) method( object, object, results );
								
							case List: //	att~=val
								if (value.split(' ').indexOf( val ) > -1) method( object, object, results );
								
							case DashList: //	att|=val
								if (value.split('-').indexOf( val ) > -1) method( object, object, results );
								
							case Prefix: //	att^=val
								if (value.startsWith( val )) method( object, object, results );
								
							case Suffix: //	att$=val
								if (value.endsWith( val )) method( object, object, results );
								
							case Contains: //	att*=val
								if (value.indexOf( val ) > -1) method( object, object, results );
								
							case _:
								
						}
						
					}
					
				case _:
					
			}
			
		}
		
		return results;
	}
	
	private function nthChild(object:Dynamic, a:Int, b:Int, reverse:Bool = false, neg:Bool = false):Array<Dynamic> {
		var results = [];
		var fields = object.fields();
		
		for (i in 0...fields.length) {
			var obj:Dynamic = object.field( fields[i] );
			
			if (obj.typeof().match(TObject)) {
				var values = nthChild( obj, a, b, reverse, neg );
				results = results.concat( values );
				
			} else if (obj.is(Array)) {
				var n = 0;
				var len = (obj:Array<Dynamic>).length;
				var idx = (a * (neg? -n : n)) + b - 1;
				var values = [];
				
				if (reverse) {
					obj = (obj:Array<Dynamic>).copy();
					(obj:Array<Dynamic>).reverse();
				}
				
				while ( n < len && idx < len ) {
					if (idx > -1) {
						values.push( obj[idx] );
					}
					
					if (a == 0 && !neg) break;
					
					n++;
					idx = (a == 0 && neg? -n:(a * (neg? -n : n))) + b - 1;
				}
				
				if (values.length > 0) {
					if (neg) values.reverse();
					results = results.concat( values );
				}
				
			}
		}
		
		return results;
	}
	
	private function nthValues(expr:String):Array<Int> {
		var results:Array<Int> = [];
		
		if (expr.indexOf('n') > -1) {
			for (s in expr.split('n')) {
				results = results.concat( nthValues( s ) );
			}
		}
		
		if (results.length < 2) {
			
			var code = 0;
			var index = 0;
			var value = '0';
			var isFalse = false;
			
			while (index < expr.length) {
				code = expr.charCodeAt( index );
				
				switch (code) {
					case '-'.code: isFalse = true;
					case '+'.code: isFalse = false;
					case x if (x >= '0'.code && x <= '9'.code):
						value += String.fromCharCode( x );
						
					case _:
				}
				
				index++;
			}
			
			results.push( isFalse ? -Std.parseInt( value ) : Std.parseInt( value ) );
			
		}
		
		return results;
	}
	
	private function childCombinator(object:Dynamic, values:Array<Dynamic>):Array<Dynamic> {
		var results = [];
		
		if (object.is(Array)) for (o in (object:Array<Dynamic>)) {
			results = results.concat( childCombinator( o, values ) );
		}
		
		if (object.typeof().match(TObject)) for (name in object.fields()) {
			for (v in values) if (object.field( name ) == v) {
				results.push( v );
				values.remove( v );
				break;
			}
		}
		
		return results;
	}
	
}
