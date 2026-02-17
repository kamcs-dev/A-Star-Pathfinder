
# coord_demo.nim

import std/[sets, strutils]
import coord

proc main() =
  echo "Demonstrating Coord hash-based set functionality"
  echo "=".repeat(50)

  # Create a hash set of coordinates
  var visited = initHashSet[Coord]()

  # Add some coordinates
  let coord1 = Coord(x: 5, y: 10)
  let coord2 = Coord(x: 3, y: 7)
  let coord3 = Coord(x: 5, y: 10)  # Duplicate of coord1
  let coord4 = Coord(x: 0, y: 0)

  visited.incl(coord1)
  visited.incl(coord2)
  visited.incl(coord3)  # Should not create duplicate
  visited.incl(coord4)

  echo "\nAdded coordinates: (5,10), (3,7), (5,10), (0,0)"
  echo "Set size: ", visited.len
  echo "Expected: 3 (duplicate should be ignored)"

  # Test membership
  echo "\n--- Testing Membership ---"
  echo "Contains (5,10)? ", Coord(x: 5, y: 10) in visited
  echo "Contains (3,7)? ", Coord(x: 3, y: 7) in visited
  echo "Contains (0,0)? ", Coord(x: 0, y: 0) in visited
  echo "Contains (1,1)? ", Coord(x: 1, y: 1) in visited

  # Iterate through set
  echo "\n--- All coordinates in set ---"
  for coord in visited:
    echo "  (", coord.x, ", ", coord.y, ")"

  # Remove a coordinate
  echo "\n--- Testing Removal ---"
  visited.excl(Coord(x: 3, y: 7))
  echo "Removed (3,7)"
  echo "Set size now: ", visited.len
  echo "Contains (3,7)? ", Coord(x: 3, y: 7) in visited

  echo "\n--- Final set contents ---"
  for coord in visited:
    echo "  (", coord.x, ", ", coord.y, ")"

  echo "\nDemo complete!"

when isMainModule:
  main()