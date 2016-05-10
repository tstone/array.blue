---
title: Implicit Function Conversion
tags: scala, implicits
date: May 10, 2016
category: scala
---

Most Scala developers are familiar with implicit type conversion which grants the Scala compiler the ability to automatically convert any type `A` to `B` at compilation time.

```
case class Person(name: String, age: Int)

implicit def personToInt(p: Person): Int = p.age

def increment(i: Int) = i + 1

val john = Person("John", 23)
val johnsAgeNextYear = increment(john)
```

One area where this abstraction leaks is when applying a function.  The following is NOT possible solely by the `implicit def`:

```
val people: Seq[Person] = Seq(Person("John", 23), Person("Sally", 38))
val agesNextyear = people.map(increment)
```

At first glance this seems like a short coming.  Scala knows how to implicitly convert from `Person => Int`.  `val people` is a `Seq[Person]`, therefore it should be possible to map that collection to a `Seq[Int]`.

The problem, however, isn't that Scala doesn't know how to do `Person => Int`.  Instead it is that `map` is expecting a function of type signature `Person => B` and `increment` is actually `Int => B`.

It turns out this can be resolved by defining a second implicit  conversion:

```
implicit def intFunc1ToPersonFunc1[R](f: Int => R): Person => R =
  (p: Person) => f(p.age)
```

Scala now has two implicit functions, one to `Person => Int` and a second to `(Person => B) => (Int => B)`.  It's now possible to apply `increment` when mapping a `Seq[Person]` because Scala will implicit convert `increment` to a function that takes a `Person` and returns their age plus one.

```
val agesNextyear = people.map(increment)
```

There's a bit of a problem with the `def intFunc1ToPersonFunc1` however: it repeats the same logic of conversion that is already in the `implicit def personToInt`.  It would be better to describe that conversion once, and use it wherever needed.

```
implicit def intFunc1ToPersonFunc1[R](f: Int => R)(implicit convert: Person => Int): Person => R =
  (p: Person) => f(convert(p))
```

Now any conversion from `Person => Int` can be used, as long as it is in scope.

In fact, this approach could be used to generically allow _any_ implicit function conversion for all types that have an implicit conversion defined for them.

```
implicit def aFuncToBFunc[A,B,R](f: A => R)(implicit convert: B => A): B => R =
  f.compose(convert)
```

SIDEBAR:  `(b: B) => f(convert(b))` is the same thing as `f.compose(convert)`

Global implicit type conversions that work on all types can sometimes cause unpredictable bugs.  Be careful how this is used.
