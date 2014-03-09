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
#! Constructs the empty edge weighted graph.
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

#! @Description
#! @Arguments graph
#!
#! Creates and adds a new vertex to the given weighted graph.
DeclareGlobalFunction("AddWeightedGraphVertex");

#! @Description
#! @Arguments graph, startVertex, endVertex, weight
#!
#! Creates and adds an edge of the given weight to the given graph connecting the given start vertex to the given end vertex.
#!
DeclareGlobalFunction("AddWeightedEdge");

#! @Description
#! @Arguments graph, startVertex, endVertex
#!
#! Gets the weight of the edge from the startVertex to the endVertex in the graph.
#!
DeclareGlobalFunction("GetWeightedEdge");

#! @Description
#! @Arguments graph, startVertex, edgeIndex
#!
#! Gets the weight of the edgeIndex-th edge for the startVertex in the graph.
#!
DeclareGlobalFunction("GetWeight");

#! @Description
#! @Arguments graph
#!
#! @Returns a list containing the parent of each vertex in a minimum spanning tree. A tree that connects to all vertices and is of minimum total weight. The graph has to be stronly connected, otherwise only one tree the of the minimum spanning forest will be returned.
#!
#! Implements Prim's algorithm that uses d-ary heap for the priority queue implementation to get the next smallest edge to add.
DeclareGlobalFunction("MinimumSpanningTree");

#! @Description
#! @Arguments graph, startVertex
#!
#! @Returns a list of previous vertices in the shortest path from the given start vertex to a vertex in the given graph.
#!
#! Implements Dijkstra's algorithm that uses d-ary heap for the priority queue implementation to get the next smallest edge to add.
DeclareGlobalFunction("ShortestPath");
