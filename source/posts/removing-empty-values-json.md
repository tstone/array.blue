---
title: Removing Empty Values in Play's JSON Writes[A]
tags: json, play, scala
category: scala
date: September 15, 2014
---

One of the biggest stumbling blocks for people coming to the Play Framework is JSON reading and writing.  While the task of writing is the easier
of the two, one thing isn't so obvious: Getting rid of empty values.

The way JSON writing works in Play is through a trait, `Writes[A]`, and the magic of implicits.  Say you have a case class...

```scala
case class Person(name: String, age: Option[Int])
```

You would implement an implicit `Writes[Person]` for the class:

```scala
implicit def PersonWrites = new Writes[Person] {
  def writes(person: Person) = Json.obj(
    "name" -> person.name,
    "age" -> person.age
  )
}
```

What actually happens here is `def obj` of `Json` takes the arguments `fields: (String, JsValueWrapper)*`.  That is, it takes a splatted list of
tuples of type `String`, `JsValueWrapper`.  However, in the above code when we do `"name" -> person.name`, `person.name` is not of type `JsValueWrapper`,
but actually of type `String`.  An implicit conversion is being implied here:

```scala
implicit def AnyToJsValueWrapper[A](any: A)(implicit writer: Writes[A]) = ...
```

Effectively, in order for us to be able to say `Json.obj("name" -> person.name)` it means we must have an implicit `String => Writes[String]` in scope.  For
primitive types like `String` the library includes this, but then there becomes the issue of `Option`.  If the above code were to be compiled the compiler
would complain that there is not an implicit `Writes[Option[_]]` in scope (the Play library does not include one by default).

We could write one.

```scala
implicit def OptionWrites[A](implicit valueWrites: Writes[A]) = new Writes[Option[A]] {
  def writes(opt: Option[A]) = opt match {
    case Some(value)  => valueWrites.writes(value)
    case None         => JsUndefined
  }
}
```

This works, but provides a less than ideal output when `age` is `None`:

```json
{
  "name": "Bob",
  "age": undefined
}
```

What would be better is if the `age` property were just to be removed from the JSON.  With the `Writes[A]` interface that's tricky because by
the time we got into the `implicit def OptionWrites[A]` it's already too late.  There's no way from the `Writes` for `Option` to say, "just kidding!
please remove this property."

I realized there was a simple work around: Instead of `Json.obj` taking `(String, JsValueWrapper)` it should instead take `(String, Option[JsValueWrapper])`.
This way right before the values are turned into a JSON string the `None` properties could be filtered out.  Removing empty properties is easy, but
the more interesting part is how do we implicitly convert `"name" -> person.name` into a `(String, Option[JsValueWrapper])`?

More implicits of course.

Actually, to simplify the type signatures I thought it easier to introduce a new type:

```scala
case class JsProperty(key: String, value: Option[JsValue])
```

I simplified `JsValueWrapper` down to `JsValue` and wrapped up the tuple in a single type, `JsProperty` to make things a bit easier to understand.

From there I defined a new `Json.obj` which took `JsProperty` instead of `JsValueWrapper`:

```scala
object Json {
  def obj(properties: JsProperty*): JsObject = play.Json.obj(
    properties.map { case JsProperty(key, optValue) =>
      optValue.map { value =>
        key -> play.Json.toJsFieldJsValueWrapper(value)
      }
    }.flatten: _*
  )
}
```

This looks and behaves exactly like the build-in `Json.obj` except it removes empty properties.  All that's necessary now is to provide an implicit
`(String, A) => JsProperty` in scope to control the rules around what is considered "emtpy".  I wrote this all up in a [library](https://github.com/tstone/play-rwjson),
and these are the default rules:

```scala

// None = empty
implicit def OptionToJsProperty[A](kv: (String, Option[A]))(implicit json: Writes[A]) = kv match {
  case (key, None)        => JsProperty(key, None)
  case (key, Some(value)) => JsProperty(key, Some(json.writes(value)))
}

// JsObjects with no properties = empty
implicit def JsObjectToJsProperty[A](kv: (String, JsObject)): JsProperty = {
  val (key, jsObj) = kv
  if (jsObj.fields.size > 0) JsProperty(key, Some(jsObj))
  else JsProperty(key, None)
}

// Empty sequence = empty
implicit def SeqToJsProperty[A](kv: (String, Seq[A]))
  (implicit json: Writes[Seq[A]]) =
  kv match {
    case (key, Nil) => JsProperty(key, None)
    case (key, xs)  => JsProperty(key, Some(json.writes(xs)))
  }

// Everything else = not empty
implicit def AnyToJsProperty[A](kv: (String, A))(implicit json: Writes[A]) =
  JsProperty(kv._1, Some(json.writes(kv._2)))
```

Since all that is required is an implicit `(String, A) => JsProperty` it's easy to extend the definition of what is "empty".  For exmaple if
we wanted strings with only whitespace to be considered empty we could add:

```scala
implicit def StringToJsPropety(kv: (String, String))(implicit json: Writes[String]) = {
  val (key, value) = kv
  value.trim.size match {
    case 0 => JsProperty(key, None)
    case v => JsProperty(key, Some(v))
  }
}
```

This all becomes transparent by simply importing the modified version of `Json` instead of the Play default one.  All of this code is rolled up
into a library on Github: [play-rwjson](https://github.com/tstone/play-rwjson).
