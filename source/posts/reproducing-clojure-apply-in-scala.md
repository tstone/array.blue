---
title: Reproducing Clojure's apply Method in Scala
date: October 4, 2014
tags: scala, clojure
category: clojure
---

As you most likely already know, [Clojure](http://clojure.org/) is a reincarnation of Lisp on the JVM.  It is a functional, dynamic language that
promotes functions as the primary unit and as such has some interesting functions for deal with, well, functions.  `apply` is one of those methods.
At first glance `apply` is a tad confusing and the documentation doesn't help a whole lot either...

 > ([f args] [f x args] [f x y args] [f x y z args] [f a b c d & args])
 > Applies fn f to the argument list formed by prepending intervening arguments to args.

For some background, being a dynamic language Clojure allows a type of method overloading based on function [arity](http://en.wikipedia.org/wiki/Arity)
(the number of arguments).  If you've ever used Erlang or Elixir this should be a familiar concept.  The first line of the documentation specifies
that the first argument is always `f` which is a function to be applied.  The last argument `args` is also specified to be the thing which applied. So
what are `x`, `y`, `z`, etc.?  Trying apply out in the console might make it clearer.

Clojure collections have a `conj` (conjoin) method which behaves similar to Scala's `:+`.

```scala
Seq(1, 2, 3) :+ 4  // => Seq(1, 2, 3 4)
```

```clojure
(conj [1 2 3] 4)  ;; => [1 2 3 4]
```

We can use the `conj` method to understand `apply` a bit better...

```clojure
(conj [1 2 3] [4 5 6])  ;; => [1 2 3 [4 5 6]]
(apply conj [1 2 3] [4 5 6])  ;; =>  [1 2 3 4 5 6]
```

In this use of `apply`, `conj` is the `f` argument (the function being applied), `[1 2 3]` is the `x` argument, and `[4 5 6]` are the args being
used for the application of `conj`.  This shows us what is happening:  `apply` takes a function and applies it with the given arguments for every
argument of the list of args at the end.  Without `apply` we got nested lists, where as with `apply` we got one list.  That tells us `apply` has
a kind of accumulation or fold-like effect.

This clearly can be reproduced in Scala.

As with most things Scala it's helpful to start with a type signature.  In this case it's worth considering the type signature of `conj` so that we
can imagine how `apply` might use it.

```scala
def conj[A](seq: Seq[A], a: A): Seq[A] = seq :+ a
```

One thing to notice here, and this is relevant to our implementation of `apply`, the first argument type is the same as the return type.  We know
we want to take in a function.  To limit scope initially we'll only worry about `Function2` and try to reproduce specifically the `conj` example in
Scala.

```scala
def apply[A,B,C](f: (A,B) => C, x: A, args: B*): C = ???
```

This is a start.  It lets us take in a function `f` which has two arguments, one which we will capture as `x: A`, and a second which we will get a list
of as `args: B*`.  However this is missing our rule, that the first argument (`x`) must also be the same as the return type.

```scala
def apply[A,B](f: (A,B) => A, x: A, args: B*): A = ???
```

This now let's us chain the result of each application together.  We could implement this recursively or we could use an iterator.  In this case
`foldLeft` would allow us to start with the initial value `x` and reduce the arguments down to a final return value of `A`.

```scala
def apply[A,B](f: (A,B) => A, x: A, args: B*): A =
  args.foldLeft(x) { case (acc, b) => f(acc,b) }
```

So as you can see, Clojure's `apply` is really just a different way to invoke what Scala calls `foldLeft`.

In use in Scala this becomes a bit tricky because we can't just pass in `conj` because Scala won't treat it as a function by default...

```scala
scala> apply(conj, Seq(1, 2, 3), 4, 5, 6)
<console>:10: error: type mismatch;
 found   : (Seq[Nothing], Nothing) => Seq[Nothing]
 required: (Seq[Int], Int) => Seq[Int]
              apply(conj, Seq(1, 2, 3), 4, 5, 6)
```

The `_` is required after the function to signal that we're talking about the function `conj` not attempting to call it.  Also, you'll notice that Scala's
type inference is detecting `conj` as `(Seq[Nothing], Nothing) => Seq[Nothing]`.  Apparently the type inference can't figure out we're dealing with `Int`'s
so that will need to be specified as well.

```scala
apply((conj[Int] _), Seq(1, 2, 3), 4, 5, 6)
res2: Seq[Int] = List(1, 2, 3, 4, 5, 6)
```

While this might not translate directly over to Scala as being something useful in it's current form, the concept is interesting.  The idiomatic way
of writing this in Scala would be to create a new partial function and just use the `foldLeft` off the list of arguments.

```scala
Seq(4, 5, 6).foldLeft(Seq(1, 2, 3))(_ :+ _)
```
