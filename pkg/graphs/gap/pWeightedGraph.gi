# Record for private members.
PWGRAPH := rec();
PWGRAPH.PMST := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexNext, vertexTail, head, heads, newHeads, vertex, task, tasks, head1, head2, tmp, edge, edges, vertexEdge;

  edges := [];

  vertexCount := VertexCount(graph);
  vertexHead := EmptyPlist(vertexCount); 
  vertexNext := EmptyPlist(vertexCount);
  vertexTail := EmptyPlist(vertexCount);

  vertexEdge := FixedAtomicList(vertexCount);

  heads := EmptyPlist(vertexCount);
  for vertex in [1..vertexCount] do
    heads[vertex] := vertex;
    vertexHead[vertex] := vertex;
    vertexTail[vertex] := vertex;
    vertexNext[vertex] := 0;
    vertexEdge[vertex] := 1;

    # Sort edges. TODO parallel.
    SortParallel(graph!.weights[vertex], graph!.successors[vertex]); 
  od;

  ShareObj(graph!.successors);
  ShareObj(graph!.weights);

  ShareObj(vertexHead);
  ShareObj(vertexNext);
  ShareObj(vertexTail);

  # TODO make atomic vs shared.
  # TODO change serial mst to edges.

  while Length(heads) > 1 do
    tasks := [];
    for head in heads do
      task := RunTask(PWGRAPH.PMST.findMinEdge, graph, head, vertexHead, vertexNext, vertexTail, vertexEdge);
      Add(tasks, task);
    od;

    WaitTasks(tasks);

    # Change heads and join the lists. # TODO maybe in parallel?
    atomic vertexHead, vertexNext, vertexTail do
      for task in tasks do
        
        edge := TaskResult(task);
        if edge = false then
          continue;
        fi;

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
      od;
    od;
    
    # Traverse the partition lists and update heads for it. TODO in parallel.
    atomic vertexHead, vertexTail, readonly vertexNext do
      newHeads := [];
      for head in heads do 
        if vertexHead[head] = head then
        
          Add(newHeads, head);
        
          vertex := head;
          while vertex > 0 do
            vertexHead[vertex] := head; # TODO might be able to stop early.
            vertex := vertexNext[vertex];
          od;
        fi;
      od;
    od;

    if Length(heads) = Length(newHeads) then
      break;
    fi;

    heads := newHeads;
  od;

  return edges;
end);

PWGRAPH.PMST.findMinEdge := function(graph, head, vertexHead, vertexNext, vertexTail, vertexEdge)
  local vertex, minWeight, minStart, minEnd, weight, successor, successors, tmp;

  atomic readonly graph!.successors, graph!.weights, vertexHead, vertexNext do

    # Check all vertices in the partition to find the min edge.
    vertex := head;
    while vertex > 0 do
      
      successors := VertexSuccessors(graph, vertex);
      if vertexEdge[vertex] <= Length(successors) then
      
        successor := successors[vertexEdge[vertex]];
        if vertexHead[vertex] <> vertexHead[successor] then

          # Pick the next sorted edge for this vertex.
          weight := GetWeight(graph, vertex, vertexEdge[vertex]);

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
    
    return [minStart, minEnd];
  else
    return false;
  fi;
end; 
