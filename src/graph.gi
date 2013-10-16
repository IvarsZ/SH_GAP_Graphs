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
  order := [];

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
  order := [];
  
  queue := [start]; # TODO make of right size.
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
  local vertex, colouring, colourCounts, colour;

  # Colour counts, colouring all to 0.

  return b;
end);
