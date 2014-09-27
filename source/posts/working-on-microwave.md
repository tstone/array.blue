---
title:  Working on a Microwave w/ Express.js
date:   June 7, 2012
tags:   [expressjs, node]
category: javascript
---

Seems like I've been working a _lot_ on node lately; Well, node+[express.js](http://http://expressjs.com).  In the past week or two, primarily for [MicrowaveJS](https://github.com/tstone/MicrowaveJS), but also for [jake-scaffolder](https://github.com/tstone/jake-scaffolder) (which is still kind of under development).

MicrowaveJS has seen a lot of improvements this week:

- It now includes search "out of the box"
- It's mobile friendly/responsive CSS
- The syntax highlighting language can now be specified
- Posts can be "scheduled"
- And of course a bunch of bug fixes

Earlier this week I also converted over some of the route handling code to using Express's route middleware.  In a nutshell, what route middleware allows you to do is to create functions which are run _before_ the route itself.

Here's a quick example.  The recommended setup for Heroku is that while you can point a "naked domain" at a Heroku app (ie. google.com), you should instead prefer the sub-domain'ed url (ie. *www*.google.com).  To support this, I wanted each route to check if my preferred host was being used, and to HTTP 301 to the sub-domain'ed host if not.

The code for doing this is simple...

```javascript
if (req.headers.host !== settings.host)
    res.writeHead(301, { 'Location': settings.host + req.originalUrl });
```

However, what would be redundant would be to copy/paste this code to every route in the web app.  Instead, this functionality can be encapsulated into a route middleware function.

The form of route middleware is simple:

```javascript
var mymiddleware = function(req, res, next) {
    // Do stuff
    next();
}
```

It's basically just a javascript function which receives a copy of the request, response, and a magic function called `next`.  Creating a middleware handler is as simple as doing whatever you need to do, then calling `next()` which passes control back to Express to either go on to another route middleware or to call the route handler itself.

In this case the actual middleware turned out to be...

```javascript
middleware.forcehost = exports.forcehost = function(req, res, next) {
    var settings = req.app.settings;
    if (settings.env.production && settings.forcehost && req.headers.host !== settings.domain) {
        res.writeHead(301, { 'Location': settings.host + req.originalUrl });
        res.end();
    } else {
        next();
    }
};
```

(Note: support was added to not redirect when testing locally based on NODE_ENV.)

Applying a route middleware to a route is just as simple.  Typically a route in Express is setup using a syntax such as...

```javascript
app.get('/the/url', function(req, res){ ... });
```

To install the middleware, simply add it after the URL string but before the actual handler...

```javascript
app.get('/the/url', middleware.forcehost, function(req, res){ ... });
```

And that's it.
