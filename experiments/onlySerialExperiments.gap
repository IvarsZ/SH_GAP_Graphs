Read("experimentsBase.gap");

graph := [];

runExperimentsForSerial := function()
  local vertexCount, density, i, filename, graphP;
  
  # SCC, BFS and DFS.
  for vertexCount in [100, 500, 1000, 5000, 10000] do
    for density in [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1] do
      for i in [1..0] do
        
        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/sdg", vertexCount, density, i], "_");
        Read(filename);

        testStrongComponents(graph, vertexCount, density);
        testBFSForAllVertices(graph, vertexCount, density);
        testDFSForAllVertices(graph, vertexCount, density);
      od;
    od;
  od;

  # Coloring
  for vertexCount in [5..30] do
    for density in [0.1, 0.25, 0.5, 0.75, 1] do
      for i in [1..1] do
        
        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/sg", vertexCount, density, i], "_");
        Read(filename);

        testColoring(graph, vertexCount, density);
      od;
    od;
  od;

  # Minimum spanning tree and shortest paths
  for vertexCount in [100, 250, 500, 750, 1000] do
    for density in [0.01, 0.05, 0.1, 0.5, 1] do
      for i in [1..0] do

        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/cswg", vertexCount, density, i], "_");
        Read(filename);

        testMST(graph, vertexCount, density);
        testShortestPaths(graph, vertexCount, density);
      od;
    od;
  od;
end;
runExperiments();

QUIT;
