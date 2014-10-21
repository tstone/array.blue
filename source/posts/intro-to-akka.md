---
title: "Getting Started with Akka and Testing"
date: October 13, 2014
tags: scala, akka, actor
category: akka
---

#### Assumptions

 1.  You have a working knowledge of Scala
 2.  You don't know anything about Akka
 3.  You know how to write and run tests
 4.  You know how to use SBT to add dependencies to your project

### Introduction

Akka is one of those libraries that seems like a party that everyone is enjoying except you.  Or at least that's how I felt for a long while. Part of the reason
I suspect this is so is because while Akka includes [comprehensive online documentation](http://akka.io/docs/) it's difficult to go from a description
of the pieces to knowing how to apply them to building systems.  This is particularly true
for those who have worked with other concurrency models and come to Akka with some pre-conceived ideas about how things work.

In truth Akka actually _simplifies_ the task of building concurrent systems but has a prerequisite that you to have some key points of understanding first,
and without those it's easy to get lost.  As you read the following guide continually ask yourself, "What is Akka doing for me, and what do I need to do?"
Being able to answer this question is the first step towards sucess with Akka.


### Understand Your Part

The most important part of using Akka is comprehending what the developer is responsible for and what the framework is responsible for.  A lot of poor
architectural decisions await if this isn't well understood.  Akka has many features but most don't magically appear without you doing something.

As you're probably aware the unit of abstraction in Akka is the *Actor*.  [Actors](http://en.wikipedia.org/wiki/Actor_model) aren't unique to Akka but Akka
does have it's own slant on things which care should be given to learn.

```scala
class MinimumViableActor extends Actor {
  def receive = Map.empty
}
```

The minimum requirement for an actor is that it implements `def receive: Receive`.  `receive` is just a Scala partial function with a type signature of
`Any => Unit`.  You might be wondering what the `Map.emtpy` bit on the end there is -- In scala `Map.empty` will represent a partial function that does nothing.
It's a bit weird, I know, but that's the syntax.  Only if you want an actor that does nothing would you write that (which probably means you can throw away
that knowledge right now).


### Messages

`receive` will be called whenever a message is sent to your actor.  You can think of messages as a hybrid between an event happening in the
system and a function call.  Unlike pub/sub systems or the browser DOM, events aren't pushed to every actor in the system.  They must be explicitly sent
to an actor (more specifically to an actor _reference_, which we'll get into later).  In addition to incoming messages, an actor will probably want to send
outgoing messages to other actors.

For example, if there was an actor which read from the database, an incoming message might be "read this row" and the actor would
reply by sending back that database row after fetching it from the database.

Let's build a simple actor which just echos whatever messages it receives.

```scala
class EchoActor extends Actor {
  def receive = {
    case msg => sender ! msg
  }
}
```

The `Actor` trait puts some methods and values in scope.  `sender` comes from `Actor` and is a function (`def`) which returns the "thing" that sent the current
message  to the actor.  The fact that it is a function will become relevant later.


### Testing

Before we get too far into Akka, it's useful to talk about testing.  A system that you can't trust and refactor isn't any fun to work on.  Getting into testing
early on will also let you explore how Akka is working which will make learning faster.  Akka includes a library called "TestKit"
([documentation](http://doc.akka.io/docs/akka/snapshot/scala/testing.html)).

##### A Couple Things to Note:

  1. I'll be using [Specs2](http://etorreborre.github.io/specs2/), but the same things should work with with Scalatest or whatever other framework
  2. TestKit is not included by default with Akka, it must be added as an additional dependency.

Let's write a test for our `EchoActor`.  We want to assert that when our actor receives a message it echos that exact message back to the sender.

```scala
class EchoActorSpec extends Specification {
  "=> Any" should {
    "echo message back to sender" in {
      ???
    }
  }
}
```

We've stubbed out what the test might look like.  I like to describe tests which have to do with a message being sent to an actor as starting with "=>" and describing
the type of the message.  This is a personal preference and is not a requirement.  Right now we only have one message and it's type is `Any` so it isn't too helpful.
Later when we have actors that receive many messages types it becomes a nice way to organize tests.

Before we can write an actor test we need to mixin the bits that Akka TestKit gives
us.  The first thing is to change `Specification`, which is a class, to `SpecificationLike` which is a trait as TestKit requires us to inherit from a `TestKit` class.

```scala
class EchoActorSpec extends TestKit(ActorSystem("test-system")) with SpecificationLike
```
`TestKit` creates a new `ActorSystem` to run the tests -- that's the thing which manages all the actors.  It's a good practice to shut down the system
after the Spec is done running so we can add that...

```scala
class EchoActorSpec extends TestKit(ActorSystem("test-system")) with SpecificationLike {
  override def map(fs: =>Fragments) = fs ^ Step(shutdownTestKit)
  private[this] def shutdownTestKit = TestKit.shutdownActorSystem(system)

  ...
}
```

I realize this syntax is a but funky bit you won't ever have to type this again (I'll show you in a second).  All this does is say, "after the examples
have finished running, execute the step `shutdownTestKit`".  While we're setting this up I have a few recommendations that will make things easier
later on.

First, when dealing with asynchronous things it's easier to debug if the specs run in the order you've entered them.  By default Specs2 runs each `should`
block at random or in parallel (depending on config) but it would be easier if we ran them all in order.  This can be achieved by adding `sequential` as
a step.

Second, TestKit includes a trait `ImplicitSender` which will set the sender whenever you send a message to an actor your testing.  Later on this will make
assertions a tad easier.

Third, by default Specs2 includes implicit conversions for duration.  Unfortunately the duration type it implicitly converts to is not the same duration type that
Akka uses.  This can lead to frustration later on by typing in `1.second` (been there, done that).
These implicit conversions can be disabled by mixing in the trait, `NoTimeConversions`.

So our final test boilerplate for testing an Akka actor should look like the following.

```scala
class EchoActorSpec extends TestKit(ActorSystem("test-system"))
  with SpecificationLike
  with ImplicitSender
  with NoTimeConversions {

  override def map(fs: =>Fragments) = sequential ^ fs ^ Step(shutdownTestKit)
  private[this] def shutdownTestKit = TestKit.shutdownActorSystem(system)

  "=> Any" should {
    "echo message back to sender" in {
      ???
    }
  }
}
```

Right.  That is pretty ugly and verbose.  I highly recommend making an `abstract class` somewhere else that you can inherit from for all your Akka specs.

```scala
// src/test/scala/support/ActorSpec.scala

package test.support

abstract class ActorSpec extends TestKit(ActorSystem("test-system"))
  with SpecificationLike
  with ImplicitSender
  with NoTimeConversions {

  override def map(fs: =>Fragments) = sequential ^ fs ^ Step(shutdownTestKit)
  private[this] def shutdownTestKit = TestKit.shutdownActorSystem(system)
}
```

This will then clean up the actual spec...

```scala
import test.support.ActorSpec

class EchoActorSpec extends ActorSpec {
  "=> Any" should {
    "echo message back to sender" in {
      ???
    }
  }
}
```


### Asking

Now that we've got all the setup out of the way once and for all, let's actually test the actor.  If we just sent a message to our actor and it did
something and that was it, we might write a test that sends the message then checks that whatever thing happened.  However, we expect that not only
will our actor receive messages, but also that it will reply.

To test a response we can use a thing called _ask_.  Ask has two different syntaxes but the more common one is `?`.  By default ask is not in scope
and must be imported with `import akka.pattern.ask`.

Ask is easy to abuse so before you see the code for it understand this: Ask is primarily for outside code to interface with the actor system.  It is
not for use within your actors, specifically for them to talk to each other.  It's possible to write code like that but you want to avoid doing so.
Test are a perfect example of "outside code" that is "interfacing" with your actor system, so ask will make your life easier in this context.

```scala
import test.support.ActorSpec
import scala.concurrent.duration._

class EchoActorSpec extends ActorSpec {
  "=> Any" should {
    "echo message back to sender" in {
      val subject = TestActorRef[EchoActor]
      val futureResp = (subject ? "arkanoid").mapTo[String]
      val resp = Await.resolve(futureResp, 1.second)
      resp mustEqual "arkanoid"
    }
  }
}
```

There are some new bits of syntax here.  The `TestActorRef[EchoActor]` part tells Akka to create a new `EchoActor` and to do so specifically for testing.
`TestActorRef` is a type that let's us reference an actor, giving us special access for testing that we wouldn't otherwise have in a running system.  It also makes
the messaging synchronous and thus easier to test.

On the next line our first use of ask appears, `subject ? "arkanoid"`.  Ask always returns a `Future[Any]`.  It's possible to change the type
through `mapTo` which is shorthand for `(subject ? "arkanoid").map(_.asInstanceOf[String])`.

There are other ways to test that messages came back.  However ask is the simplest of them to use.  The downside is that the future must
be unwrapped.  In this case I turned the asynchronous future into a synchronous wait through `Await`.

The clever `1.second` syntax is made possible through the duration import, `import scala.concurrent.duration._`.  It specifies how long the test should
wait for that Future to resolve before considering it a failure.  `Await` returns the value inside the Future, which in this case is our response message
that the actor sent back to us.

Personally I find the Await syntax slightly verbose.  I prefer to create a helper function to simplify it a bit.  Typically I stick this helper function
on my `ActorSpec` class so that all actor tests can use it...

```scala
implicit val timeout: Duration = 1.second
def await[A](futureResp: => Future[Any])(implicit timeout: Duration) =
  Await.resolve(futureResp, timeout).asInstanceOf[A]
```

This shortens the test syntax down to...

```scala
"echo message back to sender" in {
  val subject = TestActorRef[EchoActor]
  val resp = await[String] { subject ? "arkanoid" }
  resp mustEqual "arkanoid"
}
```
