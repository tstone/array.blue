---
title: On Architecture (and Types) in Scala
date: January 10, 2014
tags: scala, architecture
category: scala
---


In considering a whole bucket of early mistakes that were made with Scala, here are some reflections about things.  These comments
are considered from the perspective of a web application, but probably have a broader application as well.


## 1. Models should strive to represent data as the domain is concerned and to the detail the domain is specific

**This means:**

 * Representing data types with specific and strong types
 * Only using `Option` when it's a valid business case

**What not to do:**

* Model data exactly as APIs are returning it

This is poor:

```scala
case class Something (
  every: Option[String],
  thing: Option[String],
  is: Option[String],
  optional: Option[String]
)
```

This is also poor:

```scala
case class Place {
  postalCode: String
}
```

#### Why

By modeling domain data using generic (primitive) types like `String`, it shifts the burden of handling that data from the code which is initializing the model to the code that is consuming the model.  The notion of "postal code" as `String` means that we are creating a contract with the system such that we could take any postal code and substitute it for any `String` anywhere, and vice versa, any `String` could be substituted for any postal code.  This is clearly wrong.  Every time this happens a developer needs to deal with validation, asking themselves, "what if this `String` is really 'asdf' and not a postal code?"  Every time this happens what's really happening is the type system is being re-implemented in a poor way.

Scala makes this an easily sovled problem.  A simple starting example (this could be expanded to include international postal codes if that was within the application's domain):

```scala
case class PostalAddress(code: String, plusFour: Option[String]) {
  require(isNumeric(code))
  require(isGreaterThan(0, code.toInt))
  require(isLessThan(100000, code.toInt))

  plusFour.map { pf =>
    require(isNumeric(pf))
    require(isGreaterThan(0, pf))
    require(isLessThan(10000, pf))
  }
}

case class Place {
  postalAddress: PostalAddress
}
```

#### Same for Functions

This rule could also equally apply to functions.  Function parameters should reflect what is necessary for computation, not just what the provider of the data happened to have.



## 2. Models should be focused around abstract traits (interfaces) than concrete models.  Functions that consume models should not take the model, but a trait that describes the least amount of interface the code needs to do it's work.

#### Why

This follows the same rational as why scoping, private, protected, sealed, are important:  Exposing extra interface creates dependencies on implementation that make refactoring in the future difficult.  Given a method:

```scala
def getWeather(p: Place)
```

This method is equivalent to saying: "all 30 properties and sub-properites exposed by the `Place` model are necessary to get the weather".  In actuality, the `getWeather` function may only need to read the #address property of place.

If models were organized into logical slices of model properties this would allow a function to consume only the portion of the interface it needed.  As one team member put it, "it's duck typing in a static language using pre-described ducks."

```scala
trait LocatablePlace {
  val address: Address
  val latLng: LatLng
}

def getWeather(p: LocatablePlace)
```


## 3. Web applications should separate web layer code and service layer code

1. Every piece of code goes in either one or the other.  There isn't any middle ground.  Bonus:  Make the service layer code a different SBT project.

2. Separate models for the web application and models that services return.  Services shouldn't know anything about web app models.

3. Services that implement service-specific models (ie. XyzResponse) should have those models be a part of the namespace for that service.  This seems obvious but it's easy to miss.

4. Folders like "helpers" and "utils" are junk drawers and great places for bad code to hide out.

5. A "presenters" folder is needed (for a Play 2 app).  Controllers act as translation layers between services and views.  There there can be a lot of common logic between turning service responses into data for views and that has to live somewhere.  Sticking to a known (or at least well published) pattern is better than trying to create a new convention.

6. Bring widget/component files together, HTML, js, css all in one folder.  There isn't any advantage to storing files based on what language they are built in.  If components have all 3 language files together it's easier to refactor into being their own repo and sharing them across projects.


## 4. There has to be a better DI pattern

None of them are good.

**Constructor**:  Passing in dependencies as class constructor arguments means traits can't have dependencies.  That's too big of a cost in my opinion, to cut out a big language feature just because it doesn't fit a given DI pattern.  It also can be a real pain to setup for testing.

**Guice**:  See above

**Cake**:  How does cake get implemented for services that are their own SBT project?  Do they end up having their own or does it force coupling?  It seems like a lot of boilerplate/wiring for what isn't that complicated of a problem.  On top of that I can see it getting out of hand and creating a lot of spaghetti code as things would be including all kinds of Env traits that are already pseudo-global, which we all know is bad... or something.

**Monad**:  Looks really cool but this isn't a trivial thing to understand conceptually and puts quite a mental tax on getting things done, particularly for junior team members.


## 5. Component templates (widget, partial templates) should take primitive/generic types; They should be named for what UI widgets they implement, not what business service they represent.

In other words, they shouldn't take models.

Sub-components should be refactored into their own components.

We don't want to unnecessarily create a dependency between a service implementation and a front-end component.  This would decrease their reusability across several apps.  On the component level this is more critical as components should be shared across apps.


## 6.  Views (page templates) should take presenters not models.

It's highly probably that page templates will rarely or never be shared across apps.  And it's also highly probably that they will need to consume more information than a small template tag.  Accepting a presenter is a good compromise: we don't create a dependency between the template and a service but we get the advantage of not having to pass down 50x parameters just to get something rendered.

The added benefit here is that testing and refactoring should be made easier.  View tests should not break when service implementations are changed.
