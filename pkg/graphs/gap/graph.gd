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
#! @Arguments graph, start, end
#!
#! Adds an edge to the given graph connecting the given start and end vertices.
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

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list ordering the vertices of the given graph in the order of a depth first search starting from the given start vertex.
#!
#! In depth first search each branch is fully explored before backtracking to another branch. The implementation uses a stack for the recursive traversal of vertices.
DeclareGlobalFunction("DFS");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list ordering the vertices of the given graph in the order of a breadth first search starting from the given start vertex.
#!
#! TODO BFS explanation and a reference.
DeclareGlobalFunction("BFS");

#! @Description
#! @Arguments graph, numberOfColours
#!
#! @Returns a list of colours for vertices of the given graph for the given number of colours or false if it can't be coloured.
#!
#! TODO colouring explanation and a reference.
DeclareGlobalFunction("GetColouring");

#! @Description
#! @Arguments graph
#!
#! @Returns a list that partitions vertices of the given graph into strongly connected components. Each vertex is assigned the index of its component, where the indexes of components start from vertex count + 1.
#!
DeclareGlobalFunction("GetStrongComponents");
