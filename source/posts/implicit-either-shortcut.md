---
title: Implicit Either Shortcut
date: July 28, 2014
tags: scala, implicits
category: scala
---

I have some team members that get weirded out when using `Either`, specifically around the fact
that you have to wrap everything in ether `Left` or `Right`.  It hit me, it's always obvious in
retrospect, that it's possible to just write an implicit conversion for this and abstract it away
(for better or for worse)...

```scala
implicit def aToEither[A,B](a: A): Either[A, B] = Left(a)
implicit def bToEither[A,B](b: B): Either[A, B] = Right(b)

def f(input: Either[String, Int]) = input match {
  case Left(s) => println(s"Hello, $s")
  case Right(i) => println(s"You are $i years old")
}

scala> f(10)
You are 10 years old
```
