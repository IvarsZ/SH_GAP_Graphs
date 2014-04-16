#! @AutoDoc
#! @Chapter PGraphs
#! @Section Weighted PGraphs

if IsBound(IsWeightedGraphP) = false then
  #! A directed graph with non-negative weights for edges.
  DeclareCategory("IsWeightedGraphP", IsGraphP);
fi;

#! @Description
#! @Arguments
#!
#! @Returns a new empty graph with edge weights.
#!
#! Constructs the empty edge weighted graph.
#!
DeclareGlobalFunction("EmptyWeightedGraphP");

#! @Description
#! @Arguments successors, weights
#!
#! @Returns a new graph with edge weights.
#!
#! Constructs the weighted graph from the given adjacency list of successors for each vertex
#! and a second list of weights.
#!
DeclareGlobalFunction("WeightedGraphP");

#! @Description
#! @Arguments graph
#!
#! Creates and adds a new vertex to the given weighted graph.
DeclareGlobalFunction("AddWeightedGraphVertexP");

#! @Description
#! @Arguments graph, startVertex, endVertex, weight
#!
#! Creates and adds an edge of the given weight to the given graph connecting the given start vertex to the given end vertex.
#!
DeclareGlobalFunction("AddWeightedEdgeP");

#! @Description
#! @Arguments graph, startVertex, endVertex
#!
#! Gets the weight of the edge from the startVertex to the endVertex in the graph.
#!
DeclareGlobalFunction("GetWeightedEdgeP");

#! @Description
#! @Arguments graph, startVertex, edgeIndex
#!
#! Gets the weight of the edgeIndex-th edge for the startVertex in the graph.
#!
DeclareGlobalFunction("GetWeightP");

#! @Description
#! @Arguments graph
#!
#! @Returns a list of edges in a minimum spanning tree. A tree that connects to all vertices and is of minimum total weight.
#!
#! Implements a version of parallel Boruvka's algorithm with in place union-find data structure.
DeclareGlobalFunction("MinimumSpanningTreeP");
