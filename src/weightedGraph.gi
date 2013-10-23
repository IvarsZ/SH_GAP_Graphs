DeclareRepresentation("IsWeightedGraphAdjacencyListRep", IsGraphAdjacencyListRep, ["successors", "weights"]);

InstallGlobalFunction(WeightedGraph, function(successors, weights)

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := successors, weights := weights));
end); 

InstallGlobalFunction(EmptyWeightedGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := [], weights := []));
end);

# PRIVATE FUNCTIONS AND VARIABLES RECORD
GRAPH := rec();
