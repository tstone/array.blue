---
title: "Computer Science in Scala: Visitor Pattern"
date: September 30, 2014
tags: cs, cs-in-scala, scala, patterns, scala, implicits
category: scala
published: false
---

The "visitor pattern" is one of those design patterns when reading in the abstract is hard to follow.  Before we look at how it might be useful
in Scala, let's first look at what the original pattern was and what problem it was trying to solve.

What if you have a handful of classes that share some common ancestry.  There must be behavior on all of them to do something but what
if that behavior is outside the scope of the class?  This would be true when the behavior is extremely specific to one use case and thus would
just pollute the class's implementation.

#### Scenario

Say you're writing a media player.  Most people want the basics: play, pause, skip song, playlist.  However you also want to have a plugin that
allows DJ's to calculate the BPM of a song.  We don't want to clutter up the main player with behavior (BPM determination) that isn't core to
the product.

What is a way this problem could be solved?  As you probably guessed from the title and introduction the visitor pattern is one such approach.

## Vanilla Visitor

We start by defining a visitor.  A visitor exposes one `visit` method for every type the visitor will be used on.  This means that fundamentally
the visitor pattern is based on [method overloading](http://en.wikipedia.org/wiki/Function_overloading).  In our simple case let's assume we have
an `Audio` and a `Video` class which both extend `trait Media`.

```scala
trait MediaVisitor {
  def visit(audio: Audio): Any
  def visit(video: Video): Any
}
```

Ignore the `Any` return type.  We'll come back to that in a second.  Next, every class in implements an `accept` method that takes a visitor as it's
argument.

```scala
class Audio extends Media {
  def accept(visitor: MediaVisitor) = visitor.visit(this)
}

class Video extends Media {
  def accept(visitor: MediaVisitor) = visitor.visit(this)
}
```

At this point any behavior we wanted to implement needs to implement the `MediaVisitor` method.  Keeping with our scenario, we could have a BPM visitor.

```scala
object BPMCalculator extends MediaVisitor {
  def visit(audio: Audio) = {
    // ... do some magic to determine BPM from audio stream ...
  }

  def visit(video: Video) = {
    // ... extract audio stream
    // ... do some magic to determine BPM from audio stream ...
  }
}
```

To find the BPM of a song we could then pass `BPMCalculator` to an instance of either `Audio` or `Video`.

```scala
val song = new Song
val bpm = song.accept(BPMCalculator).asInstanceOf[Int]
```

## Improvements with Scala

The `asInstanceOf[Int]` dangling off the end there is ugly.  And it's a bad coding practice.  It means we haven't "proven" our types to the compiler
and so we must cheat and tell the compiler that it's really that thing.

One thing we could start down the road of is changing the `MediaVisitor` trait to allow the implementation to define the return type.

```scala
trait MediaVisitor[A] {
  def visit(audio: Audio): A
  def visit(video: Video): A
}
```

Our class implementations of `visit` can now be updated too.

```scala
class Audio extends Media {
  def accept[A](visitor: MediaVisitor[A]): A = visitor.visit(this)
}

class Video extends Media {
  def accept[A](visitor: MediaVisitor[A]): A = visitor.visit(this)
}
```

When we invoke `accept` now we can explicitly specify the return type.

```scala
val bpm = song.accept[Int](BPMCalculator)
```

However Scala's type inference can actually figure it out, which means we can totally remove it leaving us with:

```scala
val song = new Song
val bpm = song.accept(BPMCalculator)
```

This is a decent improvement.  The visitor pattern in Scala now works as intended.

## Using Native Language Features

Scala might have a better way.  Implicit classes effectively allow extension methods on a class by combining a new class with an `implicit def`.  Say
we kept our `BPMCalculator` object but turned it into a class and renamed the method from `visit` to `calculateBpm`.

```scala
class BPMCalculator {
  def calculateBpm(audio: Audio) = {
    // ... do some magic to determine BPM from audio stream ...
  }

  def calculateBpm(video: Video) = {
    // ... extract audio stream
    // ... do some magic to determine BPM from audio stream ...
  }
}
```

An implicit def would allow a `Song` or `Video` to be...

TODO: Finish me!
