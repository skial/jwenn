package uhx.select;

import byte.ByteData;
import haxe.DynamicAccess;
import uhx.lexer.Css as CssLexer;
import uhx.lexer.Css.CssSelectors;
import uhx.parser.Selector as SelectorParser;

using Std;
using Type;
using Reflect;
using StringTools;
using uhx.select.JsonQuery;

abstract DA<T, O, K>({iterator:Void->Iterator<T>, self:O, keys:Array<K>, get:K->T, exists:K->Bool}) {
	
	public var self(get, never):O;
	
	public #if !debug inline #end function get_self():O {
		return this.self;
	}
	
	//
	
	public #if !debug inline #end function new(v) this = v;
	
	public #if !debug inline #end function keys():Array<K> {
		return this.keys;
	}
	
	public #if !debug inline #end function get(key:K):T {
		return this.get(key);
	}
	
	public #if !debug inline #end function exists(key:K):Bool {
		return this.exists(key);
	}
	
	// to
	
	@:to public #if !debug inline #end function toIterator():Iterator<T> {
		return this.iterator();
	}
	
	// from
	
	@:from public static function fromArray<T>(v:Array<T>):DA<T, Array<T>, Array<Int>> {
		return new DA( cast new ArrayWrapper( v ) );
	}
	
	@:from public static function fromDynamicAccess<T>(v:DynamicAccess<T>):DA<T, DynamicAccess<T>, Array<String>> {
		return new DA( cast new DynamicAccessWrapper(v) );
	}
	
	@:from public static function fromDynamic<T>(v:Dynamic):DA<T, Dynamic, Array<String>> {
		return new DA( cast new DynamicAccessWrapper(v) );
	}
	
}

private class DynamicAccessWrapper<T> {
	
	private var index = 0;
	public var length = 0;
	public var keys:Array<String>;
	public var self:DynamicAccess<T>;
	
	public #if !debug inline #end function new(da:DynamicAccess<T>) {
		self = da;
		keys = self.keys();
		length = keys.length;
	}
	
	public #if !debug inline #end function iterator():Iterator<T> {
		index = 0;
		return {
			hasNext: this.hasNext,
			next: this.next,
		}
	}
	
	public #if !debug inline #end function get(key:String):T {
		return self.get(key);
	}
	
	public #if !debug inline #end function exists(key:String):Bool {
		return self.exists(key);
	}
	
	public #if !debug inline #end function hasNext():Bool {
		return index < length;
	}
	
	public #if !debug inline #end function next():T {
		var r = self[keys[index]];
		index++;
		return r;
	}
	
}

private class ArrayWrapper<T> {
	
	public var length:Int;
	public var self:Array<T>;
	public var keys:Array<Int>;
	
	public #if !debug inline #end function new(v:Array<T>) {
		self = v;
		keys = [for (i in 0...(length = self.length)) i];
	}
	
	public #if !debug inline #end function iterator():Iterator<T> {
		return self.iterator();
	}
	
	public #if !debug inline #end function get(key:Int):T {
		return self[key];
	}
	
	public #if !debug inline #end function exists(key:Int):Bool {
		return self[key] != null;
	}
	
}

private typedef Key = Any;
private typedef Value = Any;
private typedef Index = Int;
private typedef Parent = Any;
private typedef Results = Array<Any>;
private typedef Method = Key->Index->Value->Parent->Results->Void;
private typedef Indexes = Array<{key:Key, parent:Parent, index:Index}>;

