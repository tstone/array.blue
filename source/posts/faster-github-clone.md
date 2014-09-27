---
title:    Easier Github Clone
date:     June 23, 2012 8:50
tags:     [bash, shell scripting]
category: git
---

I just started playing around with bash shell scripting and it's pretty cool.  Aside from writing mega scripts as a shell script (I'd probably use node for that anyways), one thing that's really helpful is to create slightly more in depth shortcuts or aliases for common things.

Here's an example: cloning a github repository.

Sure, I know the github address isn't _that_ long, but it does require about as much boilerplate as it does substance.  It's possible to trim the command down to just it's essential parts.  Typically, cloning from Github would be something along the lines of...

    $ git clone git://github.com/<username>/<reponame>.git

Let's start first by creating `ghclone.sh` in your bin folder `/usr/<username>/bin` typically or `/c/Users/<username>/bin` for Cygwin/windows bash (this includes the git bash prompt as well).  You'll want to create that `/bin` folder if it doesn't already exist.  Also, it's worth taking a second to make sure that bin folder is on your path (`echo $PATH`).

Start by creating the new shell script...

    $ touch ghclone.sh && nano ghclone.sh &

then editing it with the following contents.

    #!/bin/bash
    git clone git://github.com/$1/$2.git

In shell scripting command line arguments are available within the script with `$#` where the `#` is the position of the argument.  This shell script basically says run a `git clone` for the reposition with <username> <repo> as the first and second arguments.

    $ ghclone.sh tstone MicrowaveJS

The `.sh` on the end there is a bit ugly.  There are two things we could do to drop it.  First, rename the shell file to just `ghclone`.  If this is done, we'll also need to `chmod` the file to have execute permissions.  Alternately, and this is what I did, we could just add an alias in our shell profile.

    $ nano ~/.bashrc

    # Add this:
    alias ghclone='ghclone.sh'

That's it.  You can now simply...

    $ ghclone tstone MicrowaveJS

From your command line for a faster github clone.  This technique could be used with all sorts of stuff to create a really powerful environment for coding.
