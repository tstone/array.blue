---
title:    Adding Monads to Functions in Javascript
date:     September 15, 2012 10:00
tags:     javascript, functional-programming, monads
category: javascript
---

Now things are just getting silly.

The [second half of my blog post about array functions](http://www.typeof.co/post/a-brief-intro-to-iterative-array-functions-in-javascript) included a brief intro to functional composition.  One thing I didn't mention was combining composed functions.

```javascript
var greaterThan = function(num) {
    return function(x) {
        return x > num;
    }
};

var lessThan = function(num) {
    return function(x) {
        return x < num;
    }
};
```

It's possible to use these two separately...

```javascript
[1, 2, 3].filter(lessThan(3));
```

...but what if we wanted to use them together to define a range?

```javascript
[1, 2, 3].filter(greaterThan(1) *and* lessThan(3));
```

A simple solution would be to create a function that would combine the effects of two filtering functions into a single filter.

```javascript
var bind = function() {
    var fs = Array.prototype.slice.apply(arguments, [0]);
    return function(x) {
        return fs.every(function(f){ return f(x); });
    }
};
```

This monad (bind) takes an unlimited list of input functions (`arguments`), and turns them into an array. The function that is returned will `every` through each filter function, returning the `&&` of all filters;

```javascript
[1, 2, 3].filter(bind(greaterThan(1), lessThan(3)));

// Output:
[2]
```

Having a separate function, `bind` to combine functions works, but it's a bit ugly.

One solution is just to build a `range` function that combines the other two.

```javascript
var range = function(low, high) {
    return bind(greaterThan(low), lessThan(high));
}

[1, 2, 3].filter(range(1, 3));

// Output: [2]
```

Another possible alternative syntax would be if functions could be chained together in a more natural/english sort of way.  Something along the lines of...

```javascript
[1, 2, 3].fitler(greaterThan(1).and(lessThan(3)));
```

To make this possible there would need to be an `.and` method on whatever the filter function returned.  Recall that the filter methods return a function, which means that the returned function would need to have `.and`.  We can start by creating a function that adds the `.and` extention onto a function.

```javascript
var $f = function(comp) {
    return function() {
        var f = comp.apply(f, arguments);
        f.and = function(f2) {
            return $f(function() {
                return bind(f, f2);
            })();
        };
        return f;
    };
}
```

`$f` is a bit of a magical function.  It takes one argument, `comp` which is our compositional function.  `comp` would typically be returning a function that would be our filter, however `$f` replaces that with a function that applies the arguments to `comp`, then adds the `.and` property onto that composed (comp resulting) function.

In order to allow subsequent `.and`'s to be called, the `$f` is then called on whatever `.and` binds.

Then we can re-defined `greaterThan` as a filter.  Note the new `$f()` wrapping the filters.

```javascript
var greaterThan = $f(function(num) {
    return function(x) {
        return x > num;
    }
});

var lessThan = $f(function(num){
    return function(x) {
        return x < num;
    }
});

var even = $f(function(){
    return function(x) {
        return x % 2 == 0;
    }
});

[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan(5))
    .and(even())
);

// Output:
// [2, 4]
```

Oh geeze, this is starting to look like Lisp.

It's worth pointing out that the syntax could be extended to include `or`.  Here's the whole clip of code.

```javascript
// Monads

var bind = function() {
    var fs = Array.prototype.slice.apply(arguments, [0]);
    return function(x) {
        return fs.every(function(f){ return f(x); });
    }
};

var bindOr = function() {
    var fs = Array.prototype.slice.apply(arguments, [0]);
    return function(x) {
        return fs.some(function(f){ return f(x); });
    }
};

// Filter builder

var $f = function(comp) {
    return function() {
        var f = comp.apply(f, arguments);

        f.and = function(f2) {
            return $f(function() {
                return bind(f, f2);
            })();
        };

        f.or = function(f2) {
            return $f(function() {
                return bindOr(f, f2);
            })();
        };

        return f;
    };
}

// Filters

var greaterThan = $f(function(num) {
    return function(x) {
        return x > num;
    }
});

var lessThan = $f(function(num){
    return function(x) {
        return x < num;
    }
});

var even = $f(function(){
    return function(x) {
        return x % 2 == 0;
    }
});

var equals = $f(function(num){
    return function(x) {
        return x === num;
    }
});

// In use

[1, 2, 3, 4, 5, 6].filter(
    greaterThan(1)
    .and(lessThan(5))
    .and(even())
    .or(equals(3))
);

// Output:
// [2, 3, 4]
```

The clever programmer would have spotted that our monads could actually be re-factored into their own composer too...

```javascript
// This:

var bind = function() {
    var fs = Array.prototype.slice.apply(arguments, [0]);
    return function(x) {
        return fs.every(function(f){ return f(x); });
    }
};

var bindOr = function() {
    var fs = Array.prototype.slice.apply(arguments, [0]);
    return function(x) {
        return fs.some(function(f){ return f(x); });
    }
};

// Into this:

var monad = function(filter) {
    return function() {
        var fs = Array.prototype.slice.apply(arguments, [0]);
        return function(x) {
            return fs[filter](function(f){ return f(x); });
        }
    }
}

var bind = monad('every');
var bindOr = monad('some');
```

And that, boys and girls, is getting started in the amazing world of functional programming.
