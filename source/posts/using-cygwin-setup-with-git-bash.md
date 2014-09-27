---
title:    Using Cygwin Setup with Git Bash
date:     June 24, 2012 9:14
tags:     git, bash
category: windows
---

Git for Windows comes with "Git Bash", a subset of Cygwin tools for using git from bash.  One of the nice things Git Bash adds is it will show the current branch on the prompt.  Example:

    User@COMPUTER /c/Code/wherever (master)

Where `master` is the current branch of `wherever`.  It's an incredibly helpful feature and I've found myself using the Git bash as my primary shell now days.  But there's one thing about it: what if you want to use the [Cygwin](http://www.cygwin.com/) setup to add functionality to the git bash?

It turns out it's ridiculously easy.

#### Install Cygwin

Install Cygwin somewhere on your computer with whatever utilities you'd like.  In my case I wanted to add `make`, `autoconf` and friends.

#### Edit Your Path

Once Cygwin is installed, open up your bash profile for editing...

    $ notepad ~/.bashrc

Then, add the `/bin` folder from the Cygwin installation to your path...

    export PATH=$PATH:/d/Cygwin/bin

That's it.  Restart your shell session and you'll have access to all the additional Cygwin files.  You can continue to use the Cygwin setup to add and remove tools to your git bash installation.

If you're curious about what happens when the same file appears in both bin folders, bash will prefer the file in the `/bin` of Git bash.

It's also possible to ask bash which version of something it's using...

    $ which git
    /bin/git

    $ which make
    /d/Cygwin/bin/make

I should point out that Cygwin provides some git goodies as well which are worth installing, such as [git completion](http://cygwin.com/packages/git-completion/).
