# Record for private functions.
PGRAPH := rec();

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(PBFS, function(graph, start)
  local inbag, outbag, isVisited, order, vertex, task, tasks;

  # Locks.
  order := [];
  ShareObj(graph!.successors, order);
  atomic readonly graph!.successors do

    # Both isVisited and order lists will have as many elements as vertices.
    isVisited := BlistList([1..VertexCount(graph)], []);
    #order := EmptyPlist(VertexCount(graph));
    
    # Start is the first vertex traversed.
    inbag := [start];
    isVisited[start] := true;
    
    # While there are vertices in the bag,
    while (Length(inbag) > 0) do

      # visit all vertices in the current layer.
      outbag := [];
      tasks := [];
      for vertex in inbag do
        task := RunTask(PGRAPH.visitVertex, graph, vertex, outbag, order, isVisited);
        Add(tasks, task);
        WaitTask(task);
        Print(outbag, "\n");
      od;
      for task in tasks do
        Append(outbag, TaskResult(task));
      od;
      inbag := outbag;
    od;
  od;

  return order;
end);

PGRAPH.visitVertex := function(graph, vertex, outbag, order, isVisited)
  local successor;
  atomic readonly graph!.successors do

    # Add vertex to the order.
    Add(order, vertex);
    Print(vertex, "\n");
    Print(isVisited, "\n");

    # Enqueue its successors.
    for successor in VertexSuccessors(graph, vertex) do
      if isVisited[successor] = false then
        Add(outbag, successor);

        isVisited[successor] := true;
      fi;
    od;
  od;

  return outbag;
end;
