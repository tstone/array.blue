---
title: Data Attributes & Javascript
date:  June 13, 2012
tags:  javascript, html5
category: javascript
---

A little over a year ago I started a new convention in the front-end code I was writing.  This convention came from a problem I was starting to see.  Now days, most developers that I know tend to use classes to describe elements and only use ids in rare occasions.  That's a good thing.  However, what happens is javascript is developed against those classes.

Consider a common occurrence in front-end coding...

```html
<div class="foo"></div>

...

$('.foo').text('Hello World');
```

The big problem is that when viewing the HTML there is nothing to indicate the javascript is making use of it.  This means your designers and back-end programmers can easily break the client-side javascript unknowingly.

Also, what happens when the CSS class on the HTML gets changed?  In an ideal world CSS classes are always semantic and they wouldn't change, but in the real world it doesn't quite happen like that.  Further, in an agile situation you're going to want to have the ability to refactor CSS class names and change them without worrying about breaking things.

So I came up with a little convention to use instead.

```html
<div class="foo" data-function="output"></div>

...

$('[data-function="output"]').text('Hello World');
```

HTML5 introduced the concept of a `data-` attribute.  Before that you could ninja HTML attributes at will.  Now, you can ninja HTML attributes at will, and be syntatically correct.  Woo.

Anyways, this adds a little more code, but a lot more robustness.  For one, any team member could easily look at that HTML and understand that it realize there was something special about the tag.  The CSS class name could be changed, removed, etc., and everything would keep on working.

I've been doing this method for about a year now, and finally realized I needed a slight update to it.

One issue is answering the question, "What is the value of data-function"?  There is a bit of ambiguity here, is `data-function` describing what the contents of the HTML element is or what action it will perform?  Consider the following...

```html
<input data-function="email" />
<button data-function="signup">Sign Up</button>

...

$('[data-function="signup"').click(function(){
	$.post('/newsletter/signup', { email: $('[data-function="email"]') });
});
```

In this example, `data-function` is actually being used for both aspects.  That doens't seem like a problem, but let's say later we wanted to add a checkbox if the user wanted to sign up for an extra weekly coupon newsletter in addition to the regular newsletter.

	<input data-function="email" />
	<input type="checkbox" data-function="signup" />
	<button data-function="signup">Sign Up</button>

See; It's ambiguous, right?

I went through several phases of naming, and finally decided on splitting `data-function` into two distinct attributes...

- `data-is`
- `data-does`

There were some other candidates, but these seemed to be the most intuitive.  I should mention, a notable runner up was...

- `data-noun`
- `data-verb`

The is/does creates a clearer situation for _what_ should be the value of the data attribute.  Our signup example above could be re-factored to.

```html
<input data-is="email" />
<input type="checkbox" data-is="coupon-signup" />
<button data-does="signup">Sign Up</button>

...

$('[data-does="signup"').click(function(){
	$.post('/newsletter/signup', { email: $('[data-is="email"]') });
});
```
