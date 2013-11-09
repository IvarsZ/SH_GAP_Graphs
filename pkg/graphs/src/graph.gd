#
# Declaration file for directed graps and their functions.
#

# TODO comment here?
DeclareCategory("IsGraph", IsObject);

#
# Constructs an empty graph. 
#
DeclareGlobalFunction("EmptyGraph", "Constructs an empty graph");

#
# Given an adjacency list of successor vertices for each vertex constructs a graph.
#
DeclareGlobalFunction("Graph");

#
# Adds a vertex to a graph.
#
DeclareGlobalFunction("AddVertex");

#
# Adds an edge to a graph connecting two specified vertices.
#
DeclareGlobalFunction("AddEdge");

#
# Returns the number of vertices in the graph.
#
DeclareGlobalFunction("VertexCount");

#
# Returns all successor vertices s for a vertex (all edges (vertex, s)).
#
DeclareGlobalFunction("VertexSuccessors");

#
# Returns a list ordering the vertices in the order of a depth first search starting from the given vertex.
#
DeclareGlobalFunction("DFS");

#
# Returns a list ordering the vertices in the order of a breadth first search starting from the given vertex.
#
DeclareGlobalFunction("BFS");

#
# Returns a list of colours for vertices of the graph for the given number of colours or false if it can't be coloured.
#
DeclareGlobalFunction("GetColouring");

#
# Returns a list that partitions vertices into strongly connected components.
#
DeclareGlobalFunction("GetStrongComponents");
