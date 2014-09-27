---
title: A Truly Modular Web Framework
date: nov 17, 2009
---

Web development is weird. It’s weird because the rendering of the UI (in HTML) feels so incredibly disconnected from the logic and objects that are represented by the UI. It’s weird because the UI is usually rendered by a server-side template facility, but is occasionally rendered by cilent-side javascript.

Here’s an example. I find the [decorator pattern](http://en.wikipedia.org/wiki/Decorator_pattern) really cool. Let’s say I’m writing a blog. Actually, everyone writes blogs. Let’s say I’m writing a Stack Overflow clone. In Stack Overflow users can ask questions. Other users can answer them. Users can also comment on a question (different from an answer), or comment on an answer made by another user. The shared functionality is placing comments on an object.

The mechanics of a comment aren’t particularly unique that they need to be bound to a specific object. A UI is presented for a user to type in a message. The server should store the messages and associate them with a specific object.

So let’s say in this example the comment functionality is implemented as a decorator generically which can be applied to any object. So we have the question functionality, implemented perhaps as a class, and we can decorate it with the comment functionality. If later we decided to implement a “News” section, and need each news post to also have comments, we could also decorate the news posts using the same decorator as well. The comment functionality at this point is a self-contained decorator.

Programatically this doesn’t seem like a difficult suggestion (maybe), but what happens when we need to render this out to HTML? Even worse, let’s say the comment functionality requires javascript to fetch comments via AJAX — then what?

I think the problem here is that whatever is doing the rendering doesn’t know what the object Question or Answer looks like. It also doesn’t know what the decorator Comments looks like either. If it did, it could render them intelligently. I’m thinking of decorated rendering here.

Functionality similar to what I’m describing can be achieved in current web frameworks, but usually through things like template tags, framework widgets, or partially rendered views. But that’s not quite what I’m talking about. It still requires a lot of repetition and isn’t really modular. Template tags still need to be coded very specifically.

Part of the issue is that in web development frameworks we are using HTML to describe too many things. Take Django’s template system, which despite many people’s complaints, is quite functional and I actually kind of like. Django templates provide the facilities of context (passing variable data to the template), template tags (custom bits of code that can be arbitrarily executed) and filters (helpers to modify data to conform to a particular output).

But for each page template that is created, the following things are being handled in that one template:

 1. How a given object should be rendered
 2. How the page is layed out
 3. What media files need to be linked/included in order for this page to rendered properly (js/css/etc.)’

I’m thinking out loud here, but what would a rendering system (and supporting framework) look like which separated what the template system did into separate pieces?

 - Each object has it’s own multiple HTML “interpretations”, outfits if you will for the class. Decorators can call the decorated class’s outfits if needed.
 - Page templates become more semantic and less about display — they’re interested in where pieces go on the page, not necessarily the markup to render it to appear a certain way. More of an outline than a sea of div tags. It seems very often the task of laying out what goes on a page, and implementing the UI are two completely separate tasks, and yet most template systems I’ve used force you to do them together.
 - Media files are handled programatically in code, somewhere, somehow. An object outfit can for example say “I need this javascript file” and the template engine will react accordingly. This prevents <script> tags and @import statements being strewn all over, and allows the framework to pass those media files off to a handler that decide if something should be done with them (ie automatically put <script> at bottom and <link> at the top, compress the JS, etc.). Disclaimer: This is probably a harder problem than I’m thinking it is, especially when AJAX gets involved.

More to come on this. I might have to do some experimental code. Should template engines help you by handling some pieces of the Javascript on the client? Hmm…
