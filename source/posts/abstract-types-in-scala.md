---
title: Abstract Types in Scala
date: may 29, 2010
tags: scala
category: scala
---

Whenever I learn new programming languages, there is invariably features of the language that will surprise me.  One of those in Scala (one of many actually) is abstract types.  When I first read the textual description of an abstract type, I wondered what use it would ever entail.  However, the authors of [Programming Scala](http://programming-scala.labs.oreilly.com/) gave a very clear example of proper use.

This code snippet comes from Chapter 2 of the book.

Starting with an abstract class, we can declare an abstract type.  In this case, type `In` on our class `BulkReader` is abstract.  It’s there, but it does not have a concrete type associated with it.  Yet, our value `Source` is typed as type `In`.  How can this be?

```scala
abstract class BulkReader {
  type In
  val source: In
  def read: String
}
```

The magic comes when we declare a concrete version of `BulkReader` and can assign a concrete type to “In”:

```scala
class StringBulkReader(val source: String) extends BulkReader {
  type In = String
  def read = source
}

class FileBulkReader(val source: File) extends BulkReader {
  type In = File
  def read = {
    val in = new BufferedInputStream(new FileInputStream(source))
    val numBytes = in.available()
    val bytes = new Array[Byte](numBytes)
    in.read(bytes, 0, numBytes)
    new String(bytes)
  }
}
```

Very cool!  In our two concrete instances of `BulkReader` we assigned two different types to our abstract type `In`.  Note that the value typed as `In`, “source” is actually part of the concrete class’s constructor which is, at this point for me, completely mind bending in terms of flexibility towards class design.

I have a feeling it will take me some time to get used to this notion and power before I really start to design code that makes use of it.
