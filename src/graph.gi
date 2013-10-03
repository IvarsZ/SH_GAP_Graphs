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
GRAPH := rec(dfs            := false,
             traversalOrder := false,
             isVisited      := false);

InstallGlobalFunction(AddVertex, function(graph)

  Add(graph!.vertices, []);
  return Length(graph!.vertices);
end);

InstallGlobalFunction(AddEdge, function(graph, startIndex, endIndex)

  Add(graph!.vertices[startIndex], endIndex);
end);

InstallGlobalFunction(DFS, function(graph, start)

  GRAPH.isVisited := BlistList([1..Length(graph!.vertices)], []);
  GRAPH.traversalOrder := [];

  GRAPH.dfs(graph, start);
  return GRAPH.traversalOrder;
end);

InstallGlobalFunction(BFS, function(graph, start)
  local queue, queueStart, current, successor;

  GRAPH.isVisited := BlistList([1..Length(graph!.vertices)], []);
  GRAPH.traversalOrder := [];
  
  queue := [start]; # TODO make of right size.
  queueStart := 1;
  
  while (Length(queue) >= queueStart) do
    
    current := queue[queueStart];
    queueStart := queueStart + 1;
    Add(GRAPH.traversalOrder, current);

    for successor in graph!.vertices[current] do
      if GRAPH.isVisited[successor] = false then
        Add(queue, successor);
      fi;
    od;
  od; 

  return GRAPH.traversalOrder;
end);

GRAPH.dfs := function(graph, cur)
  local successor;

  GRAPH.isVisited[cur] := true;
  Add(GRAPH.traversalOrder, cur);

  for successor in graph!.vertices[cur] do
    if GRAPH.isVisited[successor] = false then
      GRAPH.dfs(graph, successor);
    fi;
  od;
end;
