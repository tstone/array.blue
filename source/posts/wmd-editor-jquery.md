---
title: WMD Editor & jQuery
date: nov 23, 2009
tags: [javascript, markedit]
category: javascript
---

I’ve been using Dana Robinson’s WMD Editor fork for a couple of months now. It was a great place to start. The problem is, it’s becoming a real pain to customize. Small things were taking huge amounts of time to accomplish so I had a tough decision to make: Continue to use WMD Editor and have to spend hours for customization that should only take a minute or two -OR- re-write the UI myself on top of the existing Markdown rendering component?

Introducing: [MarkEdit](http://bitbucket.org/tstone/jquery-markedit) — the Javascript MarkDown editor built on jQuery (to replace WMD Editor). It’s currently being hosted on [BitBucket](http://bitbucket.org/tstone/jquery-markedit/src/).

 - Built On jQuery/UI — Lighter weight code and less cross-browser issues
 - Themeroller Support — Use existing or custom jQuery UI Themeroller themes
 - International — Supports the loading of an alternate language
 - Sensible Defaults — You should be able to get up and running with 1 line of javascript
 - Configurable — Almost all defaults can be overridden very easily upon initialization
 - Public API — Interact with whatever part you’re interested in
 - Documented

Since everybody loves screenshots, here’s the editor running under a jQuery theme and using the Chinese language translation.

![](/public/wmd1.png)

And again here’s a translated popup asking for the URL to insert an image…

![](/public/wmd2.png)

And here’s preview mode using a different theme but still in Chinese…

![](/public/wmd3.png)

So far I’ve invested about 15 hours into the project with it being probably around 95% complete for initial coding. There is still a TON of testing to be done. I haven’t even tried to fire it up in any of the fussy browsers yet.

I actually wrote a whole lot about it so far — it’s all up on the [Wiki](http://bitbucket.org/tstone/jquery-markedit/wiki/Home). There is still lots more documentation to come.
