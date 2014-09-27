---
title:    Conditional Should in RSpec
date:     April 22, 2013 7:44
tags:	    rspec, testing
category: ruby
---

Something I've been trying to get more comfortable with is custom matchers for RSpec.  In my opinion, behaviour tests should be as short as possible.  After all, they convey a certainly level of documentation, but their goal is really to allow the developer to express the intended behavior of a given pieces of code.

Custom matchers go a long way to shortening up boilerplate code into consise statements which (can) clearly imply intent.  The tricky part comes in making them somewhat conditional.

I ran into this case today and realized there is an easier solution than might be obvious at first pass.

The problem lies in that RSpec somehow parses every should, regardless of the conditional around it.  In my case, I had a function which took 4 values.  Only the first 3 were requred, but when the 4th was given the custom matcher needed to make sure it was correct too.

```ruby
RSpec::Matchers.define :have_custom_value do |a, b, c, d=nil|
  match do |obj|
    # ...

    # RSpec will still assert this:
    obj.prop_that_might_be_there.should == d unless d.nil?

    # ...and this:
    unless d.nil?
    	obj.prop_that_might_be_there.should == d
    end
  end
end
```

I'm guessing it has something to do with the DSL magic that RSpec implements behind the scenes, but `#should` assertions always seem to go through, regardless of the conditional blocks around them.

This actually produces a very difficult to track down error because the problem is in the matcher, and like most programmers, it's easy to assume that's correct and spend 30 minutes pouring over the code being tested.

The solution I found for this is to fallback to `expect` and give RSpec a block.  The block can first contain the conditional to short-circuit the code if the value isn't defined, then second to test the assertion manually with a conditional.

```ruby
RSpec::Matchers.define :have_custom_value do |a, b, c, d=nil|
  match do |obj|
    # ...

    expect { d.nil? || obj.d == d }.to be_true
  end
end
```
