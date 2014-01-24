# Record for private functions.
PGRAPH := rec();

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(PBFS, function(graph, start)
  local inbag, outbag, isVisited, order, vertex, task, tasks;

  # Both isVisited and order lists will have as many elements as vertices.
  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));
  
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
    od;
    WaitTask(tasks);
    inbag := outbag;
  od; 

  return order;
end);

PGRAPH.visitVertex := atomic function(readonly graph, readonly vertex, outbag, order, isVisited)
  local successor;

  # Add vertex to the order.
  Add(order, vertex);

  # Enqueue its successors.
  for successor in VertexSuccessors(graph, vertex) do
    if isVisited[successor] = false then
      Add(outbag, successor);

      isVisited[successor] := true;
    fi;
  od;
end;
