---
title: Angular Filters for Play
date: May 8, 2014
tags: play, scala
category: scala
---

I was looking at the Angular filters a bit.  As a pattern I think they are conceptually simpler than our current notion of presenters in Scala.  For consistency of development on a Play/Angular project, I was wondering if it would be good to have one concept of how to deal with presentation for both JS and Scala.  I prototyped a filter system for Twirl that is functionally equivalent to Angular filters in Scala and the syntax is super close too (unfortunately Twirl has already reserved `|` and `||` so I used `|||`, but that operator could be whatever).

It's pretty common to use implicit classes to apply the presenter pattern in Play...

```scala
// presenters.scala
object presenters {
  implicit class StringPresenter(s: String) {
    def reverse = Html(s.reverse)
  }

  implicit DateTimePresenter(dt: DateTime){
    def format(f: String) = DateTimeFormat.forPattern(f).print(dt)
  }
}


// index.scala.html
@import presenters._

@main {
  <h1>@message.reverse</h1>
  <h3>@event.start.format("YYYY-MM-dd")</h3>
}
```

Filters as a concept however are really just a function.  You could make a `|` method that implicitly used such functions...

```scala
// filters.scala
object filters {

  // --- Setup (once for all filters) ---

  type HtmlFilter[A] = (A) => Html

  implicit class Filtererer[A](a: A) {
    def |||(filter: HtmlFilter[A]): Html = filter(a)
  }

  // --- Filter Examples ---

  val reverse = new HtmlFilter[String] {
    def apply(s: String) = Html(s.reverse)
  }

  def format(f: String) = new HtmlFilter[DDateTime] {
    def apply(date: DateTime) = Html(DateTimeFormatter.forPattern(f).print(date))
  }
}


// index.scala.html
@import filters._

@main {
  <h1>@{ message ||| reverse }</h1>
  <span>@{ event.start ||| format("YYYY-MM-dd") }</span>
}
```

The limitation here compared to Angular filters is that they cannot be chained.  ...or at least I haven't yet figured that part out.

[gist](https://gist.github.com/tstone/db350000ba9230bdfa38)
