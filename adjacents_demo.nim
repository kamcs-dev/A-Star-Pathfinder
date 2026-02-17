
# adjacents_demo.nim

import std/strutils
import coord

proc main() =
  echo "Demonstrating 4-adjacency for Coord"
  echo repeat("=", 40)

  let center = Coord(x: 5, y: 10)

  echo "\nCenter coordinate: (", center.x, ", ", center.y, ")"
  echo "\nAll 4-adjacent coordinates:"

  for adj in center.adjacents():
    echo "  (", adj.x, ", ", adj.y, ")"

  echo "\n--- Testing edge cases ---"

  let origin = Coord(x: 0, y: 0)
  echo "\nOrigin (0, 0) adjacents:"
  for adj in origin.adjacents():
    echo "  (", adj.x, ", ", adj.y, ")"

  let negative = Coord(x: -5, y: -3)
  echo "\nNegative coordinate (-5, -3) adjacents:"
  for adj in negative.adjacents():
    echo "  (", adj.x, ", ", adj.y, ")"

  echo "\nDemo complete!"

when isMainModule:
  main()