/**
 * ...
 * @author Skial Bainn
 * ---
- [x] `*`
- [-] `#id`
- [x] `.class`
- [o] `type`
- [x] `type, type`
- [x] `type ~ type`
- [x] `type + type`
- [x] `type type`
- [x] `type > type`
- [x] `[name]`
- [x] `[name="value"]`
- [x] `[name*="value"]`
- [x] `[name^="value"]`
- [x] `[name$="value"]`
- [x] `[name~="value"]`
- [x] `[name|="value"]`
- [x] `[attr1=value][attr2|="123"][attr3*="bob"]`
# Level 2 - http://www.w3.org/TR/CSS21/selector.html
- [ ] `:custom-pseudo`
- [ ] `:first-child`
- [-] `:link`
- [-] `:visited`
- [-] `:hover`
- [-] `:active`
- [-] `:focus`
- [-] `:lang`
- [-] `:first-line`
- [-] `:first-letter`
- [ ] `:before`
- [ ] `:after`
# Level 3 - http://www.w3.org/TR/css3-selectors/
- [-] `:target`
- [-] `:enabled`
- [-] `:disabled`
- [-] `:checked`
- [-] `:indeterminate`
- [ ] `:root`
- [ ] `:nth-child(even)`
- [ ] `:nth-child(odd)`
- [ ] `:nth-child(n)`
- [ ] `:nth-last-child`
- [ ] `:nth-of-type`
- [ ] `:nth-last-of-type`
- [ ] `:last-child`
- [ ] `:first-of-type`
- [ ] `:last-of-type`
- [ ] `:only-child`
- [ ] `:only-of-type`
- [ ] `:empty`
- [ ] `:not(selector)`
# Level 4 - http://dev.w3.org/csswg/selectors4/
- [ ] `:matches`
- [ ] `:has`
- [ ] `:any-link`
- [ ] `:scope`
- [-] `:drop`
- [ ] `:current`
- [ ] `:past`
- [ ] `:future`
- [-] `:read-only`
- [-] `:read-write`
- [-] `:placeholder-shown`
- [-] `:default`
- [-] `:valid`
- [-] `:invalid`
- [ ] `:in-range`
- [ ] `:out-range`
- [-] `:required`
- [-] `:optional`
- [-] `:user-error`
- [-] `:blank`
 * ---
 */
class JsonQuery {
	
	private static var engine:JsonQuery = new JsonQuery();
	
	private static inline function parse(selector:String):CssSelectors {
		return new SelectorParser().toTokens( ByteData.ofString( selector ), 'json-selector' );
	}
	
	/*private static function exact(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		results.push( child );
	}*/
	private static function exact(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		results.push( value );
	}
	
	/*private static function matched(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		if (results.indexOf( parent ) == -1) {
			results.push( parent );
		}
	}*/
	private static function matched(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		if (results.indexOf( parent ) == -1) results.push( parent );
	}
	
	/*private static function found(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		results.push( child );
	}*/
	private static function found(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		results.push( value );
	}
	
	private static function track(key:Key, index:Index, value:Value, parent:Parent, results:Results, indexes:Indexes, method:Method):Void {
		indexes.push( {key:key, index:index, parent:parent} );
		method( key, index, value, parent, results );
	}
	
	/*private static function filter(parent:Dynamic, child:Dynamic, results:Array<Dynamic>) {
		//untyped console.log( results );
	}*/
	
	public static function find(object:Dynamic, selector:String):Array<Dynamic> {
		var selectors = selector.parse();
		
		var results:Array<Dynamic> = [];
		
		if (selectors == null) return results;
		
		engine.original = object;
		results = engine.process( cast DA.fromDynamicAccess(object), selectors, found, object );
		engine.original = null;
		
		// This doesnt seem right...
		if (results.length == 1 && Std.is(results[0], Array)) {
			results = results[0];
			
		}
		
		return results;
	}
	
	public var original:Dynamic = null;
	
	public function new() {
		
	}
	
