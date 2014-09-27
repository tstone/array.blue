---
title: FizzBuzz in Ruby
date: nov 1, 2009
tags: fizzbuzz, ruby
category: ruby
---

Well since I was in the mood writing FizzBuzz and since I’ve been working on learning Ruby, I figured, why not do recursive fizzbuzz in ruby?

```ruby
def fizzbuzz(start, ending)
    if (start % 15 == 0)
        puts 'Fizzbuzz'
    elsif (start % 5 == 0)
        puts 'Buzz'
    elsif (start % 3 == 0)
        puts 'Fizz'
    else
      puts start
    end

    if start < ending
      fizzbuzz(start+1, ending)
    end
end

fizzbuzz(1, 100)
```

Ruby is quite an expressive language. It feels like it comes with more built-in keywords and default methods than python, so I’m sensing it is a bit more complex to learn. However, it has some neat stuff. I’m thinking of writing FizzBuzz using some of the different methods it has, like .net and the `..` range. I’ve also seen a built in function something to the effect of `.upto` which might be fun to play with as well.
