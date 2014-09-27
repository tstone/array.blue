---
title:    Thinking of Template Engines
date:     September 13, 2012 6:30
tags:     templates, haml, html
category: idea
---

I'd be amiss if I didn't tell you I just spent the better part of today evaluating template engines.  This certainly isn't the first time I've had to evaluate and select a template engine.  It was, however, the first time I've had to do it knowing that 8+ developers were going to have to use this bringing in all their experience and background from other languages.

It turns out it's ridiculously difficult to select a template engine for a web project which 1.) is easy to read and understand, 2.) isn't too overwhelming for designers, 3.) enforces some kind of consistency, and 4.) everyone can agree on.  That last goal is probably asking for too much, but the first three certainly are something most business would want when selecting a template engine.

Having been in web development now for almost 15 years, the templating "scene", if you could call it that, has seen some ebbs and flows.  Early web development with Perl/CGI was little more than concatenating HTML as a string in some script.

```perl
'<a href="/post/' . $projectid . '">Project Id #' . $projectid . '</a>' if $isproject
```

As things evolved, ASP and PHP put forth a mainstream idea to have a separate HTML file which contained some display logic but primarily separated the HTML from the processing script.

```php
<% if (isproject) { %>
    <a href="/post/<%= project.id %>">Project Id #<%= project.id %></a>
<% } %>
```

"Spaghetti code" was a phrase that began to be associated with this PHP/ASP type of templating.  Interestingly enough Rails picked up this style with it's default choice of ERB.

Soon however came the not-code-but-tags type of templates.  The Django template language, for example, allowed _some_ logic and functionality through pre-defined tags but did not allow code to be directly in the template.  These tags offered most functionality that you'd need for display logic, but prevented the native language (Python, Ruby, VBScript, whatever) from being anywhere in the HTML.  This notion was likely aimed at preventing the spaghetti code of above.

```liquid
{% if isproject %}
    <a href="/post/{{ project.id }}">Project Id #{{ project.id }}</a>
{% endif %}
```

From there things started going crazy.  A few of the more extreme spin-offs happened, such as the minimalistic, significant white space, tag-less type of template engines like HAML and Jade.  These approach the problem by throwing away HTML completely, and designing a new language to describe the structure of documents which results in HTML output.

```slim
- if isproject
    a href="/post/#{project.id}" Project Id ##{project.id}
```

On the opposite end of the spectrum are logic-less templates, which stuck closer to the ideas of the Django/Liquid template language, but took that idea as far as it could go.  In such logic-less templates there are no `if`'s or `then`'s, only blocks.  Blocks automatically resovle to if's or for/each's on the backend, but such logic isn't actually typed out into the template.

```handlebars
{#isproject}
    <a href="/post/{{project.id}}">Project Id #{{project.id}}</a>
{/isproject}
```

I realize this little history lesson isn't exhaustive, but it at least gives context to what I'm going to say:  I _still_ don't like any mainstream template languages.

ERB/ASP still suffer from spaghetti code.  HTML/Jade are too extreme, too difficult to read, and can become awkward to work with.  Mustache/Handlebars (logic-less) become too restrictive.  The Django/Liquid style of templates is probably the best pick, but the syntax can be rather verbose.

### What's Missing? ###

LESS, the CSS pre-processor, introduced an idea that seems to have been lost with many web template engines:  all of CSS is valid syntax.  In other words, start with the existing language, then add on top of it.  This approach stands head and shoulders above the rest for real world, team applications because it lowers the learning curve a lot for new folks coming in.  Starting with a language that you can write everything as you know it, then begin to add on tricks as you learn them is a big advantage.

Secondly, it makes templates actually look like, you know, HTML.  This is a benefit for designers who need to set things up initially, but aren't programmers and don't want to learn intricacies of a custom language or a logic-less system.

### Sculpting Something New ###

One of those intangibles is where a language becomes the syntax of how a programmer thinks it in their head, cutting out the fluff in between.  Here's an example of that.

```html
<a href="/post/1234" class="button">Project Id #1234</a>
```

The above markup is very common.  The tag-less languages would let you identify this tag simply with:

```css
a.button
```

But that doesn't "read" like HTML, so what if we brought back the tags?

```html
<a.button></a>
```

Tag-less languages usually end up having a verbose syntax for attributes.  As an example, HAML requires the "hash rocket" syntax and symbols...

```haml
%a{:href => "/post/1234"}
```

That's a bit too verbose.  The more substitution-based languages don't shorten this down at all.  It's been my observation that _many_ HTML tags have what could be considered a "default attribute":

  - `src` for `<img>`
  - `href` for `<a>`
  - `type` for `<input>`
  - and so on...

