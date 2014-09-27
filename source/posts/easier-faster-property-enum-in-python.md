---
title: Easier, Faster Property Enumeration in Python
date: june 6, 2009
tags: python
category: python
---

I just discovered a really neat trick in Python to take a collection of objects, and turn one of their properties into a list. It's not terribly difficult to perform this the old way...

```python
subscribers = []
for subscription in self.subscriptions.all():
    subscribers.append(subscription.user)
return subscribers
```

This would return something like `[(User:bob),(User:jerry),(User:tim)]` and so on. However, this can be done in just a single line...

```python
return [s.user for s in self.subscriptions.all()]
```

+1 for Python coolness.
