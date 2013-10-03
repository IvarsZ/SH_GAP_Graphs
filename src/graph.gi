DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["vertices"]);

InstallGlobalFunction(Graph, function(vertices)

  # TODO check vertices

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(vertices := vertices));
end); 

InstallGlobalFunction(EmptyGraph, function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(vertices := []));
end);

InstallGlobalFunction(AddVertex, function(graph)

  Add(graph!.vertices, []);
  return Length(graph!.vertices);
end);

InstallGlobalFunction(AddEdge, function(graph, startIndex, endIndex)

  Add(graph!.vertices[startIndex], endIndex);
end);

visited := BlistList([], []);
ord := [];

dfs := function(graph, cur)
  
  visited[cur] := true;
  Add(ord, cur);

  for successor in graph!.vertices[cur] do
    if visited[successor] = false then
      dfs(graph, successor);
    fi;
  od;
end;

InstallGlobalFunction(DFS, function(graph, start)

  visited := BlistList([1..Length(graph!.vertices)], []);
  dfs(graph, start);
  return ord;
end);

