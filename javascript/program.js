// 1.  Function Object 
// Four patterns: method(in object),  function(global),  constructor(new syntax), apply(haskell curing).

var myobject = {
	value: 0,
	increment: function( inc ) {
		this.value += typeof inc === 'number' ? inc : 1;
	}
};

myobject.increment( );
document.writeln( myobject.value );

myobject.increment( 10 );
document.writeln( myobject.value );

document.writeln('Hello World');

// 2.  Exception Test

var add = function( a , b ) {
	if( typeof a !== 'number' || typeof b !== 'number' ) {
		throw {
			name: 'Type Error',
			message: 'Add Needs Numbers'
		}
	}
	return a + b;
}

var try_it = function() {
	try { 
		add("seven"); 
	}
	catch( e ) {
		document.writeln( e.name + ':' + e.message );
	}
}

try_it();

// 3. Augment Type.  This is so powerful that a method added to its prototype is available to all its 
// clones immediately, similar to ObjC categories.
Function.prototype.method = function(name, func) {
	if( !this.prototype[name]) {
		this.prototype[name] = func;
	}
	return this;
}

Number.method( 'integer', function() {
	return Math[ this < 0 ? 'ceiling' : 'floor'](this);
})

document.writeln( (10/3).integer( ) );

String.method('trim', function() {
	return this.replace(/^\s+|\s+$/g, '');
})

document.writeln('"' + "       neat        ".trim() + '"');

// 4. Scope:  very weird, no block scope, but only function scope.
var scope = "global";
var fscope = function() {
	// here it will not print "Global" becaue of absence of block scope.
	document.writeln("inside function: " + scope); 
	var scope = "local";
	document.writeln("end of function: " + scope);
}
fscope();

// 5. Closure and Module.  It's a good way to information hidding. 
// Note the book contains errors.

var serial_maker = function() {
	var prefix = '';
	var seq    = 0;
	return {
		set_prefix : function( p ) {
			prefix = String(p);
		},
		set_seq : function( s ) {
			seq = s;
		},
		gensym : function() {
			var result = prefix + seq;
			seq += 1;
			return "Unique Serial Numbers";
		}
	};
}();  // because of (), now serial_maker is an object. 

var seqer = serial_maker;  //Here can't be serial_number(), the book is wrong.
seqer.set_prefix = 'Q';
seqer.set_seq = 1000;
var unique = seqer.gensym();

document.writeln( unique );

// 6. Curry.  Ok, Haskell, Haskell ~
Function.method( 'curry', function() {
	var slice = Array.prototype.slice,
		args  = slice.apply( arguments ),
		that  = this; 

	return function() {
		return that.apply(null, args.concat( slice.apply(arguments)));
	};
})
var add1 = add.curry( 1 );
document.writeln( add1( 6 ));

// 7. Dynamic Programming.  memorize the interim result.

var fibonacci = function() {
	var memo = [0, 1];
	var fib = function( n ) {
		var result = memo[ n ];
		if ( typeof result !== 'number' ) {
			result = fib(n - 1) + fib( n - 2);
			memo[n] = result;
		};
		return result;
	}

	return fib;
} ();

document.writeln("fibonacci Result : ", fibonacci( 20 ));

//------ Utilities -----------
var log = function( msg ) {
	document.writeln( msg );
}

// 8. Float number, problems from IEEE-754, binary representation.
// x == y   => false
// x == .1  => false
// y == .1  => true
var x = .3 - .2;
var y = .2 - .1; 
if ( y == .1 ) {
	log("Able to Judge Float Number by == ");
}
else  {
	log("Sorry, unable to judge float number by == ");
}

if( x - y < 0.0000000000000001)  {
	log("Ok, x, y are equal");
}

// 9.  Unicode - UTF-16 encoding of the Unicode character set. 
// some special character may have 2 16-bit values, JS treat only
// 16-bit values.
var p = "π";
log("Length of 1 char π is " + p.length);

// 10. Wrapper Object
var s = "test";
s.len = 4;   // s is wrapped into a temporary object and discarded immediately.
log("Length of a string is " + s.len);  //s.len here is 'undefined'

// 11. Property Attributes

log("Property Attributes: a.y ");
var prop = {x:1};
var newProp    = Object.create(o);

newProp.y = 3;

alert( Object.getOwnPropertyDescriptor( newProp, "y") );
