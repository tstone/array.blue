---
title: For Comprehension and Serial Futures
date: January 15, 2014
tags: scala, future
category: scala
---

One of the really neat features of the Scala standard library is `Future`.  These are like javascript promises on
steroids.  However Futures can be a bit magical if you don't understand how they or for comprehensions work.

I set out to understand this better, not by reading the documentation, but by using the Scala console to actually
test what the behavior was.  My complete test code, including the benchmarking is in a [gist](https://gist.github.com/tstone/8449893).

I put together three different ways that Futures were called because I wanted to see if they actually were behaving concurrently.

### 1. For Comprehension

The Scala language includes a for comprehension which allows monads that implement `flatMap` to be written together in a single control structure.
This was the form I had seen Futures used in the most.

```scala
def test1 = {
  for {
    f1Result <- Future { Thread.sleep(3000); 1 }
    f2Result <- Future { Thread.sleep(3000); 2 }
    f3Result <- Future { Thread.sleep(3000); 3 }
  } yield (f1Result, f2Result, f3Result)
}
```

### 2. Future Then Comprehension

Suspecting that the above code wasn't correct, my second test was to first invoke all the `Future`'s, then use a for comprehension to "un-wrap" them.

```scala
def test2 = {
  val fut1 = Future { Thread.sleep(3000); 1 }
  val fut2 = Future { Thread.sleep(3000); 2 }
  val fut3 = Future { Thread.sleep(3000); 3 }

  for {
    f1Result <- fut1
    f2Result <- fut2
    f3Result <- fut3
  } yield (f1Result, f2Result, f3Result)
}
```

### 3. Future Sequence

Lastly, the `Future` includes a `Future.sequence` method which basically does `Seq[Future[A]] => Future[Seq[A]]`.  However, I wasn't sure if
the futures were continuing to run in parallel at that point or if they were in series.

```scala
def test3 = {
  // Seq[Future] => Future[Seq]
  Future.sequence(Seq(
    Future { Thread.sleep(3000); 1 },
    Future { Thread.sleep(3000); 2 },
    Future { Thread.sleep(3000); 3 }
  ))
}
```

## Results

And the results were...

```
[test2] elapsed time: 3s
[test3] elapsed time: 3s
[test1] elapsed time: 9s
```

The semi-surprise here is that using the for-comprehension to invoke the future was the slowest, causing them to run in series.  After understanding
for-comprehensions better this made sense.

Ultimately this...

```scala
for {
  f1Result <- Future { Thread.sleep(3000); 1 }
  f2Result <- Future { Thread.sleep(3000); 2 }
  f3Result <- Future { Thread.sleep(3000); 3 }
} yield ???
```

Is the same thing as this...

```scala
val f3Result = Future { Thread.sleep(3000); 1 }.flatMap { f1Result =>
  Future { Thread.sleep(3000); 2 }.flatMap { f2Result =>
    Future { Thread.sleep(3000); 3}.map { _ =>
      ???
    }
  }
}
```

What should be obvious in the expanded form is that the subsequent futures are not being started until the initial future is completed.  In other words
invoking a `Future` in a for-comprehension makes it run in series.
