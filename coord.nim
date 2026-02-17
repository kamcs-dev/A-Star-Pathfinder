
# coord.nim

import std/hashes

type
  Coord* = object
    x*: int
    y*: int

proc `==`*(a, b: Coord): bool =
  ## Equality comparison for Coord
  a.x == b.x and a.y == b.y

proc hash*(coord: Coord): Hash =
  ## Hash procedure for Coord to enable use in hash-based collections
  var h: Hash = 0
  h = h !& hash(coord.x)
  h = h !& hash(coord.y)
  result = !$h

proc adjacents*(coord: Coord): array[4, Coord] =
  ## Returns all 4-adjacent coordinates (up, down, left, right)
  [
    Coord(x: coord.x, y: coord.y - 1),  # Up
    Coord(x: coord.x, y: coord.y + 1),  # Down
    Coord(x: coord.x - 1, y: coord.y),  # Left
    Coord(x: coord.x + 1, y: coord.y)   # Right
  ]