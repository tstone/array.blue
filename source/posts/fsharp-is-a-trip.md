---
title: F# is a Trip (or What is Function Currying)
date: feb 11, 2012
tags: f#, functional-programming
category: f-sharp
---

For developers that have been living in javaland, javascriptland, or C#land for any lengthy period of time, the first encounter with a very functional language, it’s definitely weird.  F# is Microsoft’s latest language addition to their .NET kingdom.  It’s a functional/object oriented hybrid language which leans more towards the functional side and finds it’s roots in OCaml.

Quite frankly, it has some of the coolest features you’ll find on .NET at the moment, which head and shoulders above the rest of the .NET languages is the interpreter.  Further, the integration of the interpreter with Visual Studio reminds me of a Paul Graham quote from Hackers and Painters, (paraphrased) “programming languages should be for programmers to sketch in”.

It works like this:

  - Highlight code you’d like to execute
  - Press Alt+Enter
  - The code runs and the result appears in a console below the code, directly in Visual Studio

As it turns out the interactive console is also great for language exploration.  The syntax of F# is a bit more minimal than you’d expect coming from C#.  Functions are defined just like values using an = where parameters aren’t wrapped in parenthesis.

    let increment x = x + 1

Running that in the interpreter returns

    val increment : int -> int

Two really important things are in that line.  First, F# inferred the type.  No where in the code is int specified as the type.  F# is a strongly typed language, but it will infer the type.

The second important thing is that F# returned to us the type signature of the function.  This type signature business is reminiscent of languages like Scala and Haskell.  `int -> int` — It basically means one integer is inputted and one integer is outputted.

But things get more interesting.  The increment function could be given a more broad usage.

    let add x y = x + y

Interpreting the new function add returns

    val add : int -> int -> int

That is not what one would expect.  The way the function is written is the average developer would expect a type signature of

    val add : int, int -> int

But that’s not what F# is returning.  Reading the type signature, it appears that F# is interpreting the add function as two functions which it turns out is the case.  If the lack of `()`’s on the functions was odd at first, then this is part of the reason why.  For each parameter on a function, behind the scenes F# makes a new function that returns a function.  (It’s not called a “functional language” for nothin’)

Why does all of this matter however?  Is it just compiler trickery or is there any use for this?  Because F# is internally creating a function for each additional parameter past the first one, if only _some_ of the arguments were to be passed into `add`, what would be returned would not be a result, but another function.

Consider

    let add x y = x + y
    let increment = add 1

    > val increment : (int -> int)

    let a = increment 2

    > val a : int = 3

The type signature for increment is `int -> int`!  Increment is a partially applied function.  It executions _some_ of the parameters of `add`.

This is function currying.

It’s a trip.
