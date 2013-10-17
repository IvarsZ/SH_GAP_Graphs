DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["successors"]);

InstallGlobalFunction(Graph, function(successors)

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := successors));
end); 

InstallGlobalFunction(EmptyGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := []));
end);

# PRIVATE FUNCTIONS AND VARIABLES RECORD
GRAPH := rec();

InstallGlobalFunction(AddVertex, function(graph)

  Add(graph!.successors, []);
end);

InstallGlobalFunction(AddEdge, function(graph, start, end_)

  Add(VertexSuccessors(graph, start), end_);
end);

InstallGlobalFunction(VertexSuccessors, function(graph, vertex)

  return graph!.successors[vertex];
end);

InstallGlobalFunction(VertexCount, function(graph)

  return Length(graph!.successors);
end);

InstallGlobalFunction(DFS, function(graph, start)
  local stack, stackTop, isVisited, order, current, successor;

  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));

  stack := [start];
  stackTop := 1;
  isVisited[start] := true;

  while (stackTop > 0) do
    
    current := stack[stackTop];
    stackTop := stackTop - 1;
   
    Add(order, current);

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

InstallGlobalFunction(BFS, function(graph, start)
  local queue, queueStart, isVisited, order, current, successor;

  isVisited := BlistList([1..VertexCount(graph)], []);
  order := EmptyPlist(VertexCount(graph));
  
  queue := [start];
  queueStart := 1;
  isVisited[start] := true;
  
  while (Length(queue) >= queueStart) do
    
    current := queue[queueStart];
    queueStart := queueStart + 1;
    Add(order, current);

    for successor in VertexSuccessors(graph, current) do
      if isVisited[successor] = false then
        Add(queue, successor);
        isVisited[successor] := true;
      fi;
    od;
  od; 

  return order;
end);

InstallGlobalFunction(GetColouring, function(graph, numberOfColours)
local vertex, colouring, colourCounts, colour, successor, isClash, v;

  vertex := 1;
  colouring := EmptyPlist(VertexCount(graph));
  colourCounts := EmptyPlist(numberOfColours);

  for colour in [1..numberOfColours] do
    colourCounts[colour] := 0;
  od;

  for v in [1..VertexCount(graph)] do
    colouring[v] := -1;
  od;
  
  colouring[1] := 1;
  colourCounts[1] := 1;

  while (vertex < VertexCount(graph)) do

    #Print(vertex);
    #Print("\n");
    # Check for colour clash.
    isClash := false;
    for successor in VertexSuccessors(graph, vertex) do
      if (colouring[vertex] = colouring[successor]) then
        isClash := true;
        # BREAK !!!
      fi;
    od;

    if (isClash) then
      
      colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] - 1;
      colouring[vertex] := colouring[vertex] + 1;
      
      #Print(colourCounts[colouring[vertex]]);
      #Print("\n");
      #Print(colouring[vertex]);
      #Print( "\n");
      while (colourCounts[colouring[vertex] - 1] = 0 or
             colouring[vertex] = numberOfColours + 1) do

        if (vertex = 1) then
          return false;
        else
          vertex := vertex - 1;
        fi;

        colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] - 1;
        colouring[vertex] := colouring[vertex] + 1;
      od;

      colourCounts[colouring[vertex]] := colourCounts[colouring[vertex]] + 1;
    else
      vertex := vertex + 1;
      if (vertex <= VertexCount(graph)) then
        colouring[vertex] := 1;
        colourCounts[1] := colourCounts[1] + 1;
      fi;
    fi;
  od;

  return colouring;
end);

SCC_DFS := function(graph, vertex)

  topOfS := topOfS + 1;
  S[topOfS] := vertex;

  Print(I);
  Print("\n");
  Print(S);
  Print("\n");

  I[vertex] := S[topOfS];
  topOfB := topOfB + 1;
  B[topOfB] := I[vertex];

  for successor in VertexSuccessors(graph, vertex) do
    if (I[successor] = 0) then
      SCC_DFS(graph, successor);
    else
      while (I[successor] < B[topOfB]) do
        topOfB := topOfB - 1;
      od;
    fi;
  od;

  if (I[vertex] = B[topOfB]) then
    topOfB := topOfB - 1;
    c := c + 1;
    while (topOfS > 0 and I[vertex] <= S[topOfS]) do
      I[S[topOfS]] := c;
      topOfS := topOfS - 1;
    od;
  fi;
end;

# Uses Gabow's algorihtm.
InstallGlobalFunction(GetStrongComponents, function(graph)

  S := [];
  B := [];
  topOfS := 0;
  topOfB := 0;

  I := EmptyPlist(VertexCount(graph));
  for vertex in [1..VertexCount(graph)] do
    I[vertex] := 0;
  od;

  c := VertexCount(graph);
  for vertex in [1..VertexCount(graph)] do
    if (I[vertex] = 0) then
      SCC_DFS(graph, vertex);
    fi;
  od;

  return I;
end);
