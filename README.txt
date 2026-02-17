
README.txt

name: Kameron Soukup

handin script: 

handin cmsc262 proj3 .


running the file:

All commands use nim c -r which compiles and immediately runs the program.

Pathfinding Program

nim c -r pathfinder.nim test_grid.txt
nim c -r pathfinder.nim test_grid2.txt
nim c -r pathfinder.nim test_grid3.txt
nim c -r pathfinder.nim test_grid.txt manhattan
nim c -r pathfinder.nim test_grid.txt euclidean

Coordinate Hash Demo

nim c -r coord_demo.nim

Adjacency Demo

nim c -r adjacents_demo.nim


Acknowledgements:
Created using Claude AI, conversation recoreded in "conversation.md"

10/21/2025
Worked with Cluade AI to implement the ability to accepte 1-2 command-line arguments(filename required, heuristic optional). Support for "manhattan" and "euclidean" heuistic strings. The ability to parse all 5 cell types(., #, o, *, and 1-9) and ignores extra lines in files. Can print the grid followd by the status line. Confirmes grid format and makes sure there are always one start and finish. Also Reports "Path found with cost 1." or "No adjacent path."

Key functions implemented parseCell(), readGrid(). printGrid(), isAdjacent(), findAdjacentPath(), parseHeuristic(), and main().

10/21/2025
Implemented(with Claude) HashSet[Coord], adding cordinates, testing membership, iterating throught the setm removing coordinates, displaying set size and contents.

10/21/2025
Added the adjeacents() proc that returns an array[4, Coord] that contains all 4-adjeacent coordinates. Used an array to allow for efficient and easy iteration. Also created ajacents_demo.nim. This program gets adjeacents for a normal coordinate, tests with the origin, and tests with negative coodinates.

10/31/2025
Added AI Acknowledgements directly in my code to represent what I am working on and what the AI was working on. After that I implemented a prio queue item along with a procedure that compares two prio queue items. Added scaffold TODO procdures in the code.

11/3/2025
Implemented manhattanDistance() procedure, euclideanDistance() procedure, and reconstructPath() procdure.

11/4/2025
Added helper functions: inBounds() which checks if a coord is within the grid boundaries and returns a bool, and getCellCost() which retrieves the movement cost for a cell at the given coord. After adding the helper functions, I got started on the A* algorithm. Currently have data structure initialization (openSet, closedSet, gScore, cameFrom) along with initialization for converting positions, setting the start node, and calculating start heuristic. Updated PQItem to include tiebreaking (prefers higher gScore when fScores are equal)."

Implemented Node Precessing in aStar(). Loop condition, pop node, extract coordinate, duplicate check, mar as explored.

Added Goal check, compres current coord with the finish coord, if we reached the goal. also recontructPath() to trace back from the finish to the start using the cameFrom table. Sueccess return, returns tuple with found, cost, path, and explored.

Added Neighbor Loop that iterates through all 4 adjacent cells. Filters out neighbors that are out of bounds or already explored (in closedSet).

Added cost checking which gets neighbor's cell cost, skips walls (cost < 0), and calculates tentative gScore (cost to reach neighbor through current node).

Added path update check. Checks if this is a better path to the neighbor (neighbor not seen before OR lower cost found). If better than updates cameFrom and gScore, calculates heuristic and fScore (g + h), then adds neighbor to openSet for exploration.

Added printGridWithPath() function that visualizes A* results by printing the grid with path cells marked as '@' and explored cells as '+'. Updated main() to check if path was found, display the cost, call printGridWithPath() to show visualization, or print 'No path found' if unsuccessful." Or if you want it even shorter: "Created printGridWithPath() to visualize path (@) and explored (+) cells. Updated main() to display path cost and call visualization function if path found, otherwise print 'No path found'.

Added seenSet to track nodes in openSet. Mark as seen when pushing to queue. Updated return, printGridWithPath, and main to display seen nodes as '-'." Or even more minimal: "Track nodes added to openSet in seenSet. Display seen-but-not-explored nodes as '-' in visualization.

11/5/2025
Edited PQItem tiebreaking. Added hScore field to store heuristic value. Updated comparison operator to use two-level tiebreaking: when fScores are equal, prefer lower heuristic (closer to goal), then higher gScore (further along path). Updated both openSet.push() calls to include hScore.