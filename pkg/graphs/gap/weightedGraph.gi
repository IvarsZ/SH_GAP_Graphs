#! @AutoDoc
#! @Chapter Graphs
#! @Section Weighted Graphs

#! @Description
#!
#! The representation is record with  a list of successors and a list of weights for each vertex.
#!
DeclareRepresentation("IsWeightedGraphAdjacencyListRep", IsGraphAdjacencyListRep, ["successors", "weights"]);

InstallGlobalFunction(WeightedGraph, function(successorsLists, weightsLists)
  local atomicSuccessorsList, successors, atomicWeightsList, weights;

  # Make the successors lists atomic.
  atomicSuccessorsList := AtomicList([]);
  for successors in successorsLists do
    Add(atomicSuccessorsList, AtomicList(successors));
  od;
  
  # Make the weights lists atomic.
  atomicWeightsList := AtomicList([]);
  for weights in weightsLists do
    Add(atomicWeightsList, AtomicList(weights));
  od;

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := atomicSuccessorsList, weights := atomicWeightsList));
end); 

InstallGlobalFunction(EmptyWeightedGraph, function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := AtomicList([]), weights := AtomicList([])));
end);

InstallGlobalFunction(AddWeightedGraphVertex, function(graph)

  AddVertexP(graph);
  Add(graph!.weights, AtomicList([]));
end);

InstallGlobalFunction(AddWeightedEdge, function(graph, startVertex, endVertex, weight)

  AddEdgeP(graph, startVertex, endVertex);
  Add(graph!.weights[startVertex], weight);
end);

InstallGlobalFunction(GetWeightedEdge, function(graph, startVertex, endVertex)
 local successors, i;

  successors := VertexSuccessors(graph, startVertex);
  for i in [1..Length(successors)] do
    if (successors[i] = endVertex) then
      return graph!.weights[startVertex][i];
    fi;
  od;

  return -1;
end);

InstallGlobalFunction(GetWeight, function(graph, startVertex, edgeIndex)
  return graph!.weights[startVertex][edgeIndex];
end);
