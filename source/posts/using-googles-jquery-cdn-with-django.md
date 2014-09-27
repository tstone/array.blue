---
title: Using Google's jQuery CDN with Django When Not in Development
date: dec 11, 2009
tags: [jquery, django]
category: python
---

I wanted to transition the Django site I work with primarily to use [Google’s jQuery CDN](http://code.google.com/apis/ajaxlibs/documentation/). However, when developing locally, it’s often faster to just use a local copy. What I wanted was a way to toggle which copy of jQuery was being used based on the environment.

### Environment Detection
Before we can toggle the jQuery location, we need to have a way to detect which environment we’re running in.I previously blogged about how I have my settings.py configured. There are different ways to do this. One is to use local_settings.py, the other is to have conditional code in your main settings.py which determines values. Either way works.

As for my setting, on the webserver is a folder structure that resembles…

    \webroot
        \django_devel
        \django_prod

My webserver pulls double duty, hosting both a production version (“prod”) and a staging/testing version (“devel”). In my settings.py file I’m using this to determine which environment Django is running in…

```python
import os
DJANGO_ROOT = os.path.abspath(os.path.dirname(__file__))

# Globals for determining settings
STAGING = PRODUCTION = DEVELOPMENT = False

if 'django_devel' in DJANGO_ROOT:
    STAGING = True
elif 'django_prod' in DJANGO_ROOT:
    PRODUCTION = True
else:
    DEVELOPMENT = True
```

Most likely, you’ll have some other what you’re determining your environment. In that case just substitute that.

### Template Tag

Now that we have the required support code to detect what environment we’re running in, putting together the actual implementation is simple.

I decided to go with a template tag. It’s simple and easy.

```python
import settings
from django import template
from django.conf import settings

register = template.Library()

# -----------------------------------------------------------------------------
#   jQuery
# -----------------------------------------------------------------------------
@register.tag
def jquery(parser, token):
return JQueryNode()

class JQueryNode(template.Node):
def render(self, context):
     jquery = 'http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js'
     jquery_ui = 'http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js'
if getattr(settings, 'DEVELOPMENT', True):
         media_url = getattr(settings, 'MEDIA_URL', '/media/')
         jquery = '%sjs/jquery-1.3.2.min.js' % media_url
         jquery_ui = '%sjs/jquery-ui-1.7.2.custom.min.js' % media_url
return '<script type="text/javascript" src="%s"></script><script type="text/javascript" src="%s"></script>' % (jquery, jquery_ui)
```

There are a couple of things to note here.

First, there’s a hard-coded path in this code. Because I plan to always use this template tag every time I need jQuery, I felt confident doing so as it leaves only one place to edit. However, if you won’t be following that rigid of an implementation pulling the locations of jQuery out and into a settings.py file would probably be a smart idea.

Second, I’m implementing my type of detection for the environment. This probably differs from the majority of Django users.

When all is said and done, all that needs to remain is to simply drop the tag into base.html and we’re good to go.

    {% load jquery %}{% jquery %}
