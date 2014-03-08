# TODO update documentation.

#! @AutoDoc
#! @Chapter Graphs
#! @Section Graphs

#
# Declaration file for directed graps and their functions.
#

#! A directed graph with vertices and edges between them.
if IsBound(IsGraph) = false then
  DeclareCategory("IsGraph", IsObject);
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

# TODO comment
DeclareGlobalFunction("VertexSuccessorP");

DeclareGlobalFunction("BFSP");

DeclareGlobalFunction("ColorVerticesP");
