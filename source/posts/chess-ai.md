---
title: Build a Chess AI Player
date: October 3, 2014
tags: ai, game
category: ruby
---

I've been doing a lot of algorithm-y things lately, and in particular a few co-workers have been working on some sudoku game
implementations.  As a result I've ended up coding a few bits of sudoku code [here](https://github.com/tstone/algorithms/blob/master/jvm/src/main/scala/sudoku/2DArray.scala)
and [there](https://github.com/tstone/algorithms/blob/master/jvm/src/main/java/algorithms/sudoku/2DArrayJ.java).  I also recently
read through (most of) _[Introduction to Graph Theory](http://amzn.com/0486678709)_ by Richard Trudeau.

I came across a simple implementation of the game of 2-player chess in Ruby and it struck me that I could build an AI player for it.  Not
that I've ever done anything previously with AI in my life, but with a lot of permutation generation and graph algorithms fresh
in my mind I started to quickly conceive of how I might approach this.

Without a doubt there are well-studied approaches as to how this should work already in existence.  But I wanted to reason through it myself
first.  I've found that often when I try to solve a problem myself, when I then do read up on already discovered solutions it's typically much
easier for me to understand them as I'm already familiar with the problem domain and can focus solely on the solution.

In any case, here was my general strategy.

At the top level was the notion of an "AI Player".  At any one point in time the ai player has only one piece of state: a move list (an array of moves).
The move list is generated by a `Strategy`.  In a nutshell, the "AI" part of all this is a simple algorithm to assess the state of the game.  A decision
will then be made to continue with the current move list or to use another strategy to generate a new move list.

Assume a variable `game` is in scope which has three properties, `#board`: the game board as a 2D array; `#moves`: a list of all moves up to that point;
and `#graveyard`: pieces that have been removed from the board (pieces active on the board would be available via `#board#pieces`).

The ai player logic would be something simple like...

```ruby
class AiPlayer

  def initialize
    @move_list = []
  end

  def next_move(game)
    if in_check?
      @move_list = DefensiveStrat.determine_moves(game)
    elsif !moves_left? or !next_move_is_valid?
      @move_list = choose_new_offense(game).determine_moves(game)
    end

    @move_list.shift()
  end

  def choose_new_offense(game)
    if game.moves.size < 3
      ScriptedOpeningStrat
    elsif games.moves.size < 20
      ControlBoardCenterStrat
    else
      ShortestPathToCheckStrat
    end
  end

end
```

Determining the next move is a matter of first seeing if the AI player is in check This could be expanded to see if the AI player is in check in N more moves as well.
Next check if there are moves remaining in the current `@move_list` or if the next planned move from the `move_list` is now invalid for one reason or another.  If
either of these cases are true we'll need to select a new offensive strategy.

I imagine offensive strategies fall into 3 buckets: repeat a scripted opening, try to control the center of the board by moving offensive pieces out, and finally figure out
the shortest path to putting the enemy king in check.

### ScriptedOpening

Thinking of openings as "scripted" is fairly close to how [actual chess games](http://en.wikipedia.org/wiki/Chess_opening) are played.  There's not a lot of thought that
happens except choosing which opening to go with.  If the AI player is white, they can randomly picked from a pre-programmed list.  If the AI player is black it can randomly
pick from a smaller sub-set of possibilities based on the human player's first move, typically king or queen pawn.

### ControlBoardCenterStrat

This is the first use of graph theory.  The position a piece can be in is a vertex and the positions into can go to are also a vertex and the action of making that move is
the edge.  A breadth-first search of the imposed graph (moves/positions) would allow a search to go until either a center of the board was found or a certain number of moves
was encountered.  The latter restriction is because we don't want to have to have a piece hop all over taking 4 or 5 moves to control the center.  We want it to be 1 or 2 moves
away.

Graph searching has some background but the A* algorithm is the general purpose workhorse for most applications.  Red Blob Games has an excellent [Introduction to A*](http://www.redblobgames.com/pathfinding/a-star/introduction.html)
which I highly recommend reading.

Since the algorithm can be used in a number of places I was playing around with implementing it using a ruby block to capture the "when to quit" condition.  This isn't fully-formed
code but it conveys the idea:

```ruby
def a_star(board, piece, &block)
  frontier = Queue.new
  frontier.push(piece.pos)
  visited = { }
  visited[piece] = true

  current = frontier.pop
  while !frontier.empty? and block.call(current, visited, frontier)
    piece.position = current
    piece.moves.each do |possible_pos|
      unless visited.has_key?(possible_pos)
        frontier.push(possible_pos)
        visited[possible_pos] = true
      end
    end
    current = frontier.pop
  end
end
```

The idea is that `&block` is used to give the restrictions for the particular case we're interested in.  For `ControlBoardCenterStrat` we might want to limit the number of
moves to `2` and also stop if we've found the center of the board.  I imagine it would look like something to the effect of...

```
a_star(game.board, piece[0]) do |current_pos, visited, frontier|
  current_pos == "d4" or
  current_pos == "d5" or
  current_pos == "e4" or
  current_pos == "e5" or
  visited > 2
end
```

### ShortestPathToCheckStrat

This strategy is similar to `ControlBoardCenterStrat` except that it might have a priority list of pieces to try in order, say Rook, Queen, Bishop, and so on.  For each piece
it would attempt to use the same A* algorithm to find the shortest path to check, regardless of length.  The strategy would choose the piece with the shortest path and execute
that sequence, then try again with another piece.  One trick would be to avoid using the same piece to place the player in check over and over.  This could perhaps be it's own
strategy, `AnnoyWithOneStepCheckStrat` or something along those lines.


## Improvements

One thing I like about this approach is that there is a lot of room for improvements because of the separation between strategy implementation and choosing which strategy
to run.  It avoids trying to have a huge block of if/thens and handle all these odd cases.  Even if you have two strategies that seemingly look alike, it makes more sense
to have two strategies which each handle the nuance of their particularities.

The `choose_offensive_strat` function is rather weak but easily improved.

```ruby
def choose_new_offense(game)
  if game.moves.size < 3            # early game
    ScriptedOpeningStrat
  elsif games.graveyard.size >= 10  # late game
    ShortestPathToCheckStrat
  else                              # mid game
    ControlBoardCenterStrat
  end
end
```

Picking a strategy based number of moves is a fairly weak way to go.  I considere the idea of an `Assessment` or a encapsulated way to analyze the board.  For example,
one assessment might be `ControlOfCenterAssessment` which returns an `influence` (number of pieces which are attacking a spot on the center of the board).  Or another
assessment might be `SelfPawnStructureAssessment` which returns an `influence` reflecting the number of pawns that are in an advantageous position.  These could be used
to make decisions about strategies instead of just something simple like the number of moves that have taken place.


## OO

One thing I ran into which was less than stellar was that implementing the AI required me to "explore the graph" which is a fancy way of saying I needed to play out permutations
of a board.  Typically a graph is stored, at least by it's mathematical definition, as a set of vertices and a set of edges (which are themselves a 2 length set of vertices).
Applying that to the game board there isn't quite a 1:1 alignment.  Instead we have current position (starting vertex) and possible positions (neighboring vertices).  The
edges are inferred.

Anyways, one thing I found was that to explore the graph I needed to create various modifications of the game board.  However with Ruby's strong OO style the game board wasn't
just a few pieces of data but a whole object that had a 2D array within it, where the values in the 2D array were instance of piece objects.  From a Ruby perspective this
makes a lot of sense.  However with my intent to rapidly created 100's of these per move it didn't seem like a good plan.

What I'd like to investigate is representing the game board as a very lightweight 2D array that only contains primitives (each piece type is represented by a number, pawn
  is 1, rook is 2, etc.)  This way I can quickly spin up a bunch of variations fast and then have a large variety of functions to apply towards them.  In a real way I think
  I'm preferring a funcitonal approach for this instead.
  

## UI

The other reason I think I'm going to move away from Ruby for this project is that ultimately I want to be able to attach some kind of nice presentation to all this.  A
console or Ruby GUI toolkit won't quite match what the browser gives now days.  HTML, SVG, Canvas, and WebGL are all extremely accessible in browsers now days and for people
like me who don't want to get into a really complex game engine it's a great way to get going fast without getting stuck in the weeds.  Whatever solution I pick I think the
web as a platform is the route I'll go.

A minor hiccup in this regard is should I or should I not go with a UI toolkit.  I'd like to spend more time with Angular or Ember however i worry that their view model approach
would bind my game implementation too much to the UI.  In an ideal world the game would be implemented simply "in memory" and a presentation layer of HTML or SVG or whatever could
just be "bolted" on the top after the fact without affecting the game.