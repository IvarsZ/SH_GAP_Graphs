#! @Chapter Examples

#! @Section DFS
#! A depth first search  on the graph below starting at vertex 1, branches are explored as deep as possible.
#! @Example
g := Graph([[2, 4], [3, 5], [], [6], [3, 4], [1]]);
#! <object>
DFS(g, 1)
#! [1, 4, 6, 2, 5, 3]
#! @EndExample

#! Example where not all vertices are visited by DFS, as the graph below isn't strongly connected.
#! @Example
g := Graph([[2, 4], [3, 5], [], [6], [3, 2], [1]]);
#! <object>
DFS(g, 2); 
#! [ 2, 5, 3 ] 
#! @EndExample

#! @Section BFS
#! A breadth first search  on the graph below starting at vertex 1, vertices are visited level by level.
#! @Example
g := Graph([[2, 4], [3, 5], [], [6], [3, 4], [1]]);
#! <object>
BFS(g, 1);
#! [ 1, 2, 4, 3, 5, 6 ]
#! @EndExample

#! Example where not all vertices are visited by BFS, as the graph below isn't strongly connected.
#! @Example
g := Graph([[2, 4], [3, 5], [], [6], [3, 2], [1]]);
#! <object>
BFS(g, 2);
#! [ 2, 3, 5 ]
#! @EndExample

#! @Section Colouring
#! Colouring a graph that can be coloured with 3 colours.
#! @Example
g := Graph([[3, 4, 5], [3], [1, 2, 4], [1, 3, 5, 6], [1, 4, 6], [4, 5]]);
#! <object>
GetColouring(g, 3); 
#! [ 1, 1, 2, 3, 2, 1 ] 
#! @EndExample

#! The same graph can't be coloured with 2 colours, as it contains K_3.
#! @Example
GetColouring(g, 2); 
#! false
#! @EndExample

#! @Section Strongly connected components
#! Example of finding strongly conencted components of a graph by assigning component's index to each vertex with indexes from vertex count + 1
#! @Example
g := Graph([[2, 6, 7], [3], [4, 6], [5, 7], [6], [2], [], [9, 10], [], [8]]);
#! <object>
GetStrongComponents(g);
#! [ 13, 12, 12, 12, 12, 12, 11, 15, 14, 15 ]
#! @EndExample

#! @Section Minimum spanning tree
#! Example of finding a minimum spanning tree of a weighted graph.
#! @Example
w := WeightedGraph([[2, 3, 4, 5], [1, 5], [1, 4, 6, 7], [1, 3, 5, 7],
                       [1, 2, 4, 7, 8], [3, 7], [3, 4, 5, 6, 8], [5, 7]],
                      [[1, 2, 5, 5], [2, 1], [2, 2, 10, 5], [5, 2, 10, 3],
                       [5, 1, 10, 10, 10], [10, 9], [5, 3, 10, 3, 9], [10, 3]]);
#! <object>
MinimumSpanningTree(w);
#! [ 0, 1, 1, 3, 2, 7, 4, 7 ] 
#! @EndExample

#! @Section Shortest paths
#! Finds the shortest path from the vertex 2 to all other connected vertices of the graph.
#! @Example
w := WeightedGraph([[2, 3, 4, 5], [1, 5], [1, 4, 6, 7], [1, 3, 5, 7],
                       [1, 2, 4, 7, 8], [3, 7], [3, 4, 5, 6, 8], [5, 7], []],
                      [[1, 2, 5, 5], [1, 1], [2, 2, 10, 5], [5, 2, 10, 3],
                       [5, 1, 10, 10, 10], [10, 9], [5, 3, 10, 9, 3], [10, 3],
                       []]);
#! <object>
ShortestPath(w, 2); 
#! [ 2, 0, 1, 3, 2, 7, 3, 5, -1 ] 
#! @EndExample
