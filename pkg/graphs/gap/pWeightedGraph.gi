# Record for private members.
PWGRAPH := rec();
PWGRAPH.PMST := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, treeParents, vertexHead, vertexNext, vertexTail, head, heads, newHeads, vertex, task, tasks;

  vertexCount := VertexCount(graph);
  treeParents := EmptyPlist(vertexCount);

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

  # TODO make atomic or shared tree, treeParents...
  # TODO change serial mst to make the tree traversable???

  # TODO doesn't work for forests.
  while Length(heads) > 1 do
    Print(vertexHead, "\n");
  
    tasks := [];
    for head in heads do
      task := RunTask(PWGRAPH.PMST.findMinEdge, graph, head, vertexHead, vertexNext, vertexTail, treeParents);
    od;

    WaitTasks(tasks);
    
    # Traverse the partition lists and update heads for it. TODO in parallel.
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

    heads := newHeads;
  od;

  return treeParents;
end);

PWGRAPH.PMST.findMinEdge := function(graph, head, vertexHead, vertexNext, vertexTail, treeParents)
  local vertex, minWeight, minStart, minEnd, weight, tmp, successor;

  atomic readonly graph!.successors, graph!.weights do

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

  #if minStart > minEnd then
  #  tmp := minStart;
  #  minStart := minEnd;
  #  minEnd := tmp;
  #fi;

  # Change heads and join the lists.
  vertexHead[minEnd] := vertexHead[minStart];
  tmp := vertexNext[minStart];
  vertexNext[minStart] := minEnd;
  vertexNext[vertexTail[minEnd]] := tmp;
  vertexTail[minEnd] := vertexTail[minStart];

  treeParents[minEnd] := minStart;
end; 
