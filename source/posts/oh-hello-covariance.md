---
title: Oh, Hello Covariance
date: January 21, 2014
tags: scala, covariance
category: scala
---

Having read about co- and contra-variance when I first learned Scala, I, for the most part, stuck them in the back of my head and forgot about it.  As it turned out, I was actually able to solve a real world problem with it.

The problem that I needed to solve was two fold:

  1. Can we have an abstract class (or trait) which has multiple implementations that all return the same type but take in a different types as parameters
  2. Can we deal with instances of these classes in bulk (ie. `Seq` or `Set`)

The particular use case of this was in creating a structured way that 3rd party tracking pixels could be generated.  On one hand every 3rd party has something slightly different they need for their pixel.  On the other hand we wanted to be able to
deal with pixels generically downstream.  For a given web request we will have a `Seq` of 3rd parties that need to have pixels generated for.  the goal was to take that list and turn it into a list of things that needed to be tracked, events, pixels, urls, whatever.

The first part of the problem is somewhat easy to solve.  Expose a function that returns impression pixels for a given provider.

```scala
abstract class TrackingProvider {
  def getImpressionPixels(foo: String, bar: String): TrackingPixel
}
```

The tricky part however is that each provider needs different data.  Vendor A might need some values out of the cookie and querystring where as Vendor B might need something from a database.  Polymorphism is the answer.

```scala
abstract class TrackingProvider[A] {
  def getImpressionPixels(payload: A): TrackingPixel
}
```

The class itself becomes polymorphic, and any implementation can supply it's definition of what `A` actually is.  As an example, an implementation for (a fictitious) `VendorA` might look like:

```scala
case class VendorATrackingConfig(vendorId: String, propertyId: String)

class VendorATrackingProvider extends TrackingProvider[VendorATrackingConfig] {
  def getImpressionPixels(config: VendorATrackingProvider) = ???
}
```

Because the class itself is polymorphic, when we inherit from it, we can specify what A is: `extends TrackingProvider[VendorATrackingConfig]`.

However, what this does not solve is the latter part:  We cannot deal with these in bulk.  For example, let's say we wanted to have a function to turn `Seq[ThirdParty]` into `Seq[TrackingProvider]`.  The problem is, you can't just have a `Seq[TrackingProvider]`, you must have a `Seq[TrackingProvider[SOME_TYPE]]` because `TrackingProvider` as a class is polymorphic.  We have this same issue, for example with `Seq`/`Option`.  You can't have `Seq[Option]`.  You must have `Seq[Option[TYPE]]`.

As an example, the following code would be invalid because a Seq must all be the same type.  Given the following list…

```scala
Seq(
  new VendorATrackingProvider,
  new VendorBTrackingProvider
)
```

...this is actually how Scala sees that list:

```scala
Seq(
  TrackingProvider[VendorATrackingConfig],
  TrackingProvider[VendorBTrackingConfig]
)
```

And you can't mix types like that... unless you tell Scala otherwise.

Our first thought was to create a base type that the configs could inherit from. This was a partially correct solution.

```scala
trait TrackingConfig

abstract class TrackingProvider[A <: TrackingConfig] {
  def getImpressionPixels(payload: A): TrackingPixel
}
```

The `A <: TrackingConfig` part specifies a type restriction on `A` that it must be or be a child of `TrackingConfig`.

If all the `$VENDORTrackingConfig` classes were to extend that trait, it would seem like the following should be possible:

```scala
case class VendorATrackingConfig(vendorId: String, propertyId: String) extends TrackingConfig
case class VendorBTrackingConfig(customTokenFoo: String, partnerId: String) extends TrackingConfig

// ...

Seq(
  new VendorATrackingProvider,
  new VendorBTrackingProvider
)
```

What's the type of the `Seq`?  It should be `Seq[TrackingProvider[TrackingConfig]]`, right?  By default Scala is very strict and it still sees the types as being mixed.  That's where a feature of the scala type system comes in, and it's the feature that made our tracking code possible:  Covariance.

Covariance allows us to say, "`Seq[TrackingProvider[VendorATrackingConfig]]` is the same thing as `Seq[TrackingProvider[TrackingConfig]]`."  That's relevant because if we can tell the scala compiler to treat `VendorATrackingConfig` as if it were a `TrackingConfig`, then it means we could have a "mixed" set of `TrackingProvider` that each take their own config that we can treat as bulk because scala will deal with them all as if they were `TrackingConfig`.

The code for covariance is to add a + to the front of the type:

```scala
abstract class TrackingProvider[+A <: TrackingConfig] {
  def getImpressionPixels(payload: A): TrackingPixel
}
```

This now allows us to express the following:

```scala
val providers = Seq(
  new VendorATrackingProvider,
  new VendroBTrackingProvider
)
```

The type of providers here is `Seq[TrackingProvider[TrackingConfig]]`.  What's even more interesting about this though is that while Scala might treat `VendorBTrackingProvider[VendorBTrackingConfig]` as if it were `TrackingProvider[TrackingProvider]`, because of dynamic binding, whenever we invoke the provider it's calling the actual `VendorBTrackingProvider` code, not the generic code provided by `TrackingProvider`.

By using covariance we are able to deal with implementations in bulk, without having to call every provider every single time.  This makes things highly flexible and re-usable.
