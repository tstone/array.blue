---
title: Non-Intrusive Javascript Hovers by Convention
date: nov 16, 2010
tags: javascript, jquery, html
category: javascript
---

As I’ve been learning Rails lately, the value of [convention-over-configuration](http://en.wikipedia.org/wiki/Convention_over_configuration) has been becoming more apparent to me.  Here’s a quick example of how you can use this principle to speed up common tasks in web development.

For demonstration, let’s use a really common task:  Making mouse over hover effects.  I’ll be using [jQuery](http://jquery.com/) but you can use the JS framework of your choice.

#### The Simple Way
Each time we want an element to have a hover effect, we need the following code:

```css
button { font-weight: normal; color: #000; }
button.hover { font-weight: bold; color: #333; }
```

```html
<button id="mybutton">Click Me!</button>
<script>
    $('#mybutton').hover( function() {
        $(this).addClass('hover');
    }, function() {
        $(this).removeClass('hover');
    });
</script>
```

Sure, that’s easy enough, but it’s cumbersome to implement all of that every time, it’s ugly to have javascript scattered all over your page, and it probably isn’t resource-efficient if the user has to download that script (however small) every page view.

#### Improving it with a plugin

The first thing we could do to reduce effort would be to re-factor our code into a plugin so that it’s reusable by a single call….

```javascript
$.fn.hoverClass = function(cssClass) {
  $(this).each(function() {
    $(this).hover( function() { $(this).addClass(cssClass); }, function() { $(this).removeClass(cssClass); } );
  });
  return this;
};
```

This gives us much shorter code when implementing a hover behavior…

```html
<button id="mybutton">Click Me!</button>
<script>
    $('#mybutton').hoverClass('hover');
</script>
```

#### Introducing a convention

So we’re doing better but we can introduce our first convention-over-configuration here. We can agree with ouselves that “hover” will be the default name of the hover class. This is a good start. Our hover behavior implementation is getting smaller…

```html
<button id="mybutton">Click Me!</button>
<script>
    $('#mybutton').hoverClass();
</script>
```

…but we’re still being rather redundant: every time we want to implement the hover behavior we need to call our hoverClass method. What would be better is if we could simply annotate which elements recieved the behavior. If we introduce a 2nd convention this can be possible.

#### Annotating elements through markup

There are a handful of ways to annotate tags for certain things. A popular route is to use CSS classes. This is a perfectly plausible route, but I think I’m going to make use of the new HTML5 data attributes instead. There is an advantage to using them instead which I’ll show you in a second.

So let’s develop a convention for marking tags as the ones we want to have the hover behavior on. The simplest would be to add an attribute to the tag: data-hover.

```html
<button id="mybutton" data-hover="">Click Me!</button>
```

With jQuery we can easily find every tag that has this attribute by using wildcard and empty attribute selector `*[data-hover]`. Since we’ve created this convention now, we can activate the plugin to all those elements on DOM ready…

```javascript
$.fn.hoverClass = function(cssClass) {
  $(this).each(function() {
    $(this).hover( function() { $(this).addClass(cssClass); }, function() { $(this).removeClass(cssClass); } );
  });
  return this;
};

// On DOM Ready...
$(function(){
  $('*[data-hover]').hoverClass();
});
```

And with that we’ve removed the need to have a `<script>` tag following every element on our page that needs this behavior. But still we can improve upon this. Occasionally we’ll run into situations where we don’t want to use the .hover class to implement the effect but something else. Here’s where using HTML5 data attributes vs. CSS class names comes to play.

#### Breaking out of the convention

In the `data-hover=””` attribute we can optionally specify a value. Using jQuery we can check if that value is available and use that as the hover class instead of ‘hover’

```javascript
$.fn.hoverClass = function(cssClass) {
  $(this).each(function() {
    $(this).hover( function() { $(this).addClass(cssClass); }, function() { $(this).removeClass(cssClass); } );
  });
  return this;
};

// On DOM Ready...
$(function(){
  $('*[data-hover]').each(function() {
    var hc = $(this).data('hover') || 'hover';
    hoverClass(hc);
  });
});
```

With this setup you have the choice to take the default or specify a custom hover class…

```html
<button id="mybutton" data-hover="">Click Me!</button> <!-- Take the defaults -->
<button id="mybutton" data-hover="custom-hover">Click Me!</button> <!-- Use this class instead -->
```

#### Wrapping up loose ends

If you’ve done a lot of javascript development you may have noticed a shortcoming in the way we’re approaching this. Our handle little convention runs once on DOM load and never again. This means if we create new DOM elements after page load or if we have content that’s loaded through AJAX which contains these data-hover marked elements they won’t having .hoverClass applied to them.

There’s three ways that we can go about fixing this.

The first is to just call `$.hoverClass` on any new elements we make. But the issue here is how do we know which elements to call it on? There’s a better way…

The second way to handle this would be to re-factor our DOM ready code into its own jQuery plugin which we can call at any time.

```javascript
$.fn.hoverClass = function(cssClass) {
  $(this).each(function() {
    $(this).hover( function() { $(this).addClass(cssClass); }, function() { $(this).removeClass(cssClass); } );
  });
  return this;
};

$.fn.autoHoverClass = function() {
  $('*[data-hover]').each(function() {
    var hc = $(this).data('hover') || 'hover';
    hoverClass(hc);
  });
};

// On DOM Ready...
$(function(){
  $.autoHoverClass();
});
```

This is a decent route as we retain all “auto” functionality but with the ability to refresh the automatic functionalty after we’ve changed some page content. Still yet, jQuery 1.4 provides us with another way…

jQuery 1.4 introduced the `.live` method which I previous mentioned in a blog post. The .live method is a replacement for .bind with the exception that it will bind events for all current and future elements. It’s a bit dizzying to imagine how this works internally, but given a jQuery wrapped set we can make sure the event handler is always “hooked up”.

To do this though requires us to re-factor our code a bit. For one our code is written to call .each then to call the event binders. This is a problem because .each isn’t updated “live”. The solution is to move the event binding code so that it’s on the wrapped set then to evaluate the value of data-hover within the event handling code.

```javascript
$('*[data-hover]').live('mouseover', function() {
  $(this).addClass($(this).data('hover') || 'hover');
});
$('*[data-hover]').live('mouseout', function() {
  $(this).removeClass($(this).data('hover') || 'hover');
});
```

For simplicity I dropped the jQuery plugin syntax to be clear about exactly what’s going on. I’ve tested doing it this way, and while it does work it can cause noticable browser lag ad whenever new DOM elements are added or removed. For this particular use-case I don’t feel the performance impact warrents what we’re using it for, but know it is an option.

#### Final code

So our final code that we ended up with for hover behavior by convention is….

```javascript
// separate-js-file.js
$.fn.hoverClass = function(cssClass) {
  $(this).each(function() {
    $(this).hover( function() { $(this).addClass(cssClass); }, function() { $(this).removeClass(cssClass); } );
  });
  return this;
};

$.fn.autoHoverClass = function() {
  $('*[data-hover]').each(function() {
    var hc = $(this).data('hover') || 'hover';
    hoverClass(hc);
  });
};

// On DOM Ready...
$(function(){
  $.autoHoverClass();
});
```

```html
<!-- In your markup -->
<button id="mybutton" data-hover="">Click Me!</button>
```
