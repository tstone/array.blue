---
title: So I Started Working on a Scala Web Framework...
date:  January 6, 2014
tags:  scala, web framework
category: scala
---

...even though I probably shouldn't have.  At some point attempting to design something on your own will often lean to a better understanding and appreciation of what is already out there.

The HTTP pipeline will consist of two type signatures:

 * Request Processor:  `PartialFunction[Request, Either[Request, Response]]`
 * Response Processor:  `PartialFunction[Request, Request]`

A `RequestProcessor` takes in a `Request`, can matches a particular case of that `Request`, returning either a new `Request` (modified in some way) or a `Response`.  If a `Response` is returned the framework will stop processing at that point and return that response.  If a `Request` is returned the framework will continue processing, using that new `Request`. And if the case isn't handled it will just fall through to the next `RequestProcessor`.

The web framework will have an "entry point" where a composed function of request processors and response processors is given.  Something like…

```scala
App.beforeAll(
  FauxHttpMethod andThen
  Cookies andThen
  Router
)

App.afterAll(
  xPoweredBy
)
```

A request processor is what other frameworks like Django or Connect refer to as "middleware".  I think that's a weird name however and I'll demonstrate why in a second.

As you probably noticed, the router is just a request processor, and happens to be the last one in the chain.  This is also similar to how other frameworks do it.  But I realize something interesting about that — It's possible to have different types of routers, and to choose the one that best suits the application.  An app could use more than 1 type of router.  Or someone could write a very simple router if that's all that was needed.

Example:

```scala
type RequestProcessor = ParitalFunction[Request, Either[Request, Response]]

object SimpleRouter extends RequestProcessor {
  def apply(req: Request): Either[Request, Response] = {
    case req if req.url.startsWith("/whatever") => doSomething(req)
    case _ => Http(404)
  }
}
```

The framework would probably come with a base `Router` trait that defined some of the plumbing around calling a controller.  A controller is simply `Request => Future[Response]`.  However, as the plumbing side of always passing in `Request` would be annoying, controller methods could be implemented like they are in Play, where the controller method actually returns a function of that type signature and the router is responsible for applying it.

Perhaps something along the lines of the following…

```scala
class MyRouter extends Router with Controllers {
  def process(req: Request): Future[Action] = req match {

    // Assets
    case GET("assets", file: String*)                   => Assets.at(path = "/public", file)

    // Print Preview
    case GET("testPP")                                  => PrintPreviewTest.test
    case GET("testPP", placeType: String)               => PrintPreviewTest.test(placeType)

    // Backwards Compatibility POI
    case GET("p", id: Regex("[0-9]"))                   => Application.poi(id.value)
    case GET("places", id: Regex("(.*)\\-(<id>[0-9])")) => Application.poi(id.group("id"))

    // Weather
    case GET("/weather") if (
      req.QueryString("lat").isPresent &&
      req.QueryString("lng").isPresent &&
      req.QueryString("postalcode").isPresent)          => Weather.initialWeather
  }
}
```

I haven't fully flushed out how to use unapply to implement all of the above, but I think something along these lines would be possible.

There are a couple interesting benefits in making things open and simple like this:

1. Any DI strategy can be used.  In this case I was intending Cake pattern to be used (hence the "with Controllers") but it's really up to the developer.
2. If simple routing is all that's needed, a lighter weight router can be used.  Where regex is needed (and the performance penalty of using it is acceptable), that type of router can be used.
3. Routing shouldn't just be on the HTTP method and URL.  You should also be able to steer routes based on HTTP headers, parameters, etc.

So about Controllers, I mentioned before I didn't like the name middleware.  That's because I'd like `RequestProcessors` to be able to be used on controllers as well.  Controller methods themselves could perhaps be `PartialFunctions`.

```scala
import app.authentication.Authenticate

class Record extends Controller {

  // private def Fetch = ???

  def show(id: String) = Authenticate andThen Fetch(id) andThen Action { case req =>
    ???
  }
}
```

I haven't worked all those details out, but something to that effect.  You can see `Authenticate` and `Fetch` being applied to process the request prior to the method actually running.

Anyways, those were some thoughts on how this thing might come together.  I started a github for this project:

[Windlass](https://github.com/tstone/Windlass)
