#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(BFS, function(graph, start)
  local queue, queueStart, isVisited, order, current, successor, depth;

  # Both isVisited and order lists will have as many elements as vertices.
  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));
  
  # Start is the first vertex traversed.
  queue := [start, -1];
  queueStart := 1;
  isVisited[start] := true;
  depth := -1;

  # While there are vertices in the queue,
  while (Length(queue) >= queueStart) do
  
    # Dequeue a vertex.
    current := queue[queueStart];
    queueStart := queueStart + 1;
    if (current > 0) then

      # Add it to the order.
      Add(order, current);

      # Enqueue its successors.
      for successor in VertexSuccessors(graph, current) do
        if isVisited[successor] = false then
          
          Add(queue, successor);
          isVisited[successor] := true;
        fi;
      od;
    else

      depth := depth + 1;
      if (queueStart <= Length(queue)) then
        Add(queue, -1);
      fi;
    fi;
  od; 

  return [order, depth];
end);
