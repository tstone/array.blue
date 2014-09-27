---
title: A Crash Course in Scala Pattern Matching
date:  July 9, 2014
tags:  scala, pattern matching
category: scala
---

## Theory

Initial implementations of pattern matching find their roots in calculus' piecewise functions:  [http://en.wikipedia.org/wiki/Piecewise](http://en.wikipedia.org/wiki/Piecewise).
Other languages like erlang, elixir, and haskell have an implementation closer to the calculus form, but in Scala pattern matching has been implemented in a couple places, most notably in what other language's `switch` statement is.

## Why

If/then's have been a long favorite of control flow so why did we need a different control structure?  The problem is that they
require every situation to be distilled down to a boolean.  As programmers we like and use booleans so much because we're used to them, but
if I asked any non-programmer if they would be okay describing every situation they might encounter in their life as "true" or
"false" they would find the notion ridiculous.

What programming languages really need, and what pattern matching provides, is the ability to describe the pattern of a situation
instead of if something is `true` or `false`.  This has the added benefit of not requiring anyone reading the code to translate
things into `true` or `false` in their head in order to understand it.

## Patterns

Changing one's thinking from if/then/boolean to patterns takes some time.  The reward is less code that expresses things at a
higher level.  Scala has about 6 or 7 built-in patterns and programmers can make their own as well.  Let's do an example to
visualize how patterns might be used.  What if we wanted to write some code to branch based on the first letter of a `String`.  If
it's "A" do this, if it's "B" do this, and so on.  We might start by thinking that we could slice off the first letter then
`match` on that latter (in much the same way we'd use if/then)...

```scala
phrase.firstLetter match {
  case "A" => ...
  case "B" => ...
}
```

The syntax for a Scala pattern is to…

```
VALUE match {
  case PATTERN1 => run this code if PATTERN1 is true
  case PATTERN2 => run this code if PATTERN2 is true
}
```

A pattern can be more than just a single value.  For example, if we had a tuple `(String, String)`, we could match that as well...

```scala
("Bob", "Smith") match {
  case ("Carley", _)       => "Call me"
  case ("Bob", "Williams") => "Hello Bob"
  case (_, "Johnson")      => "Your surname is Johnson"
}
```

The underscore `_` means "anything".  Notice how we can describe a pattern referencing either or both of the values in the tuple.

## Deconstruction

One of the features of Scala's pattern matching is that it also does deconstruction, sometimes call "destructuring".  In the example above,
what if we wanted to get the first name when the surname was "Johnson".  While we wrote `(_, "Johnson")`, we could have captured the `_` into a value.  Languages
like erlang and elixir actually use this to indicate if a function succeeded for not.  Let's re-implement that in Scala.

```scala
def doComputation: Tuple2[Symbol,Long] = ???

doComputation() match {
  case ('Ok, value)   => println("The computed value was ", value)
  case ('Error, code) => println("An error happened, error code: ", code)
}
```

The `doComputation` function returns a tuple, where the first value is a symbol (represented in scala by prefixing the name with a single apostrophe).
This symbole contains if the call succeeded for failed.  The second value of the tuple is actually the return value.  We could capture this into a
value (variable) then do something with it.  Using the a value is the same as underscore except the value is preserved for us to use to the right of the pattern.

This type of deconstruction works with case classes as well...


```scala
case class Person(name: String, gender: String)
```

And given a person we want to do one thing if the person's gender is male and something else if it's female…

```scala
val person = Person("Bob", "male")
person match {
  case Person(name, "male") => print(s"$name, please use the Men's bathroom")
  case Person(name, "female") => print(s"$name, please use the Women's bathroom")
}
```

Classes (case classes specifically) in Scala are also patterns**.  The magic here is that I'm matching the against `gender` using an actual value but `name` is a variable that is being filled with the person's name!  This is actually really amazing because in one line of code I'm expressing a pattern and getting back variables as a result, which I can then use in the code on the right after the `=>`.

** = What is ultimately making all of these things "a pattern" is the presesence of an `unapply` method.

It's possible to use pattern matching outside of the `match` statement too actually...

```scala
val person = Person("Titus", "male")
val Person(name, gender) = person
println(s"Hello $name")
```

## Guards

So what happens if we want to have a pattern of a range?  Say our Person class had age instead of gender, we could do something like…

```scala
case class Person(name: String, age: Int)

val person = Person("Titus", 31)
person match {
  case Person(name, age) if age < 15 => print(s"$name, you cannot drive.")
  case Person(name, age) if age > 15 => print(s"$name, you can drive.")
}
```

The `if age < 15` bit after the pattern is called a "guard".  It allows an additional (albiet boolean) assertion to be applied in order for the pattern to be considered matched.

## Cons (the good kind)

There are some neat built-in patterns that are worth knowing about, in particular `::` is.  In Scala `::` is both a function and a pattern named "cons".  Sequences (arrays, lists, etc.) are based on a computer science concept called ["linked lists"](http://en.wikipedia.org/wiki/Linked_list).  The wikipedia page has a nice graphic which you might want to check out, but basically a linked list is a strategy for storing things in memory where each node has a value and a pointer to the next value.  We could express this with a class…

```scala
case class Node(value: String, next: Node)
```

Note that the second property of Node is "next" which is a reference to another Node.  If we wanted to make a list we could just keep combining Nodes…

```scala
val myList = Node("a", Node("b", Node("c", Nil)))
```

That's verbose and hard to read, so we could make an operator that given any String would return a new Node, adding the Node to the right of it to a list.

```scala
class Node(value: String, next: Node)
def ::(value: String) = Node(value, this)
```

At that point we could construct lists using that function to build a lists.

```scala
// These all produce the same thing:
val myList = Node("a", Node("b", Node("c", Nil)))
val myOtherList = "a" :: "b" :: "c" :: Nil
val myThirdList = Seq("a", "b", "c")
```

So that's cons the function.

What Scala did is that it also made Cons a pattern.  Cons works where an element is on the left and the list is on the right.  The Scala pattern works the same way but also utilizing deconstruction.

```scala
val list = Seq(1, 2, 3)
list match {
  case head :: tail => ...
}
```

This is the pattern you see in Steve's example.  In this case `head` would be 1 and `tail` would be Seq(2, 3) because of how cons works.  At this point you should notice the use of head/tail which align with the recursive solution patterns I sent you.

## An Improvement

Going back to our inital example of having a pattern that matches on the first letter of a `String`, because people are so used to booleans it would be easy to use the cons pattern with a guard...

```scala
case first :: remainder if first == "A" => ...
```

The real benefit of patterns is that it affords us the opportunity to completely bypass booleans (ie. if/thens) and simply express the case we're interested in.  We could instead convert our `String` to a char array and use cons to match the character we're intersted in...

```scala
case 'A' :: rest => ...
```

This pattern reads "the case where the first letter of a string is 'A' and the remainder is anything, assigned to the variable `rest`" which is exactly what we want.

Patterns take some time to learn and get comfortable with but they offer the advantage of being much easier to read.  Once you understand cons you can look at the pattern and instantly know the case we care about rather than having to mentally translate things to a boolean (or worse, mentally make them NOT because a `!` Is hanging around).
