---
title:    A Brief Intro to Iterative Array Functions in Javascript
date:     September 14, 2012
tags:     javascript, arrays
category: javascript
---

ECMAScript 5 (javascript 1.6) introduces a number of new iteration methods to the Array object -- [Reference @ MDN](https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Array).  While it's possible to claim that these simply add syntatic sugar to the language, their brevity makes it possible to express a lot of processing in very few lines of code.

### ForEach, Map, and Reduce ###

jQuery users will likely be familiar with `forEach`.  ForEach is an instance method, called on an array, in which the first argument (a callback function), is executed one time for each object that is within the array.

```javascript
[1, 2, 3].forEach(function(x){ console.log(x); });

// Output:
"1"
"2"
"3"
```

There are a few differences between `Array#forEach` and `$.each`.  The biggest difference is the order of arguments in the callback.  `jQuery.each` gives the index first and the item second.  `forEach` gives the item first and the index second (in other words, it's the correct way.)

```javascript
var a = ['tim', 'john'];

a.forEach(function(x, i){ console.log(i); });
$.each(a, function(i, x){ console.log(i); });

// Output:
"1"
"2"
"1"
"2"
```

ForEach is simply about executing code.  `Map` introduces the idea of a return.  As with `forEach`, the callback function is executed once for every element in the array, however that function returns a value which creates a new array.

```javascript
var a = [1, 2, 3];

// These are equivalents:

var b = a.map(function(x){ return x + 1; });

var c = [];
a.forEach(function(x){ c.push(x); });

// Both b & c are:
// [2, 3, 4]
```

Like `map`, `reduce` returns a value which is the "accumulated" value of the array.  Each time the callback function is called, it's passed the accumulator and the item.  The callback function returns whatever accumulation processing needs to happen, and the result of the `reduce` is the accumulated value.  That sounds weird, but consider the following code.

```javascript
var a = [1, 2, 3];

// These are equivalents:

var b = a.reduce(function(acc, x){ return acc + x; }, 0);

var c = 0;
a.forEach(function(x){ c += x; });

// Both b & c are:
// 6
```

Note that `reduce` takes a second parameter, the initial value of the accumulator.  It's possible to leave this off and the `acc` will start with `undefined`.  It could be written like this in that case.  But writing it this way is less efficient and looks uglier.

```javascript
var b = a.reduce(function(acc, x){ return (acc || 0) + x; });
```

#### In Use ####

In practice, `map` and `reduce` allow things to be done very easily.  Say perhaps that we have a DOM element, and we want one of the children to full the remianing height that isn't already taken by the other children.

```html
<div id="parent" style="height: 500px">
    <h2 style="height: 50px;">Title</h2>
    <div id="content">
        <!-- ... -->
    </div>
    <img style="height: 100px" src="..." />
</div>
```

In effect, we want `div#content` to have a height of 350px.  We could calculate this by first getting the height of the parent, then substracting the height of all of the children with the exception of `div#content`.

```javascript
var parent = $('#parent');
var contentHeight = parent.outerHeight() - parent.children().not('#content').toArray().reduce(function(x){
    return $(x).outerHeight();
});
$('#content').css('height', contentHeight+'px');
```

In this case, we selected all of the children within `parent` that wasn't the element we wanted to set the height on (`parent.children().not('#content')`).  Because that would return a jQuery function, it was turned into an array (`.toArray()`).  Then, that array of elements was `reduce`'ed, where each element returned it's `outerHeight`.  The result of reduce was the area that `div#content` wasn't occupying, so we could calculate the correct height by simply subtracting that from the parent's height.

### Every and Some ###

On the flip side, sometimes it's more important to confirm the contents of an array rather than creating new values based on the array.  In those cases there is `every` and `some`.

```javascript
var a = [1, 2, 3];

a.every(function(x){ return x > 0 });

// Output:
// true

a.some(function(x){ return x > 2 });

// Output:
// true
```

Every and some are a bit like reduce, where the logical operator `&&` is applied to the accumulator for `every` and `||` for `some`.

```javascript
var a = [1, 2, 3];

// These are equivalents:

a.every(function(x){ return x > 0; });
a.reduce(function(acc, x){ return x > 0 && acc; }, true);

// These are also equivalents:

a.some(function(x){ return x > 2 });
a.reduce(function(acc, x){ return x > 2 || acc; }, false);
```

Clearly, however, `every` and `some` are much easier to read and write.  They're a little bit less useful however because the need for them just doesn't come up as often as `map` and `reduce`.


### Filter ###

Last, but not least, is `fitler` which is a bit like `map` but more useful in a certain case.  Consider the following:

```javascript
[1, 2, 3].map(function(x){
    if (x > 1) {
        return x;
    }
});

// Output:
// [undefined, 2, 3]
```

`undefined`!?  Recall that `map` builds a new array out of the return of the function that is applied for each array element.  That means that if `x > 1` evaluates to `false`, the callback function returns `undefined`.  This is the case where `filter` is the right choice.

```javascript
[1, 2, 3].filter(function(x){ return x > 1; });

// Output:
// [2, 3]
```

Filter is more limited than `map`, in that the value can't be changed, however it won't add `undefined` to the new array in cases where we don't want to keep the value.

Filter and map can be chained together as well.

```javascript
// Double values where the value is greater than 3

[1, 2, 3, 4].filter(function(x){ return x > 3; }).map(function(x){ return x * 2 });

// Output:
// [8]
```

### Improving Readability ###

That last line of code was a bit hard to read.

```javascript
[1, 2, 3, 4].filter(function(x){ return x > 3; }).map(function(x){ return x * 2 });
```

Javascript, having functional roots, gives us some tools for addressing the readability of that code.  Functional composition is a crazy, mathy concept, but on a simple level the idea isn't that hard: Can we have a function that creates a function where the function that was created is shaped somehow by the parent function?

In object oriented programming, code describes classes and creates new instances of objects, so why not have code that creates functions for reuse too?  What's furhter is that javascript's supports of closures mean that we could craft a function where the arguments of the outer function are closure'ed into the returned function.  All that crazy talk sounds hard, but consider the following code:

```javascript
var greaterThan = function(num) {
    return function(x) {
        return x > num;
    }
}
```

`greaterThan` is a function... that returns a function (let that sink in). The returned function takes one argument, `x`, which it compares to... `num`.  Num is present because it was closure'ed by the scope of the outer function.  If we were to execute `greaterThan` we'd get a function back, which we could pass `x` into.

```javascript
var greaterThanEight = greaterThan(8);
var greaterThanEight(10);

// Output:
// true
```

Using functional composition, we could build up a generic set of functions to create functions for filtering and mapping and such.

```javascript
var greaterThan = function(num) {
    return function(x) {
        return x > num;
    }
}

var multiply = function(num) {
    return function(x) {
        return x * num;
    }
}

// These are equivalent:

[1, 2, 3, 4].filter(greaterThan(3)).map(multiply(2));
[1, 2, 3, 4].filter(function(x){ return x > 3; }).map(function(x){ return x * 2 });

// But the composed functions can also be re-used...

[100, 200, 300, 400].filter(greaterThan(250)).map(multiply(1.5));
```

This practice can result in some extremely flexible code.  Once the composing functions get setup, it's really simple to create new functions and use them.  Recall this snippet from above:

```javascript
var contentHeight = parent.outerHeight() - parent.children().not('#content').toArray().reduce(function(x){
    return $(x).outerHeight();
});
```

A function could be created to return the property or singleton method of a jQuery object.

```javascript
var prop = function(p) {
    return function(x) {
        x = $(x);
        if (typeof x[p] === 'function') {
            return x[p]();
        } else {
            return x[p];
        }
    }
}

var contentHeight = parent.outerHeight() - parent.children().not('#content').toArray().reduce(prop('outerHeight'));
```

This one is a bit more complex.  Instead of just returning `x[p]` which would be `p` as a property of `x`, we check first if `p` is a function and execute it if so returning the result of `x[p]` instead of the value of `x[p]`.

Lots and lots of cool stuff can be done using these practices and built-in array methods.
