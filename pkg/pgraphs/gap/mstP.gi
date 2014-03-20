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

  while Length(heads) > 1 do

    Print(heads, "\n");
    Print(FromAtomicList(vertexHead), "\n");
    Print(FromAtomicList(vertexNext), "\n");
    
    # Find min edges.
    tasks := [];
    for head in heads do
      task := RunTask(MSTP_REC.findMinEdge, graph, head, vertexHead, vertexNext, vertexTail, vertexEdge);
      Add(tasks, task);
      #MSTP_REC.findMinEdge(graph, head, vertexHead, vertexNext, vertexTail, vertexEdge);
    od;
    WaitTasks(tasks);

    Print("FOUND MIN EDGES\n");

    # Join the edges by changing heads and merging the lists.
    tasks2 := [];
    for task in tasks do  
      edge := TaskResult(task);
      if edge <> false then
        #task2 := RunTask(MSTP_REC.mergeHeads, edge, vertexHead, vertexNext, vertexTail, edges); 
        #Add(tasks2, task2);
        Print(edge, "\n");
        MSTP_REC.mergeHeads(edge, vertexHead, vertexNext, vertexTail, edges);
        Print(FromAtomicList(vertexHead), "\n");
        Print(FromAtomicList(vertexNext), "\n");
      fi;
    od;
    #WaitTasks(tasks2);
    # TODO doesn't work when not in parallel?

    Print("MERGED HEADS\n");
    Print(FromAtomicList(vertexHead), "\n");
    Print(FromAtomicList(vertexNext), "\n");
    
    # Update heads list and get the new heads.
    tasks := [];
    newHeads := [];
    for head in heads do 
      if vertexHead[head] = head then
        
        Add(newHeads, head);
        #task := RunTask(MSTP_REC.updateHeads, head, vertexHead, vertexNext);
        #Add(tasks, task);
        MSTP_REC.updateHeads(head, vertexHead, vertexNext);
      fi;
    od;
    
    Print("GOT NEW HEADS\n");

    if Length(heads) = Length(newHeads) then
      break;
    fi;
    heads := newHeads;

    Print(heads, "\n");
    Print(FromAtomicList(vertexHead), "\n");

    #WaitTasks(tasks);
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
  atomic readwrite vertexHead, vertexNext, vertexTail do
    head1 := vertexHead[vertexHead[edge[1]]];
    head2 := vertexHead[vertexHead[edge[2]]];

    if head1 <> head2 then

      # TODO To avoid loops when adding same edge twice???
      if head1 > head2  then
        tmp := head1;
        head1 := head2;
        head2 := tmp;
      fi;

      Print("merging ", head1, " and ", head2, "\n");
      Add(edges, edge);
      vertexHead[edge[2]] := head1;
      vertexHead[head2] := head1;
      vertexHead[edge[1]] := head1;

      tmp := vertexNext[head1];
      vertexNext[head1] := head2;
      vertexNext[vertexTail[head2]] := tmp;

      if tmp <= 0 then
        vertexTail[head1] := vertexTail[head2];
      fi;
    fi;
  od;
end;

MSTP_REC.updateHeads := function(head, vertexHead, vertexNext)
  local vertex;

  # Traverse the partition and update the head for its vertices.
  vertex := head;
  while vertex > 0 do    
    vertexHead[vertex] := head;
    vertex := vertexNext[vertex];
  od;
end;

MSTP_REC.findMinEdge := function(graph, head, vertexHead, vertexNext, vertexTail, vertexEdge)
  local vertex, minWeight, minStart, minEnd, weight, successor, successors, tmp, minEdge;

  # Check all vertices in the partition to find the min edge.
  vertex := head;
  while vertex > 0 do
    
    successors := VertexSuccessorsP(graph, vertex);
    while vertexEdge[vertex] <= Length(successors) do
    
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

        break;
      else

        # "Remove" the edge creating a loop.
        vertexEdge[vertex] := vertexEdge[vertex] + 1;
      fi;
    od;

    vertex := vertexNext[vertex];
  od;

  if IsBound(minStart) then

    # "Remove" the picked edge.
    vertexEdge[minStart] := vertexEdge[minStart] + 1;
    
    minEdge := [minStart, minEnd];
    MakeImmutable(minEdge);
    return minEdge;
  else
    return false;
  fi;
end;
