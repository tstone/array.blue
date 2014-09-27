---
title: 5 Reasons to Consider Tornado for AppEngine (Python)
date: sep 9, 2010
tags: python, webapp, appengine, tornado
category: python
---

As I’ve begun to become better acquainted with [Google’s AppEngine platform](http://code.google.com/appengine/), I’ve hit a few points where the python-based [“webapp” framework](http://code.google.com/appengine/docs/python/.../usingwebapp.html) is less than desirable.

While I have a background in [Django](http://www.django.com/), I didn’t feel as if it was a fit for AppEngine due to it’s heavy data layer ties.  On the flip side, [Tornado](http://www.tornadoweb.org/) (IMHO) is a lightweight alternative and prime candidate.

Tornado, if you don’t know, is the web framework that powers FriendFeed and was recently open sourced by Facebook.  It includes the basics you’d expect: request handling, routing, templating; you know, the usual fare.  A scatter of MySQL utilities come bundled, but the framework leaves the data layer completely up to you (consequently it doesn’t including features like an automatic administrative interface or data models-to-web forms).

### 1.  May the Source Be With You

Sure, webapp has [online documentation](http://code.google.com/appengine/docs/python/gettingstarted/usingwebapp.html), but sometimes it’s easier to just [read the source](http://github.com/facebook/tornado/tree/master/tornado/).  Even better, in Tornado’s case it’s available via GitHub.

Depending on your experience with python this might not sound like a compelling reason but consider this: You will likely have the tornado source folder inside of your project’s folder while developing (as it needs to be deployed to AppEngine with the rest of your python source files).  This means you can simply open up the Tornado source files in another tab in your editor for quick reference.

Once you get used to doing this it greatly speeds up your development time when you need to reference something and it gets you much more acquainted with how the framework works.

### 2.  Simple Templating

There are quite a few good templating engines out there for python. The problem I have with many of them is that they typically are too complicated or unnatural in syntax or too restrictive for in form, particularly when it comes to creating re-usable sub-templates which manage their own logic and data independent of the main page (I’m referring to what Django and other engines call “template tags”).

Before I mention tags a few words about the Tornado template engine — it’s simple.  It uses the common `{% %}` format.  It lets you put real python in between the `{% %}`’s   Sure, people say logic should be out of the template, however if it’s logic that relates to display I disagree.  Tornado gives you the choice.  If you want it, use it.  If not, do it the hard way.  It’s up to you.

Behind the scenes Tornado compiles the templates to a python file to make them speedy when serving to viewers (this has the odd side effect of requiring you to restart the appengine dev server whenever you change the template).

The one slip up is that if you, like me, are used to Django-style templates, you’ll probably write things like `{% endblock %}` or `{% endif %}`.  Tornado simply uses `{% end %}` for everything.

### 3. Drop-Dead Easy Template Tags

So about template tags, Tornado refers to them as “UI modules”.  Defining a new module is dead simple…

```python
class SchemePreviewSmall(BaseUIModule):
    def render(self, scheme, lang='python'):
        data = self.handler.data.get_something_cool(scheme)
        return self.render_string('modules/scheme-preview-small.html',
                                  scheme=data,
                                  lang=lang)
```

In this example I’m calling the method `get_something_cool` which is actually a member of the calling `RequestHandler` (`self.handler`).  The return value is then used to generate the response by loading and rendering a template.  The nice thing here is that if I have a re-usable widget such as an ad, a login interface, whatever I can make it a module and re-use it throughout the site.

Using this module in a template is as easy as…

```liquid
{{ modules.SchemePreviewSmall(scheme) }}
```

### 4. Easy to follow documentation

Yes, if the source isn’t you thing, there still is easy-to-follow documentation.  There’s enough there to get you up and running in an evening and you’ll learn a lot of cool tricks too.

### 5.  Minimal to Convert

Lastly, the webapp and Tornado syntax for request handlers are so similar, converting to Tornado from webapp requires minimal effort.

```python
# webapp Request Handler
class HelloWorld(webapp.RequestHandler):
    def get(self):
        self.write("Hello World")

# Tornado Request Handler
class HelloWorld(tornado.web.RequestHandler):
    def get(self):
        self.write("Hello World")
```

There are, of course, a few other differences.  For example, fetching the value of a querystring. Webapp uses `self.request.get()` while Tornado instead does `self.get_argument()`.  The differences are minor and easily done with Find and Replace.
