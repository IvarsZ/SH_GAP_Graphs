# Record for private members.
PWGRAPH := rec();
PWGRAPH.PMST := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local tree, bags, bag, bagIndex, vertexBags, vertex, task, tasks, edge, isStartSet, isEndSet;

  tree := EmptyPList(VertexCount(graph));

  vertexBags := EmptyPList(VertexCount(graph));
  bags := EmptyPList(VertexCount(graph)); 
  for vertex in VertexCount(graph) do
    bags[vertex] := [vertex];
    vertexBags[vertex] := vertex;
  od;

  ShareObj(graph!.successors);
  ShareObj(graph!.weights);

  # TODO doesn't work for forests.
  while Length(bags) > 1 do
  
    # TODO atomic vs immutable for bags and vertexBags.
    MakeImmutable(vertexBags);
    MakeImmutable(bags);

    tasks := [];
    for bag in bags do
      task := RunTask(findMinEdge, graph, bag, vertexBags);
    od;

    newVertexBags := EmptyPList(VertexCount(graph));
    newBags := [];

    WaitTasks(tasks);
    for task in tasks do
      edge := TaskResult(task);
      isStartSet := IsBound(newVertexBags[edge[1]]);
      isEndSet := IsBound(newVertexBags[edge[2]]);
      if isStartSet and not isEndSet then
        bagIndex := newVertexBags[edge[1]];
        newVertexBags[edge[2]] := bagIndex;
        Add(newBags[bagIndex], edge[2]); 
      elif isEndSet and not isStartSet then
        bagIndex := newVertexBags[edge[2]];
        newVertexBags[edge[1]] := bagIndex;
        Add(newBags[bagIndex], edge[1]);
      elif not isStartSet and not isEndSet then
        Add(newBags, [edge[1], edge[2]]);
        newVertexBags[edge[1]] := Length(newBags);
        newVertexBags[edge[2]] := Length(newBags);
      fi;
      tree[edge[2]] := edge[1];
    od;

    vertexBags := newVertexBags;
    bags := newBags;
  od;

  # find min. #TODO remember next eligible vertex.
  # connect-components, make 
  # compact graph.

  return tree;
end);

PWGRAPH.PMST.findMinEdge := function(graph, bag, vertexBags)
  local vertex, minWeight, minStart, minEnd, weight;

  atomic readonly graph!.successors, graph!.weights do
    minWeigth := true;
    for vertex in bag do
      for successor in VertexSuccessors(graph, vertex) do
        if vertexBags[vertex] <> vertexBags[successor] then
          weight := GetWeightedEdge(graph, vertex, successor);
          if minWeight or weight < minWeight then
            minWeight := weight;
            minStart := vertex;
            minEnd := successor;
          fi;
        fi;
      od;
    od;
  od;

  return [minStart, minEnd];
end; 
