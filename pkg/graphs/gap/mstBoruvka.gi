# Record for private members.
MST_REC := rec();

InstallGlobalFunction(MinimumSpanningTree, function(graph)
  local vertexCount, vertexHead, vertexParent, vertexEdge, head, heads, headEdge, newHeads, vertex, vertices, task, tasks, edge, edges, head2, edge2;

  vertexCount := VertexCount(graph);
  vertices := [1..vertexCount];
  
  edges := EmptyPlist(vertexCount);
  
  vertexHead := EmptyPlist(vertexCount); 
  vertexParent := EmptyPlist(vertexCount);
  vertexEdge := EmptyPlist(vertexCount);
  headEdge := EmptyPlist(vertexCount);

  heads := [];
  
  for vertex in vertices do

    heads[vertex] := vertex; # Initialize in parallel.
    headEdge[vertex] := MakeImmutable([]);

    vertexHead[vertex] := vertex;
    vertexParent[vertex] := 0;
    vertexEdge[vertex] := 1;

    # Sort edges to find minimum edge quickly.
    MST_REC.sortEdges(graph, vertex);
  od;

  while Length(heads) > 1 do
    
    # Find min edges.
    for vertex in vertices do
      MST_REC.findMinEdge(graph, vertex, vertexHead, vertexEdge, headEdge);
    od;

    # Join the edges by changing heads and merging the lists.
    tasks := [];
    for head in heads do
      edge := headEdge[head];
      if edge <> [] then
        MST_REC.mergeParents(edge, vertexHead, vertexParent);
        Add(edges, edge);
        
        # if the partition of end vertex links back remove it to avoid unneeded tasks.
        head2 := vertexHead[edge[2]];
        edge2 := headEdge[head2];
        if edge2 <> [] and vertexHead[edge2[2]] = head then
          headEdge[head2] := MakeImmutable([]);
        fi;
      fi;
    od;
    
    # Compress heads.
    for head in heads do
      MST_REC.compressHeads(head, vertexHead, vertexParent);
    od;
    
    # Update heads for vertices and get new heads.
    newHeads := [];
    for vertex in vertices do
      head := vertexHead[vertex];

      if vertex <> head then
        if vertexParent[head] > 0 then
          vertexHead[vertex] := vertexParent[head];
        fi;
      else
        if vertexParent[head] = 0 then
          Add(newHeads, head);
          headEdge[head] := MakeImmutable([]);
        else
          vertexHead[head] := vertexParent[head];
        fi;
      fi;
    od;
    
    if Length(heads) = Length(newHeads) then
      break;
    else
      heads := newHeads;
    fi;    
  od;

  return edges;
end);

MST_REC.sortEdges := function(graph, vertex)
  local successors, weights;

  SortParallel(graph!.weights[vertex], graph!.successors[vertex]);
end;

MST_REC.mergeParents := function(edge, vertexHead, vertexParent)
  local head1, head2, parent1, parent2;
  
  head1 := vertexHead[edge[1]];
  head2 := vertexHead[edge[2]];

  parent1 := head1;
  while vertexParent[parent1] > 0 do
    parent1 := vertexParent[parent1];
  od;

  parent2 := head2;
  while vertexParent[parent2] > 0 do
    parent2 := vertexParent[parent2];
  od;

  # Links parent1 to parent2, note the direction is important when doing it in parallel.
  vertexParent[parent1] := parent2;
end;

MST_REC.compressHeads := function(head, vertexHead, vertexParent)
  local parent;

  parent := head;
  while vertexParent[parent] > 0 do
    parent := vertexParent[parent];
  od;

  if head <> parent then
    vertexParent[head] := parent; # So vertices attached to this head could find parent faster.
  fi;
end;

MST_REC.findMinEdge := function(graph, vertex, vertexHead, vertexEdge, headEdge)
  local successors, head, minEdge, edgeIndex, successor, weight, update, minWeight, minSuccessor;

  # Check all unpicked minimal weight edges of the vertex.
  minWeight := -1;
  minSuccessor := -1;
  head := vertexHead[vertex];
  successors := VertexSuccessors(graph, vertex);

  edgeIndex := vertexEdge[vertex];
  while edgeIndex <= Length(successors) do
    successor := successors[edgeIndex];

    # Consider only edges outside partition.
    if head <> vertexHead[successor] then
      
      weight := GetWeight(graph, vertex, edgeIndex);
      if minWeight = -1 then
        minWeight := weight;
        minSuccessor := successor;
        
        # Update the first edge that could be picked again.
        vertexEdge[vertex] := edgeIndex;
      fi;
      
      if weight = minWeight then

        # Pick the one with the smallest head.
        if vertexHead[successor] < vertexHead[minSuccessor] then
          minWeight := weight;
          minSuccessor := successor;
        fi;
      else
        # stop since the list is sorted.
        break;
      fi;
    fi;

    edgeIndex := edgeIndex + 1;
  od;

  # Update min of head's partition if needed.
  if minWeight <> -1 then
    minEdge := headEdge[head];
    if
      minEdge = [] or
      minWeight < minEdge[3] or
      (minWeight = minEdge[3] and vertexHead[minSuccessor] < vertexHead[minEdge[2]])
    then
      headEdge[head] := MakeImmutable([vertex, minSuccessor, minWeight]);
    fi;
  else
    # No edge could be repicked.
    vertexEdge[vertex] := edgeIndex;
  fi;
end;
