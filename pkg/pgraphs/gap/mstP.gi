# Record for private members.
MSTP_REC := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexNext, vertexTail, head, heads, newHeads, vertex, task, tasks, head1, head2, tmp, edge, edges, vertexEdge, task2, tasks2;

  edges := AtomicList([]);

  vertexCount := VertexCountP(graph);
  vertexHead := FixedAtomicList(vertexCount); 
  vertexNext := FixedAtomicList(vertexCount);
  vertexTail := FixedAtomicList(vertexCount);
  vertexEdge := FixedAtomicList(vertexCount);

  heads := EmptyPlist(vertexCount);
  
  tasks := [];
  ShareObj(graph!.successors);
  ShareObj(graph!.weights);

  for vertex in [1..vertexCount] do
    heads[vertex] := vertex;
    vertexHead[vertex] := vertex;
    vertexTail[vertex] := vertex;
    vertexNext[vertex] := 0;
    vertexEdge[vertex] := 1;

    # Sort edges to find minimum edge quickly.
    task := RunTask(MSTP_REC.sortEdges, graph, vertex);
    Add(tasks, task);
  od;
  WaitTasks(tasks);

  # TODO make atomic vs shared.
  # TODO change serial mst to edges.

  while Length(heads) > 1 do
    
    # Find min edges.
    tasks := [];
    for head in heads do
      task := RunTask(MSTP_REC.findMinEdge, graph, head, vertexHead, vertexNext, vertexTail, vertexEdge);
      Add(tasks, task);
    od;
    WaitTasks(tasks);

    # Join the edges by changing heads and merging the lists.
    tasks2 := [];
    for task in tasks do  
      edge := TaskResult(task);
      if edge <> false then
        task2 := RunTask(MSTP_REC.mergeHeads, edge, vertexHead, vertexNext, vertexTail, edges); 
        Add(tasks2, task2);
      fi;
    od;
    WaitTasks(tasks2);
    
    # Update heads list and get the new heads.
    tasks := [];
    newHeads := [];
    for head in heads do 
      if vertexHead[head] = head then
        
      Add(newHeads, head);
        task := RunTask(MSTP_REC.updateHeads, head, vertexHead, vertexNext);
      fi;
    od;

    if Length(heads) = Length(newHeads) then
      break;
    fi;
    heads := newHeads;

    WaitTasks(tasks);
  od;

  return FromAtomicList(edges);
end);

MSTP_REC.sortEdges := function(graph, vertex)
  local successors, weights;

  atomic graph!.successors, graph!.weights do # TODO proper lock? Best way to sort atomic lists.
    weights := FromAtomicList(graph!.weights[vertex]);
    successors := FromAtomicList(graph!.successors[vertex]);
    SortParallel(weights, successors);
    graph!.weights[vertex] := AtomicList(weights);
    graph!.successors[vertex] := AtomicList(successors);
  od;
end;

MSTP_REC.mergeHeads := function(edge, vertexHead, vertexNext, vertexTail, edges)
  local head1, head2, tmp;

  # TODO what needs locks?
  head1 := vertexHead[edge[1]];
  head2 := vertexHead[edge[2]];

  if head1 <> head2 then
        
    Add(edges, edge);
    vertexHead[edge[2]] := head1;
    vertexHead[head2] := head1;

    tmp := vertexNext[head1];
    vertexNext[head1] := head2;
    vertexNext[vertexTail[head2]] := tmp;

    if tmp <= 0 then
      vertexTail[head1] := vertexTail[head2];
    fi;
  fi;
end;

MSTP_REC.updateHeads := function(head, vertexHead, vertexNext)
  local vertex;

  # Traverse the partition and update the head for its vertices.
  vertex := head;
  while vertex > 0 do
    vertexHead[vertex] := head; # TODO might be able to stop early.
    vertex := vertexNext[vertex];
  od;
end;

MSTP_REC.findMinEdge := function(graph, head, vertexHead, vertexNext, vertexTail, vertexEdge)
  local vertex, minWeight, minStart, minEnd, weight, successor, successors, tmp, minEdge;

  # Check all vertices in the partition to find the min edge.
  vertex := head;
  while vertex > 0 do
    
    successors := VertexSuccessorsP(graph, vertex);
    if vertexEdge[vertex] <= Length(successors) then
    
      successor := successors[vertexEdge[vertex]];
      if vertexHead[vertex] <> vertexHead[successor] then

        # Pick the next sorted edge for this vertex.
        weight := GetWeightP(graph, vertex, vertexEdge[vertex]);

        # Update min if needed.
        if IsBound(minWeight) = false or weight < minWeight then
          minWeight := weight;
          minStart := vertex;
          minEnd := successor;
        fi;
      else

        # "Remove" the edge creating a loop.
        vertexEdge[vertex] := vertexEdge[vertex] + 1;
      fi;
    fi;

    vertex := vertexNext[vertex];
  od;

  if IsBound(minStart) then

    # "Remove" the pikced edge.
    vertexEdge[minStart] := vertexEdge[minStart] + 1;

    # To avoid loops when adding same edge twice.
    if minStart > minEnd then
      tmp := minStart;
      minStart := minEnd;
      minEnd := tmp;
    fi;
    
    minEdge := [minStart, minEnd];
    MakeImmutable(minEdge);
    return minEdge;
  else
    return false;
  fi;
end;
