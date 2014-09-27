---
title: Efficiently View Apache Log Files on Windows
date: dec 8, 2009
tags: apache, windows
category: windows
---

One of the annoying things about using multiple platforms is when one platform has a useful utility (no matter how small) and the other platform doesn’t. Have you ever needed to regularly check an Apache log file on your Windows development machine? The shell user inside me says “just tail it”… but this is Windows.

However, I just found a really amazing tool called [BareTail](http://www.baremetalsoft.com/baretail/).

![](/public/baretail.jpg)

BareTail “connects” to a log file, and shows you an automatically updated (live) tail of that file. It basically allows this situation to happen:

I have a window up on my developer machine (in the 2nd monitor) which is the tail of the Apache error log. Every time something is written to that log, BareTail pushes it into the window on my screen. I see log entries in real time.

Let me tell you, it makes debugging Apache error log issues much more efficient.
