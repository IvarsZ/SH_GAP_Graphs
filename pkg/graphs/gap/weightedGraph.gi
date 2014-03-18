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

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := successorsLists, weights := weightsLists));
end); 

InstallGlobalFunction(EmptyWeightedGraph, function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := [], weights := []));
end);

InstallGlobalFunction(AddWeightedGraphVertex, function(graph)

  AddVertex(graph);
  Add(graph!.weights, []);
end);

InstallGlobalFunction(AddWeightedEdge, function(graph, startVertex, endVertex, weight)

  AddEdge(graph, startVertex, endVertex);
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
