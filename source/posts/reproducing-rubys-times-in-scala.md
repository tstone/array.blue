---
title: Reproducing Ruby's times in Scala
date: September 28, 2014
tags: scala, ruby
category: ruby
---

Continuing the theme I started yesterday of implementing other language features in Scala, one of the things I miss from Ruby is `#times`.  Scala
actually has a similar feature, [Range](http://www.scala-lang.org/api/current/index.html#scala.collection.immutable.Range).  You can create
ranges with the `to` or `until` methods...

```scala
scala> 1 to 5
res0: scala.collection.immutable.Range.Inclusive = Range(1, 2, 3, 4, 5)

scala> 4 until 20 by 2
res1: scala.collection.immutable.Range = Range(4, 6, 8, 10, 12, 14, 16, 18)
```

At first glance it might seem like this is a bit of magic.  What's actually happening is an implicit class is being applied.  Consider:

```scala
implicit class RangeFactory(i: Int) {
  def to(j: Int) = new Range(i, j, 1)
  def until(j: Int) = new Range(i, j - 1, 1)
}
```

The `by` keyword is implemented on the `Range` class itself.

Something neat is that `Range` actually implements `IndexedSeq`, making it a true collection.  As such it's possible to do things like `foreach`
and `map` off of it:

```scala
scala> (1 to 5).map(_ + 1)
res2: scala.collection.immutable.IndexedSeq[Int] = Vector(2, 3, 4, 5, 6)
```

As you can see `Range` is quite flexible and expressive.  When we consider Ruby's `#times` behavior in Scala terms, we're really just talking about
and implicit method that goes from `1` to the given `Int` then calls `map`:

```scala
implicit class RangeFactory(i: Int) {
  def times[A](f: (Int) => A) = new Range(1, i, 1).map(f)
}
```

That's it.

```scala
scala> 10.times { _ * 2 }
res3: scala.collection.immutable.IndexedSeq[Int] = Vector(2, 4, 6, 8, 10, 12, 14, 16, 18)
```