	private function process(object:DA<Any, Dynamic, Array<Any>>, token:CssSelectors, method:Method, ?parent:DynamicAccess<Any> = null):Array<DynamicAccess<Any>> {
		var results = [];
		var passable = false;
		
		//for (object in objects) {
			var isArray = object.self.is(Array);
			var isObject = object.self.typeof().match(TObject);
			
			if (isArray || isObject) {
				var asArray:Array<DynamicAccess<Any>> = isArray ? cast object.self : [];
				
				switch(token) {
					case Universal:
						passable = true;
						//method(parent, object.self, results);
						method('', -1, object.self, parent, results);
						
					case CssSelectors.Type(_.toLowerCase() => name):
						passable = true;
						var value:Any = null;
						if (isObject) for (i in 0...object.keys().length) {
							var key = object.keys()[i];
							//trace( name, key, object, asObject.get(key), asObject.get(key).typeof() );
							switch [name, (value = object.get(key)).typeof()] {
								case ['int', TInt]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case ['float', TFloat]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case ['bool', TBool]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case ['object', TObject]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case ['string', TClass(String)]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case ['array', TClass(Array)]:
									//method(parent, value, results);
									method( key, i, value, parent, results );
									
								case _:
								
							}
							
						}
						
					case CssSelectors.Class(names):
						var name = names[0];
						var value:String = null;
						passable = true;
						
						if (isObject) for (i in 0...object.keys().length) {
							var key = object.keys()[i];
							value = object.get( key );
							
							//if (name == cast key) method(parent, value, results);
							if (name == cast key) method( key, i, value, parent, results );
							
						}
						
					case Group(selectors): 
						for (selector in selectors) {
							for (o in process( object, selector, JsonQuery.found, parent )) {
								//method(parent, o, results);
								method( '', -1, o, parent, results );
								
							}
							
						}
						
					case Combinator(current, next, type):
						var indexes = [];
						var m = JsonQuery.track.bind(_, _, _, _, _, _, method);
						// Browser css selectors are read from `right` to `left`, but this isnt a browser.
						var part1 = process( object, current, m.bind(_, _, _, _, _, indexes), parent );
						
						//if (part1.length == 0) continue;
						var part2 = switch (type) {
							case None: // Used in `type.class`, `type:pseudo` and `type[attribute]`
								process( cast DA.fromArray(part1), next, JsonQuery.exact, parent );
								
							case Child: //	`>`
								var r = [];
								//var m = function(p, v, r) if (p == object.self) r.push(v);
								var m = function(k, i, v, p, r) if (p == object.self) r.push( v );
								
								for (value in part1) for (result in process( cast DA.fromDynamicAccess(value), next, m, object.self )) r.push( result );
								r;
								
							case Descendant: //	` `
								var r = [];
								for (value in part1) for (result in process( cast DA.fromDynamicAccess(value), next, method, parent )) r.push( result );
								r;
								
							case Adjacent: //	`+`
								var r = [];
								var idxs = [];
								
								for (result in process( object, next, m.bind(_, _, _, _, _, idxs), object.self )) r.push( result );
								
								[for (i in 0...r.length) {
									if (indexes[0].parent == idxs[i].parent && idxs[i].index - indexes[0].index == 1) r[i];
									
								}];
								
							case General: //	`~`
								var r = [];
								var idxs = [];
								
								for (result in process( object, next, m.bind(_, _, _, _, _, idxs), object.self )) r.push( result );
								
								[for (i in 0...r.length) {
									if (indexes[0].parent == idxs[i].parent && idxs[i].index > indexes[0].index) r[i];
									
								}];
								
							case _:
								[];
								
						}
						
						results = results.concat( cast part2 );
						
					case Pseudo(name, expression):
						switch(name.toLowerCase()) {
							case 'scope':
								var array = (original.is(Array)?original:[original]);
								for (a in array) results.push( a );
								
							case 'root':
								var array:Array<DynamicAccess<Any>> = (isArray ? cast object : cast [object]);
								//for (a in array) method( a, a, results );
								for (a in array) method( '', -1, a, a, results );
								
							case 'first-child':
								if (!isArray) {
									results = results.concat( cast nthChild( cast object, 0, 1 ) );
									
								} else {
									var v:Array<DynamicAccess<Any>> = cast object;
									results.push( cast v[0] );
									
								}
								
							case 'last-child':
								if (!isArray) {
									results = results.concat( cast nthChild( cast object, 0, 1, true ) );
									
								} else {
									var v:Array<DynamicAccess<Any>> = cast object;
									results.push( cast v[v.length - 1] );
									
								}
								
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
								
								var values = nthChild( cast object, a, b, false, n );
								results = results.concat( cast values );
								
							case 'has', 'not':	// TODO test `:not`
								var expression = expression.parse();
								var method = function(p, c, r) {
									r.push(p);
									
								};
								var matches = process( object, expression, JsonQuery.matched, parent );
								var condition = name == 'has' ? function(v) return v.length > 0 : function(v) return v.length == 0;
								
								trace( matches );
								
								if (condition(matches)) results.push( object );
								
							case 'empty':
								
								
							case _:
						}
						
					case Attribute(name, type, value):
						if (isArray) passable = true;
						if (isObject && object.exists( cast name )) {
							var val = object.get( cast name );
							var isValObject = val.typeof().match(TObject);
							var isValArray = val.is(Array);
							var isValString = val.is(String);
							var asValArray:Array<Any> = isValArray ? cast val : [];
							var asValString:String = isValString ? cast val : '';
							
							isValArray = asValArray.length > 0;
							
							var arrayType = isValArray ? asValArray[0].typeof() : TUnknown;
							
							//isValArray = isValArray && (arrayType.match(TInt) || arrayType.match(TClass(String)));
							
							switch type {
								// Assume its just matching against an attribute name, not the value.
								case Unknown:
									//method( object.self, object.self, results );
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								case Exact: //	att=val
									//if (value == val) method( object, object, results );
									if (isValArray && asValArray.length == 1 && asValArray[0] == value) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									} else if (val == value) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									
								case List: //	att~=val
									if (isValArray && asValArray.indexOf( arrayType.match(TInt) ? Std.parseInt(value) : value ) > -1) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									} else if (isValString && asValString.indexOf( value ) > -1) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									//if (value.split(' ').indexOf( val ) > -1) method( object, object, results );
									
								case DashList: //	att|=val
									if (isValString && asValString.split('-').indexOf( value ) > -1) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									
								case Prefix: //	att^=val
									if (isValString && asValString.startsWith( value )) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									} else if (isValArray && asValArray[0] == (arrayType.match(TInt) ? Std.parseInt(value) : value)) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									
								case Suffix: //	att$=val
									if (isValString && asValString.endsWith( value )) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									} else if (isValArray && asValArray[asValArray.length -1] == (arrayType.match(TInt) ? Std.parseInt(value) : value)) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									
								case Contains: //	att*=val
									if (isValArray && asValArray.indexOf( (arrayType.match(TInt) ? Std.parseInt(value) : value) ) > -1) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									} else if (isValString && asValString.indexOf( value ) > -1) {
										//method( object.self, object.self, results );
										method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
										
									}
									
