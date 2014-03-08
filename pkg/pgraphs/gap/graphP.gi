#! @Chapter Graphs
#! @Section Graphs

#! @Description
#!
#! The representation is a record with an adjacency list called successors where each vertex v has a list of end vertices for each edge starting at v.
#!
if IsBound(IsGraphAdjacencyListRep) = false then
  DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["successors"]);
fi;

InstallGlobalFunction(GraphP, function(successorsLists)
  local atomicSuccessorsList, successors;

  # Make the successors lists atomic.
  atomicSuccessorsList := AtomicList([]);
  for successors in successorsLists do
    Add(atomicSuccessorsList, AtomicList(successors));
  od;

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := atomicSuccessorsList));
end);

InstallGlobalFunction(EmptyGraphP,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := AtomicList([])));
end);

#
# Adds a new vertex to the given graph.
#
InstallGlobalFunction(AddVertexP, function(graph)

  # New vertex has no successors.
  Add(graph!.successors, AtomicList([]));
end);

#
# Adds an edge to the given graph from the given start vertex to the given end vertex.
#
InstallGlobalFunction(AddEdgeP, function(graph, start, end_)

  # The end vertex becomes a successor of the start vertex, as the edge connects them.
  Add(VertexSuccessorsP(graph, start), end_);
end);

#
# Returns successor vertices of the given vertex in the given graph.
#
InstallGlobalFunction(VertexSuccessorsP, function(graph, vertex)

  return graph!.successors[vertex];
end);

InstallGlobalFunction(VertexSuccessorP, function(graph, vertex, edgeIndex)
  return graph!.successors[vertex][edgeIndex];
end);

#
# Returns the number of vertices in the given graph.
#
InstallGlobalFunction(VertexCountP, function(graph)

  return Length(graph!.successors);
end);
