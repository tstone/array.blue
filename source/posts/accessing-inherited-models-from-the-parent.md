---
title: Accessing Inherited Models from the Parent in Django
date: jan 14, 2010
tags: django, oo
category: python
---

One of the neat features of Django’s ORM is Model inheritance (table-level). It allows several neat data design patterns to occur. Here’s an example. Let’s say we’re developing a website for a game company. The company sells two types of products: board games and video games. All of the products will share some data in common, name and product_id for example, but we also need to store specific details about each. Using model inheritance we can do something as follows.

```python
class Product(models.Model):
    name = models.CharField(max_length=75)
    product_id = models.SmallIntegerField()
    price = models.DecimalField()

class BoardGame(Product):
    num_of_players = models.SmallIntegerField()
    game_type = models.CharField(max_length=50)

class VideoGame(Product):
    PLATFORM_CHOICES = (
        ('wii', 'Wii),
        ('xb3', 'Xbox 360'),
        ('ps3', 'Playstation 3'),
    )

    platform = models.CharField(max_length=3, choices=PLATFORM_CHOICES)
```

In a real use-case scenario you’d most likely have more than 1 field per, but for this example I wanted to keep things simple.

The way Django implements this, if you were to query one of the child models, you’d be able to access the methods from the parent models…

```python
b = BoardGame.objects.all()[1]
print b.name
# > 'Djangopoly'
```

Another thing that’s cool is child instances have a parent instance record. Using the “Djangopoloy” game from above, which is technically type BoardGame, one could still query Product and retrieve it.

```python
p = Product.objects.get(name='Djangopoly')
```

This is really useful, but sometimes you need to go the opposite direction, and this is where Django’s implementation stops. The link can’t go from a Product model instance to a BoardGame. It can’t retrieve state as if it was of type BoardGame.

```python
print p.platform
# > CAN'T DO THAT!
```

Because the need for this seems to be arising more often than not lately for me, I put together a re-usbale bit of code to overcome this limitation. I’ll post the code below, but using it is actually quite simple.

It works by providing an abstract model that the parent model inherits from instead of `models.Model`:

```python
from inheritance.models import ChildAwareModel

class Product(ChildAwareModel):
    pass
```

Then, an inner class `Inheritance` is supplied to describe children of the model.

```python
class Product(ChildAwareModel):
    ...

class Inheritance:
     children = (
        'myapp.models.BoardGame',
        'myapp.models.VideoGame',
     )
```

Only children that need to be reversed to should be set. Once that is configured, a method “get_child_model()” will become available, and can be used like so:

```python
p = Product.objects.get(name='Djangopoly')
b = p.get_child_model()
print b.num_of_players
# > 4
```

I’m finding this particularly useful when I’ve created an aggregate type page — that is a page that shows a summary of all the generic types (Product) — but need to on user-click show them some type of product-specific detail.

The implementation for `ChildAwareModel` is below. Save it somewhere on your python path and enjoy.

```python
from django.db import models
from django.shortcuts import _get_queryset

class ChildAwareModel(models.Model):
    class Meta:
        abstract = True

    def get_child_model(self):
        """
        Attempts to determine if an inherited model record exists.
        New child relationships can be added though the inner class Inheritance.

        class Model(ChildAwareModel):
            ...

            class Inheritance:
                children = ( 'yourapp.models.ChildModel', )
        """

        def get_child_module(module, list):
            if len(list) > 1:
                return get_child_module(getattr(module, list[0:1][0]), list[1:])
            else:
                return getattr(module, list[0])

        if hasattr(self, 'Inheritance'):
            children = getattr(self.Inheritance, 'children', [])
            for c in children:
                components = c.split('.')
                m = __import__(components[0])
                klass = get_child_module(m, components[1:])
                qs = _get_queryset(klass)
                try:
                    child = qs.get( **{ 'pk':self.pk } )
                    return child
                except qs.model.DoesNotExist:
                    pass
        return None
```
