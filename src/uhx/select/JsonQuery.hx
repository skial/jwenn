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
	
	@:from public static function fromDynamic<T>(v:Dynamic):DA<T, DynamicAccess<T>, Array<String>> {
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
- [x] `:root`
- [x] `:nth-child(even)`
- [x] `:nth-child(odd)`
- [x] `:nth-child(n)`
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
	
	private static function exact(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		results.push( value );
	}
	
	private static function matched(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		if (results.indexOf( parent ) == -1) results.push( parent );
	}
	
	private static function found(key:Key, index:Index, value:Value, parent:Parent, results:Results):Void {
		results.push( value );
	}
	
	private static function track(key:Key, index:Index, value:Value, parent:Parent, results:Results, indexes:Indexes, method:Method):Void {
		indexes.push( {key:key, index:index, parent:parent} );
		method( key, index, value, parent, results );
	}
	
	
	public static function find(object:Dynamic, selector:String):Array<Dynamic> {
		var selectors = selector.parse();
		
		var results:Array<Dynamic> = [];
		
		if (selectors == null) return results;
		
		engine.original = object;
		var da = DA.fromDynamic(object);
		results = engine.process( cast da, selectors, found, object );
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
		
		var isArray = object.self.is(Array);
		var isObject = object.self.typeof().match(TObject);
		
		if (isArray || isObject) {
			var asArray:Array<DynamicAccess<Any>> = isArray ? cast object.self : [];
			
			switch(token) {
				case Universal:
						passable = true;
						method('', -1, object.self, parent, results);
					
				case CssSelectors.Type(_.toLowerCase() => name):
						passable = true;
						var value:Any = null;
						if (isObject) for (i in 0...object.keys().length) {
							var key = object.keys()[i];
							
							switch [name, (value = object.get(key)).typeof()] {
								case ['int', TInt]:
									method( key, i, value, parent, results );
									
								case ['float', TFloat]:
									method( key, i, value, parent, results );
									
								case ['bool', TBool]:
									method( key, i, value, parent, results );
									
								case ['object', TObject]:
									method( key, i, value, parent, results );
									
								case ['string', TClass(String)]:
									method( key, i, value, parent, results );
									
								case ['array', TClass(Array)]:
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
							
							if (name == cast key) method( key, i, value, parent, results );
							
						}
					
				case Group(selectors): 
						for (selector in selectors) {
							for (o in process( object, selector, JsonQuery.found, parent )) {
								method( '', -1, o, parent, results );
								
							}
							
						}
					
				case Combinator(current, next, type):
					var indexes = [];
					var m = JsonQuery.track.bind(_, _, _, _, _, _, method);
					// Browser css selectors are read from `right` to `left`, but this isnt a browser.
					var part1 = process( object, current, m.bind(_, _, _, _, _, indexes), parent );
					
					if (part1.length != 0) {
						var part2 = switch (type) {
							case None: // Used in `type.class`, `type:pseudo` and `type[attribute]`
								var r = [];
								for (value in part1) for (result in process( cast DA.fromDynamicAccess(value), next, JsonQuery.exact, parent )) r.push( result );
								r;
								
							case Child: //	`>`
								var r = [];
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
						
					}
					
				case Pseudo(name, expression):
						switch(name.toLowerCase()) {
							case 'scope':
								var array = (original.is(Array)?original:[original]);
								for (a in array) results.push( a );
								
							case 'root':
								if (isObject) if (object.self == original) method( '', -1, object.self, object.self, results );
								
							case 'first-child':
								if (!isArray) {
									results = results.concat( cast nthChild( object, 0, 1, isObject, isArray ) );
									
								} else {
									var v:Array<DynamicAccess<Any>> = cast object;
									results.push( cast v[0] );
									
								}
								
							case 'last-child':
								if (!isArray) {
									results = results.concat( cast nthChild( object, 0, 1, isObject, isArray, true ) );
									
								} else {
									var v:Array<DynamicAccess<Any>> = cast object;
									results.push( cast v[v.length - 1] );
									
								}
								
							case 'nth-child':
								// @see https://www.w3.org/TR/css3-selectors/#nth-child-pseudo
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
										switch ab.length {
											case 1:
												b = ab[0];
												
											case _:
												a = ab[0] > 0 ? ab[0] : 1;
												b = ab[1] != null ? ab[1] : b;
												
										}
										n = expression.indexOf('-n') > -1;
										
								}
								
								if (a > 0) {
									var values = nthChild( object, a, b, isObject, isArray, false, n );
									results = results.concat( values );
									
								} else if (b > 0) {
									// single value `:nth-child(5)`
									results.push( object.get( object.keys()[b-1] ) );
									
								}
								
							case 'has', 'not':	// TODO test `:not`
								var expression = expression.parse();
								var method = function(p, c, r) {
									r.push(p);
									
								};
								var matches = process( object, expression, JsonQuery.matched, parent );
								var condition = name == 'has' ? function(v) return v.length > 0 : function(v) return v.length == 0;
								
								trace( matches );
								
								if (condition(matches)) results.push( object );
								
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
						
						switch type {
							// Assume its just matching against an attribute name, not the value.
							case Unknown:
								method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
								
							case Exact: //	att=val
								if (isValArray && asValArray.length == 1 && asValArray[0] == value) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								} else if (val == value) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								}
								
							case List: //	att~=val
								if (isValArray && asValArray.indexOf( arrayType.match(TInt) ? Std.parseInt(value) : value ) > -1) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								} else if (isValString && asValString.indexOf( value ) > -1) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								}
								
							case DashList: //	att|=val
								if (isValString && asValString.split('-').indexOf( value ) > -1) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								}
								
							case Prefix: //	att^=val
								if (isValString && asValString.startsWith( value )) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								} else if (isValArray && asValArray[0] == (arrayType.match(TInt) ? Std.parseInt(value) : value)) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								}
								
							case Suffix: //	att$=val
								if (isValString && asValString.endsWith( value )) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								} else if (isValArray && asValArray[asValArray.length -1] == (arrayType.match(TInt) ? Std.parseInt(value) : value)) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								}
								
							case Contains: //	att*=val
								if (isValArray && asValArray.indexOf( (arrayType.match(TInt) ? Std.parseInt(value) : value) ) > -1) {
									method( cast name, object.keys().indexOf(cast name), object.self, object.self, results );
									
								} else if (isValString && asValString.indexOf( value ) > -1) {
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
		
		return cast results;
	}
	
	private function nthChild(object:DA<Any, Dynamic, Array<Any>>, a:Int, b:Int, isObject:Bool, isArray:Bool, reverse:Bool = false, neg:Bool = false):Array<Any> {
		var results = [];
		var length = object.keys().length;
		
		//trace(a, b, neg, reverse, length );
		
		for (n in 0...length) {
			var idx = (a * (neg ? -n : n)) + b;
			//trace( 'a = $a', 'n = ' +(neg ? -n : n), 'b = $b', 'calc = ' + (a * (neg ? -n : n)), 'idx = $idx' );
			idx--;
			if (idx > -1 && idx < length) {
				results.push( object.get( object.keys()[idx] ) );
				
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
