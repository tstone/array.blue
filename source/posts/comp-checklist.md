---
title: Comp Checklist for Developers
date: October 22, 2013
tags: design, process
---

Being a developer requires a handful of soft skills that are rarely ever talked about much.  One such skill that every web developer is
bound to encounter sooner or later is being shown a mockup, comp, redline, or whatever your client calls it and being asked to assess
how much time it will take.

These are always tricky because as humans we tend to "mentally approximate" (aka oversimplify) things and understanding the hidden complexity behind a request is difficult.
Having worked at agile-based companies for the last several years story pointing is effectively this same process.  Since this was such a regular
part of my day job, I began to keep notes on where surprise requirements were showing up after work was started.  I then reversed those notes into
a checklist of things to consider when being presented with a comp.

I originally intended this list for developers to use but as it turns out the product owners and designers at my current company were interested
in it too.  There is a [gist](https://gist.github.com/tstone/7049448) of this up on Github too which anyone is welcome to fork/pull request.

## Checklist

#### Titles/Text

  - How is overflow handled?
  - What is the behavior if the text/title is empty?

#### Links

  - Where does it go?

#### Images

  - When the source data includes multiple, which image should be picked?
  - For fixed-size images, should they be cropped or "letterbox"?
  - What is the alt text?
  - Will the image be large and need some sort of resizing/minification?
  - For lists of thumbnails that paginate, will it require lazy loading?
  - What is the behavior when there is no image in the source data?

#### Lists

  - What is the order?
  - Are all items shown or should there be pagination?
  - Are additional items (when paginating) lazy loading?
  - What is the behavior if the list is empty?

#### UI Elements

  - What does every button do?
  - What is the hover behavior?
  - Are there tooltips?
  - Are there animations?

#### Widget

  - Does the widget appear on every page or just some?
  - Does the widget need to change for tablet/mobile?
  - Are there any conditions when this widget shouldn't appear?
  - Does it require special tracking or analytics pixels?
