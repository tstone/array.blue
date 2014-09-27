---
title: Structure and Interpretation, LISP, and Python
date: oct 29, 2009
tags: [python, lisp]
category: python
---

I’m a “city boy” when it comes to programming languages. 90% of my experience in programming is in ridiculously high level languages like VB.NET, C#, and Python. I haven’t “roughed it out” much in the wilderness of some low level language.

I had heard talk about MIT’s Open Courseware, but wasn’t sure what the hoopla was all about. Based on a reference in [someone’s blog post](http://www.joelonsoftware.com/articles/ThePerilsofJavaSchools.html), I happened upon a 1986 recording of [Structure and Interpretation of Computer Programs (YouTube)](http://www.youtube.com/watch?v=2Op3QLzMgSY). I watched the whole thing. I am thoroughly blown away.

I’ll admit, the first 20 minutes were dizzyingly abstract, but once some code samples started to show up, it began to make sense. What I was floored the most about was seeing how much an influence LISP had over the language I’ve been working in the most lately — Python. All of the “funky things” that I wasn’t used too from C#, inner methods, using “def” instead of “function”, etc. etc. were all elements of LISP.

So having [FizzBuzz](http://www.codinghorror.com/blog/archives/000781.html) on the mind, I decided to give it a shot…. in LISP (and then after recursively in Python). The course professor noted that LISP had no for loops. “A challenge” I thought to myself. (Long Side Tangent: I feel at the moment as if I’m creating a programmer’s Fight Club where I mentally abuse the comfortable high-level language life I once knew to get down and dirty fighting with the bare essentials of computational logic. [end sensationalistic, metaphoric movie reference])

In case you’re not familiar with FizzBuzz, here’s the problem:

  > Write a program that prints the numbers from 1 to 100. But for multiples of three print “Fizz” instead of the number and for the multiples of five print “Buzz”. For numbers which are multiples of both three and five print “FizzBuzz”.

I “made up” a function definition for print since the details of printing to the screen weren’t really my concern.

```lisp
(define (fizzbuzz start end) (
  (define (print x) ( ..something.. ))
  (cond
    (= (mod start 15) 0) (print "fizzbuzz"))
    (= (mod start 3) 0) (print "fizz"))
    (= (mod start 5) 0) (print "buzz"))
    ((print start))
  )
  (cond
    ((< start end) ((fizzbuzz (+ 1 start) end)))
  )
))
(fizzbuzz 1 100)
```

The odd part for me was after working through the mental process of how the solution would work recursively in LISP, writing it again in Python felt ridiculously easy…

```python
def fizzbuzz (start, end):
  if start % 15 == 0:
    print 'fizzbuzz'
  elif start % 3 == 0:
    print 'fizz'
  elif start % 5 == 0:
    print 'buzz'
  else:
    print start

  if start < end:
    fizzbuzz(start+1, end)

fizzbuzz(1, 100)
```

Look mom, no loops!
