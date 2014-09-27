---
title: The Difference a Space Can Make
date: may 20, 2010
tags: [scala]
category: scala
---

How can you print the string value of a floating point value of `5` in Scala?

    scala> 5.toString  // Wrong!
    res16: java.lang.String = 5

    scala> 5. toString
    res17: java.lang.String = 5.0

In the first line scala counts the “.” as syntax for “toString method of Integer 5”.  The second line uses the “toString” method in infix notation, applying the toString method against the floating point value of 5.0.

Here’s another example where a space can make a big difference in type:

    scala> 4.+(1)
    res20: Double = 5.0

    scala> 4 .+(1)
    res21: Int = 5
