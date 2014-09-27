---
title: 3 Cool jQuery Tricks I've Been Using Lately
date: sep 14, 2010
tags: javascript, jquery
category: javascript
---

Everyone loves jQuery.  Ok maybe not everyone, but at least a huge portion of the internet.  It’s likely because jQuery implements the DOM very similar to how it should have been implemented in the first place (but we won’t beat that dead LiveScript horse anymore).

Anyways, here are some cool tricks that I’ve learned, used, or been using lately…

### 1. Use .live for binding events on elements not yet created
It’s common to write jQuery code that creates new DOM elements or shuffles them around.  What’s not cool is to try to wire-up events up to those new or shuffled elements, especially when you don’t know if they’ve previously had event handlers attached to them.  I often found myself doing things like this…

```javascript
var bindTagEvents = function(tag) {
    $(tag).unbind().click(function(){
       // foo
    });
}

// ...

var span = $('').attr('title','My New Span');
$('body').append(span);
bindTagEvents(span);
```

Note the `unbind()` before the `click()`.  Yeah it works, but jQuery provides the `.live` function which works for all elements current and future.  This means even if we were to create that new span tag and append it to the `<body>` tag, the `.live` function would still apply it.  Using .live, we can shorten the example above down to…

```javascript
$('body > span').live('click', function() {
    // foo
});

// ...

var span = $('').attr('title','My New Span');
$('body').append(span);
```

### 2. Draw attention to newly created elements using the highlight effect

Again it’s common to create new elements in our jQuery scripts but one thing to be concerned with is how it will feel to the user.  Often times the addition of new content is subtle enough that users won’t notice, even if we the developers do.

JQuery UI provides an effect known as “Highlight” which when fired causes the element to briefly pulse in a yellow “highlighter” color, hopefully drawing attention to it.

Implementing it is ridiculously easy:

```javascript
$(tag).effect('highlight', {}, 1500);
```

The 3rd argument is the length — in milliseconds — that the yellow highlight color should fade out with.  It sounds like an obnoxious effect but it provides a subtle visual cue for users that a new element has been created.

### 3. jQuery Includes an Auto-Complete Feature

No kidding.  Like the highlight effect mentioned above, this feature requires the jquery-ui library, not just jquery ala-carte.  To be fair, there are many autocomplete implementations that have more features, but if jquery-ui is already included on your page why add another dependency (unless of course you really need that killer feature).

Autocomplete takes a couple of properties and handles most of the plumbing of what it takes to make an autocomplete/autosuggest system.  When activated on an input:text, the only thing it really needs is a datasource.

```javascript
// Any array will do...
$('input').autocomplete({
    source: ['batman', 'robin', 'joker', 'catwoman', 'dr. freeze', 'penguin']
});

// Or URL of a custom page that returns an array in JSON format...
$('input').autocomplete({
    source: 'yoursite.com/api/autocomplete'
});

// Or a callback (to implement basic caching perhaps)...
var $autoCompleteCache = {};
$('input').autocomplete({
    source: function(query, addOptions) {
        if ($autoCompleteCache.hasOwnProperty(query)) {
            addOptions($autoCompleteCache[query]);
            return;
        }
        else {
            $.getJSON(
                'yoursite.com/api/autocomplete',
                function(data) {
                    $autoCompleteCache[query] = data;
                    addOptions(data);
                }
            )
        }
    }
});
```
