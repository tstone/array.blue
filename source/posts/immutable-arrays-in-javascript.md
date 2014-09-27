---
title:  Immutable Arrays in Javascript
date:   February 22, 2012
tags:   [javascript, arrays, functional-programming]
category: javascript
---

Most instance methods of javascript’s array perform mutations on the array.  Because objects are assigned by reference, this creates some odd situations…

```javascript
var a = [1, 2, 3];
var b = a;
b.push(4);
// a == [1, 2, 3, 4];
```

When taking on functional programming practices, one of the first things is dealing with the mutation-based implementation of array methods.  Fortunately it’s possible to implement immutable methods along side the mutable methods and use those instead.

First up is a way to create a fresh array.

```javascript
Array.prototype.clone = function() { return this.slice(0); };
```

It turns out clone-like functionality is built into the language, however it’s not labeled as such.  Slice returns a new array from the given dimensions.  That means if we slice an array starting at 0 then we’ll always end up with a new copy of that array.  Nice.

Using clone we can then implement immutable alternatives to methods.  It’s worth nothing that these so-called immutable alternatives really use mutation internally to achieve the results.  However, the end effect from “outside” the method is that they work like immutable methods.

Many javascript array methods have a return value of the array’s new length.

```javascript
var a = [1, 2, 3].push(4);
// a == 4
```

However in most cases what we really want is the new array being returned.

```javascript
Array.prototype.ipush = function(x) {
    var a = this.clone();
    a.push(x);
    return a;
};
```

Using this syntax things work in immutable ways like we’d expect.

```javascript
var a = [1, 2, 3];
var b = a.ipush(4);

// a == [1, 2, 3];
// b == [1, 2, 3, 4];
```

It turns out this pattern of cloning an array, calling a mutable method, then returning the new array is how all of these functions would work, so it’s possible to simplify this a bit.

All javascript functions include two functions, call and apply, which can be used to invoke that function.  In particular, apply takes two things, the “context” of what “this” should be and an array of arguments to invoke a function with.

For example:

```javascript
function doStuff(x, y) { alert(x + ” and ” + y + “!”); }

// These are equivalent:
doStuff.apply(this, [‘foo’, ‘bar’]);
doStuff(‘foo’, ‘bar’);
```

Why would that ever matter?  Well in this case we want to implement array methods as immutable but we don’t necessarily always know how many arguments each method takes.  We can circumvent this by turning the magical keyword arguments into an array, then using apply to invoke that function.

Putting that all together, here’s a way to implement immutable versions of array methods in one swoop:

```javascript
[‘push’, ‘unshift’, ‘reverse’, ‘splice’].forEach(function(x){
    Array.prototype[‘i’+x] = function() {
        var na = this.clone()
          , args = Array.prototype.slice.call(arguments, 0);
        na[x].apply(na, args);
        return na;
    }
});
```

Tada.  We can now use these by simply prefixing “i” in front of each to get the immutable version.

```javascript
var a = [1, 2, 3];
var b = a.iunshift(4, 5, 6);

// a == [1, 2, 3];
// b == [4, 5, 6, 1, 2, 3];
```
