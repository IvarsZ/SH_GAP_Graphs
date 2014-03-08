# Record for private functions.
Color_REC := rec();

# Preordes vertices for coloring a graph by taking the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
Color_REC.orderVerticesForColoring := function(graph, numberOfColours)
 local order, position, isOrderChanged, degrees, verticesToOrderEnd, i, vertex, successor; 
 
  # Have a list of vertex degrees and their order.
  order := EmptyPlist(VertexCount(graph));
  degrees := EmptyPlist(VertexCount(graph));
  for vertex in [1..VertexCount(graph)] do
    order[vertex] := vertex;
    degrees[vertex] := Length(VertexSuccessors(graph, vertex));
  od;

  verticesToOrderEnd := VertexCount(graph);
  
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
        for successor in VertexSuccessors(graph, vertex) do
          degrees[successor] := degrees[successor] - 1;
        od;

        verticesToOrderEnd := verticesToOrderEnd - 1;
        isOrderChanged := true;

      else
        i := i + 1;
      fi;
    od;
  od;

  return order;
end;

#
# Returns a list of colours for each vertex for the given graph and the given maximal number of colours
# to use, or false otherwise.
#
InstallGlobalFunction(ColorVertices, function(graph, numberOfColours)
  local vertex, vertexIndex, colouring, colourCounts, colour, successor, isClash, order;

  order := Color_REC.orderVerticesForColoring(graph, numberOfColours);

  # Have list for assigned colours and the number of times each colour has been used.
  colouring := EmptyPlist(VertexCount(graph));
  colourCounts := EmptyPlist(numberOfColours);

  for colour in [1..numberOfColours] do
    colourCounts[colour] := 0;
  od;

  for vertex in [1..VertexCount(graph)] do
    colouring[vertex] := -1;
  od;

  # Start with the first vertex of the order and colour it with colour 1.
  vertex := order[1];
  colouring[vertex] := 1;
  colourCounts[1] := 1;
  vertexIndex := 1;

  # While there are still vertices left to colour,
  while (vertexIndex <= VertexCount(graph)) do

    vertex := order[vertexIndex];

    # Check if no two adjacent vertices have the same colour,
    isClash := false;
    for successor in VertexSuccessors(graph, vertex) do
      
      if (colouring[vertex] = colouring[successor]) then
        isClash := true;
        break;
      fi;
    od;

    if (isClash) then
  
      # Try the next colour.
      colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] - 1;
      colouring[vertex] := colouring[vertex] + 1;
      
      # Keep backtracking if the clash is due to other vertex or we're out of colours.
      while (colourCounts[colouring[vertex] - 1] = 0 or
             colouring[vertex] = numberOfColours + 1) do
 
        # If there are no more vertices to backtrack,
        if (vertexIndex = 1) then
          
          # no colouring exists.
          return false;
        else

          # otherwise backtract one more vertex.
          vertexIndex := vertexIndex - 1;
          vertex := order[vertexIndex];
        fi;

        colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] - 1;
        colouring[vertex] := colouring[vertex] + 1;
      od;

      colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] + 1;
    else

      # If there is no clash, colour the next vertex and repeat.
      vertexIndex := vertexIndex + 1;
      if (vertexIndex <= VertexCount(graph)) then
        colouring[order[vertexIndex]] := 1;
        colourCounts[1] := colourCounts[1] + 1;
      fi;
    fi;
  od;

  return colouring;
end);
