---
title: 60 Second Cake
tags: scala, dependency
date: May 15, 2014
category: scala
---

An quick example of all the pieces of the "Cake" dependency pattern, from the perspective of a web application...

```scala
// Dependencies are described on an abstract trait (interface)
trait Dependencies {
  val service: Service
}

// Controllers require an implementation of dependencies by using a self type declaration
// (this: TYPE =>) This tells the Scala compiler to require an implementation in order for
// the class to be initialized.
abstract class Controller extends Behavior { this: Dependencies =>
  ...
}

// Because trait Dependencies is abstract, we can build multiple "environments" or implementations
// The obvious one is the real services
trait ActualImplementation extends Dependencies {
  val service: Service = new Service("foo", "bar")
}

// But it's also possible to make mock versions or anything else for that matter
trait MockImplementation extends Dependencies with Mockito {
  val service: Service = mock[Service]
}

// The actual controller object Play (or whatever framework) uses mixes in actual implementation
// This is how we get the "real" thing when the app is running
object Controller extends Controller with ActualImplementation

// It's common to abstract a controller behavior to it's own trait.  When we do this it's not
// necessary to use the self type declaration.  We can just list the services we need at the
// top and as long as they are the same name it will "just work"
trait Behavior {
  val service: Service
  def doSomething = service.something()
}

// When testing the behavior trait is mixed in with the mock implementation
// This is a win-win as everything is already mocked and the only thing left to do
// is to put any specific stubs you need for the parts you're testing.
class BehaviorTest extends Spec {
  class TestContext extends MockImplementation with Behavior

  "foo" in new TestContext() {
    ...
  }
}
```
