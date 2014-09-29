---
title: Reproducing Coffeescript's Tail if/unless in Scala
date: September 29, 2014
tags: coffeescript, scala
category: coffeescript
---

Both Ruby and Coffeescript allow `if` and `unless` (not if) in the tail position:

```ruby
do_some_side_effect() unless x
```

Where practitioners typically use it is when reading the line to be executed gives better context to what might be happening over
starting a line of code with an if statement.  Compare these two:

```ruby
if str.length == 0
  str = "default value"

# vs.

str = "default value" if str.length == 0
```

There's certainly pro's and con's to this approach.  Depending on the line length the `if str.length == 0` part can easily get lost and
it's easy to read a function as "always set str to default value" until you realize there is an `if` or `unless` way off the
screen to the right.

But I digress.  Here is the challenge: Can this feature be implemented in Scala?  There are two aspects to consider.

First, in Scala all branching statements are expressions.  That is `if`, `match`, and friends always return a value.  In considering the tail
position if/unless, what if I wrote the following in Scala:

```scala
val x = 7 unless false
```

What _should_ happen?  We could throw an exception, but that's not the expected behavior.  And it would make using this feature really annoying.
One approach we could take is that a trailing conditional returns an `Option`.  If the condition is met it returns `Some` and when not met, `None`.

A second consideration is that if the statement contains any kind of computation or side effect we certainly do not want to execute it if
the condition is not true.  Consider the following code.  It should never print.

```scala
println("haha") if false
```

At this point the type signature for the Scala implementation is becoming clear:

```scala
implicit class IfUnlessMagic[A](block: =>A) {
  def unless(cond: Boolean) = ???
}
```

Notice the `=>` on `=>A` of the first line.  This is known as "call by name" in the Scala world.  Scala includes two ways that arguments are passed:
by name and by value.  In case the wording of those sounds confusing, it is.  Most of us coming from backgrounds in other languages are used to the
concepts of "by reference" and "by value".  In Scala passing an argument "by name" means that it is not immediately evaluated when the function is
run but instead is evaluated every time the name is referenced in the subsequent code.

```scala
def byValue(block: Unit) = { println("byValue"); block; block }
def byName(block: =>Unit) = { println("byName"); block; block }

scala> byValue(println("a"))
a
byValue

scala> byName(println("b"))
byName
b
b
```

Notice not only the number of times the block prints out, but also the order.  With by value the argument `block` is evaluated when the function is
applied.  That's why `"a"` is printed out first.  By name arguments are evaluated when their "name" is applied, thus why that function prints in
the order they are listed in the function.

Back to the problem at hand, by making our implicit class take an argument by name it means that we won't actually execute the block until our code
decides to.  From there the implementation should be fairly obvious.

```scala
implicit class IfUnlessMagic[A](block: =>A) {
  def unless(cond: Boolean) = if(!cond) Some(block) else None
}
```

We can add an implementation of a tail position `if` too, but `if` is a reserved keyword so it'll have to be something else.

```scala
implicit class IfUnlessMagic[A](block: =>A) {
  def iff(cond: Boolean) = if(cond) Some(block) else None
  def unless(cond: Boolean) = iff(!cond)
}
```

And in use...

```scala
scala> println("HAHA") unless true
res1: Option[Unit] = None

scala> println("HAHA") unless false
HAHA
res2: Option[Unit] = Some(())

scala> val x = 10
x: Int = 10

scala> val y = 7 iff x < 20
y: Option[Int] = Some(7)
```

I don't know how useful this actually is in Scala (I suspect "not very"), but it is possible and a fun mental challenge if nothing else.
