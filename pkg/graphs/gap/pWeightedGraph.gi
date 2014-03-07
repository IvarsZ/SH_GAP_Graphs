# Record for private members.
PWGRAPH := rec();
PWGRAPH.PMST := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexNext, vertexTail, head, heads, newHeads, vertex, task, tasks, head1, head2, tmp, edge, edges;

  edges := [];

  vertexCount := VertexCount(graph);
  vertexHead := EmptyPlist(vertexCount); 
  vertexNext := EmptyPlist(vertexCount);
  vertexTail := EmptyPlist(vertexCount);

  heads := EmptyPlist(vertexCount);
  for vertex in [1..vertexCount] do
    heads[vertex] := vertex;
    vertexHead[vertex] := vertex;
    vertexTail[vertex] := vertex;
    vertexNext[vertex] := 0;
  od;

  ShareObj(graph!.successors);
  ShareObj(graph!.weights);

  ShareObj(vertexHead);
  ShareObj(vertexNext);
  ShareObj(vertexTail);

  # TODO make atomic or shared tree, treeParents...
  # TODO change serial mst to make the tree traversable???

  # TODO doesn't work for forests.
  while Length(heads) > 1 do
    tasks := [];
    for head in heads do
      task := RunTask(PWGRAPH.PMST.findMinEdge, graph, head, vertexHead, vertexNext, vertexTail);
      Add(tasks, task);
    od;

    WaitTasks(tasks);

    # Change heads and join the lists. # TODO maybe in parallel?
    atomic vertexHead, vertexNext, vertexTail do
      for task in tasks do
        
        edge := TaskResult(task);
        Print("e ", edge, "\n");
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
        
          Print("After merging\n");
          Print("h ", vertexHead, "\n");
          Print("t ", vertexTail, "\n");
          Print("n ", vertexNext, "\n");
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
      
      Print("After traverse\n");
      Print("h ", vertexHead, "\n");
      Print("t ", vertexTail, "\n");
      Print("n ", vertexNext, "\n");
      Print("heads ", newHeads, "\n");
    od;

    if Length(heads) = Length(newHeads) then
      break;
    fi;

    heads := newHeads;
  od;

  return edges;
end);

PWGRAPH.PMST.findMinEdge := function(graph, head, vertexHead, vertexNext, vertexTail)
  local vertex, minWeight, minStart, minEnd, weight, successor, tmp;

  atomic readonly graph!.successors, graph!.weights, vertexHead, vertexNext do

    vertex := head;
    while vertex > 0 do
      for successor in VertexSuccessors(graph, vertex) do
        if vertexHead[vertex] <> vertexHead[successor] then
          weight := GetWeightedEdge(graph, vertex, successor); # TODO inefficient, store old.
          if IsBound(minWeight) = false or weight < minWeight then
            minWeight := weight;
            minStart := vertex;
            minEnd := successor;
          fi;
        fi;
      od;

      vertex := vertexNext[vertex];
    od;
  od;

  if IsBound(minStart) then

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
