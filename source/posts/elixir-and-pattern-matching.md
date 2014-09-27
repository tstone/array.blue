---
title: Pattern Matching in Elixir
date: February 18, 2014
tags: elixir, pattern-matching
category: elixir
---

[Elixir](http://elixir-lang.org/) includes a bit of a mind twist around the equal sign (`=`).  I'm not sure what the origin of this was, if it started in Erlang or
some previous language.  In any case, in the overwhelming majority of languages `=` is assignment.

```javascript
var foo = "asdf";
```

This is a special syntax in most languages for allocating memory and setting the value of that memory.

In Elixir however `=` is actually _pattern match_.  That is by saying `x = 5` in Elixir you are not saying "initialize some new memory which
I will refer to as `x` and set in it the value of 5".  That effect will happen, but what you are actually saying is, "Match a variable `x` to
the value 5".  Elixir's pattern matching engine sees the variable of `x` as a "wildcard pattern" and thus de-structures the right hand of the `=`,
`5` into the variable `x`.

It sounds like a mouthful when written out so perhaps some examples are in order (taken from `iex` the interactive Elixir console):

```elixir
iex(1)> x = 6
6
iex(2)> x
6
```

This is a slightly different way of thinking about what `=` means, however it provides some mental question marks.  For example, what happens
if the patterns are not equivalent?

```elixir
iex(1)> 7 = 6
** (MatchError) no match of right hand side value: 7
```

You get an exception.  I find that a little odd.  However since Elixir is built on the Erlang VM and erlang actors are all about "crash
and restart" I'm guessing that's just "part of the platform" and something I'm not yet comfortable enbrancing.

On the positive side where pattern matching is useful is in destructuring values. I'm
not a huge fan of using exceptions for flow control.

```elixir
iex(1)> [_, x] = [1, 2]
[1, 2]
iex(2)> x
2
```

Scala and Python also have this same feature as well.
