DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["vertices"]);

InstallGlobalFunction(Graph, function(vertices)

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(vertices := vertices));
end); 

InstallGlobalFunction(EmptyGraph,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(vertices := []));
end);

# PRIVATE FUNCTIONS AND VARIABLES RECORD
GRAPH := rec();

InstallGlobalFunction(AddVertex, function(graph)

  Add(graph!.vertices, []);
  return Length(graph!.vertices);
end);

InstallGlobalFunction(AddEdge, function(graph, startIndex, endIndex)

  Add(graph!.vertices[startIndex], endIndex);
end);

InstallGlobalFunction(DFS, function(graph, start)
  local stack, stackTop, isVisited, order, current, successor;

  isVisited := BlistList([1..Length(graph!.vertices)], []);
  order := [];

  stack := [start];
  stackTop := 1;

  while (stackTop > 0) do
    
    current := stack[stackTop];
    stackTop := stackTop - 1;
   
    Add(order, current);
    isVisited[current] := true;

    for successor in graph!.vertices[current] do
      if isVisited[successor] = false then
        stackTop := stackTop + 1;
        stack[stackTop] := successor;
      fi;
    od;  
  od;

  return order;
end);

InstallGlobalFunction(BFS, function(graph, start)
  local queue, queueStart, isVisited, order, current, successor;

  isVisited := BlistList([1..Length(graph!.vertices)], []);
  order := [];
  
  queue := [start]; # TODO make of right size.
  queueStart := 1;
  
  while (Length(queue) >= queueStart) do
    
    current := queue[queueStart];
    queueStart := queueStart + 1;
    Add(order, current);

    for successor in graph!.vertices[current] do
      if isVisited[successor] = false then
        Add(queue, successor);
      fi;
    od;
  od; 

  return order;
end);
