---
title:    Messing with LESS Syntax
date:     September 28, 2012 9:18
tags:     less, language
category: less
---

There is a fun gem I've been playing with lately, Parslet ([http://kschiess.github.com/parslet/](http://kschiess.github.com/parslet/)).  It's kind of a cross between a parser combinator and a ruby DSL.  Anyways, I've started writing parsers for some of the languages that I use, and discovering some interesting things.

Back when I was an art studio major in college, one task professors would constantly assign would be to re-create the painting or drawing of a master artist.  It seems counter-intuitive with today's "creativity is what is inside" mentality.  Why bother re-creating something someone else has done?  That's not creative?

The purpose became clear only after students attempted the task: Re-creating the work of someone else inevitably exposes you to see and consider the same things they did.

And thus is it with parsing.  Write a parser for a language you know and the result will be a much more profound understanding of that langauge.

Of course, at the same time one is also bound to find quirks.

LESS CSS ([http://lesscss.org/](http://lesscss.org/)) includes the ability to use operators on color values.  It's a neat feature actually (though to be honest I rarely use it).

```css
body { color: #ff0000 + 100; } => body { color: #ff6464; }
```

See how that works?

Well, think about this from a parser's perspective.  How does the parser know the difference between `#ff0000 + 100;` and simply `#ff0000`?  Also, are spaces important?  As in, will any combination of spaces work?

The `+` operator is probably the easiest to parse, because it's not a valid character in a property name.  Let's see what LESS does.

```css
body { color: #ff0000+100; } 	=> body { color: #ff6464; }
body { color: #ff0000+ 100; } 	=> body { color: #ff6464; }
body { color: #ff0000 +100; } 	=> Syntax error
body { color: #ff0000 + 100; } 	=> body { color: #ff6464; }
```

The curious bit here is why `<space>+100` fails and the others don't.  A fair guess would be that the parser considers `+100` as a single value `"+100" and doesn't recognize `+` as an operator.

The `-` operator is where things start getting interesting.  This operator, unlike `+`, is a valid character in a CSS property name.  Oddly, it doesn't demonstrate any more functionality, but also doesn't throw a syntax error.

```css
body { color: #ff0000-100; } 	=> body { color: #9b0000; }
body { color: #ff0000- 100; } 	=> body { color: #9b0000; }
body { color: #ff0000 -100; } 	=> body { color: #ff0000 -100; }
body { color: #ff0000 - 100; } 	=> body { color: #9b0000; }
```

The introduction of variables adds a further level of complication.

```css
@primary: #ff0000;
body { color: @primary; }
```

Here's where operators get tricky.

```css
body { color: @primary+100; }	=> body { color: #ff6464; }
body { color: @primary+ 100; }	=> body { color: #ff6464; }
body { color: @primary +100; }	=> Syntax error
body { color: @primary + 100; }	=> body { color: #ff6464; }
body { color: @primary-100; }	=> variable @primary-100 is undefined
body { color: @primary- 100; }	=> variable @primary- is undefined
body { color: @primary -100; }	=> body { color: #ff0000 -100; }
body { color: @primary - 100; } => body { color: #9b0000; }
```

The `-` bug for `<variable><space>-<value>` is interesting.  This bug actually persists when a variable is on the right hand side.

```css
@primary: #ff0000;
@offset: 100;
body { color: @primary -@offset; }  =>  body { color: #ff0000 -100; }
```

In any case, parsing is hard.
