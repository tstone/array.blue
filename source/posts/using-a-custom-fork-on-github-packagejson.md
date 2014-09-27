---
title: Using a Custom Fork on Github with npm/package.json
date: feb 4, 2012
tags: github, npm, heroku
category: javascript
---

I just learned a really neat trick.  Have you ever had this situation come up:

You forked a public repo on github of an npm module and made some fixes or changes, but now you want to be able to use your fork in another project, perhaps even on Heroku?

Here’s how it’s done…

In the package.json file, replace the version of the npm module with the HTTP address of it’s github tarball.

Change this:

```json
"dependencies": {
   "stylus": ">=0.1.0"
}
```

To this:

```json
"dependencies": {
    "stylus": "http://github.com/tstone/stylus/tarball/master"
}
```

That’s it.  Pretty slick huh?
