---
title: Ignoring .pyc Files in NetBeans
date: june 5, 2009
tags: [python, netbeans]
category: python
---

I started using the [Netbeans 6.5 Python (Early Access) IDE](http://www.netbeans.org/features/python/) a couple of weeks ago, and while all seemed to be going well, one thing that bugged me was seeing all the [.pyc (python compiled file)](http://www.fileinfo.com/extension/pyc) in the treeviews. Turns out NetBeans has a simple way to fix this:

 - On the menu go to Tools > Options
 - Then "Miscellaneous"
 - Then "Files" tab
 - And find the section "Files Ignored by the IDE"

This value is a [regular expression](http://www.regular-expressions.info/) which makes it easy to add the functionality we're looking for.

Change this:

    ^(CVS|SCCS|vssver.?\.scc|#.*#|%.*%|_svn)$|~$|^\.(?!htaccess$).*$


To this:

    ^(CVS|SCCS|vssver.?\.scc|#.*#|%.*%|_svn)$|~$|^\.(?!htaccess$)|pyc.*$

You could easily use this method for any other file type you'd like to ignore. Just add `|extension` before the `.*$`.
