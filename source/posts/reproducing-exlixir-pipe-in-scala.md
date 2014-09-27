---
title: Reproducing Elixir's |> in Scala
date: September 27, 2014
tags: elixir, scala
category: elixir
---

Elixir includes a pipe operator `|>` which it borrowed from F#.  The way `|>` works it that given a function on the left it
takes the output of that function and applies it as the first argument of the following function.

```elixir
def inc(x), do: x + 1
def double(x), do: x * 2

1 |> inc |> double
```

This can be simulated in Scala.

The first step is to identify the type signature.  `1 |> inc` is saying any (`A`) can call a method `|>` and pass it a `Function1[A, B]`.

```scala
implicit class PipeOp[A](a: A) {
  def |>[B](f: Function1[A,B]): B = f(a)
}
```

That's it.  No, really, that's it.  That is the pipe operater implemented in Scala.

### Partial Application

It might seem limiting that it's restricted to a `Function1`.  What if, for exmaple, the function we
wanted to pipe was...

```scala
def incBy(incrementBy: Int, x: Int) = by + x
```

One thing we could do is partially apply the function.

```scala
1 |> incBy(5, _: Int)
```

For some reason this fails.  It seems like it should work as a partially applied function returns a function.  This might be a Scala compiler
bug.

```
<console>:13: error: missing parameter type for expanded function ((x$1) => inc2(5, x$1))
              incBy(5, _)
```

### Currying

The work around, and probably the better choice in the first place, is to just curry the function to begin with.

```scala
def incBy(inc: Int)(x: Int) = inc + x

...

1 |> incBy(5)
```
