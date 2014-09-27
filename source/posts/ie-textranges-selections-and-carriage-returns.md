---
title: IE TextRanges, Selections, and Carriage Returns
date: dec 3, 2009
tags: javascript, ie
category: javascript
---

I spent several hours this week trying to track down a bug with programmatically selecting text via javascript.

```javascript
if (textarea.setSelectionRange) {
// Set selection for Mozilla-ish browsers
    textarea.setSelectionRange(start, end);
 }
else {
// Set selection for IE
    var range = textarea.createTextRange();
 range.collapse(true);
 range.moveEnd('character', start);
 range.moveStart('character', end);
 range.select();
}
```

Assuming that `textarea` is the element of the `<textarea>`, and `start` and `end` are Number values that indicate the start and end of the selection, respectively.

I was managing this in MarkEdit by keeping a state object that recorded the “Before Select” (everything before the selection), the selection text, and the “After Select” (everything after the selection).

So it seems easy to implement right?

```javascript
start = beforeSelect.length;
end = start + select.length;
```

**That doesn’t always work!**

It works sometimes, but occasionally the selection will be the proper length, but randomly offset by 3-7 characters. It took quite a bit to figure out (that’s an understatement). Here’s what a lot of debugging and experimentation came up with:

When Internet Explorer creates a Range or a TextRange object, it converts all line returns to Carriage Return/Line Feed format; basically `[0A] -> [0D 0A]`. Easy to counter? Just determine all the instances of `[0D]` and `[0A]`, subtract the two, then you have the offset? That’s what I thought too, but even with the offset, the discrepancy persisted.

So it was time for a new approach. What if we converted all of the `[0A]` characters in the textarea to `[0D 0A]`’s ? Again, the offset of the selection persisted.

Here’s what I finally narrowed it down to be: When you create a `TextRange`, IE doesn’t actually re-render the text internally, converting all [0A]’s. However, when you request the text (`TextRange.text`) it converts it at that time. This means if you were to get the length of the selected text, `TextRange.text.length`, it would be longer than what the `TextRange` is seeing internally! When using `.moveEnd` on the `TextRange`, the value counts the position from the internal text, not from the text it gives you.

That is reeeeeeediculously wrong. The final solution is to “sanitize” the text `TextRange` gives you by removing all `[0D]` characters from it. From there you can accurately calculate the selection position and give the `TextRange` the proper coordinates.

Whew… that was several hours needlessly wasted by IE (again).
