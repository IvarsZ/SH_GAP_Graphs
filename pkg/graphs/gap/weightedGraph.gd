#
# A graph with non-negative weights for vertices.
#
DeclareCategory("IsWeightedGraph", IsGraph);

#
# Constructs a weighted graph from the given adjacency list of successors for each vertex
# and a second list of weights.
#
DeclareGlobalFunction("WeightedGraph");

#
# Construcs an empty weighted graph.
#
DeclareGlobalFunction("EmptyWeightedGraph");

#
# Returns a list containing the parents of each vertex in a minimum spanning tree.
# A tree that contains all vertices and is of minimum total weight.
#
# The graph has to be stronly connected.
#
DeclareGlobalFunction("MinimumSpanningTree");

#
# Finds the shortest path to each vertex from the given vertex.
#
# Returns a list where the previous vertex in the path is given for each vertex.
#
DeclareGlobalFunction("ShortestPath");
