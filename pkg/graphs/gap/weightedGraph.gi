#! @AutoDoc
#! @Chapter Graphs
#! @Section Weighted Graphs

#! @Description
#!
#! The representation is record with  a list of successors and a list of weights for each vertex.
#!
DeclareRepresentation("IsWeightedGraphAdjacencyListRep", IsGraphAdjacencyListRep, ["successors", "weights"]);

InstallGlobalFunction(WeightedGraph, function(successors, weights)

  return Objectify(NewType(NewFamily("WeightedGraphs"), IsWeightedGraph and IsWeightedGraphAdjacencyListRep),
                   rec(successors := successors, weights := weights));
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
  od;

  return tree;
end);

InstallGlobalFunction(ShortestPath, function(graph, startVertex)
  local tree, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors, pathLength;

  verticesLeft := VertexCount(graph);

  # Empty graph has no paths.
  if (verticesLeft = 0) then
    return [];
  fi;

  tree := EmptyPlist(verticesLeft);
  for i in [1..verticesLeft] do
    tree[i] := -1;
  od;

  # TODO experiment what d-ary heap to use.
  # Use a heap to choose the next edge to visit.
  heap := EmptyDHeap(2,
                     function(first, second)
                       return first.pathLength > second.pathLength;
                     end
  );

  # Visit the starting vertex.
  isAdded := BlistList([1..VertexCount(graph)], []);
  tree[startVertex] := 0;
  isAdded[startVertex] := true;
  verticesLeft := verticesLeft - 1; 

  # Add its outgoing edges to the heap.
  nextVertex := startVertex;
  successors := VertexSuccessors(graph, nextVertex);
  for i in [1..Length(successors)] do
    pathLength := graph!.weights[nextVertex][i];
    Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := pathLength));
  od;

  while (verticesLeft > 0 and Length(heap!.nodes) > 0) do
  
    # Find the edge of smallest weight, that adds an unadded vertex.
    while (isAdded[nextVertex] = true and Length(heap!.nodes) > 0) do
      minEdge := Dequeue(heap);
      nextVertex := VertexSuccessors(graph, minEdge.startVertex)[minEdge.edgeIndex];
    od;

    if (isAdded[nextVertex] = false) then

      tree[nextVertex] := minEdge.startVertex;
      isAdded[nextVertex] := true;
      verticesLeft := verticesLeft - 1;
    
      # Add the edges of the visited vertex.
      successors := VertexSuccessors(graph, nextVertex);
      for i in [1..Length(successors)] do
        pathLength := graph!.weights[nextVertex][i] + minEdge.pathLength;
        Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, pathLength := pathLength));
      od;
    fi;
  od;

  return tree;
end);
