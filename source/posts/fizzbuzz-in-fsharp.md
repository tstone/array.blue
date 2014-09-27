---
title: FizzBuzz in F#
date: feb 18, 2012
tags: f#, fizzbuzz
category: f-sharp
---

If you’re not familiar with what FizzBuzz is, check out [this blog post by Jeff Atwood (Coding Horror)](http://www.codinghorror.com/blog/2007/02/why-cant-programmers-program.html).  FizzBuzz is sort of that bare-minimum-entry-level-bar that when you can clear you know you’ve at least understood the basic grammar of a language.  Typically I find in learning languages what takes the most time is really learning the standard library and built in functions.

F# has proven to be no exception to this and even though it has the entire .NET framework library behind it, there were some quirky things there to trip me up.  A great example is the `printfn` function.

Consider the following, which, though it seems like a trivial bit of code is actually wrong:

    let x = “Hello World”
    printfn x

Running the above will thrown an exception…

  > The type ‘string’ is not compatible with the type ‘Printf.TextWriterFormat<’a>’

Really?  A `string` can’t be printed out?  There’s a [question on StackOverflow](http://stackoverflow.com/questions/2162081/type-of-printfn-in-f-static-vs-dynamic-string) which summarizes why this happens, but the short version is that `printfn` expects input to be of type `TextWriterFormat<T>`.  Right.

So the fix for the code above would be:

    let x = “Hello World”
    printfn “%s” x

I’ve been trying to write FizzBuzz in F# now for a week and while I probably have had it correct for a while, the printfn issue has been throwing me off this whole time.

In any case, here is FizzBuzz in F# (where the side effect of printing has been isolated to outside of the function):

    let fizzbuzz n =
        match n with
        | n when n % 15 = 0 -> “FizzBuzz”
        | n when n % 5 = 0  -> “Buzz”
        | n when n % 3 = 0  -> “Fizz”
        | _                 -> n.ToString()

    [1 .. 100] |> Seq.iter(fun x -> printfn “%s” (fizzbuzz x))
