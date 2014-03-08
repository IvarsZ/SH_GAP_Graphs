# Record for private members.
ColorVerticesP_REC := rec();

InstallGlobalFunction(ColorVerticesP, function(graph, numberOfColours)
  local order, colouring, orderIndex, vertex, isColourUsed, successor;

  order := ColorVerticesP_REC.orderVertices(graph, numberOfColours);
  MakeImmutable(order);

  colouring := EmptyPlist(VertexCountP(graph));
  MakeImmutable(colouring);

  colouring := ColorVerticesP_REC.colourVertex(graph, numberOfColours, order, colouring, 1);
  colouring := ShallowCopy(colouring);

  if colouring <> false then
    # Greedy colour the rest low degree vertices.
    # Loop over part of a list.
    for orderIndex in [(order[2]+1)..Length(order[1])] do

      vertex := order[1][orderIndex];
      isColourUsed := BlistList([1..numberOfColours], []);
      for successor in VertexSuccessorsP(graph, vertex) do
        if IsBound(colouring[successor]) then
          isColourUsed[colouring[successor]] := true;
        fi;
      od;
      
      colouring[vertex] := Position(isColourUsed, false);
    od;
  fi;

  return colouring;
end);

ColorVerticesP_REC.colourVertex := function(graph, numberOfColours, order, colouring, vertexIndex)
  local colour, isValid, successor, vertex, task, tasks, colouringCopy, taskIndex, result;

  if vertexIndex > order[2] then
    return colouring;
  fi;

  tasks := [];
  vertex := order[1][vertexIndex];

  for colour in [1..numberOfColours] do
    isValid := true;
    for successor in VertexSuccessorsP(graph, vertex) do
      if IsBound(colouring[successor]) and colouring[successor] = colour then
        isValid := false;
        break;
      fi;
    od;

    if isValid  = true then
      colouringCopy := ShallowCopy(colouring);
      colouringCopy[vertex] := colour;
      MakeImmutable(colouringCopy);
      task := RunTask(ColorVerticesP_REC.colourVertex, graph, numberOfColours, order, colouringCopy, vertexIndex + 1);
      Add(tasks, task);
    fi;
  
    WaitTasks(tasks);
    for task in tasks do
      result := TaskResult(task);
      if result <> false then
        return result;
      fi;
    od;
 
    return false;
  od;
end;

# TODO if keeping wait for all, then don't create new task for last colour.
# TODO bunch few last vertices together.

# Preordes vertices for coluring a graph by taking the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
ColorVerticesP_REC.orderVertices := function(graph, numberOfColours)
 local order, position, isOrderChanged, degrees, verticesToOrderEnd, i, vertex, successor; 
 
  # Have a list of vertex degrees and their order.
  order := EmptyPlist(VertexCountP(graph));
  degrees := EmptyPlist(VertexCountP(graph));
  for vertex in [1..VertexCountP(graph)] do
    order[vertex] := vertex;
    degrees[vertex] := Length(VertexSuccessorsP(graph, vertex));
  od;

  verticesToOrderEnd := VertexCountP(graph);

  # Try to reorder vertices untill no more reordering was done.
  isOrderChanged := true;
  while (isOrderChanged) do
    isOrderChanged := false;

    # For each vertex that has not been ordered, yet.
    i := 1;
    while (i <= verticesToOrderEnd) do
      vertex := order[i];

      # If it has few enough unordered adjacent vertices,
      if (degrees[vertex] < numberOfColours) then

        # colour it last - order it at the end.
        order[i] := order[verticesToOrderEnd];
        order[verticesToOrderEnd] := vertex;

        # Now each adjacent vertex has one less unordered adjacent vertex.
        for successor in VertexSuccessorsP(graph, vertex) do
          degrees[successor] := degrees[successor] - 1;
        od;

        verticesToOrderEnd := verticesToOrderEnd - 1;
        isOrderChanged := true;

      else
        i := i + 1;
      fi;
    od;
  od;

  return [order, verticesToOrderEnd];
end;