As a shorthand for these default attributes, it could be written as if `tag equals default attribute`.

```html
<a.button="/post/1234"></a>
```

Additional attributes could be written in as normal:

```html
<a.button="/post/1234" target="_blank"></a>
```

I think this works because typically when I'm coding, I think "This anchor equals this destination URL."  I don't think, "This anchor's href attribute equals this URL."  If this mental shorthand that we're already doing could be tapped in a language, it could create something that reads and writes as easy as HTML, but is less verbose.

### About Code Blocks ###

In the ASP or PHP world, this kind of thing ended up being common:

```php
<% if (something) { %>
    // ...
<% } %>
```

What the heck is this: `<% } %>`.  I can't even begin to describe how awkward that is to read, being all symbols and visually rubbish.

On the flip-side, the tag-less template engines use the significant white space (read: indentation) to isolate code blocks

```haml
    - if something
        // ...

    some other markup here
```

This creates the opposite problem: There isn't anything telling you the block is done or where the markup is out of the block except the white space.  And the white space is rather vague in it's appearance.

The Liquid/Django engines provide a decent alternative here by simply being verbose.

```liquid
{% if something %}
    // ...
{% endif %}
```

Using `{` and `%` is just hands-down, one of the worst character combinations to type...  shift+[, shift+5, space.  Ugh.  Secondly, `endif` is unnecessarily verbose.

This is one place where a corporate language got it "kind of" right: Razor.  Microsoft's Razor template engine, for MVC3 and above, simply uses @.  And while @ is still shift+2 it is for one reason or another easier to type than %.  What if the whole code block was shortened down to just...

    @if something
        // ...
    @end

Not too bad?  The @'s set it off as being a separate block, but there isn't a huge amount to type to get there.

Which brings us to the issue of substitution.  To be honest, there isn't much difference between `#{project.id}` and `{{ project.id }}`.  And there's not likely much room for improvement either.

The best that can be hoped for here is a syntax which makes the substitution stand out.  White space here _should be required_ when the substitution is happening mid-string.  A nicety would be if the same character that was used for a code block was used for substitution. This simply reduces the surface of the language, and only requires developers to remember that `@@` is needed when they need an actual `@` symbol in the text.

```html
<a.button="/post/@: project.id :" target="_blank">Project Id #@: project.id :</a>
```

The idea here is to use white space plus symbols to set off the substitution.  The colon `:` character was chosen in combination with the `@` to give it a sense that there is an insertion happening (imagine `@:` being a portal, and text is flying in through that portal).

However, sometimes it happens than the insertion will go into a sentence of human language.  In this case, the trailing `:` and required white space become awkward to code instead of improving visibility.  In these cases no white space would be required at the start, but white space or punctuation after the variable would be required.

```html
<p>Hello, @:name.  Your current balance of @:balance is up 2% over yesterday!</p>
```

One more thing: single line comments should be allowed.

```html
// Link to the currently selected project
<a.button="/post/@: project.id :" target="_blank">Project Id #@: project.id :</a>
```

So would all of this make a better template engine?  I don't know.  Someone should build it and we'll find out.

At the moment, the best alternative to the above which I've seen is [Slim](http://slim-lang.com/).  In that vein, I'll re-code the same document that appears on the front of both Slim and Jade here in my fake template language.

#### Slim vs. Mine ####

[Template In Slim Code](http://slim-lang.com/)

```html
<!DOCTYPE html>
<html>
    <head>
        <title>Examples</title>
        <meta="keywords" content="template language" />
        <meta="author" content="template language" />

        <script>
            alert('Supports embedded javascript!');
        </script>
    </head>

    <body>
        <h1>Markup examples</h1>

        <div#content>
            <p>This example shows you how a basic template file looks like.</p>

            @yield

            @if items
                <table>
                    @for item in items
                        <tr>
                            <td.name>@: item.name :</td>
                            <td.price>@: item.price :</td>
                        </tr>
                    @end
                </table>
            @else
                <p>No items found.  Please ad some inventory.  Thank you!</p>
            @end
        </div>

        <div#footer>
            @render 'footer'
            Copyright © @:year @:author
        </div>
    </body>
</html>
```

#### Jade vs. Mine ####

[Template In Jade](http://jade-lang.com/)

```html
<!DOCTYPE html>
<html="en">
    <head>
        <title>Jade</title>
        <script="text/javascript">
            if (foo) {
                bar();
            }
        </script>
    </head>

    <body>
        <h1>Mine - a possible template engine</h1>

        <div#container>
            @if youAreUsingMine
                <p>You are amazing</p>
            @else
                <p>Get on it!</p>
            @end
        </div>
    </body>
</html>
```