								case _:
									
							}
							
						}
						
					case _:
						
				}
				
				if (passable) for (o in object) {	
					var isArray = o.is(Array);
					var isObject = o.typeof().match(TObject);
					var asArray:Array<Any> = isArray ? cast o : [];
					
					if (isArray || isObject) {
						var da:DA<Any, Dynamic, Array<Any>> = isArray ? cast DA.fromArray(asArray) : isObject ? cast DA.fromDynamicAccess(cast o) : cast DA.fromDynamic(cast o);
						
						for (result in process( da, token, method, object.self ) ) {
							results.push( cast result );
							
						}
						
					}
					
				}
				
			}
			
		//}
		
		return cast results;
	}
	
	private function nthChild(object:DynamicAccess<Any>, a:Int, b:Int, reverse:Bool = false, neg:Bool = false):Array<DynamicAccess<Any>> {
		var results = [];
		var fields = object.fields();
		
		if (object.typeof().match(TObject)) for (i in 0...fields.length) {
			var obj:Dynamic = object.field( fields[i] );
			
			if (obj.typeof().match(TObject)) {
				var values = nthChild( obj, a, b, reverse, neg );
				results = results.concat( values );
				
			} else if (obj.is(Array)) {
				var n = 0;
				var len = (obj:Array<Any>).length;
				var idx = (a * (neg? -n : n)) + b - 1;
				var values = [];
				
				if (reverse) {
					obj = (obj:Array<Any>).copy();
					(obj:Array<Any>).reverse();
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
			
		} else if (Std.is(object,Array)) {
			var array:Array<Any> = cast object;
			var n = 0;
			var len = array.length;
			var idx = (a * (neg? -n : n)) + b - 1;
			var values:Array<DynamicAccess<Any>> = [];
			
			if (reverse) {
				array = array.copy();
				array.reverse();
			}
			
			while ( n < len && idx < len ) {
				if (idx > -1) {
					values.push( array[idx] );
				}
				
				n++;
				idx++;
			}
			
			if (values.length > 0) {
				if (neg) values.reverse();
				results = results.concat( values );
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
