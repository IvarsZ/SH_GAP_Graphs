#! @AutoDoc
#! @Chapter Graphs
#! @Section Weighted Graphs

#!
#! A directed graph with non-negative weights for edges.
#!
if IsBound(IsWeightedGraph) = false then
  DeclareCategory("IsWeightedGraph", IsGraph);
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

# TODO comment.
DeclareGlobalFunction("GetWeightedEdgeP");

# TODO comment.
DeclareGlobalFunction("GetWeightP");

DeclareGlobalFunction("MinimumSpanningTreeP");
