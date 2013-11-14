#! @AutoDoc
#! @Chapter Graphs
#! @Section Weighted Graphs

#!
#! A directed graph with non-negative weights for edges.
#!
DeclareCategory("IsWeightedGraph", IsGraph);

#! @Description
#! @Arguments
#!
#! @Returns a new empty graph with edge weights.
#!
#! Construcs the empty edge weighted graph.
#!
DeclareGlobalFunction("EmptyWeightedGraph");

#! @Description
#! @Arguments successors, weights
#!
#! @Returns a new graph with edge weights.
#!
#! Constructs the weighted graph from the given adjacency list of successors for each vertex
#! and a second list of weights.
#!
DeclareGlobalFunction("WeightedGraph");

# TODO AddWeightedEdge, TODO AddWeightedGraphVertex

#! @Description
#! @Arguments graph
#!
#! @Returns a list containing the parent of each vertex in a minimum spanning tree. A tree that contains all vertices and is of minimum total weight.
#!
#! The graph has to be stronly connected, otherwise only one tree the of the minimum spanning forest will be returned.
#!
#! TODO : reference + explanation + test example.
DeclareGlobalFunction("MinimumSpanningTree");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list of previous vertices in the shortest path from the given start vertex to a vertex in the given graph.
#!
#! TODO : reference + explanation + test example.
DeclareGlobalFunction("ShortestPath");