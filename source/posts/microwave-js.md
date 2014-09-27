---
title: Introducing Microwave.JS
tags:  [javascript]
date:  May 25, 2012
category: javascript
---

This blog post is a bit recursive.  Last weekend I built a new blog platform, and this post is the first _new_ post
being written on it.  Actually, it's not being written on it at all.  It's being written in Komodo Edit, which is the
point of the platform.

I'm beginning to have a reputation at work for oft referring to the principle of [Worse is Better](http://en.wikipedia.org/wiki/Worse_is_better).
Blog editors are an exellent example of this.  Almost every blog platform has a huge amount of javascript which is responsible
for a very complex and intelligent WYSIWYG editor that most authors write their posts in.

The problem is this editor also usually doubles as the worst place to write code, ever.  Often times as I'm composing a blog post,
I write the code in the blog, not in an editor first.  The simplest things like tab fail to be available, and always space'bar'ing it up
for things is annoying, especially anything beyond 1 level deep.

Microwave.js was born out of the Worse is Better mantra in that it has no editor.  In fact, it has no admin interface.  It doesn't even
have a database.  All it has are disk files.

Why?  None of that is needed.

The project is written in node.js, and there's a lot more documentation about the specifics of installing and configuring it on the
[github page](https://github.com/tstone/MicrowaveJS).

Microwave.js has a clear target in mind for users: developers.  The low-level approach should appeal to many, and the automatic syntax highlighting
is something I've been wanting for so long in a blog editor.

And oh yeah, my blog lives at my new domain now, [typeof.co](http://www.typeof.co)!
