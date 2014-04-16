#! @AutoDoc
#! @Chapter PGraphs
#! @Section PGraphs

#
# Declaration file for directed graps and their functions.
#

if IsBound(IsGraphP) = false then

  #! A directed graph with vertices and edges between them.
  DeclareCategory("IsGraphP", IsObject);
fi;

#! @Description
#! @Arguments
#!
#! @Returns a new empty graph. 
#!
#! Constructs the empty graph with no vertices and edges.
#!
DeclareGlobalFunction("EmptyGraphP");

#! @Description
#! @Arguments successors
#!
#! @Returns a new graph.
#!
#! Constructs the graph with the given adjacency list of successor vertices for each vertex.
#!
DeclareGlobalFunction("GraphP");

#! @Description
#! @Arguments graph
#!
#! Creates and adds a new vertex to the given graph.
#!
DeclareGlobalFunction("AddVertexP");

#! @Description
#! @Arguments graph, startVertex, endVertex
#!
#! Creates and adds an edge to the given graph connecting the given start vertex to the given end vertex.
#!
DeclareGlobalFunction("AddEdgeP");

#! @Description
#! @Arguments graph
#!
#! @Returns the number of vertices in the given graph.
DeclareGlobalFunction("VertexCountP");

#! @Description
#! @Arguments graph, vertex
#!
#! @Returns all direct successor vertices of the given graph and vertex.
#!
DeclareGlobalFunction("VertexSuccessorsP");

#! @Description
#! @Arguments graph, vertex
#!
#! @Returns all direct successor vertices of the given graph and vertex.
#!
DeclareGlobalFunction("VertexSuccessorP");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns vertices of the given graph in ascending order by their distance to the given startVertex, of course only vertices reachable from start vertex are included. The exact output is a list of lists for each possible distance containing the vertices with that distance. Due to the parallel implementation each list containing the vertices of that particular distance is actually a list of lists, i.e. the vertices of that level are split into multiple disjoint partitions.
DeclareGlobalFunction("BFSP");

#! @Description
#! @Arguments graph, numberOfColours
#!
#! @Returns a list of colours for vertices of the given undirected, loopless graph for the given number of colours or false if it can't be coloured such that no two adjacent vertices have the same colour.
#!
#! The implementation is a brute force search executed by recursively generating all possible combitnations in parallel.
#!
DeclareGlobalFunction("ColorVerticesP");
