---
title: Avoid 'val's on Implicit Classes
date: June 6, 2014
tags: scala, implicits
category: scala
---

Implicit classes (known early on in the community as the "pimp my library" pattern) are used to extend classes
with additional methods or values within a given context.  As a rule, having a `val` on an implicit class is less
than spectactular.  Scala expands each use of the implicit at the time it is applied.  This means that for each time
an implicit method is accessed, a `new` instance of the implicit class is created.  Since `val`'s are evaluated at class
creation time, this basically means the compute every single time an implicit class is created.

Similarly, `lazy val` doesn't offer any additional value because a new instance of the class is being created, which means
the memoizing effect of lazy val will never be utilized.

The best choice for an implicit class is probably `def`.  If values will be used multiple times, it's probably better to just
explicitly instantiate the class yourself and keep that copy around.

This can be demonstrated easily in the Scala console:

```scala
implicit class StringOps(s: String) {

  val one = { println("one"); "one" }
  val two = { println("two"); "two" }
  lazy val three = { println("three"); "value" }

}

scala> "asdf".three
one
two
three
res1: String = value

scala> "asdf".two
one
two
res2: String = two
```

Notice how the `.one` method is never called but computes every single time?
