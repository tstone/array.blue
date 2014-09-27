---
title: HttpModule for Easier Master Pages
date: may 4, 2009
tags: [.net, asp.net]
category: c-sharp
---

You know, I just don't like ASP.NET's Master Page feature. The thing is, I've always felt they create more hassle in the long run. Typically, I end up with way too many content place holders. I also really dislike looking at HTML pages which are only a series of `<asp:Content>` tag blocks.

So here's my workaround: a custom HttpModule that emulates the effect of Master Page without having to actually create and use a Master Page.

### How It Works

 - A custom HttpModule is registered in the Web.config file
 - This module catches every request that is of Content-Type text/html (this includes aspx and such) and inserts pre-defined HTML into the outgoing HTML.

Sounds easy right? Yeah it is. I call my creation "Page Master"! (Aren't I a clever one)

### Specifics of What It Makes Easier

Generally, I found the only thing I was using master pages for was...

 - Common CSS files
 - Common Javascript files
 - Page header
 - Page footer

Page Master supports all 3 of these, all user-definable in the `web.config` file:

```xml
<!-- Config for PageMaster Http Module -->
<pagemaster>
    <headtag file="~/PageMaster/headtag.html" />
    <header file="~/PageMaster/header.html" />
    <footer file="~/PageMaster/footer.html" >
</pagemaster>
```

So, let's say you have a basic HTML page...

```html
<-- HTML page unmodified -->
<html>
    <head>
        <title>My Page</title>
    </head>
    <body>
        <p>Body Text</p>
    </body>
</html>
```

The contents of your `headtag.html` is...

```html
<script src="/js/fake.js" />
```

With Page Master, the resulting page will be returned to the client instead as...

```html
<-- HTML page after Page Master -->
<html>
<head>
    <script src="/js/fake.js"></script>
    <title>My Page</title>
</head>
<body>
    <p>Body Text</p>
</body>
</html>
```

...without ever having to use Master Pages.

### Limitations

Since this was a quick project I whipped up in a couple hours, it's rather limited.

Right now this module only supports static HTML files, but I'd like to expand it to also be able to execute ASPX files, or to fetch a file from another server with HTTP. In case you're worried about performance, the data which is inserted is cached to the whole application, so it's only loaded once, and not every page request.

Another limitation is that it will insert the values for all pages of Content-Type "text/html", and not just the ones you've specified. Perhaps a feature that allows one to configure pages to ignore or not to do that on.

Download Page Master Http Module Source + Test Project (now broken)
(Hit the 'click here' link next to "Save file to your PC:")

### References
[Producing XHTML Compliant Pages with Response Filters](http://aspnetresources.com/articles/HttpFilters.aspx)

[Customizing SectionGroups and Sections](http://www.codeproject.com/KB/aspnet/Managing_Webconfig.aspx)

[configSection Element (MSDN)](http://msdn.microsoft.com/en-us/library/ms228256.aspx)
