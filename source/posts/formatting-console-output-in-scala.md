---
title: Formatting Console Output in Scala
date: june 5, 2010
tags: scala, functional-programming
category: scala
---

So it’s midnight and I’m programming Scala (heh).  I’m actually starting to be able to write little scripts in Scala.  Here’s a quick one that I put together, inspired by Chapter 3 of “Programming Scala” which reads a source code file and formats the file to the screen with line numbers.

```scala
import scala.io.Source

if (args.length > 0) {

    def formatSourcePrefix(line: Int, suffix: String, max: Int = 5): String = {
        var prefix: String = ""
        for (i <- 1 to (max - line.toString.length))
            prefix += " "
        prefix + line.toString + suffix
    }

    def formatSourceLine(lines: List[String], line: Int = 1, output: String = ""): String = {
        val out = output + formatSourcePrefix(line, " | ") + lines.head + "\n"
        if (lines.length > 1)
            formatSourceLine(lines.tail, line + 1, out)
        else
            out
    }

    // Read file from disk
    val lines = Source.fromPath(args(0)).getLines().toList

    // Print results to screen
    println
    print(formatSourceLine(lines))

}
else {
    // Print out proper syntax
    Console.err.println
    Console.err.println("scala file.scala [filename]")
}
```

I tried to be as functional as possible.  The `formatSourceLine` I felt was getting close to the concept, using recursion, immutable values, and always returning a value (avoiding the side effect of printing from within the function).
