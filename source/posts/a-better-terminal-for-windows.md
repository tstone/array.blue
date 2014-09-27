---
title: A Better Terminal for Windows
date:  June 2, 2012
tags:  windows, shell, monokai
category: windows
---

Paul Irish's presentation, ["Javascript Development Workflow of 2013"](http://www.youtube.com/watch?v=f7AU2Ozu8eo), given at the recent Fluent Conf 2012 is starting to make it's rounds.  In it, he goes over a handful of tools that can improve one's efficiency and productivity while developing.

It inspired me to tune-up my own environment.  OSX is certianly popular now days, but I still do a lot of .NET work so I primarily am on Windows.  And with a lot of the windows compatibilty improvements node.js has been seeing lately, there's no reason to not consider Windows as a valid development platform.

That said, one area that needs the most help is the terminal.  In an ideal world, here's what our windows developer terminal would look like:

- It should allow us to execute familiar unix/linux commands
- It should have command and file completion
- It should look nice
- It should be instantly accessible from anywhere, easily, somehow

Turns out, all of this is possible.

## Start with the Shell

[Z shell (or zsh)](http://www.zsh.org/) is one of the most-loved shells among power users.  It was originally written for the POSIX environment, but can be had on Windows through [Cygwin](http://www.cygwin.com/).

### Getting Zsh on Your Windows Box

1. First, head over to [cygwin.com](http://www.cygwin.com/) and download the Cygwin installer
2.  At some point in the installation, after clicking "Next &gt;" a handful of times, you'll end up on a "Select Packages" screen.  The important one to get is Shells &gt; Zsh.  You might also want to pickup other packages like git or nano while you're here.

That's pretty much it.  Zsh is now on your system wherever you installed it.  By default when you launch the Cygwin prompt it will be running bash.  In a second we'll look at changing this.

![Alt Stock Cygwin](/images/stock-cygwin.png)

## Now Give it a Better UI

If you tried launching Cygwin, you'll notice that the way it works is by running the bash.exe (bash shell) under cmd.exe.  This works, but there is a better option: [Console2](http://sourceforge.net/projects/console/).  Console2 provides a few notable improvements:

- It looks a lot nicer
- It has tabbed console windows, so you can have more than one open and flip between them

Download and Install Console2.

Once you've got it installed, we need to configure it to run our Zsh under Cygwin.  To do so, open Console2 and on the menu go to Edit &gt; Settings.  Then configure the following values:

	# Shell:
	D:\Cygwin\bin\zsh.exe --login -i -c "cd ~;exec /bin/zsh"

You can leave "Startup dir" blank.  In this case, I've installed my Cygwin to `D:\Cygwin` but if you installed it elsewhere you'll want to use that path instead.

While you're on the settings screen you might also want to increase the default window size.  I have mine set to...

	Rows: 34
	Columns: 124

With all that done, save the settings and re-launch Console2.  You should now get a prompt that is like...

	(YourName@YourComputerName)[1] ~

If so, you've done everything correctly.

## Now Make it Accessible

One of the things I like about Ubuntu is that the terminal window is easily available via a hot key from anywhere in the system.  By default, this key combination is `ctrl+alt+t`.  I've gotten used to that and it's possible to have this same behavior on Windows with a utility called [AutoHotKey](http://www.autohotkey.com/).

As with all of the other software mentioned in this blog post, it's free.  Go ahead and download it.

AutoHotKey is a little more tricky to setup.  It uses "hot key scripts" to define what keys map to what functionality.  The language of these scripts is proprietary, so I won't cover it in detail here.  You can read through the included help file or website if you want to learn it.

For our purposes we simply want to bind `ctrl+alt+t` to launching our Zsh in Console2.

After AutoHotKey is installed, create a new file named "AutoHotKey.ahk" in your Startup folder (you know the one on the Start Menu).

Edit it and add in the following:

	; ctrl + alt + t = terminal
	^!t::
	    run D:\Program Files\Console2\Console.exe
	    return

In this case `^` is CTRL and `!` is Alt, so `^!t::` means `ctrl+alt+t`.  You can think of the `::` as a kind of function definition.

After you've got the file saved, click (or double click) on the .ahk file to start AutoHotKey.  Since it's in the startup folder it will start automatically with your computer, but for the first time we need to manually start it.  You should see a green "H" icon appear in the task bar area next to the clock.

Go ahead and press the key combination and Console2 should appear.

## Now Make it Look Good

We're almost there.  We've got Zsh running in Console2, but by default that green and mustard are ugly.  It turns out Console2 allows cusomizing of colors, but it's a little cumbersome.  There isn't any kind of "scheme" import utility, you have to do things yourself.

The colors can be edited under Settings or can be manually edited in bulk by messing with the configuration file.  The config file is `console.xml` and is located in the same directory as the `console.exe` executable.

There are 2 color schemes up on github (at the time of writing) and becuase I like it so much, I put together a monokai one as well.

- [Monokai](https://github.com/tstone/console2-monokai)
- [Solarized](https://github.com/stevenharman/console2-solarized)
- [IR Black](https://github.com/alanstevens/console2-ir_black)

For all three of themes, the color scheme can be installed by copying everything between `<colors>` and `</colors>` out of the file on github and into your `console.xml` file.

## Then Actually Make Use of Those Colors

One last thing.  It's a bit pointless to setup a nice color scheme if by default the colors arne't always shown.  One thing we can do as setup aliases to enable colors by default.  A great example of this is for the command `ls`.  By default, `ls` will use white for everything, however `ls --color` will colorize directories, executables, etc. in different ways.  It would be cumbersome to type this everytime, so we can setup a zsh alias to do it for us.

Aliases can be added to your `.zshrc` file.

	nano ~/.zshrc

And add this line:

	alias ls='ls --color'

Restart your zsh and now every type you do `ls` you should get a colorized version, in monokai colors (or the scheme of your choice).

![Alt Console2 with Monokai Colors](/images/console2.png)

## And Add Some Cool Tricks

Bash and zsh will both let you pipe the output from one command into another.  One technique I've found that's useful is to pipe the output of a command into the clipboard.  Say for example I want to copy my SSH public key and add it to github.  Typically I'd do something along the lines of...

	$ less ~/.ssh/github_rsa.pub

And then I'd have to highlight all the text in the console and hit `ctrl+c`.  However, if we were to instead do...

	$ cat ~/.ssh/github_rsa.pub | clip

The contents of that file would, instead of being written out to the console, be stuck into my clipboard.  I could then `ctrl+v` it into github as needed.

### Caveats

The only thing I haven't yet gotten working is `npm` under zsh/bash/cygwin.  The problem seems to be the paths to the modules don't resolve correctly.
