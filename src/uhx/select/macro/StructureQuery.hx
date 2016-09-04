package uhx.select.macro;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

import byte.ByteData;
import uhx.lexer.Css as CssLexer;
import uhx.lexer.Css.CssSelectors;
import uhx.parser.Selector as SelectorParser;

using Reflect;
using StringTools;
using haxe.macro.ExprTools;
using uhx.select.macro.StructureQuery;

typedef QueryField = {name:String, type:Type, pos:Position, children:Array<QueryField>};

class StructureQuery {
	
	public static var engine:StructureQuery = new StructureQuery();
	
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
	
	public static macro function find(object:Expr, selector:String):ExprOf<Array<{}>> {
		var results = [];
		var final = macro @:pos(object.pos) uhx.select.JsonQuery.find( $object, $v{selector} );
		
		try {
			var type = Context.typeof(object);
			var token = selector.parse();
			trace( token );
			var searchResults:Array<QueryField> = [];
			
			for (field in engine.asQueryFields( type )) {
				var res = engine.process( field, token, StructureQuery.found );
				if (res != null) searchResults.push( res );
			}
			
			trace( searchResults );
			
			if (searchResults.length > 0) {
				final = object;
				
				function loop(obj:QueryField, expr:Expr) {
					var name = obj.name;
					expr = macro @:pos(object.pos) $expr.$name;
					for (child in obj.children) loop( child, expr.copy() );
					if (obj.children.length == 0) results.push( expr.copy() );
					
				}
				
				for (result in searchResults) {
					loop( result, final.copy() );
					
				}
				
			}
			
			if (Context.defined('debug')) {
				trace( results.map( function(r) return r.toString() ) );
				
			}
			
		} catch (e:Dynamic) {
			Context.warning( 'Unable to determine type of expression passed into ::find([object], "$selector").', object.pos );
			
		}
		
		return macro [$a{results}];
	}
	
	public function new() {
		
	}
	
	#if macro
	public function asQueryFields(type:Type):Array<QueryField> {
		return switch type {
			case TAnonymous(_.get() => a): 
				var fields = [];
				
				for (field in a.fields) 
					fields.push( { name:field.name, type:field.type, pos:field.pos, children:[] } );
					
				fields;
					
			case _: [];
		}
	}
	
	public function processType(type:Type, token:CssSelectors, ?parent:QueryField = null, ?constraint:Type = null):Array<QueryField> {
		trace( token );
		return switch type {
			case TAnonymous(_.get() => a): 
				var results = [];
				
				for (field in a.fields) {
					var obj = process( { name:field.name, type:field.type, pos:field.pos, children:[] } , token, found, parent, constraint );
					if (obj != null) results.push( obj );
					
				}
						
				results;
				
			case _: 
				trace( type );
				[];
		}
	}
	
	public function process(object:QueryField, token:CssSelectors, method:Dynamic, ?parent:QueryField = null, ?constraint:Type = null):Null<QueryField> {
		trace( object );
		var results = null;
		
		//for (object in objects) {
			switch token {
				case Universal:
					
				case CssSelectors.Type(name):
					try {
						var localType:Null<Type> = (constraint == null) ? Context.getType( name ) : constraint;
						if (Context.unify(object.type, localType)) results = object;
						
						for (o in processType( object.type, token, object, localType )) object.children.push( o );
						
					} catch (e:Dynamic) {
						for (o in processType( object.type, token, object )) object.children.push( o );
						
					}
					
				case CssSelectors.Class(names):
					if (object.name == names[0]) {
						trace( object.name, object );
						if (names.length > 1) Context.warning( 'Trying to match against .${names.join('.')} is not supported, only .${names[0]} will be attempted.', object.pos );
							
						results = object;
					
					}
					
					for (o in processType( object.type, token, object, constraint )) object.children.push( o );
					
				case Group(selectors): 
					
				case Combinator(current, next, type):
					var part1 = process( object, current, StructureQuery.found, parent, constraint );
					//if (part1.length == 0) continue;
					
					//for (o in part1) results.push( o );
					
					var part2 = switch (type) {
						case None: // Used in `type.class`, `type:pseudo` and `type[attribute]`
							[];
							
						case Child: //	`>`
							[];
							
						case Descendant: //	` `
							[];
							
						case Adjacent, General: //	`+`, //	`~`
							[];
							
						case _:
							[];
							
					}
					
					/*if (part2.length > 0) results.push( object );
					for (o in part2) results.push( o );*/
						
				case Pseudo(_.toLowerCase() => name, _.toLowerCase() => expression):
					
				case Attribute(name, type, value):
					var access:haxe.DynamicAccess<Dynamic> = cast object;
					
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
			
		//}
		trace( parent, results );
		if (results == null && object.children.length > 0) results = object;
		
		return results;
	}
	#end

}
