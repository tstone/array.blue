---
title: Developer Blog Entries
date: nov 28, 2009
---

I haven’t done any development in the past few days thanks to this holiday weekend, however I did have a chance to catch up on my blog subscriptions (which were really beginning to pile up). My wife just peeked over my should and said I was also spending quality time with her.

[Ryan Tomayko on Unicorn](http://tomayko.com/writings/unicorn-is-unix) (ruby), “because it’s Unix.” A neat post on using some of the unixy functionalities of ruby to develop a network service. I’d really like to try it, but I don’t have a POSIX computer up and running. Hmmm… I should fix that.

[Simon Willison talks about Node.js](http://simonwillison.net/2009/Nov/23/node/), a server-side javascript framework which looks ridiculously cool. Having been spending a lot of time working on MarkEdit, I can certainly appreciate some of the non-blocking/callback ideas that it implements. However, again with the lack of POSIX. It doesn’t yet run on Windows. I really need to remedy that.

Again from Simon Willison he mentions [flXHR](http://flxhr.flensed.com/) — A replacement for XmlHttpRequest, but implemented by an invisible flash (.swf) wrapper layer. It’s a really interesting concept, though completely hacky. Why bother with this? 1.) get around cross-browser issues, and 2.) get around browser security issues (like making an AJAX request to API on another domain for example).