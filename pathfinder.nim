
# pathfinder.nim

import std/[os, strutils, sequtils, tables, sets, heapqueue, math, algorithm]
import coord

type
  CellType = enum
    ctOpen,      # '.'
    ctWall,      # '#'
    ctStart,     # 'o'
    ctFinish,    # '*'
    ctDifficult  # '1'..'9'

  Cell = object
    cellType: CellType
    cost: int  # For difficult terrain

  Grid = object
    width: int
    height: int
    cells: seq[seq[Cell]]
    startPos: tuple[x, y: int]
    finishPos: tuple[x, y: int]

  Heuristic = enum
    hManhattan,
    hEuclidean

  PQItem = object
  # prio queue item
    coord: Coord
    fScore: int
    gScore: int  # For tiebreaking: prefer higher gScore (further from start)
    hScore: int  # Heuristic score for secondary tiebreaking

proc `<`(a, b: PQItem): bool =
  if a.fScore != b.fScore:
    return a.fScore < b.fScore
  # First tiebreaker: prefer lower heuristic (closer to goal)
  if a.hScore != b.hScore:
    return a.hScore < b.hScore
  # Second tiebreaker: prefer higher gScore (further along the path)
  return a.gScore > b.gScore


proc parseCell(c: char): Cell =
  ## Parse a single character into a Cell
  case c
  of '.':
    Cell(cellType: ctOpen, cost: 1)
  of '#':
    Cell(cellType: ctWall, cost: -1)
  of 'o':
    Cell(cellType: ctStart, cost: 1)
  of '*':
    Cell(cellType: ctFinish, cost: 1)
  of '1'..'9':
    Cell(cellType: ctDifficult, cost: ord(c) - ord('0'))
  else:
    raise newException(ValueError, "Invalid cell character: " & c)

proc readGrid(filename: string): Grid =
  ## Read and parse the grid from a file
  let lines = readFile(filename).splitLines()

  if lines.len < 2:
    raise newException(ValueError, "File must have at least 2 lines")

  # Parse width and height
  let dimensions = lines[0].splitWhitespace()
  if dimensions.len != 2:
    raise newException(ValueError, "First line must contain width and height")

  result.width = parseInt(dimensions[0])
  result.height = parseInt(dimensions[1])

  # Initialize cells
  result.cells = newSeq[seq[Cell]](result.height)

  # Parse grid cells
  var startFound = false
  var finishFound = false

  for y in 0 ..< result.height:
    if y + 1 >= lines.len:
      raise newException(ValueError, "Not enough lines for grid height")

    let line = lines[y + 1]
    if line.len < result.width:
      raise newException(ValueError, "Line " & $(y + 1) & " is too short")

    result.cells[y] = newSeq[Cell](result.width)

    for x in 0 ..< result.width:
      result.cells[y][x] = parseCell(line[x])

      # Track start and finish positions
      if result.cells[y][x].cellType == ctStart:
        if startFound:
          raise newException(ValueError, "Multiple start positions found")
        result.startPos = (x, y)
        startFound = true
      elif result.cells[y][x].cellType == ctFinish:
        if finishFound:
          raise newException(ValueError, "Multiple finish positions found")
        result.finishPos = (x, y)
        finishFound = true

  if not startFound:
    raise newException(ValueError, "No start position found")
  if not finishFound:
    raise newException(ValueError, "No finish position found")

proc printGrid(grid: Grid) =
  ## Print the grid to stdout
  for y in 0 ..< grid.height:
    for x in 0 ..< grid.width:
      let cell = grid.cells[y][x]
      case cell.cellType
      of ctOpen:
        stdout.write('.')
      of ctWall:
        stdout.write('#')
      of ctStart:
        stdout.write('o')
      of ctFinish:
        stdout.write('*')
      of ctDifficult:
        stdout.write(char(ord('0') + cell.cost))
    stdout.write('\n')

proc isAdjacent(pos1, pos2: tuple[x, y: int]): bool =
  ## Check if two positions are adjacent (4-adjacency only, no diagonals)
  let dx = abs(pos1.x - pos2.x)
  let dy = abs(pos1.y - pos2.y)
  return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

proc findAdjacentPath(grid: Grid): bool =
  ## Check if there's an adjacent path from start to finish with cost 1
  if not isAdjacent(grid.startPos, grid.finishPos):
    return false

  # They are adjacent, so the path cost is 1
  return true

proc parseHeuristic(heuristicStr: string): Heuristic =
  ## Parse heuristic string argument
  case heuristicStr.toLower()
  of "manhattan":
    hManhattan
  of "euclidean":
    hEuclidean
  else:
    raise newException(ValueError, "Unknown heuristic: " & heuristicStr)


# heuristic functions:
proc manhattanDistance(start: Coord, finish: Coord): int =
  return abs(start.x - finish.x) + abs(start.y - finish.y)

proc euclideanDistance(start: Coord, finish: Coord): float =
  let dx = float(start.x - finish.x)
  let dy = float(start.y - finish.y)
  return sqrt(dx * dx + dy * dy)

# path reconstruction:
proc reconstructPath(cameFrom: Table[Coord, Coord], current: Coord): seq[Coord] =
  var path: seq[Coord] = @[current]
  var curr = current
  while cameFrom.hasKey(curr):
    curr = cameFrom[curr]
    path.add(curr)
  path.reverse()
  return path

