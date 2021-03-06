LoadPackage("Graphs");

#
# Possibly undirected, unconnected graph.
#
DeclareGlobalFunction("GenerateSimpleDirectGraph");

DeclareGlobalFunction("GenerateSimpleGraph");

DeclareGlobalFunction("GenerateSimpleConnectedGraph");

DeclareGlobalFunction("GenerateConnectedSimpleWeightedGraph");

InstallGlobalFunction(GenerateSimpleDirectGraph, function(vertexCount, density)
  local i, graph, start, endVertex, randomUnitSize, vertices, randomList;

  # Adjust density to randomUnitSize.
  randomUnitSize := 100000000;
  density := Int(density * randomUnitSize);

  graph := EmptyGraph();
  for i in [1..vertexCount] do
    AddVertex(graph);
  od;

  vertices := [1..VertexCount(graph)];
  randomList := [1..randomUnitSize];

  # Each edge has probability equal to density.
  for start in vertices do
    for endVertex in vertices do
      if (start <> endVertex) then
        if (RandomList(randomList) <= density) then
          AddEdge(graph, start, endVertex);
        fi;
      fi;
    od;
  od;

  return graph;
end);

InstallGlobalFunction(GenerateSimpleGraph, function(vertexCount, density)
  local i, graph, start, endVertex, randomUnitSize, vertices, randomList;

  # Adjust density to randomUnitSize.
  randomUnitSize := 100000000;
  density := Int(density * randomUnitSize);

  graph := EmptyGraph();
  for i in [1..vertexCount] do
    AddVertex(graph);
  od;

  randomList := [1..randomUnitSize];

  # Each edge has probability equal to density.
  for start in [1..vertexCount - 1] do
    for endVertex in [start + 1..vertexCount] do
      if (RandomList(randomList) <= density) then
        AddEdge(graph, start, endVertex);
        AddEdge(graph, endVertex, start);
      fi;
    od;
  od;

  return graph;
end);

InstallGlobalFunction(GenerateSimpleConnectedGraph, function(vertexCount, density)
  local i, graph, start, endVertex, randomUnitSize, vertices, randomList, visitedCount, previousVertex, nextVertex, isVisited, previous;

  # Adjust density to randomUnitSize.
  randomUnitSize := 100000000;
  density := Int(density * randomUnitSize);

  graph := EmptyGraph();
  for i in [1..vertexCount] do
    AddVertex(graph);
  od;

  randomList := [1..randomUnitSize];
  vertices := [1..vertexCount];
  
  # Create a random minimum spanning tree.
  previous := EmptyPlist(vertexCount);
  previous[1] := 0;
  visitedCount := 1;
  previousVertex := 1;
  while (visitedCount < vertexCount) do
    nextVertex := RandomList(vertices);
    if (IsBound(previous[nextVertex]) = false) then

      AddEdge(graph, previousVertex, nextVertex);
      AddEdge(graph, nextVertex, previousVertex);
      previousVertex := nextVertex;

      previous[nextVertex] := previousVertex;
      visitedCount := visitedCount + 1;
      previousVertex := nextVertex;
    fi;
  od;

  # Each edge has probability equal to density.
  for start in [1..vertexCount - 1] do
    for endVertex in [start + 1..vertexCount] do
      if (previous[start] <> endVertex and previous[endVertex] <> start and RandomList(randomList) <= density) then
        AddEdge(graph, start, endVertex);
        AddEdge(graph, endVertex, start);
      fi;
    od;
  od;

  return graph;
end);

InstallGlobalFunction(GenerateConnectedSimpleWeightedGraph, function(vertexCount, density, maxWeight)
  local i, graph, start, endVertex, randomUnitSize, vertices, randomList, weightList, weight, nextVertex, previousVertex, visitedCount, previous;

  # Adjust density to randomUnitSize.
  randomUnitSize := 100000000;
  density := Int(density * randomUnitSize);

  graph := EmptyWeightedGraph();
  for i in [1..vertexCount] do
    AddWeightedGraphVertex(graph);
  od;

  vertices := [1..vertexCount];
  randomList := [1..randomUnitSize];
  weightList := [1..maxWeight];

  # Create a random minimum spanning tree.
  previous := EmptyPlist(vertexCount);
  previous[1] := 0;
  visitedCount := 1;
  previousVertex := 1;
  while (visitedCount < vertexCount) do
    nextVertex := RandomList(vertices);
    if (IsBound(previous[nextVertex]) = false) then

      weight := RandomList(weightList);
      AddWeightedEdge(graph, previousVertex, nextVertex, weight);
      AddWeightedEdge(graph, nextVertex, previousVertex, weight);

      previous[nextVertex] := previousVertex;
      visitedCount := visitedCount + 1;
      previousVertex := nextVertex;
    fi;
  od;

  # Each edge has probability equal to density.
  for start in [1..vertexCount - 1] do
    for endVertex in [start + 1..vertexCount] do
      if (previous[start] <> endVertex and previous[endVertex] <> start and RandomList(randomList) <= density) then  
        weight := RandomList(weightList);
        AddWeightedEdge(graph, start, endVertex, weight);
        AddWeightedEdge(graph, endVertex, start, weight);
      fi;
    od;
  od;

  return graph;
end);
