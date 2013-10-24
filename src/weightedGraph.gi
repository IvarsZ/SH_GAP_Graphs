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

InstallGlobalFunction(MinimumSpanningTree, function(graph)
  local tree, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors;

  tree := [];
  verticesLeft := VertexCount(graph);
  if (verticesLeft = 0) then
    return tree;
  fi;

  heap := EmptyDHeap(2,
                     function(first, second)
                       return first.weight > second.weight;
                     end
  );
  isAdded := BlistList([1..VertexCount(graph)], []);

  Add(tree, 0);
  isAdded[1] := true;
  verticesLeft := verticesLeft - 1; 

  nextVertex := 1;
  successors := VertexSuccessors(graph, nextVertex);
  for i in [1..Length(successors)] do
    Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := graph!.weights[nextVertex][i]));
  od;

  while (verticesLeft > 0) do
  
    # Find the edge of smallest weight, that adds an unadded vertex.
    while (isAdded[nextVertex] = true) do
      minEdge := Dequeue(heap);
      nextVertex := VertexSuccessors(graph, minEdge.startVertex)[minEdge.edgeIndex];
    od;
    tree[nextVertex] := minEdge.startVertex;
    isAdded[nextVertex] := true;
    verticesLeft := verticesLeft - 1;
    
    # Add the edges of the added vertex.
    successors := VertexSuccessors(graph, nextVertex);
    for i in [1..Length(successors)] do
      Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := graph!.weights[nextVertex][i]));
    od;

    Print(tree);
  od;

  return tree;
end);

InstallGlobalFunction(ShortestPath, function(graph, startVertex)
  local tree, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors, pathLengths;

  tree := [];
  verticesLeft := VertexCount(graph);
  if (verticesLeft = 0) then
    return tree;
  fi;

  heap := EmptyDHeap(2,
                     function(first, second)
                       return first.pathLength > second.pathLength;
                     end
  );
  isAdded := BlistList([1..VertexCount(graph)], []);
  pathLengths := EmptyPlist(VertexCount(graph));

  Add(tree, startVertex);
  isAdded[startVertex] := true;
  pathLengths[startVertex] := 0;
  verticesLeft := verticesLeft - 1; 

  nextVertex := startVertex;
  successors := VertexSuccessors(graph, nextVertex);
  for i in [1..Length(successors)] do
    Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := graph!.weights[nextVertex][i] + pathLengths[nextVertex]));
  od;

  while (verticesLeft > 0 and Length(heap!.nodes) > 0 ) do
  
    # Find the edge of smallest weight, that adds an unadded vertex.
    while (isAdded[nextVertex] = true) do
      minEdge := Dequeue(heap);
      nextVertex := VertexSuccessors(graph, minEdge.startVertex)[minEdge.edgeIndex];
    od;
    tree[nextVertex] := minEdge.startVertex;
    isAdded[nextVertex] := true;
    verticesLeft := verticesLeft - 1;
    
    # Add the edges of the added vertex.
    successors := VertexSuccessors(graph, nextVertex);
    for i in [1..Length(successors)] do
      Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := graph!.weights[nextVertex][i] + pathLengths[nextVertex]));
    od;

    Print(tree);
  od;

  return tree;
end);
