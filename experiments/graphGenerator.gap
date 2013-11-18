#
# Possibly undirected, unconnected graph.
#
DeclareGlobalFunction("GenerateSimpleDirectedGraph");

#
DeclareGlobalFunction("GenerateConnectedGraph");

DeclareGlobalFunction("GenerateSimpleGraph");

InstallGlobalFunction(GenerateSimpleDirectedGraph, function(vertexCount, density)
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
      if (RandomList(randomList) <= density) then
        AddEdge(graph, start, endVertex);
      fi;
    od;
  od;

  return graph;
end);
