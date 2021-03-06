//------ Utilities -----------
var log = function( msg ) {
	document.writeln( msg );
}

var sep = function( msg ) {
	log("\n" + (new Array(60)).join('-'));
	if ( msg ) {
		log(msg);
	};
}

//------ Notes ---------------
sep("Function as First-Class Variable");

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
sep("Support Exception");
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
sep("Augment Type. \nThis is so powerful that a method added to its prototype is available to all its clones immediately, similar to ObjC categories.");

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
sep("Scope:  No block scope, but only function scope.");
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
sep("Support Closure");
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
sep("Curry - Haskell");
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
sep("Dynamic Programming ");
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

// 8. Float number, problems from IEEE-754, binary representation.
sep("Float Number - inaccuracy");
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
sep("Unicode - one char may have length 2");
var p = "π";
log("Length of 1 char π is " + p.length);

// 10. Wrapper Object
sep("Wrapper Object - temporary");
var s = "test";
s.len = 4;   // s is wrapped into a temporary object and discarded immediately.
log("Length of a string is " + s.len);  //s.len here is 'undefined'

// 11. Property Attributes

sep("Property Attributes");

var prop = {x:1};
var newProp    = Object.create( prop );

newProp.y = 3;
log( Object.getOwnPropertyDescriptor( newProp, "y").toString() );

// 12. JS Array
sep("Array");
log("JS Array is special that its elements can have different types.");
log("Array is object. [] is used same as other objects. a[1] actually is a['1'] ");

var a = ["Hello"];
a["1"] = " My ";
a[2.0000] = "Friend";
log(a[0] + a[1] + a[2]);
a.push("Aligaduo", "Gedayimasi");

//add a new method to all array.
Array.method("count", function()  {
	var count = 0;
	log("The Length of " + this.length );
	for( var i = 0;  i < this.length; i++) {
		if( this[i] ) count += 1;
	}
	return count;
})

// for/in will print methods in its prototype, so avoid it.
// hasOwnProperty will filter out these methods.
for(var index in a){
	if( a.hasOwnProperty(index))
		log(a[index]);
}

log( a.count() );

// forEach will only print all its own properties, Nice. 
a.forEach(function(x) { log(x); });
log( a.join(" => ") );

// ECMAScript 5 new methods.
var aa = [2, 3, 4];
// map creates a new array.
log( aa.map( function(x) {return x*x}).join());   // 1, 4, 9
log( aa.every( function(x) { return x < 10}));  // all elements less than 10
log( aa.some( function(x) { return x < 2})); // exists one  < 2.
//use reduce to sum, Haskell fold
log( aa.reduce( function(x, y) { return x+y;}, 10));
log( aa.reduceRight( function(x,y) { return Math.pow(y,x)}));
log("Index Of " + aa.indexOf(3));


