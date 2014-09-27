---
title: Moving to Middleman
category: ruby
tags: blog, ruby
date: September 20, 2014
---

[Back in 2012](/blog/2012/microwave-js.html) I started working on blog platform named [Microwave.JS](https://github.com/tstone/MicrowaveJS). At
the time I was working with [Grant Klinsing](https://twitter.com/gklinsing) who also [contributed](https://github.com/tstone/MicrowaveJS/graphs/contributors)
a bit to it as well.  The project was based on node.js with the fundamental idea that blog posts were written in Markdown as individual
.md files.  When the server started it would scan all these files and hold them in memory, allowing search and other type things to be performed
on them.  I had also toyed with a [Ruby re-write](https://github.com/tstone/Radiowave) several months later as well.

Time went by and eventually the idea of a static site generated started to grow on me.  The past 2 weekends I converted my blog (the
  site presentingly being viewed) over to [Middleman](http://middlemanapp.com/basics/blogging/).  I had let my previous domain `typeof.co` expire
  which gave me a chance to pick from the new swarm of gTLD's that are now available.  As an aside, I actually have two other domain names that
  I'd rather have but those gTLD's aren't released yet so we'll see if I can get lucky during the landgrab phase when they do become available.

## About Middleman

Middleman solves the same requirements that I had for Microwave.JS:

  * Write blog posts using a code editor
  * Not have to deal with HTML when writing a blog post
  * Super fast and simple to publish new posts
  * Flexible, offering a good amount of control over presentation

Middleman offers all of these by basically being a pre-compiled Rails app.  The site is coded using the framework, then a build command is run
which transforms the dynamic Ruby site into a static HTML page by pre-rendering every permutation of page that is possible.  It comes bundled
with familiar tools like ERB and Sprockets which allows it to have dynamic layouts, asset compression, and similar during the build step.

What's even more crazy is that since it's so close to Rails, it can use gems and features written for Rails.  A good example of this is that my
blog is actually running Turbolinks.

I maintain two repositories for this site, the [source](https://github.com/tstone/array.blue) and the [build](https://github.com/tstone/tstone.github.com) (output).

## The Start

Middleman has two core files that serve as the origin for the rest of the system: `Gemfile` and `config.rb`.

The `Gemfile` basically plays the role of answering the question, "what plugins do you want to use?"  Here's what mine looks like:

```ruby
source "http://rubygems.org"

gem "middleman", "~> 3.3.6"
gem "middleman-blog", "~> 3.5.3"
gem "middleman-syntax"
gem "middleman-deploy", "~> 0.3.0"
gem "middleman-minify-html"
gem "middleman-ogp"
gem "middleman-search_engine_sitemap"
gem "middleman-blog-similar"

gem "nokogiri"
gem "redcarpet"
gem "builder", "~> 3.0"
gem "turbolinks", require: false
```

The `config.rb` is where default options are set and where plugins are activated and configured.

```ruby
activate :blog do |blog|
  blog.layout = "layout"
  blog.default_extension = ".md"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # pagination
  blog.paginate = true
  blog.per_page = 20
  blog.page_link = "page/{num}"
end
```

## Templates

As you can see from the `config.rb` snippet the configuration allows an overall layout page to be used and for specific page types, tags, calendar, etc.
to use specific pages as well.  What's not clear just by looking at the config is those layouts/pages are actually ERB.  They could just as well
be HAML, Slim, or whatever template engine is preferred.

Middleman provides a handful of variables in the template that can be used to describe how things should be displayed.  For exmaple, on the blog index
page something like the following might take place...

```html
<% page_articles.each do |article| %>
  <article>
    <% link_to(article) do %>
      <span class="title"><%= article.title %></span>
      <span class="date"><%= article.date.strftime('%B %e, %Y') %></span>

      <% if article.data.category %>
        <span class="category <%= article.data.category %>"><%= article.data.category %></span>
      <% end %>
    <% end %>
  </article>
<% end %>
```

Middleman in this case is providing the `pgae_articles` variable.  It provides several others as well to allow probably any configuration you could
imagine.

## Extras

One of the fantastic features of Middleman is the availability of [extensions](http://middlemanapp.com/advanced/custom/) that are easy to use.
It was extremely trivial to add the following features to my site:

  * Asset unification
  * Asset minification
  * HTML minification
  * sitemap.xml generation
  * Open graph tags
  * Markdown rendering
  * Simple deploys to Github pages

Overall I've been happy with the Middleman experience so far and if I ever run across anything for which there is not an extension available,
being in Ruby I could always write an extension myself.