proc inBounds(grid: Grid, coord: Coord): bool =
  return coord.x >= 0 and coord.x < grid.width and
         coord.y >= 0 and coord.y < grid.height

proc getCellCost(grid: Grid, coord: Coord): int =
  return grid.cells[coord.y][coord.x].cost

# main A* algorithm:
proc aStar(grid: Grid, heuristic: Heuristic): tuple[found: bool, cost: int, path: seq[Coord], explored: HashSet[Coord], seen: HashSet[Coord]] =
  # Initialize data structures
  var openSet = initHeapQueue[PQItem]()
  var closedSet = initHashSet[Coord]()
  var seenSet = initHashSet[Coord]()  # Track all nodes added to openSet
  var gScore = initTable[Coord, int]()
  var cameFrom = initTable[Coord, Coord]()

  # Convert start and finish positions to Coord
  let start = Coord(x: grid.startPos.x, y: grid.startPos.y)
  let finish = Coord(x: grid.finishPos.x, y: grid.finishPos.y)

  # Initialize start node
  gScore[start] = 0
  let startH = if heuristic == hManhattan:
    manhattanDistance(start, finish)
  else:
    int(euclideanDistance(start, finish))

  openSet.push(PQItem(coord: start, fScore: startH, gScore: 0, hScore: startH))
  seenSet.incl(start)  # Mark start as seen

  # Main A* loop
  while openSet.len > 0:
    let current = openSet.pop()
    let currentCoord = current.coord

    # Skip if already explored (might be in queue multiple times)
    if currentCoord in closedSet:
      continue

    # Mark as explored
    closedSet.incl(currentCoord)

    # Check if we reached the goal
    if currentCoord == finish:
      let path = reconstructPath(cameFrom, currentCoord)
      return (found: true, cost: gScore[currentCoord], path: path, explored: closedSet, seen: seenSet)

    # Explore neighbors
    for neighbor in currentCoord.adjacents():
      # Skip if out of bounds
      if not grid.inBounds(neighbor):
        continue

      # Skip if already explored
      if neighbor in closedSet:
        continue

      # Get cell cost (skip walls with cost -1)
      let cellCost = grid.getCellCost(neighbor)
      if cellCost < 0:
        continue

      # Calculate tentative gScore
      let tentativeG = gScore[currentCoord] + cellCost

      # Check if this path is better
      if not gScore.hasKey(neighbor) or tentativeG < gScore[neighbor]:
        # Update path
        cameFrom[neighbor] = currentCoord
        gScore[neighbor] = tentativeG

        # Calculate heuristic
        let h = if heuristic == hManhattan:
          manhattanDistance(neighbor, finish)
        else:
          int(euclideanDistance(neighbor, finish))

        let f = tentativeG + h
        openSet.push(PQItem(coord: neighbor, fScore: f, gScore: tentativeG, hScore: h))
        seenSet.incl(neighbor)  # Mark neighbor as seen

  # No path found
  return (found: false, cost: 0, path: @[], explored: closedSet, seen: seenSet)

# grid printing with path visualization:
proc printGridWithPath(grid: Grid, explored: HashSet[Coord], seen: HashSet[Coord], path: seq[Coord]) =
  # Convert path to a set for fast lookup
  var pathSet = initHashSet[Coord]()
  for coord in path:
    pathSet.incl(coord)

  # Print grid with visualization
  for y in 0 ..< grid.height:
    for x in 0 ..< grid.width:
      let coord = Coord(x: x, y: y)
      let cell = grid.cells[y][x]

      # Start and finish always show as 'o' and '*'
      if cell.cellType == ctStart:
        stdout.write('o')
      elif cell.cellType == ctFinish:
        stdout.write('*')
      # Path cells show as '@'
      elif coord in pathSet:
        stdout.write('@')
      # Explored cells show as '+'
      elif coord in explored:
        stdout.write('+')
      # Seen (but not explored) cells show as '-'
      elif coord in seen:
        stdout.write('-')
      # Everything else shows normally
      elif cell.cellType == ctWall:
        stdout.write('#')
      elif cell.cellType == ctDifficult:
        stdout.write(char(ord('0') + cell.cost))
      else:
        stdout.write('.')
    stdout.write('\n')


proc main() =
  # Parse command-line arguments
  let args = commandLineParams()

  if args.len < 1:
    echo "Usage: pathfinder <grid_file> [heuristic]"
    echo "  heuristic: manhattan (default) or euclidean"
    quit(1)

  let gridFile = args[0]

  var heuristic = hManhattan  # Default
  if args.len >= 2:
    try:
      heuristic = parseHeuristic(args[1])
    except ValueError:
      echo "Error: ", getCurrentExceptionMsg()
      echo "Valid heuristics: manhattan, euclidean"
      quit(1)

  # Read and parse the grid
  var grid: Grid
  try:
    grid = readGrid(gridFile)
  except IOError, ValueError:
    echo "Error reading grid: ", getCurrentExceptionMsg()
    quit(1)

  # Print the grid
  printGrid(grid)

  # Check for adjacent path
  if findAdjacentPath(grid):
    echo "Path found with cost 1."
  else:
    echo "No adjacent path."

  let result = aStar(grid, heuristic)

  if result.found:
    echo "Path found with cost ", result.cost
    echo "Visualized grid (o=start, *=finish, @=path, +=explored, -=seen):"
    printGridWithPath(grid, result.explored, result.seen, result.path)
  else:
    echo "No path found"


when isMainModule:
  main()
