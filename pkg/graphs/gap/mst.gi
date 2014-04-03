PrintHeap := function(heap)
  local i, node;
  
  for i in [1..Length(heap!.nodes)] do
    node := heap!.nodes[i];
    #Print("[", node.endVertex, ", ", node.weight, "], ");
  od;
  #Print("\n");
end;

InstallGlobalFunction(MinimumSpanningTree, function(graph)
  local edges, heap, minDistance, verticesLeft, nextVertex, i, minEdge, successors, ratio, weight;

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
                     end, EmptyPlist(VertexCount(graph))
  );

  # Add the first vertex to the tree.
  minDistance := EmptyPlist(VertexCount(graph));
  minDistance[1] := -1;
  verticesLeft := verticesLeft - 1; 

  # Add its outgoing edges to the heap.
  nextVertex := 1;
  successors := VertexSuccessors(graph, nextVertex);
  for i in [1..Length(successors)] do
    weight := graph!.weights[nextVertex][i];
    Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := weight, endVertex := successors[i]));
    minDistance[successors[i]] := weight;
  od;

  while (verticesLeft > 0) do
  
    # Find the edge of smallest weight, that adds an unadded vertex.
    while (minDistance[nextVertex] = -1) do
    
      if Length(heap!.nodes) < 1 then
        return edges; # Done, because no more edges are left.
      fi;
    
      minEdge := Dequeue(heap);
      nextVertex := VertexSuccessors(graph, minEdge.startVertex)[minEdge.edgeIndex];
    od;
    Add(edges, [minEdge.startVertex, nextVertex, minEdge.weight]);
    minDistance[nextVertex] := -1;
    verticesLeft := verticesLeft - 1;
    
    # Add the edges of the added vertex.
    successors := VertexSuccessors(graph, nextVertex);
    for i in [1..Length(successors)] do
    
      weight := graph!.weights[nextVertex][i];
      if IsBound(minDistance[successors[i]]) = false then
        Enqueue(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := weight, endVertex := successors[i]));
        #Print("-------------\n");
        #Print(heap!.elementNodeIndex, "\n");
        #PrintHeap(heap);
        #Print(nextVertex, "->", successors[i], "\n");
        #Print(heap!.elementNodeIndex, "\n");
        #PrintHeap(heap);
        minDistance[successors[i]] := weight;
      fi;
      
      if weight < minDistance[successors[i]] then
        LowerElement(heap, rec(startVertex := nextVertex, edgeIndex := i, weight := weight, endVertex := successors[i]));
        #Print("-------------\n");
        #Print(heap!.elementNodeIndex, "\n");
        #PrintHeap(heap);
        #Print(nextVertex, "->", successors[i], "\n");
        #Print(heap!.elementNodeIndex, "\n");
        #PrintHeap(heap);
        minDistance[successors[i]] := weight;
      fi;
    od;
  od;

  return edges;
end);
