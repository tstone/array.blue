---
date: August 1, 2014
title: Implicits and Challenges for Declarative Programming
tags: scala, declarative, implicits
category: scala
---

I really want to like Scala implicits but I just keep bumping into limitations with them.  The one
which has become the most annoying is that implicits only look up what the current "view" of the
type is, not the "most specific" of what the type is.  Here's a quick example...

```scala
trait Person
class Manager extends Person
class Engineer extends Person

implicit class JsonOps[A](any: A) {
  def toJson(implicit convert: JsonConverter[A]) = convert(any)
}
```

What's happening here is we have a base type, `Person`, and two child types, `Manager` and `Engineer`.  There
is an implicit class that is providing a `toJson` method to everything where `toJson` will look up an
implicit `JsonConverter` of type `A` for whatever type it's called on.  This is a fairly straight forward way of saying,
"everything should have a toJson method".

It works because the compiler will assert for us that there is always
an implicit `JsonConverter` of whatever `A` we have in scope during compilation.  For example, If I have
`val engy = new Engineer` and call `engy.toJson`, then Scala will look for `JsonConverter[Engineer]` and all
is good.

In theory this should allow us to write code declaratively, describing once how Engineer JSON is created and leaving
it at that.  However, what if I have a list of `Person`'s?

```scala
val people = Seq(new Engineer, new Manager)
people.map(_.toJson)
```

What happens is that `people` actually is of type `Seq[Person]` (Seq is covariant).  At that point the type system
"sees" the new Engineer and new Manager as type `Person` not as types `Engineer` and `Manager`.  That means that
when `toJson` is called from within the `map` when it his the `new Engineer`, Scala will look for an implicit
`JsonConverter[Person]` which is not what we want.

The only work around I've come up with for this is to use some kind of dynamic dispatch...

```scala
val people = Seq(new Engineer, new Manager)
people.map {
  case e: Engineer => e.toJson
  case m: Manager  => m.toJson
}
```

This ultimately defeats the entire goal of declarative programming because now I'm back to describing flow.
