package uhx.jwenn;

import uhx.select.*;
import utest.Assert;

@:keep
class JsonQuerySpec {
	
	public function new() {
		
	}
	
	public function testUniveral_singleValue() {
		var data = { a:'b' };
		var results = JsonQuery.find( data, '*' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testUniveral_arrayValue() {
		var data = ['a', 'b'];
		var results = JsonQuery.find( data, '*' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + data, '' + results );
	}
	
	public function testUniveral_nestedStruct() {
		var data = { a:{ b:{ c:[1, 2, 3] }, d:[4, 5, 6] } };
		var results = JsonQuery.find( data, '*' );
		
		Assert.equals( 5, results.length );
		Assert.equals( '' + ([data, data.a, data.a.b, data.a.b.c, data.a.d]:Array<Any>), '' + results );
	}
	
	public function testClass_singleValue() {
		var data = { a:'b' };
		var results = JsonQuery.find( data, '.a' );
		
		Assert.equals( 1, results.length );
		Assert.equals( 'b', '' + results[0] );
	}
	
	public function testClass_nestedValues() {
		var data = { 
			a:{ 
				b:{ 
					c:[1, 2, 3] 
				} 
			}, 
			c:[4, 5, 6] 
		};
		var results = JsonQuery.find( data, '.c' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [[4, 5, 6], [1, 2, 3]], '' + results );
	}
	
	public function testType_singleConstValue() {
		var data = { a:'b' };
		var results = JsonQuery.find( data, 'string' );
		
		Assert.equals( 1, results.length );
		Assert.equals( 'b', '' + results[0] );
	}
	
	public function testType_multipleConstValue() {
		var data = { a:'b', b:'c', c:1, d:2,  };
		var results = JsonQuery.find( data, 'string' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + ['b', 'c'], '' + results );
	}
	
	public function testType_nestedConstValues() {
		var data = { 
			a:{ 
				b:{ 
					c:[1, 2, 3] 
				} 
			}, 
			c:[4, 5, 6] 
		};
		var results = JsonQuery.find( data, 'array' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [[4, 5, 6], [1, 2, 3]], '' + results );
	}
	
	public function testAttribute_singleValue_byName() {
		var data = { a:'b' };
		var results = JsonQuery.find( data, '[a]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_nestedValue_byName() {
		var data = { a:'b', b:{ a:'c' }, c:{ a:'d' } };
		var results = JsonQuery.find( data, '[a]' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + ([data, data.b, data.c]:Array<Any>), '' + results );
	}
	
	public function testAttribute_singleValue_exact() {
		var data = { a:'b' };
		var results = JsonQuery.find( data, '[a=b]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_nestedValue_exact() {
		var data = { a:'b', b:{ a:'c' }, c:{ a:'d' } };
		var results = JsonQuery.find( data, '[a=b]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_nestedValue_multiple() {
		var data = { a:'b', b:{ a:'c' }, c:{ a:'d' } };
		var results = JsonQuery.find( data, '[a=b][c]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_nestedValue_multipleExact() {
		var data = { a:'b', b:{ a:'c' }, c:'d' };
		var results = JsonQuery.find( data, '[a=b][c="d"]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringList() {
		var data = { a:'1 2 3' };
		var results = JsonQuery.find( data, '[a~=2]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_arrayStringList() {
		var data = { a:['1', '2', '3'] };
		var results = JsonQuery.find( data, '[a~=2]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_arrayIntList() {
		var data = { a:[1, 2, 3] };
		var results = JsonQuery.find( data, '[a~=2]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringDashList() {
		var data = { a:'1-2-3' };
		var results = JsonQuery.find( data, '[a|=2]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringPrefix() {
		var data = { a:'abc' };
		var results = JsonQuery.find( data, '[a^=a]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringArrayPrefix() {
		var data = { a:['a', 'b', 'c'] };
		var results = JsonQuery.find( data, '[a^=a]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_IntArrayPrefix() {
		var data = { a:[1, 2, 3] };
		var results = JsonQuery.find( data, '[a^=1]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringSuffix() {
		var data = { a:'abc' };
		var results = JsonQuery.find( data, '[a$=c]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringArraySuffix() {
		var data = { a:['a', 'b', 'c'] };
		var results = JsonQuery.find( data, '[a$=c]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_IntArraySuffix() {
		var data = { a:[1, 2, 3] };
		var results = JsonQuery.find( data, '[a$=3]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringContains() {
		var data = { a:'abc' };
		var results = JsonQuery.find( data, '[a*=b]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_stringArrayContains() {
		var data = { a:['a', 'b', 'c'] };
		var results = JsonQuery.find( data, '[a*=b]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testAttribute_singleValue_IntArrayContains() {
		var data = { a:[1, 2, 3] };
		var results = JsonQuery.find( data, '[a*=2]' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testGroup() {
		var data = { a:1, b:{ c:2 }, c:3 };
		var results = JsonQuery.find( data, '.b, .c' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + ([data.b, data.c, data.b.c]:Array<Any>), '' + results );
	}
	
	public function testCombinator_descendant() {
		var data = { a: { b: { c:1 } } };
		var results = JsonQuery.find( data, '.a .b .c' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.a.b.c, '' + results[0] );
	}
	
	public function testCombinator_descendant_skipSelector() {
		var data = { a: { b: { c:1 } } };
		var results = JsonQuery.find( data, '.a .c' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.a.b.c, '' + results[0] );
	}
	
	public function testCombinator_child() {
		var data = { a: { b: { b:1 } } };
		var results = JsonQuery.find( data, '.a > .b' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.a.b, '' + results[0] );
	}
	
	public function testCombinator_adjacent() {
		var data = { a:1, b:2, c:3, d:4 };
		var results = JsonQuery.find( data, '.a + .b' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.b, '' + results[0] );
	}
	
	public function testCombinator_adjacent_multiple() {
		var data = { a:1, b:2, c:{ b:3 }, d:{ b:4 } };
		var results = JsonQuery.find( data, '.a + .b' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.b, '' + results[0] );
	}
	
	public function testCombinator_general() {
		var data = { a:1, b:2, c:3, d:4 };
		var results = JsonQuery.find( data, '.a ~ .c' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.c, '' + results[0] );
	}
	
	public function testCombinator_general_multiple() {
		var data = { a:1, b:{ c:2 }, c:3, d:{ c:4 } };
		var results = JsonQuery.find( data, '.a ~ .c' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.c, '' + results[0] );
	}
	
	public function testPseudo_root() {
		var data = { a:1, b:2 };
		var results = JsonQuery.find( data, ':root' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data, '' + results[0] );
	}
	
	public function testPseudo_nthChild_everyThirdItem() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(3n+3)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.c, '' + results[0] );
	}
	
	public function testPseudo_nthChild_everyThirdItem_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(3n+3)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data[2], '' + results[0] );
	}
	
	public function testPseudo_nthChild_everyThirdItem_simple() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(3n)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.c, '' + results[0] );
	}
	
	public function testPseudo_nthChild_everyThirdItem_simple_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(3n)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data[2], '' + results[0] );
	}
	
	public function testPseudo_nthChild_everyItem_reversed() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(-n+3)' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + [data.c, data.b, data.a], '' + results );
	}
	
	public function testPseudo_nthChild_everyItem_reversed_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(-n+3)' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + [3, 2, 1], '' + results );
	}
	
	public function testPseudo_nthChild_odd() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(odd)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [data.a, data.c], '' + results );
	}
	
	public function testPseudo_nthChild_odd_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(odd)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [1, 3], '' + results );
	}
	
	public function testPseudo_nthChild_even() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(even)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.b, '' + results[0] );
	}
	
	public function testPseudo_nthChild_even_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(even)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '2', '' + results[0] );
	}
	
	public function testPseudo_nthChild_first() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.a, '' + results[0] );
	}
	
	public function testPseudo_nthChild_first_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [1], '' + results );
	}
	
	public function testPseudo_nthChild_lastTwo() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(n+2)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [data.b, data.c], '' + results );
	}
	
	public function testPseudo_nthChild_lastTwo_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(n+2)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [2, 3], '' + results );
	}
	
	public function testPseudo_nthChild_firstTwo() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(-n+2)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [data.b, data.a], '' + results );
	}
	
	public function testPseudo_nthChild_firstTwo_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-child(-n+2)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [2, 1], '' + results );
	}
	
	public function testPseudo_nthLastChild_last() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-last-child(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.c], '' + results );
	}
	
	public function testPseudo_nthLastChild_last_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-last-child(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [3], '' + results );
	}
	
	public function testPseudo_nthLastChild_lastComplex() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-last-child(0n+1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.c], '' + results );
	}
	
	public function testPseudo_nthLastChild_lastComplex_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-last-child(0n+1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [3], '' + results );
	}
	
	public function testPseudo_nthLastChild_lastComplex_negative() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-last-child(-0n+1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.c], '' + results );
	}
	
	public function testPseudo_nthLastChild_lastComplex_negative_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':nth-last-child(-0n+1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [3], '' + results );
	}
	
	public function testPseudo_nthOfType() {
		var data = { a:'1', b:2, c:'3' };
		var results = JsonQuery.find( data, 'int:nth-of-type(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.b], '' + results );
	}
	
	public function testPseudo_nthLastOfType() {
		var data = { a:'1', b:2, c:'3', d:4 };
		var results = JsonQuery.find( data, 'int:nth-last-of-type(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.d], '' + results );
	}
	
	public function testPseudo_lastChild() {
		var data = { a:'1', b:2, c:'3', d:4 };
		var results = JsonQuery.find( data, ':last-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.d], '' + results );
	}
	
	public function testPseudo_lastChild_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':last-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [3], '' + results );
	}
	
	public function testPseudo_firstChild() {
		var data = { a:'1', b:2, c:'3', d:4 };
		var results = JsonQuery.find( data, ':first-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.a], '' + results );
	}
	
	public function testPseudo_firstChild_array() {
		var data = [1, 2, 3];
		var results = JsonQuery.find( data, ':first-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [1], '' + results );
	}
	
	public function testPseudo_firstOfType() {
		var data = { a:'1', b:2, c:'3', d:4 };
		var results = JsonQuery.find( data, 'int:first-of-type' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.b], '' + results );
	}
	
	public function testPseudo_lastOfType() {
		var data = { a:'1', b:2, c:'3', d:4 };
		var results = JsonQuery.find( data, 'string:last-of-type' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.c], '' + results );
	}
	
	public function testPseudo_multiple1() {
		var data = { a:1 };
		var results = JsonQuery.find( data, ':first-child:last-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.a], '' + results );
	}
	
	public function testPseudo_multiple1_array() {
		var data = [1];
		var results = JsonQuery.find( data, ':first-child:last-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [1], '' + results );
	}
	
	public function testPseudo_multiple2() {
		var data = { a:1 };
		var results = JsonQuery.find( data, ':nth-of-type(1):nth-last-of-type(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.a], '' + results );
	}
	
	public function testPseudo_multiple2_array() {
		var data = [1];
		var results = JsonQuery.find( data, ':nth-of-type(1):nth-last-of-type(1)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [1], '' + results );
	}
	
	public function testPseudo_onlyChild() {
		var data = { a:1 };
		var results = JsonQuery.find( data, ':only-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.a], '' + results );
	}
	
	public function testPseudo_onlyChild_array() {
		var data = [1];
		var results = JsonQuery.find( data, ':only-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [1], '' + results );
	}
	
	public function testPseudo_onlyChild_nested() {
		var data = { a:1, b:{ c:2 }, d:3 };
		var results = JsonQuery.find( data, ':only-child' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.b.c], '' + results );
	}
	
	public function testPseudo_onlyOfType() {
		var data = { a:1, b:'2' };
		var results = JsonQuery.find( data, 'int:only-of-type' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + [data.a], '' + results );
	}
	
	public function testPseudo_notClass() {
		var data = { a:1, b:'2', c:3 };
		var results = JsonQuery.find( data, ':not(.a)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + ([data.b, data.c]:Array<Any>), '' + results );
	}
	
	public function testPseudo_hasClass() {
		var data = { a:1, b:{ c:'hey' }, d:3 };
		var results = JsonQuery.find( data, ':has(.c)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + ([data, data.b]:Array<Any>), '' + results );
	}
	
	public function testJsonObject_arrayObjects() {
		var data = { a:[{b:1}, {b:2}, {b:3}] };
		var results = JsonQuery.find( data, '[b]' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + [data.a[0], data.a[1], data.a[2]], '' + results );
	}
	
	public function testJsonObject_arrayNestedObjects() {
		var data = { a:[{b:{c:1}}, {b:{c:2}}, {b:{c:3}}] };
		var results = JsonQuery.find( data, '[c]' );
		
		Assert.equals( 3, results.length );
	}
	
	public function testJsonObject_arrayHasObjects() {
		var data = { a:[{b:1}, {b:2}, {b:3}] };
		var results = JsonQuery.find( data, '.a :has([b])' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + ([data.a[0], data.a[1], data.a[2]]:Array<Any>), '' + results );
	}
	
	public function testJsonObject_arrayHasNestedObjects() {
		var data = { a:[{b:{c:1}}, {b:{c:2}}, {b:{c:3}}] };
		var results = JsonQuery.find( data, '.a :has(.b [c])' );
		
		Assert.equals( 3, results.length );
		Assert.equals( '' + [data.a[0], data.a[1], data.a[2]], '' + results );
	}
	
	public function testJsonObject_complex() {
		var data = {
			objects: [
				{
					fullname:{
						last:'smith',
						first:'bob'
					}
				},
				{
					fullname:{
						last:'bar',
						first:'foo'
					}
				},
				{
					fullname:{
						last:'baz',
						first:'foo'
					}
				}
			],
			lastnames:['smith', 'bar', 'baz'],
		}
		
		var lastnames = JsonQuery.find( data, '.lastnames' );
		trace( lastnames );
		Assert.equals( 3, lastnames.length );
		
		for (i in 0...lastnames.length) {
			var lastname = lastnames[i];
			//trace( lastname );
			var selector = '.objects :has([last="$lastname"])';
			var object = JsonQuery.find( data, selector );
			//trace( selector, object );
			Assert.equals( 1, object.length );
			Assert.equals( '' + [data.objects[i]], '' + object );
			
		}
		
	}
	
}
