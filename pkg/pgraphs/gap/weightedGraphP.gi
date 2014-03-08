#! @AutoDoc
#! @Chapter Graphs
#! @Section Weighted Graphs

#! @Description
#!
#! The representation is record with  a list of successors and a list of weights for each vertex.
#!
if IsBound(IsWeightedGraphAdjacencyListRep) = false then
  DeclareRepresentation("IsWeightedGraphAdjacencyListRep", IsGraphAdjacencyListRep, ["successors", "weights"]);
fi;

InstallGlobalFunction(WeightedGraphP, function(successorsLists, weightsLists)
  local atomicSuccessorsList, successors, atomicWeightsList, weights;

  # Make the successors and weights lists atomic.
  atomicSuccessorsList := AtomicList([]);
  for successors in successorsLists do
    Add(atomicSuccessorsList, AtomicList(successors));
  od;

  atomicWeightsList := AtomicList([]);
  for weights in weightsLists do
    Add(atomicWeightsList, AtomicList(weights));
  od;

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := atomicSuccessorsList, weights := atomicWeightsList));
end); 

InstallGlobalFunction(EmptyWeightedGraphP, function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := AtomicList([]), weights := AtomicList([])));
end);

InstallGlobalFunction(AddWeightedGraphVertexP, function(graph)

  atomic graph!.successors, graph!.weights do
    AddVertexP(graph);
    Add(graph!.weights, AtomicList([]));
  od;
end);

InstallGlobalFunction(AddWeightedEdgeP, function(graph, startVertex, endVertex, weight)

  atomic graph!.successors, graph!.weights do
    AddEdgeP(graph, startVertex, endVertex);
    Add(graph!.weights[startVertex], weight);
  od;
end);

InstallGlobalFunction(GetWeightedEdgeP, function(graph, startVertex, endVertex)
 local successors, i;

  successors := VertexSuccessorsP(graph, startVertex);
  for i in [1..Length(successors)] do
    if (successors[i] = endVertex) then
      return graph!.weights[startVertex][i];
    fi;
  od;

  return -1;
end);

InstallGlobalFunction(GetWeightP, function(graph, startVertex, edgeIndex)
  return graph!.weights[startVertex][edgeIndex];
end); 
