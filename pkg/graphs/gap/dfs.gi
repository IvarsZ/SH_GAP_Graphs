#
# Returns the vertices of the given graph in a depth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(DFS, function(graph, start)
  local stack, stackTop, isVisited, order, current, successor;

  # Both isVisited and order lists will have as many elements as vertices.
  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));

  # Start is the first vertex traversed.
  stack := [start];
  stackTop := 1;
  isVisited[start] := true;

  # While there are vertices in the stack,
  while (stackTop > 0) do
    
    # pop a vertex and add it to the order,
    current := stack[stackTop];
    stackTop := stackTop - 1;
    Add(order, current);

    # and push all its successors on the stack.
    for successor in VertexSuccessors(graph, current) do
      if isVisited[successor] = false then
        stackTop := stackTop + 1;
        stack[stackTop] := successor;

        isVisited[successor] := true;
      fi;
    od;  
  od;

  return order;
end);
