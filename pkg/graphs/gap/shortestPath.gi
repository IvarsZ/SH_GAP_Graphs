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
