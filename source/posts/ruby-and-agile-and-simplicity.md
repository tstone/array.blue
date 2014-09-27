---
title:    Ruby, Agile, and Simplicity
date:     September 21, 2012 6:56
tags:     ruby, agile
category: ruby
---

When first, _seriously_ starting on Ruby, it's hard not to miss what otherwise appears as awkward syntax.  Here is an example from rails.

```ruby
class Comment < ActiveRecord::Base
    belongs_to :post
    attr_readonly :created_at
end
```

It almost doesn't even look like code.  It just looks like some words; as if directives are just being given to the compiler out of context.

The reason this is possible is because Ruby makes parts of the syntax _optional_.  Most ruby developers write in a style similar to the above, but it's longhand version would look something more akin to the following.

```ruby
class Comment < ActiveRecord::Base
    self.belongs_to(:post)
    self.attr_readonly(:created_at)
end
```

At first glance it's an odd thing to do.  And to a seasoned Java or C# developer, it's probably a "horrible" thing to do.  But ruby's approach here brings out two subtle attributes.

### Succinctness ###

The first is `succinctness`.  Paul Graham wrote probably the best essay about this, ["Succinctness is Power"](http://www.paulgraham.com/power.html).  In it, he uses Python as his example language and criticizes it a bit for it's design choices.

  > It seems to me that succinctness is what programming languages are for. Computers would be just as happy to be told what to do directly in machine language. I think that the main reason we take the trouble to develop high-level languages is to get leverage, so that we can say (and more importantly, think) in 10 lines of a high-level language what would require 1000 lines of machine language. In other words, the main point of high-level languages is to make source code smaller.

  > If smaller source code is the purpose of high-level languages, and the power of something is how well it achieves its purpose, then the measure of the power of a programming language is how small it makes your programs.

### Simplicity ###

The second is `simplicity`, but it's worth it to consider how this ruby code would look in other languages.

#### Javascript (Dynamic, Semi-Functional) ####

```javascript
var Comment = function(){
    this.belongsTo('post');
    this.attrReadInly('created_at');
};
var Comment.prototype = new ActiveRecord.Base();
var Comment.prototype.constructor = Comment.prototype;
```

#### C# (Static, Object-Oriented) ####

```csharp
namespace Models
{
    [BelongsTo(typeof Models.Post)]
    public class Comment : ActiveRecord.Base
    {
        [ReadOnly]
        public DateTime CreatedAt { get; set; }
    }
}
```

This is where ruby hits home for me.  The [Agile Manifesto](http://agilemanifesto.org/principles.html) has as it's 10th principle this thought:

  > Simplicity--the art of maximizing the amount of work not done--is essential.

The art of maximizing work not done.  Comparing ruby to both javascript and C#, I'm beginning to see how ruby _is_ a more agile language.
