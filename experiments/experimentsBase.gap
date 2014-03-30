# Load needed packages and files.
LoadPackage("Graphs");
LoadPackage("PGraphs");
Read("graphGenerator.gap");

# Set parameters - seed and minimal run length.
Reset(GlobalMersenneTwister, 495817502);
TIMERS_MIN_RUN_LENGTH := 200;
SetRecursionTrapInterval(0);

FLOAT.DECIMAL_DIG := 2;

# Writes some graphs to files, not used anymore due to filesize.
writeGraphs := function()
  local vertexCount, density, i, graph, filename;

  for vertexCount in [100, 500, 1000, 5000, 10000] do
    for density in [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1] do
      for i in [1..20] do

        graph := GenerateSimpleDirectGraph(vertexCount, density);
        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/sdg", vertexCount, density, i], "_");
        PrintTo(filename, "vertexCount := ", vertexCount, ";\n");
        AppendTo(filename, "density := ", density, ";\n");
        AppendTo(filename, "graph := Graph(", graph!.successors, ");\n");
      od;
    od;
  od;

  for vertexCount in [5..30] do
    for density in [0.1, 0.25, 0.5, 0.75, 1] do
      for i in [1..100] do

        graph := GenerateSimpleGraph(vertexCount, density);
        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/sg", vertexCount, density, i], "_");
        PrintTo(filename, "vertexCount := ", vertexCount, ";\n");
        AppendTo(filename, "density := ", density, ";\n");
        AppendTo(filename, "graph := Graph(", graph!.successors, ");\n");
      od;
    od;
  od;

  for vertexCount in [100, 250, 500, 750, 1000] do
    for density in [0.01, 0.05, 0.1, 0.5, 1] do
      for i in [1..20] do

        graph := GenerateConnectedSimpleWeightedGraph(vertexCount, density, vertexCount);
        filename := JoinStringsWithSeparator(["/media/SH_USB1/graphs/cswg", vertexCount, density, i], "_");
        PrintTo(filename, "vertexCount := ", vertexCount, ";\n");
        AppendTo(filename, "density := ", density, ";\n");
        AppendTo(filename, "graph := WeightedGraph(", graph!.successors, ", ", graph!.weights, ");\n");
      od;
    od;
  od;
end;

# Times a function f run with the given arguments.
timeFunction := function(f, args)
  local result, n, t, j;

  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
    GASMAN("collect");
    t := -Runtime();
    for j in [1..n] do
      result := CallFuncList(f, args);
    od;
    t := t + Runtime();
    n := n * 5;
  od;

  return [Int(Float(1000000*t/n)), result];
end;

# Times a function f run with the given arguments.
timeNoReturnFunction := function(f, args)
  local result, n, t, j;

  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
    GASMAN("collect");
    t := -Runtime();
    for j in [1..n] do
      CallFuncList(f, args);
    od;
    t := t + Runtime();
    n := n * 5;
  od;

  return Int(Float(1000000*t/n));
end;

testStrongComponents := function(graph, vertexCount, density)
  local numberOfComponents, result;

  result := timeFunction(StrongComponents, [graph]);
  numberOfComponents := Length(Collected(result[2]));
  Print("sc ", vertexCount, " ", density, " ", result[1], " ", numberOfComponents, "\n");
end;

testBFSForAllVertices := function(graph, vertexCount, density)
  local n, t, j, i, totalDepth, numberOfComponents, isVisited, bfs, vertices, vertex;
  
  vertices := [1..vertexCount];
  
  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
      GASMAN("collect");

      t := -Runtime();
      for j in [1..n] do
        
        totalDepth := 0;
        numberOfComponents := 0;
        isVisited := BlistList([1..vertexCount], []);
        
        for i in vertices do
          if (isVisited[i] = false) then

            bfs := BFS(graph, i);
            for vertex in bfs[1] do
              isVisited[vertex] := true;
            od;

            numberOfComponents := numberOfComponents + 1;
            totalDepth := totalDepth + bfs[2];
          fi;
        od;
      od;
      t := t + Runtime();

      n := n * 5;
  od;

  Print("bfs ", vertexCount, " ", density, " ", Int(Float(1000000*t/n))," ", numberOfComponents, " ", totalDepth, "\n");
end;

testDFSForAllVertices := function(graph, vertexCount, density)
  local n, t, j, i, numberOfComponents, isVisited, vertices, vertex;
  
  vertices := [1..vertexCount];
  
  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
      GASMAN("collect");

      t := -Runtime();
      for j in [1..n] do

        numberOfComponents := 0;
        isVisited := BlistList([1..vertexCount], []);
        for i in vertices do

          if (isVisited[i] = false) then

            numberOfComponents := numberOfComponents + 1;
            for vertex in DFS(graph, i) do
              isVisited[vertex] := true;
            od;
          fi;
        od;
      od;
      t := t + Runtime();

      n := n * 5;
  od;
  
  Print("dfs ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), " ", numberOfComponents, "\n");
end;

testColoring := function(graph, vertexCount, density)
  local n, t, j, numberOfComponents, isColoured, colorCount;

  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
    GASMAN("collect");

    t := -Runtime();
    for j in [1..n] do
     
      isColoured := false;
      colorCount := 0;
      while (isColoured = false) do
        colorCount := colorCount + 1;
        isColoured := ColorVertices(graph, colorCount);
      od;
    od;
    t := t + Runtime();

    n := n * 5;
  od;
  
  Print("col ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), " ", colorCount, "\n");
end;

testMST := function(graph, vertexCount, edgesPerVertex)
  local result, weight, edge;

  result := timeFunction(MinimumSpanningTree, [graph]);
  
  # Traverse mst and get weight.
  weight := 0;
  for edge in result[2] do
    weight := weight + GetWeightedEdge(graph, edge[1], edge[2]);
  od;

  Print("mst ", vertexCount, " ", edgesPerVertex, " ", result[1], " ", weight, " ", GAPInfo.KernelInfo.NUM_CPUS, "\n");

  return weight;
end;

testShortestPaths := function(graph, vertexCount, density)
  local result;

  result := timeFunction(ShortestPath, [graph, 1]);
  Print("sp ", vertexCount, " ", density, " ", result[1], "\n"); 
end;

testMSTP := function(graph, vertexCount, edgesPerVertex)
  local result, weight, edge;

  result := timeFunction(MinimumSpanningTreeP, [graph]);

  # Traverse mst and get weight.
  weight := 0;
  for edge in result[2] do
    weight := weight + GetWeightedEdge(graph, edge[1], edge[2]);
  od;

  Print("mstp ", vertexCount, " ", edgesPerVertex, " ", result[1], " ", weight, " ", GAPInfo.KernelInfo.NUM_CPUS, "\n");

  return weight;
end;

testColoringP := function(graph, vertexCount, density)
  local n, t, j, numberOfComponents, isColoured, colorCount;

  n := 1;
  t := 0;
  while t < TIMERS_MIN_RUN_LENGTH do
    GASMAN("collect");

    t := -Runtime();
    for j in [1..n] do
     
      isColoured := false;
      colorCount := 0;
      while (isColoured = false) do
        colorCount := colorCount + 1;
        isColoured := ColorVerticesP(graph, colorCount);
      od;
    od;
    t := t + Runtime();

    n := n * 5;
  od;
  
  Print("colp ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), " ", colorCount, "\n");
end;
