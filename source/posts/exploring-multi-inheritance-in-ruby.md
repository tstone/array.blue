---
title:    Exploring Multi-Inheritance in Ruby
date:     September 12, 2012 8:35
tags:     ruby, inheritance
category: ruby
---

[Ruby](http://ruby-lang.org) allows a _kind_ of multi inheritance.  First, ruby allows single class to class inheritance found in every traditional OO language.

```ruby
class A
end

class B < A
end
```

In addition to class inheritance, ruby also provides `modules` or "mixins" which are a kind of interface coupled with implementation.  These modules often contain class-agnostic behaviors or traits.

```ruby
module Printable
    def print
        puts "Printed!"
    end
end

class A
    include Printable
end

obj = A.new
obj.print

# Output:
# => Printed!
```

That's all well and good, but what happens if the same method is defined on both the `module` and the `class`?

```ruby
module Printable
    def print
        puts "Printed!"
    end
end

class A
    include Printable

    def print
        puts "A!"
    end
end

obj = A.new
obj.print

# Output:
# => A!
```

In these cases ruby follows the rule of "closest proximity wins".  In this case the `print` method defined on `A` is closer to `obj`.  Ruby determines this by running a "search path", looking first at the object instance, then at the child-most class, then that class' it's mixins, then the parent classes, and the parent class' mixins and so on up the chain.

Where things begin to get interesting is that ruby provides a `super` method.  When ruby finds a match to a given method, it stops and runs that method.  `super` basically tells ruby to execute the possible match in the search path.  If `A#print` were modified to include super, the output would become:

```ruby
# Output:
# => A!
# => Printed!
```

This is because ruby would first find `A#print`, then calling super would invoke `Printable#print`.

In considering this, it's a bit different than most OO languages. Typically, `super` refers only to the parent class.  And certainly, if `A` were inheriting from another class super _might_ refer to that. But in the example above `super` is actually running code from the mixin.  In effect, it's treating the mixin as if it were a parent.

So what happens if _both_ a parent and a mixin have the same method?

```ruby
module X
    def print
        puts "X"
    end
end

class A
    def print
        puts "A"
    end
end

class B < A
    include X
end

obj = B.new
obj.print

# Output:
# => "X"
```

In this case the `module` wins.  Why?  Because it has the closest proximity (another way of saying this is it's the lowest down on the inheritance chain).  What's interesting about ruby's search chain for method precedence is that if a class contains more than one module, it takes the modules in the reverse order they were added to the class.

```ruby
module X
    def print
        puts "X"
        super
    end
end

module Y
    def print
        puts "Y"
        super
    end
end

class A
    include X
    include Y
end

obj = B.new
obj.print

# Output:
# => Y
# => X
```

You can see the order was Y then X where ruby inferred that modules included last were in closer proximity than those included earlier.

So here's a question -- what happens when everything included has the same method and they all call `super`?

```ruby
# Modules

module X
    def print
        puts "X"
        super
    end
end

module Y
    def print
        puts "Y"
        super
    end
end

module Z
    def print
        puts "Z"
        super
    end
end

# Classes

class A

    include X

    def print
        puts "A"
        super
    end
end

class B < A

    include Y
    include Z

    def print
        puts "B"
        super
    end
end

# Execute

obj = B.new
obj.print

# Output:
# => B
# => Z
# => Y
# => A
# => X
```

Notice that `super` doesn't mind if the method is on a module or on a class.  Also notice that ruby favors methods on the parent class first before methods on the parent class' mixins.

Also of note is that `X#print` calls `super` which because it's last in the search chain there is nothing "above" it.  However instead of throwing an error it just does nothing.
