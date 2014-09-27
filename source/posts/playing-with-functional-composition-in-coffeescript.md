---
title:    Playing with Functional Composition in CoffeeScript
date:     September 18, 2012 8:16
tags:     coffeescript, javascript, functional-programming
category: coffeescript
---

I've been doing a lot of studying of [Ruby](http://ruby-lang.org) the past week or so and as a consequence have been messing around a bit with CoffeeScript.  There aren't many things more controversial in javascript circles than CoffeeScript.  It's been the recipient of about as much hype as it has criticism.  In any case, it offers _an_ alternative syntax that along with being ruby-like cuts down a bit on some of the fluff that is often found about javascript code.  To that degree, I wanted to re-write some of the filtering and composed function code from the previous two blog posts, but in CoffeeScript.

One of the most glaring different things in CoffeeScript is the syntax for anonymous functions: skinny arrow `->`.

```coffeescript
// Javascript:
[1, 2, 3].forEach(function(x){ console.log(x); });

# CoffeeScript:
[1, 2, 3].forEach (x) -> console.log x
```

[Ryan Florence ](http://ryanflorence.com) wrote a somewhat popular blog post titled, ["A Case Against Using CoffeeScript"](http://ryanflorence.com/2011/case-against-coffeescript/), in which he details how studies have shown people recognize symbols faster than words.  While that fact may be true, given the above two code samples, it's easy to see javascript can be symbol-overload at times.

But it's not all peaches and roses.  There are sometimes where the coffeescript syntax doesn't work out so well.  `reduce` is a good example of this.  `reduce` takes two arguments, a callback function and the initial value of the accumulator.

These don't work:

```coffeescript
# The natural but vauge way this could be written (that doesn't work)
[1, 2, 3].reduce (acc, x) -> acc.push(x) if x > 2, []

# More explicity, cleanrer syntax (that doesn't work)
[1, 2, 3].reduce (acc, x -> acc.push(x) if x > 2), []
```

But this works:

```coffeescript
[1, 2, 3].reduce ((acc, x) -> acc.push(x) if x > 2), []
```

That doesn't quite look as nice.

But there's a second problem with the above code.  Another interesting language feature is that like ruby or python, coffeescript will always return the result of the last line of code executed.  This is a nice-to-have, but it can create code that is difficult to debug.  What would the result of the last line of code from above be?

Trick question, it would throw an exception, `TypeError: Cannot call method 'push' of undefined`.  CoffeeScript is a nicer syntax on top of javascript, but _it doesn't get rid of javascript's bad default object implementation_.  I've written about the quirks of javascript array functions before ([Immutable Arrays in Javascript](/post/immutable-arrays-in-javascript));  `push` returns, not the new array, but the _length_ of the new array.  Because `reduce` is expecting the accumulator to be returned, it sets the acc to `undefined` if `x < 2`.  Oops.

CoffeeScript, for the simplicity it brings, does by the same stroke makes it easy to write code with unintended bugs like this.

Regardless, because it's still "just javascript" under the covers, it's possible to bring out the same functional nature of javascript in coffeescript.

```coffeescript
# A composed function
greaterThan = (num) -> (x) -> x > num

# It's also possible to write it on multiple lines, if preferred
greaterThan = (num) ->
    (x) ->
        x > num

// the compiled javascript output
var greaterThan;

greaterThan = function(num) {
  return function(x) {
    return x > num;
  };
};
```

As you can see, it certainly could make things shorter.  Perhaps also making it a bit more cryptic in the process.

In functional programming, often times functions are very short, focusing on just doing a single thing.  In CoffeeScript, this literally allows functions to become a single line of code.  For example, the and and or monads would simply become:

```coffeescript
bind (args...) -> (x) -> args.every (f) -> f(x)
bindOr (args...) -> (x) -> args.some (f) -> f(x)
```

And our filter builder:

```coffeescript
$f (comp) -> (args...) ->
    f = comp.apply(f, args)

    f.and = (f2) ->
        $f do () -> bind(f, f2)
    f.or = (f2) ->
        $f do () -> bindOr(f, f2)
```

So far, things are shorter, but maybe or maybe not cleaner.  Here's where I think CoffeeScript could possible start to shine: consuming these libraries.  Sadly, method chaining in coffeescript isn't as straight forward as it might seem.

```coffeescript
# Attempt 1
[1, 2, 3, 4, 5, 6].filter
    greaterThan 1
    .and lessThan 5
    .and even
    .or equals 3

# Result:
# PARSE ERROR ON LINE 1: UNEXPECTED 'INDENT'


# Attempt 2
[1, 2, 3, 4, 5, 6].filter
    greaterThan(1)
    .and lessThan(5)
    .and even()
    .or equals(3)

# Result (Wrong):
[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan(5)
        .and(even()
            .or(equals(3)))));


# Attempt 3
[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan 5)
    .and(even)
    .or(equals 3)
)

# Result (Almost Right):
[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan(5))
    .and(even) // << this should be even()
    .or(equals(3))
);

# Attempt 4
[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan 5)
    .and(even())
    .or(equals 3)
)
```

And at that point, it's so close to the javascript I'm wondering if it's worth it.

So with that, here is the whole code listing from the previous post, but in CoffeeScript.  The creation of the functions are certainly much shorter.  The consumption of the functions, not as much (comparison code, bottom of blog post: [Adding Monads to Functions in Javascript](/post/adding-monads-to-functions-in-javascript)).

```coffeescript  
# Monads
bind (args...) -> (x) -> args.every (f) -> f(x)
bindOr (args...) -> (x) -> args.some (f) -> f(x)

# Filter Builder
$f (comp) -> (args...) ->
    f = comp.apply(f, args)

    f.and = (f2) ->
        $f do () -> bind(f, f2)
    f.or = (f2) ->
        $f do () -> bindOr(f, f2)

# Filters
greaterThan = $f (num) -> (x) x > num
lessThan = $f (num) -> (x) x < num
even = $f (num) -> (x) x % 2 == 0
even = $f (num) -> (x) x == num

# Consumption
[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan 5)
    .and(even())
    .or(equals 3)
)
```
