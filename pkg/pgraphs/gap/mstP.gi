# Record for private members.
MSTP_REC := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexParent, vertexEdge, head, heads, headEdge, newHeads, vertex, vertices, task, tasks, edge, edges, head2, edge2;

  edges := AtomicList([]);

  vertexCount := VertexCountP(graph);
  vertices := [1..vertexCount];

  vertexHead := FixedAtomicList(vertexCount); 
  vertexParent := FixedAtomicList(vertexCount);
  vertexEdge := FixedAtomicList(vertexCount);
  headEdge := FixedAtomicList(vertexCount);

  heads := [];
  
  tasks := [];
  for vertex in vertices do

    heads[vertex] := vertex; # Initialize in parallel.
    headEdge[vertex] := MakeImmutable([]);

    vertexHead[vertex] := vertex;
    vertexParent[vertex] := 0;
    vertexEdge[vertex] := 1;

    # Sort edges to find minimum edge quickly.
    task := RunTask(MSTP_REC.sortEdges, graph, vertex);
    Add(tasks, task);
  od;
  WaitTasks(tasks);

  while Length(heads) > 1 do
    
    # Find min edges.
    tasks := [];
    for vertex in vertices do
      task := RunTask(MSTP_REC.findMinEdge, graph, vertex, vertexHead, vertexEdge, headEdge);
      Add(tasks, task);
    od;
    WaitTasks(tasks);

    # Join the edges by changing heads and merging the lists.
    tasks := [];
    for head in heads do
      edge := headEdge[head];
      if edge <> [] then
        task := RunTask(MSTP_REC.mergeParents, edge, vertexHead, vertexParent, heads, edges);
        Add(tasks, task);
        
        # if the partition of end vertex links back remove it to avoid unneeded tasks.
        head2 := vertexHead[edge[2]];
        edge2 := headEdge[head2];
        if edge2 <> [] and vertexHead[edge2[2]] = head then
          headEdge[head2] := MakeImmutable([]);
        fi;
      fi;
    od;
    WaitTasks(tasks);
    
    # Update vertex heads list. # TODO do current heads first by linking them to parents directly. Combine with below.
    tasks := [];
    for vertex in vertices do
      task := RunTask(MSTP_REC.updateHeads, vertex, vertexHead, vertexParent);
      Add(tasks, task);
    od;
    WaitTasks(tasks);

    # Get new heads. # TODO paralelise a bit, depending on P count.
    newHeads := [];
    for head in heads do
      if vertexHead[head] = head then
        Add(newHeads, head);
        headEdge[head] := MakeImmutable([]);
      fi;
    od;

    if Length(heads) = Length(newHeads) then
      break;
    else
      heads := newHeads;
    fi;    
  od;

  return FromAtomicList(edges);
end);

MSTP_REC.sortEdges := function(graph, vertex)
  local successors, weights;

  weights := FromAtomicList(graph!.weights[vertex]);
  successors := FromAtomicList(graph!.successors[vertex]);
  SortParallel(weights, successors);
  graph!.weights[vertex] := AtomicList(weights);
  graph!.successors[vertex] := AtomicList(successors);
end;

MSTP_REC.mergeParents := function(edge, vertexHead, vertexParent, heads, edges)
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
  Add(edges, edge);
end;

MSTP_REC.updateHeads := function(vertex, vertexHead, vertexParent)
  local parent;

  # TODO tree compression, possibly not needed if using balancing? Will be done above i.e. heads first.
  
  parent := vertexHead[vertex];
  while vertexParent[parent] > 0 do
    parent := vertexParent[parent];
  od;

  vertexHead[vertex] := parent;
end;

MSTP_REC.findMinEdge := function(graph, vertex, vertexHead, vertexEdge, headEdge)
  local successors, head, minEdge, edgeIndex, successor, weight, update;
    
  successors := VertexSuccessorsP(graph, vertex);
  head := vertexHead[vertex];

  edgeIndex := vertexEdge[vertex];
  while edgeIndex <= Length(successors) do
  
    successor := successors[edgeIndex];
    if head <> vertexHead[successor] then

      # Pick the next sorted edge for this vertex.
      weight := GetWeightP(graph, vertex, edgeIndex);

      # Update min if needed.
      atomic headEdge[head] do
        minEdge := headEdge[head];
        if
          minEdge = [] or
          weight < minEdge[3] or
          (weight = minEdge[3] and vertexHead[successor] < vertexHead[minEdge[2]])
        then
          headEdge[head] := MakeImmutable([vertex, successor, weight]); # TODO is this safe with above lock.
        fi;
      od;

      # Update vertex edge for the next time and stop since the list is sorted.
      vertexEdge[vertex] := edgeIndex;
      break;
    else

      # Skip the edge creating a loop.
      edgeIndex := edgeIndex + 1;
    fi;
  od;
end;
