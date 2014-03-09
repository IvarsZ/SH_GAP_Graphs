InstallGlobalFunction(MinimumSpanningTree, function(graph)
  local edges, heap, isAdded, verticesLeft, nextVertex, i, minEdge, successors;

  edges := [];
  verticesLeft := VertexCount(graph);
  
  # Empty graph has an empty spanning tree.
  if (verticesLeft = 0) then
    return edges;
  fi;

  # Optimal d to use in the d-ary heap.
  ratio := Int(EdgeCount(graph)/(2 * VertexCount(graph))); # Each edge direction is counted twice.
  if ratio < 2 then
    ratio := 2;
  fi;

  # Use a heap to choose the next edge with minimum weight.
  heap := EmptyDHeap(ratio,
                     function(first, second)
                       return first.weight > second.weight;
                     end
  );

  # Add the first vertex to the tree.
  isAdded := BlistList([1..VertexCount(graph)], []);
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
    Add(edges, [minEdge.startVertex, nextVertex]);
    isAdded[nextVertex] := true;
    verticesLeft := verticesLeft - 1;
    
    # Add the edges of the added vertex.
    successors := VertexSuccessors(graph, nextVertex);
    for i in [1..Length(successors)] do
      Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := graph!.weights[nextVertex][i]));
    od;
  od;

  return edges;
end);
