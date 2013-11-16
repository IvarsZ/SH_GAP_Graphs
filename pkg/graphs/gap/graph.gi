#! @Chapter Graphs
#! @Section Graphs

#! @Description
#!
#! An adjacency list for graphs is a record where each vertex v has list of end vertices for each edge starting at v.
#!
DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["successors"]);

# Record for private functions.
GRAPH := rec();

InstallGlobalFunction(Graph, function(successors)

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := successors));
end); 

InstallGlobalFunction(EmptyGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := []));
end);

#
# Adds a new vertex to the given graph.
#
InstallGlobalFunction(AddVertex, function(graph)

  # New vertex has no successors.
  Add(graph!.successors, []);
end);

#
# Adds an edge to the given graph from the given start vertex to the given end vertex.
#
InstallGlobalFunction(AddEdge, function(graph, start, end_)

  # The end vertex becomes a successor of the start vertex, as the edge connects them.
  Add(VertexSuccessors(graph, start), end_);
end);

#
# Returns successor vertices of the given vertex in the given graph.
#
InstallGlobalFunction(VertexSuccessors, function(graph, vertex)

  return graph!.successors[vertex];
end);

#
# Returns the number of vertices in the given graph.
#
InstallGlobalFunction(VertexCount, function(graph)

  return Length(graph!.successors);
end);

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

  # While there vertices in the stack,
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

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(BFS, function(graph, start)
  local queue, queueStart, isVisited, order, current, successor;

  # Both isVisited and order lists will have as many elements as vertices.
  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));
  
  # Start is the first vertex traversed.
  queue := [start];
  queueStart := 1;
  isVisited[start] := true;
  
  # While there are vertices in the queue,
  while (Length(queue) >= queueStart) do
    
    # dequeue a vertex and it to the order.
    current := queue[queueStart];
    queueStart := queueStart + 1;
    Add(order, current);

    # Enqueue its successors.
    for successor in VertexSuccessors(graph, current) do
      if isVisited[successor] = false then
        Add(queue, successor);

        isVisited[successor] := true;
      fi;
    od;
  od; 

  return order;
end);

# Preordes vertices for coluring a graph by taking the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
GRAPH.orderVerticesForColouring := function(graph, numberOfColours)
 local order, position, isOrderChanged, degrees, verticesToOrderEnd, i, vertex, successor; 
 
  # Have a list vertex degrees, their order and their position in the order.
  order := EmptyPlist(VertexCount(graph));
  position := EmptyPlist(VertexCount(graph));
  degrees := EmptyPlist(VertexCount(graph));
  for vertex in [1..VertexCount(graph)] do
    order[vertex] := vertex;
    position[vertex] := vertex;
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
        position[verticesToOrderEnd] := position[vertex];
        position[vertex] := verticesToOrderEnd;
        order[position[verticesToOrderEnd]] := order[verticesToOrderEnd];
        order[position[vertex]] := vertex;

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
InstallGlobalFunction(GetColouring, function(graph, numberOfColours)
  local vertex, vertexIndex, colouring, colourCounts, colour, successor, order, isClash;

  order := GRAPH.orderVerticesForColouring(graph, numberOfColours);

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

# 
# Finds strongly connected components of the given graph.
#
# It returns a list where each vertex is assigned its strongly connected components number,
# the numbering starts from the largest index of a vertex + 1.
#
InstallGlobalFunction(GetStrongComponents, function(graph)
  local S, topOfS, B, topOfB, I, c, vertex, SCC_DFS;

  S := []; # Stack of visited vertices in one dfs run.
  B := []; # Stack of weekly visited vertices (only one direction).
  topOfS := 0;
  topOfB := 0;

  I := EmptyPlist(VertexCount(graph)); # Lists the components index for each vertex.
  for vertex in [1..VertexCount(graph)] do
    I[vertex] := 0;
  od;

  # Recursive depth first search for finding components.
  SCC_DFS := function(graph, vertex)
    local successor;

    # The vertex is visited now so push it to S and B.
    topOfS := topOfS + 1;
    S[topOfS] := vertex;
    topOfB := topOfB + 1;
    B[topOfB] := vertex;

    # Temporarely mark the vertex as in its own componentt
    I[vertex] := vertex;

    for successor in VertexSuccessors(graph, vertex) do
      
      # Run dfs on all unvisited successor vertices recursively.
      if (I[successor] = 0) then
        SCC_DFS(graph, successor);
      else
        
        # If the successor has been visited, cutoff the path after it from B.
        while (I[successor] < B[topOfB]) do
          topOfB := topOfB - 1;
        od;
      fi;
    od;

    # If there was no cutoff, 
    if (I[vertex] = B[topOfB]) then

      # the vertex is in a new component.
      topOfB := topOfB - 1;
      c := c + 1;

      # So add all visited vertices after the vertex to the component.
      while (topOfS > 0 and I[vertex] <= S[topOfS]) do
        I[S[topOfS]] := c;
        topOfS := topOfS - 1;
      od;
    fi;
  end; # End of recursive dfs.

  # Run dfs for each unvisited vertex.
  c := VertexCount(graph);
  for vertex in [1..VertexCount(graph)] do
    if (I[vertex] = 0) then
      SCC_DFS(graph, vertex);
    fi;
  od;

  return I;
end);
