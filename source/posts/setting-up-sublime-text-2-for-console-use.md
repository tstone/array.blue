---
title:    Setting up Sublime Text 2 for Console Use
date:     July 30, 2012 8:08
tags:     Sublime Text
category: windows
---

As a follow-up to my [A Better Terminal for Windows](http://www.typeof.co/post/a-better-terminal-for-windows), one thing you'll find quickly is that being able to use a good editor from the command line is very important.  Since [Sublime Text 2](http://www.sublimetext.com/2) is my weapon of choice I'll be using that, but really the instructions below should work with just about any editor.

### Step 1: Add To Path ###

In order for all of this to work, the first step is to add the path to the sublime exe to your bash shell.  This is done with the `export` command, but since we want it to persist for all sessions we'll need to add it to the `.bashrc`.

```shell
$ notepad ~/.bashrc
```

Within the bashrc, add the following:

```shell
export PATH=$PATH:/c/Program\ Files/Sublime\ Text\ 2
```

Of course, if you have installed your sublime to somewhere other than that use that path instead.  Note that the windows path uses spaces, "Program Files", but under bash or zsh you'll need to escape that space with a slash `\`.

Once you've restarted the shell the `Sublime Text 2` folder should be accessible.  You can test this by running sublime from the command line...

```shell
$ sublime_text.exe
```

### Step 2: Add a Dash of Usability ###

But really, who wants to type all that out, `sublime_text.exe` every time?  Also, did you notice that running the exe from the command line "steals" the use of the command line until sublime is closed.  This is the default nature of executing commands on the command line, and both of these issues can be addressed by creating a simple shell script.

    $ notepad /c/Program\ Files/Sublime\ Text\ 2/sublime

Notepad will ask you if you want to create that file.  Say yes, then enter the following:

    #!/bin/bash
    sublime_text.exe $1 &

Save that file.

### Step 3: Making it Executable ###

The last thing we need to do is mark our `sublime` shell script as being executable.  By default, bash will just assume that the file we created is a text file (which it is, but stay with me).  In order to be able to execute it, we need to make it as executable.

    $ chmod 444 /c/Program\ Files/Sublime\ Text\ 2/sublime

That's it.  With this setup there are several useful things you can now use it for:

    # Open sublime from the console
    $ sublime

    # Open a file from the console
    $ sublime ~/.bashrc

    # Open a directory from the console
    $ sublime ~

    # Open the current directory from the console
    $ sublime .

Have fun.
