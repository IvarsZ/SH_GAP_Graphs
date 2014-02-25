# Record for private members.
PWGRAPH := rec();
PWGRAPH.PMST := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local tree, bags, bag, bagIndex, vertexBags, vertex, task, tasks, edge, isStartSet, isEndSet;

  treeParent := EmptyPList(VertexCount(graph));

  bags := []; # Each element has head and tail of the list.
  vertexHead := EmptyPList(VertexCount(graph)); 
  vertexNext := EmptyPList(VertexCount(graph));

  for vertex in VertexCount(graph) do
    vertexHead[vertex] := vertex;
    Add(bags, [vertex, vertex]);
  od;

  ShareObj(graph!.successors);
  ShareObj(graph!.weights);

  # TODO make atomic or shared tree, treeParent...
  # TODO change serial mst to make the tree traversable???

  # TODO doesn't work for forests.
  while Length(tree) > 1 do
  
    tasks := [];
    for parent in bags do
      task := RunTask(findMinEdge, graph, bag, vertexBags);
    od;

    newVertexBags := EmptyPList(VertexCount(graph));
    newBags := [];

    WaitTasks(tasks);
    for task in tasks do
      edge := TaskResult(task);
      if edge[2] < edge[1] then
        tmp := edge[1];
        edge[1] := edge[2];
        edge[2] := tmp;
      fi;

      head1 := vertexHead[edge[1]];
      head2 := vertexHead[edge[2]];   
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
