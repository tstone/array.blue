---
title: "Programming Puzzle: String Length"
date: Feb 21, 2012
tags: [javascript, puzzle]
category: javascript
---

**Determine the length of a string without using any built-in `.length` or length getting functions.**

Typical to true-engineering form, my first idea was overly complicated.  I had reasoned that I could write a recursive loop to progressively build up a 2nd string, then compare them to see if the lengths matched.  The problem there of course is that in order to do the comparison I have to use `.length`. #fail

After chuckling at myself for such an obvious oversight I realized there was a simpler solution.  A string could be treated as an array, and the first character could simply be shifted off recursively and the length determined that way.  A simpler implementation would be instead of converting the string to an array, simply using `.substr(1)`.

```javascript
function getStrLen (s) {
    var loop = function(acc, s) {
        if (s === “”) { return acc; }
        return loop(acc + 1, s.substr(1));
    };
    return loop(0, s);
}
```

Now that I’ve gotten used to tail recursion, it seems that I’m seeing uses for it everywhere.  I hope that’s a good thing…
