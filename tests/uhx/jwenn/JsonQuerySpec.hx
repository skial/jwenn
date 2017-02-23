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
	
	public function testPseudo_nthChild_odd() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(odd)' );
		
		Assert.equals( 2, results.length );
		Assert.equals( '' + [data.a, data.c], '' + results );
	}
	
	public function testPseudo_nthChild_even() {
		var data = { a:1, b:2, c:3 };
		var results = JsonQuery.find( data, ':nth-child(even)' );
		
		Assert.equals( 1, results.length );
		Assert.equals( '' + data.b, '' + results[0] );
	}
	
}
