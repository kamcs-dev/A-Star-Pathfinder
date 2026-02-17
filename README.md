# CMSC262 Project 3 - A* Pathfinder

A grid-based pathfinding program written in Nim that implements the A* search algorithm with support for weighted terrain and multiple heuristics.

## Project Overview

This project implements:
- A* search algorithm with priority queue (min-heap)
- Manhattan and Euclidean distance heuristics
- Weighted terrain with variable movement costs
- Grid parsing with validation (walls, start/finish, difficult terrain)
- ASCII visualization of search results (path, explored nodes, frontier)
- Custom `Coord` type with hashing for use in hash-based collections

## Prerequisites

- [Nim](https://nim-lang.org/) compiler (1.6+)

## Project Structure

```
pathfinder/
├── pathfinder.nim        # Main source - A* algorithm, grid parsing, visualization
├── coord.nim             # Coord type with equality, hashing, and adjacency
├── coord_demo.nim        # Demo: HashSet[Coord] operations
├── adjacents_demo.nim    # Demo: adjacents() function behavior
├── test_grid.txt         # 8x5 test grid with walls and costly terrain
├── test_grid2.txt        # Grid where start/finish are not adjacent
├── test_grid3.txt        # Grid where start/finish are adjacent
├── test_no_path.txt      # Grid with no valid path (wall barrier)
├── test_nonsquare.txt    # Non-square grid test
├── test_difficult.txt    # Grid with costly terrain digits
├── MegaMap.txt           # Large map for stress testing
└── README.md             # This file
```

## Building

```bash
nim c -d:release pathfinder.nim
```

## Usage

```bash
./pathfinder <grid_file> [heuristic]
```

### Parameters

| Parameter   | Description |
|-------------|-------------|
| `grid_file` | Path to a grid text file |
| `heuristic` | Optional: `manhattan` (default) or `euclidean` |

### Examples

```bash
./pathfinder test_grid.txt
./pathfinder test_grid.txt euclidean
./pathfinder MegaMap.txt manhattan
```

## Grid Format

The first line specifies `width height`. Subsequent lines encode the grid:

| Character | Meaning |
|-----------|---------|
| `.`       | Open space (cost 1) |
| `#`       | Impassable wall |
| `o`       | Start position |
| `*`       | Finish position |
| `1`-`9`   | Difficult terrain (cost = digit value) |

Example grid file:
```
8 5
.o......
..###...
..#..*..
..#..3..
........
```

## Output Visualization

The program prints the grid with search results overlaid:

| Symbol | Meaning |
|--------|---------|
| `o`    | Start position |
| `*`    | Finish position |
| `@`    | Cell on the optimal path |
| `+`    | Fully explored cell |
| `-`    | Cell added to frontier but not explored |

Example output:
```
.o......
..###...
..#..*..
..#..3..
........
No adjacent path.
Path found with cost 9
Visualized grid (o=start, *=finish, @=path, +=explored, -=seen):
.o@@@@--
++###@--
++#++*--
++#++3..
+++.....
```

## Architecture

- **`coord.nim`** - Defines the `Coord` object type with `==`, `hash`, and `adjacents` procedures, enabling use with Nim's `HashSet` and `Table` collections.
- **`pathfinder.nim`** - Handles grid I/O, implements A* with a `HeapQueue`-based open set, and renders the visualization. Uses tiebreaking on heuristic distance and g-score for optimal node expansion order.

## License

This is a class project for educational purposes.
