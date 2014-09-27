---
title: Rust Language
date: September 16, 2014
tags: rust
category: rust
---

I started playing with [Rust](http://rust-lang.org) back in December.  At the time it was just a [little too unstable](http://stackoverflow.com/questions/20790793/using-listt-in-rust)
for my tastes, but it seemed like there was potential building with it.  Some time has passed now and it seems like things are shaping up
well.

## Cargo

One recent improvement is that Rust now includes a build tool/library management system named [Cargo](http://crates.io/).  This is a welcome improvement as
now days it's not only the language that matters but the tooling around it.  Cargo is extremely easy to use and works
similar to how `npm` does.

Creating a new Rust project is as easy as:

```shell
$ cargo new my_project --bin
```

Building, running, and executing tests all have a command, `build`, `run`, and `test` as one would expect.

## Guide

Another nice improvement is that a [new guide](http://doc.rust-lang.org/guide.html) is available.  While it's not complete
(within an hour or two I ran into some sections that basically read like: "TODO"), there is a lot there and it's clear that it's
headed in a good direction.

## Tests

Most of Rust was fairly predictable to me in that the concepts in it I've seen or experienced in other languages.  The one surprise so far
has been Rust's implementation of tests.  As an aside, Rust fits in with the likes of `C` and `C++` on the domain of problems that one might
solving using it.  I've observed that lower level systems languages aren't typically ones that have communities with a strong testing culture
(TDD, BDD, whateverDD).  As such I'm curious how much that influenced the following.

Rust includes two types of tests built into the language: integration and unit.  Both, by the way, are executed by `cargo test`.  Integration
tests are external to a module and test it from a "black box" perspective.  They are stored in a separate `test/` directory and are to
me akin to how one might have RSpec or Specs2 tests in a test folder somewhere at the root of a project.

The second type of test, unit tests are 1.) included in the same file as the module being tested and 2.) can see items that are private
to the module that they are within.  When I first learned of this my immediate reaction was one of dislike.  As I let the thought simmer
however I realized what the intent might have been.

If you've ever had the experience of working in a statically typed languages with public/private scoping like Java, Scala, or C# then
you're probably aware of something called "dependency injection".  This is where a class or function will use some mechanism to expose it's
dependencies, perhaps via a constructor or method that can be overridden.  During a test the dependency can be replaced by a mocked or stubbed version.

A good example of this would be a service interface for an API.  The service class will have a dependency on an HTTP client.  When running
tests we don't want to actually make
HTTP calls over the wire and we want to control the response that is returned so that we can test for different conditions based on
what the server might reply with.  To do this we want to inject a mock HTTP client that we can control for the duration of our tests but
still allow the service class to use an actual HTTP implementation when running in production.

There is a lot of ceremony involved in all of that (as I'm sure it sounds just by describing it).  It dawned on me that perhaps the unit
test approach Rust was taking was an effort to avoid all of that mess.  In order for dependency injection to work a class must publicly
expose it's dependencies.  With Rust's unit testing approach the dependencies can remain contained and only modified by the unit test which
is allowed to see the private scope of the module.

Wether or not this will work out to be a good idea or not only time can tell, however having dealt with the song and dance of dependency
injection for a while now I'm open to strategies that lowers the amount of boilerplate around the testing process.

## 1.0

Rust isn't yet at a 1.0 stable release at the time of writing, however it's quickly approaching it and looking at the language now compared
to when I first did in December I can already see polish taking place.  The Rust team just [posted about 1.0 yesterday](http://blog.rust-lang.org/2014/09/15/Rust-1.0.html). The
memory safe aspect combined with the low level nature of Rust makes it an enticing language to do some "systems" level projects.  Given
that I like parsing and the like I wouldn't mind becoming adept at wiring parsers in Rust.  If only I could find an excuse to use it at work now...
