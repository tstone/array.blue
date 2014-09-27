---
title: Django Model Comparison
date: june 5, 2009
tags: django
category: python
---

I started working more with [django-notification](http://github.com/jtauber/django-notification/) today. However, my implementation (outside of Pynax) is to create a subscription app, particularly for subscribing to event or calendar updates. Using [Django's signals](http://docs.djangoproject.com/en/dev/topics/signals/), I've got most of it setup. What I needed was a way to tell the difference between the old and new event, so that the notification could actually tell you "The start time for Event X has changed to Y:ZX" instead of "An event you're watching has been updated!".

So to do that I needed some model comparision code. Here's version 1.

```python
def determine_model_change(old_model, new_model):
  """
    Compares the two models against each other, returning a dictionary of

    values that have changed (new value only).
    """
  new_values = vars(new_model)
  old_values = vars(old_model)

  changed = {}

  for key in new_values:

      # Skip internal and 'magical' properties
      if not key.startswith('_'):
          if key in old_values:

              if cmp(new_values[key], old_values[key])!= 0:

                  changed[key] = new_values[key]
          else:

              # Save the new value if it is not in the old values
              changed[key] = new_values[key]
  return changed

# Sample run:
# >>> class SomeModel(models.Model):
# >>>    name = models.CharField()
# >>>    age = models.IntegerField()

# >>>
# >>> foo1 = SomeModel()
# >>> foo1.name = "Some Model Name"
# >>> foo1.age = 14
# >>>
# >>> foo2 = SomeModel()

# >>> foo2.name = "Foo Model 2"
# >>> foo2.age = 14
# >>>
# >>> determine_model_change(foo1, foo2)
# {'name': 'Foo Model 2'}
```
