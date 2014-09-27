---
title: Notating Environment in Django's settings.py
date: oct 26, 2009
tags: [django]
category: python
---

I answered a [question (#1626326) on Stack Overflow](http://stackoverflow.com/questions/1626326/how-to-manage-local-vs-production-settings-in-django/1626529#1626529) recently about Django setttings.py files which reminded me I’m still undecided on what the best way to handle this issue.

The issue is — How do you handle Django settings which change based on which environment the web app is running in? The Django documentation recommends using something to this effect.

```python
if DEBUG:
    VALUE = 'something'
else:
    VALUE = 'something else'
```

I used this approach for a while, but found that it was becoming limiting. The reason why is that it doesn’t actually address the issue of environment. Where the `if DEBUG` trick is used, we’re really only looking to see if we’re in `DEBUG` mode, not if we’re running in a development or production environment.

When I was first setting up [django-compressor](http://github.com/mintchaos/django_compressor) (which by the way is teh hotness) I wanted to sets the setup in a development environment with DEBUG=False. The `if DEBUG` failed miserably here.

### settings.py Version 2

So my next attempt was to attempt to determine the machine the settings.py was being evaluated on, and from there set what the environment was.

```python
PRODUCTION_SERVERS = ['WEBSERVER1','WEBSERVER2',]
if os.environ['COMPUTERNAME'] in PRODUCTION_SERVERS:
    PRODUCTION = True
else:
    PRODUCTION = False

DEBUG = not PRODUCTION
TEMPLATE_DEBUG = DEBUG

# ...

if PRODUCTION:
    VALUE = 'something'
else:
    VALUE = 'something else'
```

This is easily an improvement over `if DEBUG`. At least now we have some control over values based on environment. I used this for a while and then realized…

What if I have two installations of Django running on the same physical machine but which should be running in different environments?

This is a conceivable situation. Let’s say in a smaller company like the one I work in we only have 1 webserver. Departments request features from the web team, which then get implemented by developer(s). However the features need to be tested by the web team and evaluated by the department before deployed to the production site.

So, the webserver gets configured to run 2 virtual hosts: One for “testing.domain.com” and another for “www.domain.com.” BAM! The “if PRODUCTION” method just failed. Why? Because we technically now have 3 environments (development, testing, production), 2 of which run on the same physical server.

Imagine this bit of settings.py...

```python
if PRODUCTION:
    DATABASE_HOST = '192.168.1.1' # Production MySQL
else:
    DATABASE_HOST = 'localhost'
```

Bad things would follow. The testing copy of the web app (testing.domain.com) would load up, and mark `PRODUCTION=True` as it is technically on the production server. It then uses the production MySQL database. Fail.

To overcome this, our settings.py file really needs a way to distinguish what environment it is regardless of which physical machine it’s located on.

### settings.py Version 3

Some ideas I’ve had to address this would to set the environment based on…

 - The folder path the app is currently located in.  The code for this could get ugly easily.
 - The complete hostname the server is running under.  This might be win.
 - Something else?

I’ll post some code when I find something that works well that I like.

On a related note, I was reading the [Sinatra (ruby) documentation](http://www.sinatrarb.com/configuration.html) this week, and I noticed that it automatically sets the environment based on the values set by the RACK_ENV variable. This would be the equivalent of adjusting the settings.py based on the presence of a WSGI or FCGI (or whatever) variable. It seems like a really neat idea, however it’s somewhat dependent on the way Django is being loaded, and given that there are so many possibilities, I’m not sure if it’d work out as well for Django as it does for Sinatra.
