#! @Chapter Graphs
#! @Section Graphs

#! @Description
#!
#! The representation is a record with an adjacency list called successors where each vertex v has a list of end vertices for each edge starting at v.
#!
DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["successors"]);

InstallGlobalFunction(Graph, function(successors)

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := successors));
end); 

InstallGlobalFunction(EmptyGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := []));
end);

#
# Adds a new vertex to the given graph.
#
InstallGlobalFunction(AddVertex, function(graph)

  # New vertex has no successors.
  Add(graph!.successors, []);
end);

#
# Adds an edge to the given graph from the given start vertex to the given end vertex.
#
InstallGlobalFunction(AddEdge, function(graph, start, end_)

  # The end vertex becomes a successor of the start vertex, as the edge connects them.
  Add(VertexSuccessors(graph, start), end_);
end);

#
# Returns successor vertices of the given vertex in the given graph.
#
InstallGlobalFunction(VertexSuccessors, function(graph, vertex)

  return graph!.successors[vertex];
end);

InstallGlobalFunction(VertexSuccessor, function(graph, vertex, edgeIndex)
  return graph!.successors[vertex][edgeIndex];
end);

#
# Returns the number of vertices in the given graph.
#
InstallGlobalFunction(VertexCount, function(graph)

  return Length(graph!.successors);
end);
