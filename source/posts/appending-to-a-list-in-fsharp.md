---
title: Appending to a List in F#
date: feb 15, 2012
tags: f#, functional-programming
category: f-sharp
---

One thing about functional languages which sounds somewhat simple at first but turns out to be more complex is immutable values.  Variables (or “values” as they’re called in F#) can’t be changed once they’ve been initialized.

```fsharp
let x = 2
// This isn’t allowed:
x = x + 3
```

Values in F# can be thought of as an equivalent to C#’s readonly accessor.

```csharp
int readonly x = 2;
// This isn’t allowed:
x += 3;
```

The reasons for this are beyond the scope of this blog post.  However, while the idea seems simple it contains a few “gotchas”.

One such of these is appending to a list.  In C# this is quite a common task:

```csharp
List<string> names = new List<string>();
names.Add(“Bob”);
```

There is no such thing in F#.  Instead there is the cons operator, `::`, the syntax of which is:

    element :: list

The result from the above is that cons returns a new list, with the element on the left being the first item of that new list and every item which was in list following it.  (Sidenote, the F# documentation actually has this incorrect.  It’s not appended.  Too bad it’s not a wiki.)

    let x = [1; 2; 3;]
    let y = 0 :: x

    val y : int list = [0; 1; 2; 3;]

Cons is a much better performer.  The code doesn’t have to iterate over all the list items just to add the new one.  To illustrate why this is relevant let us suppose we needed the append functionality and we were going to implement it ourself.

We could start by reversing the list, then using cons to add what we want to be the last item to the beginning.

    let a = [1 .. 3]
    let b = 4 :: List.rev a

    val b : int list = [4; 3; 2; 1;]

This gets us halfway, because even though our data is sequenced correctly, the list is in the wrong order.  We can fix that by once again reversing b into our final list.

    let a = [1 .. 3]
    let b = 4 :: List.rev a
    let c = List.rev b

    val c : int list [1; 2; 3; 4;]

At this point it should be obvious why there is no append operator.  Internally the language would be doing this.  You might say, “but it needs to get done, so why not just have a language construct for it?”

Let’s say we refactored the above code into a function for re-use.

    let append elem list = List.rev (elem :: List.rev list)

Great, now let’s use it in some code.  Let’s say we’re using tail recursion and an accumulator to make a list of CSS vendor/webkit prefixes.

    let webkitify props =
        let rec loop list acc =
            match list with
            | head :: tail -> loop tail (append (“-webkit-” + head) acc)
            | [] -> acc
        loop props []

    let props = [“border-radius”; “box-shadow”;]
    let prefixed = webkitify props

Making use of the append function now, how many times is List.rev being called?  Within append it’s called twice which means that our simple function to prefix CSS properties with -webkit- calls List.rev twice for every item of the list (n * 2).

That’s really inefficient.  This is likely a big reason there isn’t an append operator.  Instead a very small change could be made to the function.  First, instead of appending items to the accumulator, the cons operator could be used:

    let webkitify props =
        let rec loop list acc =
            match list with
            | head :: tail -> loop tail ((“-webkit-” + head) :: acc)
            | [] -> acc
        loop props []

    let props = [“border-radius”; “box-shadow”;]
    let prefixed = webkitify props

Then, once the loop has run out of items to recurse through the final result (the accumulator) can be reversed once.

    let webkitify props =
        let rec loop list acc =
            match list with
            | head :: tail -> loop tail ((“-webkit-” + head) :: acc)
            | [] -> List.rev acc
        loop props []

    let props = [“border-radius”; “box-shadow”;]
    let prefixed = webkitify props

And there you have it: Why you don’t need an list append function.

Just for clarity, the above code is just for illustration purposes.  If you really wanted to add -webkit- to a list of props you’d use List.map, which composes a new list based on a function that is applied to every list item.

    List.map (fun x -> “-webkit-” + x) props
