---
title: Determine Model Change (in Django)
date: june 6, 2009
tags: django, python
category: python
---

Well I got around to doing a 2nd revision on my model change code (being the weekend I was wondering if it would come to pass). Per a suggestion by "thepointer" (#django IRC on freenode), I switched the code from using Python's generic vars() to Django's interal `_meta`. Using an internal API is probably not the ultimate best, but `_meta` has been stable and unchanged for quite a while.

I also added a "human_friendly" mode, which will take the model change and attempt to turn it into an understandable statement (string) about what exactly has changed. It still returns it in a dictionary with the field name as the key.

```python
from django.db import models

def determine_model_change(old_model, new_model, human_friendly=False, ignore_fields={}):
    """
    Compares the two models against each other, returning a dictionary of
    values that have changed (new value only).

    Setting human_friendly=True will cause ignore internal fields like
    SlugField.  It will also attempt to parse a meaningful statement for
    the model change. ie 'Event date is now 5/7/2009'
    """
    not_human_fields = (
        models.fields.SlugField,

        models.fields.FilePathField,
        models.IPAddressField,
        models.FileField,
        models.ImageField,
        models.XMLField,
    )
    changed = {}

    if isinstance(old_model, models.Model) and isinstance(new_model, models.Model):
        for f in new_model._meta.fields:
            if not f.name in ignore_fields:
                new_value = getattr(new_model, f.name, '')
                old_value = getattr(old_model, f.name, '')
                if cmp(new_value, old_value) != 0:
                    if human_friendly:
                        if not type(f) in not_human_fields:
                            changed[f.name] = __verbose_field_change(old_model, new_model, f)
                    else:
                        changed[f.name] = new_value

    return changed

def __verbose_field_change(old_model, new_model, field):
    """
    Returns the human-friendly text for a field change
    """
    value = getattr(new_model, field.name)
    if isinstance(field, models.fields.DateField) or \
        isinstance(field, models.fields.TimeField) or \
        isinstance(field, models.fields.DateTimeField):

        value = value.strftime('%b %d, %Y %I:%M %p')
    return '%s %s has changed to %s' % (
            old_model,
            field.verbose_name,
            value
        )


# -------------
# Sample usage:
# -------------

>>>
>>> from happenings.models import *
>>> import copy, datetime
>>>
>>> event = Event.objects.get(pk=1)
>>> event.name = "My Birthday"
>>> event.start_time = datetime.datetime(2009, 7, 5, 0, 0)
>>>
>>> newevent = copy.copy(event)
>>> newevent.start_time = datetime.datetime(2009, 7, 15, 0, 0)
>>>
>>> determine_model_change(event, newevent)
{'start_time': datetime.datetime(2009, 7, 15, 0, 0)}
>>>
>>> determine_model_change(event, newevent, human_friendly=True)
{'start_time': 'My Birthday start time has changed to Jul 15, 2009 12:00 AM'}
```
