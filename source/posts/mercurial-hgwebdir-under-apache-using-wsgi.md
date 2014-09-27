---
title: Mercurial 'hgwebdir' under Apache using WSGI
date: nov 2, 2009
tags: [apache, mercurial, wsgi]
---

The doc for setting up [HgWebDirStepByStep](http://mercurial.selenic.com/wiki/HgWebDirStepByStep) sure make it seem harder than it really is. Maybe it is hard. Maybe it’s just that I spent so much time trying to understand the doc, that when I actually just tried it myself it wasn’t that bad.

I’ve been thinking of moving over from SVN to Mercurial (hg) but wasn’t sure if it was worth the fuss. I moved. It seems nice. Here’s a guide, including tutorials for both the server and client, to switch to hgwebdir (server) /TortoiseHg (client).

Let’s get started.

## Setting up Mercurial (Part 1)

Before we configure the server, the following must already be installed and running:

 - Python 2.x (not ActivePython)
 - Apache 2
 - mod_wsgi under Apache

I’m going to be demonstrating the setup on Windows 2000 Server as the host for hgwebdir/apache, and Windows Xp as the developer machine.

1. Setup the Directory Structure
Create the following structure:

    C:\Mercurial
    \src
    \hgwebdir
    \repositories

We’ll be putting files into these folders shortly.

### 2. Download mercurial source

Whatever you do, _don’t install TortoiseHg on the server_. To run hgwebdir you’re going to want to have compiled mercurial yourself.

[Download Mercurial source](http://mercurial.selenic.com/) (Be sure to not get the binary)

After download, extract the contents to `C:\Mercurial\src`, or wherever you created your ‘src’ folder in the directory structure from above.

### 3. Build Mercurial

(Instructions taken mostly from [WindowsInstall wiki page](http://mercurial.selenic.com/wiki/WindowsInstall))

    C:\> cd mercurial\src
    C:\Mercurial\src> python setup.py --pure build_py -c -d . build_ext -i build_mo --force
    C:\Mercurial\src> python setup.py --pure install --force--force

Mercurial will now be built and installed into your python site-packages folder.

### 4. Setup a 3-way Diff tool

[Download KDiff3](http://sourceforge.net/projects/kdiff3/) from SourceForge. Install using the included windows setup binary.

### 5. Configure Environment Variables

Add `C:\Python26\Scripts` and `C:\Program Files\KDiff3` to your `PATH` environment variable.

You will need to be logged into an account that has admin right on the machine to setup this next part. Right-click on “My Computer” and choose “Properties”. Choose “Advanced”, then click the button “Environment Variables.” In the list at the bottom, “System variables”, scroll down and find PATH. Click “Edit”. At the end of the textbox add a semi-colon, then type in the path from above. Your PATH variable should then resemble...

    ...;C:\Program Files\KDiff3;C:\Program Files\KDiff3;

### 6. Create a local Mercurial configuration file

Windows Explorer has a limitation that won’t let you create a new file that starts with a period. The way around this is to use notepad on the command line to type in the name of a file with a period.

Mercurial uses a local file named `.hgrc` to configure itself about which 3-way merge tool it should use and similar things to that nature.

Follow these commands to create the `.hgrc` file for the server:

    C:\> cd Python26\Scripts
    C:\Python26\Scripts> notepad .hgrc

This will cause notepad to pop up and ask if you want to create a new file named .hgrc. You do. Here’s the basic configuration file for mercurial. Edit these settings to whatever you need to be.

``ini
[ui]
editor = Notepad
username = hgadmin <webmaster@yourdomain.com>

[merge-tools]
kdiff3.priority=-1
kdiff3.args=-L1 base --L2 local --L3 other $base $local $other -o $output
kdiff3.regkey=Software\KDiff3
kdiff3.regappend=\kdiff3.exe
kdiff3.fixeol=True
kdiff3.gui=True
```

You’ve got Mercurial installed now! If you open a command prompt and type ‘hg’ it should print out the command’s help.

## Setting up Apache/hgwebdir (Part 2)

Hmmm… ok maybe that is a lot of work. It didn’t seem like it at the time.

Going into this, I’m assuming you’ve already got Apache with mod_wsgi up and running. I should point out that you can technically run hgwebdir under CGI or mod_python, but as WSGI is the hotness now days probably a lot of people have already started using that.

Good news is, I think this part is a lot easier.

On my setup I’ve only got 1 server, and so I tend to run things as Virtual Hosts. If you’re already running Apache I’m assuming you’ve got the smarts to change this config if you like a different setup, but for the example httpd.conf below, I’ll be doing a virtual host.

### 1. Create our WSGI handler file

The WSGI file is really simple. We basically need to 1.) import the necessary modules, then 2.) pass a new instance of hgwebdir with the configuration file path back to WSGI handler.

```python
from mercurial import demandimport; demandimport.enable()
from mercurial.hgweb.hgwebdir_mod import hgwebdir

CONFIG = 'C:\Mercurial\hgwebdir\hgweb.config'
application = hgwebdir(CONFIG)
```

Create this script and save it as `hgwebdir.wsgi` into the `C:\Mercurial\hgwebdir` folder.

### 2. WSGI app config file

You probably noticed in the code above that we’re referencing a config file that doesn’t yet exist. Let’s go ahead and create that.

```ini
[web]
style = coal

[paths]
/ = C:/Mercurial/repositories---*
```

Save this file as `hgweb.config` into the `C:\Mercurial\hgwebdir` folder.

### 3. Configure Apache

So we’ve got our WSGI script and config file setup. All that’s left now is to configure Apache.

We need to have a few things in our Apache conf in order to get everything working: 1.) A new virtual host to hold all of our Mercurial settings, 2.) a WSGIScriptAlias to make sure our hgwebdir.wsgi file handles web request, 3.) authentication (skip this if you want a public repository), and 4.) SSL.

    # ---- HTTPS -- Mercurial Virtual Host ----
    <VirtualHost *:443>

        ServerName hg.yourdomain.com:443
        ServerAdmin webmaster@yourdomain.com
        DocumentRoot "C:\Mercurial\repositories"

            WSGIScriptAliasMatch ^(.*) C:\Mercurial\hgwebdir\hgwebdir.wsgi$1

            <Directory "C:\Mercurial\hgwebdir">
                Options ExecCGI FollowSymlinks
                AddHandler cgi-script .cgi

                AllowOverride AuthConfig
                Order deny,allow
                Allow from all

                AuthType Basic
                AuthName "Mercurial"
                AuthUserFile "C:\Mercurial\accounts"
                Require valid-user
            </Directory>

            # SSL Stuff...
        SSLEngine on
        SSLCipherSuite ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP:+eNULL

        #   Server Certificate:
        SSLCertificateFile "...your cert file..."
        #   Server Private Key:
        SSLCertificateKeyFile "... your pk file..."
        #   SSL Protocol Adjustments:
        BrowserMatch ".*MSIE.*" \
                 nokeepalive ssl-unclean-shutdown \
                 downgrade-1.0 force-response-1.0
    </VirtualHost>

All of the above goes in httpd.conf.

There’s lots of stuff going on in there. Let’s look at a bit of it.

Even though we’ve configured hg.yourdomain.com, unless you have actually setup an A record of “hg” for yourdomain.com, that address won’t actually resolve (ie. it won’t work).

The `WSGIScriptAliasMatch` is actually what routes our incoming Mercurial requests to the hgwebdir.wsgi file for handling. In order for this directive to work, you’ll need to have mod_wsgi enabled in your httpd.conf file. (this is outside the scope of this post)

Just copy and paste the SSL configuration from elsewhere in your config file if you’re already using it. If you don’t have a cert or don’t want to use SSL then delete all of that section and change the ports at the top back to 80.

Lastly, did you notice the auth part of the configuration? We’re using AuthType Basic and we have a user file “C:\Mercurial\accounts”. We haven’t created that yet, so let’s go ahead and do so.

In Part 2 when we look at setting up the client, I’ll show you how to configure TortoiseHg to save the user/pass that will be authenticated here by Apache.

### 4. Setting up Mercurial Users

It’s important to note at this point that the authentication is being handled by Apache and not Mercurial. In my setup we’re just using HTTP Basic, however if your Apache install is already using something better (LDAP, DBM, whatever), then by all means use that instead.

If you’ve never made an Apache passwd file, it’s an easy process. Apache gives you a tool “htpasswd” which allows you to create a new passwd file or to add new users to an existing file.

* Important: I don’t know where your Apache is installed, so you’ll need to interpret some of these paths for your specific machine.

htpasswd is located in the Apache bin folder. We’re talking something to the effect of C:\Apache2.2\bin\htpasswd.exe. Figure that out, and then use the command line as indicated below to create our accounts file for Mercurial.

    C:\> cd Apache2.2\bin
    C:\Apache2.2\bin> htpasswd "C:\Mercurial\accounts" testuser

This will create the file `accounts` in `C:\Mercurial`, add a new user “testuser” and then prompt you for a password for the new user. You can repeat this command later on to add new users.

### 5. Bask in how fashionable you are using Mercurial

If everything went well up to this point, you should be able to start Apache and try out your new hgwebdir install.

But upon arrival you’ll probably notice that… it’s empty. Let’s create a new repository.

### 6. Adding repositories

Remember the folder we made `C:\Mercurial\repositories`? That’s where all the repos will be living. Create a new repository like you would locally…

    C:\> cd Mercurial\repositories
    C:\Mercurial\repositories\> mkdir testrepo
    C:\Mercurial\repositories\> cd testrepo
    C:\Mercurial\repositories\testrepo\> hg init

Refreshing your the URL of your hgwebdir install should now show a new read-only repository. By default new repositories are not push-able.

### 7. Create a repository configuration file

We can enable features and also fill out the details about repository by create a configuration file. Assuming the repository you created was “testrepo”, create a new file named `hgrc` in `C:\Mecurial\repositories\testrepo.hg\` folder.

```ini
[web]
contact = Your Name
name  = Test Repository
description = A repository that I can show how cool I am using hg
allow_push = *
allow_archive = gz zip
```

Most of this is self-explanatory. The `allow_push` directive enables files to be synchronized from the client’s repository up to the repository on the server. The “allow_archives” will enable a snapshot of a given revision to be downloaded in those formats.

Save this file, refresh and there you go.

Next, we’ll look at setting up TortoiseHg on a Windows XP developer box to connect to our new hgwebdir instance.
