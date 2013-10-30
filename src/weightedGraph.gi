#
# A weighted graph of adjacency list representation has a list of successors and a list of weights for each vertex.
#
DeclareRepresentation("IsWeightedGraphAdjacencyListRep", IsGraphAdjacencyListRep, ["successors", "weights"]);

#
# Constructs a weighted graph given its successors and weights lists. 
#
InstallGlobalFunction(WeightedGraph, function(successors, weights)

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := successors, weights := weights));
end); 

#
# Constructs and empty weighted graph.
#
InstallGlobalFunction(EmptyWeightedGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := [], weights := []));
end);

#
# Finds the minimum spanning tree of the given weighted graph.
#
InstallGlobalFunction(MinimumSpanningTree, function(graph)
  local tree, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors;

  tree := [];
  verticesLeft := VertexCount(graph);
  
  # Empty graph has an empty spanning tree.
  if (verticesLeft = 0) then
    return tree;
  fi;

  # Use a heap to choose the next edge with minimum weight.
  heap := EmptyDHeap(2,
                     function(first, second)
                       return first.weight > second.weight;
                     end
  );

  # Add the first vertex to the tree.
  isAdded := BlistList([1..VertexCount(graph)], []);
  Add(tree, 0);
  isAdded[1] := true;
  verticesLeft := verticesLeft - 1; 

  # Add its outgoing edges to the heap.
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

#
# Finds the shortest path to each vertex in the given graph from the given start vertex.
#
InstallGlobalFunction(ShortestPath, function(graph, startVertex)
  local tree, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors, pathLengths, pathLength;

  tree := [];
  verticesLeft := VertexCount(graph);

  # Empty graph has no paths.
  if (verticesLeft = 0) then
    return tree;
  fi;

  # Use a heap to choose the next edge to visit.
  heap := EmptyDHeap(2,
                     function(first, second)
                       return first.pathLength > second.pathLength;
                     end
  );

  # Visit the starting vertex. TODO remove path lengths.
  isAdded := BlistList([1..VertexCount(graph)], []);
  pathLengths := EmptyPlist(VertexCount(graph));
  tree[startVertex] := 0;
  isAdded[startVertex] := true;
  pathLengths[startVertex] := 0;
  verticesLeft := verticesLeft - 1; 

  # Add its outgoing edges to the heap.
  nextVertex := startVertex;
  successors := VertexSuccessors(graph, nextVertex);
  for i in [1..Length(successors)] do
    pathLength := graph!.weights[nextVertex][i] + pathLengths[nextVertex];
    Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := pathLength));
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
    pathLengths[nextVertex] := minEdge.pathLengt;
    
    # Add the edges of the visited vertex.
    successors := VertexSuccessors(graph, nextVertex);
    for i in [1..Length(successors)] do
      pathLength := graph!.weights[nextVertex][i] + pathLengths[nextVertex];
      Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := pathLength));
    od;

  od;

  return tree;
end);