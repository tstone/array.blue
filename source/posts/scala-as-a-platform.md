---
title:  Looking Back on a Fulltime Year With Scala
date:   August 15, 2014
tags:   scala
category:  scala
---

I've been using Scala professionally (read: every day) for about a year now.  Here are some thoughts I have about it looking back.

## Pros

#### 1.) Type signatures as an enforced contract have done wonders for architecture and design
I've worked in other statically typed languages for years (C# for 5-6 years) but something about the emphasis and syntax around
function type signatures really pushes them to the forefront.  I suspect this is in part because a function's return type is written _after_
the arguments (unlike Java, C#, and similar).  Overall this has made a really big difference for me personally and I assume
for others as well.  Before, I would think about what the function did, now I think in terms of the "contract" a type signature makes.  

Before, we might have talked about "a function that waits for promises to resolve and then gets rid of the ones that didn't return a
result".  Now I can talk with team members by saying `Seq[Future[Option[A]]] => Future[Seq[A]]` and it's very clear what's being talked about.  What I've found is that it's much easier to design systems, because the focus ends up being on designing only the type signatures (aka interfaces/contracts) and once all the type signatures fit implementation is just a matter of writing the function body.

#### 2.) Separation of concerns is enforced via the compiler
The ability to describe modules and their relationships, then have that enforced at the compiler level is phenomenal.  Since we learned about this feature we've used it extensively in all projects.  I feel like the proof is really evident, we can fire up a new Scala project and the overwhelming majority of code in the libraries is immediately usable because there is no coupling to the app it was originally written for and where there is coupling those relationships have been carefully defined.

#### 3.)  A wealth of concurrency management libraries
Scala Futures, Scalaz Tasks, and Akka Actors — Compared to other languages that are common in industry use it's almost embarrassing how many options Scala has to choose from to deal with concurrency.  And what's even better is all 3 of those aren't just some off beat hobby projects they're all well supported and known projects with active communities.

#### 4.) Static types force branches to be dealt with
Scala's standard library includes a handful of monads that are extremely useful, like `Option` (Maybe monad in Haskell and Swift).  These let a function say, "I may or may not return a value".  Because it's a type enforced by the compiler, it means that consuming code needs to deal with as well.  It means when you call that function, right away you need to address both branches if you get a value or don't.  Compare this to null in Java, Javascript, Ruby, etc. which are very often forgotten to be dealt with until it causes a problem.


## Risks

#### 1.)  Implicits need caution
Implicits are such a double edged sword.  On one hand I've been able to pull off some neat DSL-like things with them.  On the other hand most of my team rarely works on that code because you have to really understand how they work.  One of the ideas Scala tries to offer is that you can have your senior developers writing implicts and your junior devs consuming them without understanding the "magic" under the covers.  In practice that kind of happens but not really.  Implicits become a leaky abstraction.

Implicit similiarly parameters look like they solve dependency problems but they just spread more parameters around.  Implicit type conversion works as long as you have a specific type, otherwise you have to manufacture a type just for conversion.  At the same time it's easy to end up with really weird errors because some implicit conversion is applying where it wasn't intended.  I've also seen at least 1 bug hit production (including not failing any tests) because an implicit conversion subtly changed it.

#### 2.)  Fancy type system
Scala allows type-level programming.  This for-sure fits into the category of "fancy".  For example, I can describe a class that extends an existing type, then describe methods that are only for child types of the type I extended.

```scala
implicit class PlaceOps[A <: PlaceLike](place: A) {
  def delays(implicit mf: A =:= AirportLike) = ???
}
```

I don't feel that really adds much business value.  It lets people who like to geek out on "correctness" to do some crazy things that no one else on the team understands.


## Cons

#### 1.)  Near impossible to do TDD
Your tests won't even compile until you've scaffolded out everything.  That kind of defeats the purpose of really being "test driven".  Also because of how mocking and such works, it's much more difficult to do.  You could to TDD in Scala and some people do try but it doesn't work anything like how Ruby or Javascript do.

#### 2.)  Legacy module system
SBT uses Ivy2 which uses Maven.  Why use one package manager when you can use three?  Want to setup a server for your modules?  Cool, better learn how to configure maven because you'll need to configure that from SBT and make sure ivy2 doesn't muck it up on the way!  Surprise, Maven uses different domain concepts than SBT, have fun reading their documentation too.  Hey, I've got an even better idea:  We should take all our javascript files and roll them up as Maven modules too!

This is where more recent platforms are killing it.  NPM for node is far and away one of the better package managers out there.

#### 3.)  Complex build system
They thought it was a good idea to literally invent a new language based on symbols to configure a build.  Sometimes you
use `<<<=` and sometimes you use `<<=` and other times `++=` and other times `:=` and so on.  I've gotten used to it and I've
put together my fair share of "clever" build scripts, but it's always interesting to see the bewilderment of engineers new to
a project when they first encouter an SBT build script.

#### 4.)  Slow
Scala compilation is painfully slow.  Painfully slow.  For a largish project test execution time (excluding browser integration tests) is around the 8-10 minute mark depending on what needs to be compiled.  Average is around 4-5 minutes.  Oh you wanted to run tests?  Hang on, your IDE has a lock on your ivy2 file.  Similar sized projects in Ruby/Rails, for example, have test execution times around 1:45 including Capybara integration tests.

#### 5.)  Boilerplate
There are several places I'm starting to notice now that we waste a lot of time doing boilerplate that is borderline configuration.  The scala meta project has the chance of really cleaning those things up, but right now it's just a promise and is probably a solid year or two away.

#### 6.)  Community
[PLT Hulk](https://twitter.com/PLT_Hulk/status/508990357540192256) has already summed this up well:

> SCALA AM ALREADY FRAGMENTED AN LONG TIME: 1 THEM WRITING HASKELL FANFIC 2 THEM WRITING HASKELL FANFIC FANFIC 3 JAVA-SCENTED SCALA!

There is also the now forked compilers:  [Typelevel](http://typelevel.org/blog/2014/09/02/typelevel-scala.html)
