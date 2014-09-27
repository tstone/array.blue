---
title: Restoring Browser Functions to Clickable DIVs Without Javascript
date: aug 20, 2010
tags: [css, html, jquery]
category: javascript
---

Occasionally the situation comes up in web development where you have a highly styled tag such as
`<div>` or `<li>` that you want to make clickable.  This often happens when you have a list of items in which you want to make the entire item clickble instead of just the title for example.  The standard fare for doing so is to set `{ cursor: pointer; }` with CSS then to bind the `.click` event to the tag (in jQuery as so)….

```javascript
$('#myDivTag').click(function() {
    // your code here
});
```

Don’t get me wrong — this does work.  However, in doing this what you loose is the standard functionality that most viewers are used to; things like middle clicking to open in a new tab, right-click to copy URL address, and so on.  There is also the lag between when the page renders visibly to the user but the javascript hasn’t downloaded and `$(document).ready` hasn’t yet fired.  In this case the tag will not be clickable but the mouse cursor will indicate that it should be.

I’ve been dealing with this more so lately and there are a couple of ways to solve this problem.

The first is to wrap the `<div>` (or `li` or whatever else) tag in an anchor tag `<a>` and set that anchor tag to `{ display: block; }`.

```html
<style type="text/css">
    #myDivWrapper { display: block; }
    #myDiv {  }
</style>

<a id="myDivWrapper">
    <div id="myDiv">
           ... content ...
    </div>
</a>
```

By wrapping the `<div>` tag in an anchor you’ve restored the default functionality viewers are used to with a clickable item.  This works in most browsers but for the most part things like `<div>` and `<li>` are not allowed inside of an anchor tag per HTML language specifications.  In a sense in doing something like this you are rolling the dice that the next version of IE9 strict mode won’t render when it hits this.

It also feels kind of  weird, because all of the styling that was on #myDiv, things like height, width, float, etc., now need to be applied to the anchor tag instead.  And no one likes wrappers. They just clutter things up.

The 2nd way to solve this problem which I’ve started using lately is to have an absolutely positioned anchor overlay the area of the div.  Consider the following…

```html
<style type="text/css">
    #myDiv { position: relative; }
    a.clickable-overlay {
        position: absolute;
        top: 0;
        left: 0;
        height: 100%;
        width: 100%;
        z-index: 1;
        display: block;
        background-color: transparent;
    }
</style>

<div id="myDiv">
    ... content ...
    <a class="clickable-overlay" href="#wherever"></a>
</div>
```

Here’s what’s happening:  At the end of the `<div>` (or li or whatever) we’re adding an anchor tag.  The parent div is set to `{ position: relative }`, and the anchor tag to `{ position: absolute; }`.  If you’re not familiar with position absolute you’re missing out.  The way it is designed to work is that any element positioned absolutely is done so in relation to it’s parent (or any parent’s parent) that is positioned either relatively or absolutely.  What this means is that in setting our <div> tag to position: relative the anchor tag with position absolute will be positioned relative to the div.  Top 0 and left 0 will be the top left of the div,  and height 100%, width 100% will cause the anchor to fill out the area of the div.

The result is that we are left with a transparent anchor tag that completely overlays the area of the div, providing the default clickable behavior users expect.  The last CSS trick to making this work is to set z-index to 1, forcing the browser to always render the anchor tag over whatever content is in the div.

The positives to this method are that

  1. we restore the expected clickable behavior without javascript (meaning it also works as soon as that markup is rendered and not when `$(document).ready` is fired) and
  2. we’re using correct HTML syntax.

I should point out there is a downside to this method, in that because the anchor overlays the div, the contents of the div are no longer selectable or clickable.  Depending on your application this may be negligible.
