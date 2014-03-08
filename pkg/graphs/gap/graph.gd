#! @AutoDoc
#! @Chapter Graphs
#! @Section Graphs

#
# Declaration file for directed graps and their functions.
#

#! A directed graph with vertices and edges between them.
DeclareCategory("IsGraph", IsObject);

#! @Description
#! @Arguments
#!
#! @Returns a new empty graph. 
#!
#! Constructs the empty graph with no vertices and edges.
#!
DeclareGlobalFunction("EmptyGraph");


#! @Description
#! @Arguments successors
#!
#! @Returns a new graph.
#!
#! Constructs the graph with the given adjacency list of successor vertices for each vertex.
#!
DeclareGlobalFunction("Graph");

#! @Description
#! @Arguments graph
#!
#! Creates and adds a new vertex to the given graph.
#!
DeclareGlobalFunction("AddVertex");

#! @Description
#! @Arguments graph, startVertex, endVertex
#!
#! Creates and adds an edge to the given graph connecting the given start vertex to the given end vertex.
#!
DeclareGlobalFunction("AddEdge");

#! @Description
#! @Arguments graph
#!
#! @Returns the number of vertices in the given graph.
DeclareGlobalFunction("VertexCount");

#! @Description
#! @Arguments graph, vertex
#!
#! @Returns all direct successor vertices of the given graph and vertex.
#!
DeclareGlobalFunction("VertexSuccessors");

# TODO comment
DeclareGlobalFunction("VertexSuccessor");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list ordering the vertices of the given graph in the order of a depth first search starting from the given start vertex.
#!
#! In depth first search each branch is fully explored before backtracking to another branch. The implementation uses a stack for the recursive traversal of vertices.
#!
DeclareGlobalFunction("DFS");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list whose first element is a list ordering the vertices of the given graph in the order of a breadth first search starting from the given start vertex. The depth of the search is returned as the second element of the list.
#!
#! In breadth first search all successor vertices of a vertex are visited before visiting their successor vertices. Thus it traverses the graph level by level from the start vertex (root). The implementaion uses a first-in-first-out (FIFO) queue to achieve the order.
#!
DeclareGlobalFunction("BFS");

#! @Description
#! @Arguments graph, numberOfColours
#!
#! @Returns a list of colours for vertices of the given undirected, loopless graph for the given number of colours or false if it can't be coloured such that no two adjacent vertices have the same colour.
#!
#! The implementation is a backtracking solution where the vertices are coloured with the first available colour and if there is a clash of colours the next colours is tried for the first possible vertex untill a solution is found. To improve the performance the vertices are preordered by colouring the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
#!
DeclareGlobalFunction("ColorVertices");

#! @Description
#! @Arguments graph
#!
#! @Returns a list that partitions vertices of the given graph into strongly connected components. Each vertex is assigned the index of its component, where the indexes of components start from vertex count + 1.
#!
#! It is an implementation of Gabov's algorithm. It traverses the graph with DFS and uses two stacks. One to keep track of visited vertices and another one to keep track of vertices which vertices are backwards reachable and are in the same strong component. 
#!
DeclareGlobalFunction("StrongComponents");
