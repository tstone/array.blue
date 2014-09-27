---
title: Empty, as a Contract
date: June 27, 2014
tags: scala
category: scala
---

If you have a Scala project and you do any amount of testing in it, it's more than likely
you've got some big collection of "factories" that just instantiate models with test values.

Perhaps something like...

```scala
// person.scala
case class Person(name: String, age: Option[Int])

// test/factories.scala
def buildPerson(name: String = "Bob", age: Option[Int] = Some(30)) =
  Person(name, age)
```

This approach works, but it creates a constant maintenance overhead to keep up all of these factories
whenever the type signature of a model changes.  While not a perfect solution, I noticed that `Seq` has
a function `empty` on it's companion class.  We could think of `empty` as a kind of contract with a model.

```scala
trait Emptyable[A] {
  def empty: A
}
```

Example implementation:

```scala
case class Person(name: String, age: Option[Int])

object Person extends Emptyable[Person] {
  def empty = Person("", None)
}
```

Obviously this is less than pure.  `""` for `name` isn't exactly robust.  However
with the `empty` method in place, it means that we can now write our tests using that function,
being guaranteed that we'll always get back whatever that model considers "empty".  Using the `copy`
method case class provides, any values that need to be initialized go in there.  Where this
approach shines is that whenever a model changes (ie. a field gets added), it won't break every
test in the world.

```scala
val testPerson = Person.empty.copy(name = "The Field I Care About")
```
