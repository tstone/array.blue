---
title: JSON Model Mapping in Ruby
category: ruby
date: June 28, 2013
tags: ruby, json
---

I ran upon an interesting situation for which I couldn't find a simple solution.  A good majority of Rails apps are built with ActiveRecord and an
relational database.  However I needed to build a site where reading and writing data was being provided by a bulk import/export JSON type API.  The
way this API worked was that a "read" returned the entire JSON document.  Similarly, to write a POST was sent to the server with the POST body being
the same JSON document (of course modified).

I wanted to allow the Ruby code to behave exactly as if it was ActiveRecord and to at the model level abstract over this slightly different scenario while
at the same time leveraging features of ActiveModel such as validations.  To solve this problem I reached into the meta-programming back of tricks and wrote
a module to handle both filling a model from JSON and creating JSON from that model.  Since these are effectively the same relationship I wanted to declare
in one place how the JSON and model were related and let the library handle the rest.

There was also a secondary concern that I had: making the property names in Ruby's favored snakecase instead of Javascript's camelcase.

What I came up with (complete source below) takes a hash table of symbol/string, with the symbol being the property name and the string being the path
in the JSON.

### Example

Assume the following JSON.

```json
[
  {
    "name": "Bob",
    "emailAddress": "bob@example.com",
    "relationships": {
      "projectManagers": [
        "Bill", "Susan"
      ]
    }
  },
  // ...
]
```

In this we want a simple way to turn each item of the outer array int a `class Person`.  We don't want to have camelcase names like `emailAddress` and
`projectManagers`, and we also want to flatten out the `relationships` so that we don't have to deal with it on our model.  The `JsonMapper` module I
wrote handles both of these cases and to map the above JSON to a model it would only require:

```ruby
class Person
  include JsonMapper

  attr_accessor :name, :email, :project_managers

  json_map name: "name",
           email: "emailAddress",
           project_managers: "relationships.projectManagers"
```

Once the `json_map` directive is called a new class method `from_json` is now on the class, allowing a JSON string to be passed in and the values used
to return a model filled with those values.

```ruby
Person.from_json("raw JSON string")
```

It also defines an `as_json` method for turning an instance of a `Person` model into the exact JSON we see above.

## Module Source


```ruby
module JsonMapper
  extend ActiveSupport::Concern

  def as_json(options={})
    json = {}
    self.class.json_mappings.each do |class_attr, json_attr|
      set_hash_attr(json, json_attr.to_s, self.send(class_attr))
    end
    json
  end

  included do
    @json_mapping = {}
  end

  module ClassMethods
    # attr_accessor :json_mapping
    def json_mappings; @json_mapping;  end
    def json_mappings=(value); @json_mapping = value; end

    def json_map(class_attr_or_hash, json_attr=nil)
      if class_attr_or_hash.is_a? Hash
        class_attr_or_hash.each { |k,v| json_mappings[k.to_sym] = v.to_s }
      else
        json_mappings[class_attr_or_hash.to_sym] = json_attr.to_s
      end
    end

    def from_json(json)
      instance = self.new
      json = JSON.parse(json) if json.is_a? String
      set_instance_attrs(instance, json)
      instance
    end

    private

    def set_instance_attrs(instance, json, parent="")
      json.each do |key, value|
        path = parent + key.to_s
        if value.is_a? Hash
          set_instance_attrs(instance, value, path + ".")
        else
          attr = find_mapped_path_attr(path)
          instance.send("#{attr}=", value) if attr and instance.respond_to?("#{attr}=")
        end
      end
    end

    def find_mapped_path_attr(path)
      json_mappings.keys.select { |key| json_mappings[key] == path }.first
    end
  end

  private

  def set_hash_attr(hash, attr_path, value)
    if attr_path.include? "."
      segments = attr_path.split(".")
      root_attr = segments.shift
      hash[root_attr] = {} unless hash[root_attr]
      return set_hash_attr(hash[root_attr], segments.join("."), value)
    else
      value = value.as_json if value.respond_to? :as_json
      hash[attr_path] = value
      return hash
    end
  end
end
```
