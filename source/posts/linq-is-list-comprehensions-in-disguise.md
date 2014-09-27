---
title: LINQ is List Comprehensions in Disguise
date: feb 9, 2012
tags: linq, c#
category: c-sharp
---

I had a stunning realization last night.  LINQ is nothing more than Microsoft’s implementation of Haskell  list comprehensions (a language I greatly admire).  It’s not obvious this is what LINQ is, because Microsoft chose to change the keywords to be more SQL-like.

In Python or ECMAScript 6, a list comprehension can be written like so:

```python
[x for x in set (if condition)]
```

Say for example you had a list of numbers and you wanted to find the value of them squared.  You could write something verbose like…

```csharp
public List<int> Square(List<int> input)
{
    List<int> result = new List<int>();
    foreach (int i in input)
        result.Add(i * i);
    return result;
}
```

List comprehensions would allow that to be written in a much more succinct way…

```python
[x * x for x in list]
```

That’s much shorter and easier to tell the intent of what’s happening.  With a list comprehension, it’s also possible to add a conditional in there too.  For example, let’s say we only wanted to find the squared value where x was even.

```python
[x * x for x in list if x % 2 == 0]
```

It turns out, this is what LINQ is.  Microsoft made a few changes however:

The first phrase in a list comprehension is typically the function to map against.  Microsoft moved this to the end of the statement and called it `select`  The `for` was renamed `from`. `if` was renamed to `where`.

So we can take that exact list comprehension from a dynamic/functional language…

```python
[x * x for x in list if x % 2 == 0]
```

And re-write it in LINQ…

```csharp
from x in list where x % 2 == 0 select x * x
```

Do you see it?  It’s the exact same thing, though perhaps slightly more verbose.  LINQ == List Comprehensions.

When we talk about LINQtoSQL then, what we’re really talking about is “List Comprehensions to SQL” which on the surface seems like a really interesting idea (implementation aside).  LINQtoSQL is basically, given a data set, can a programmer succinctly express a list comprehension concept against it, with that concept being rendered into SQL.

Under the covers LINQ’s `select` is really just the functional Map.  Likewise LINQ’s `aggregate` is really just Reduce.  Using both of these it’s possible to write very functional code, strongly typed, with list comprehensions, _in C#_.  The odd part is that all of these excellent pieces were hidden under the covers of what looked to be a simple SQL-injected-into-C# project.  It’s not.  It’s much more than that.
