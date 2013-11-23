LoadPackage("Graphs");
Read("graphGenerator.gap");

# Set seed and minimal run length.
Reset(GlobalMersenneTwister, 495817502);
TIMERS_MIN_RUN_LENGTH := 200;
SetRecursionTrapInterval(0);

FLOAT.DECIMAL_DIG := 2;

WRITE_GRAPHS := true;
if (WRITE_GRAPHS = true) then
  
  for vertexCount in [100, 500, 1000, 5000, 10000] do
    for density in [0.01, 0.05, 0.1, 0.5, 1] do
      for i in [1..20] do

        graph := GenerateSimpleDirectGraph(vertexCount, density);
        filename := JoinStringsWithSeparator(["graphs/sdg", vertexCount, density, i], "_");
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
        filename := JoinStringsWithSeparator(["graphs/sg", vertexCount, density, i], "_");
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
        filename := JoinStringsWithSeparator(["graphs/cswg", vertexCount, density, i], "_");
        PrintTo(filename, "vertexCount := ", vertexCount, ";\n");
        AppendTo(filename, "density := ", density, ";\n");
        AppendTo(filename, "graph := Graph(", graph!.successors, ");\n");
      od;
    od;
  od;
fi;

QUIT;

for vertexCount in [100, 500, 1000, 5000, 10000] do
  vertices := [1..vertexCount];

  for density in [0.01, 0.05, 0.1, 0.5, 1] do

    for i in [1..0] do
      graph := GenerateSimpleDirectGraph(vertexCount, density);

      # Strong components.
      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");
          t := -Runtime();
          for j in [1..n] do
            GetStrongComponents(graph);
          od;
          t := t + Runtime();
          n := n * 5;
      od;
      Print("sc ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n");

      # BFS
      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");

          t := -Runtime();
          for j in [1..n] do
            isVisited := BlistList([1..vertexCount], []);
            for i in vertices do
              if (isVisited[i] = false) then
                for vertex in BFS(graph, i) do
                  isVisited[vertex] := true;
                od;
              fi;
            od;
          od;
          t := t + Runtime();

          n := n * 5;
      od;
      Print("bfs ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n");

      # DFS
      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");

          t := -Runtime();
          for j in [1..n] do
            isVisited := BlistList([1..vertexCount], []);
            for i in vertices do
              if (isVisited[i] = false) then
                for vertex in DFS(graph, i) do
                  isVisited[vertex] := true;
                od;
              fi;
            od;
          od;
          t := t + Runtime();

          n := n * 5;
      od;
      Print("dfs ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n");
      
    od;
  od;
od;

# Colouring
for vertexCount in [5..30] do
  vertices := [1..vertexCount];

  for density in [0.1, 0.25, 0.5, 0.75, 1] do

    for i in [1..1] do
      graph := GenerateSimpleGraph(vertexCount, density);

      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");

          t := -Runtime();
          for j in [1..n] do
           
            isColoured := false;
            colourCount := 1;
            while (isColoured = false) do
              isColoured := GetColouring(graph, colourCount);
              colourCount := colourCount + 1;
            od;
          od;
          t := t + Runtime();

          n := n * 5;
      od;
      Print("col ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n");
    od;
  od;
od;

# Minimum spanning tree and shortest paths
for vertexCount in [100, 250, 500, 750, 1000] do
  vertices := [1..vertexCount];

  for density in [0.01, 0.05, 0.1, 0.5, 1] do

    for i in [1..20] do
      graph := GenerateConnectedSimpleWeightedGraph(vertexCount, density, vertexCount);

      # Minimum spanning tree.
      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");
          t := -Runtime();
          for j in [1..n] do
            MinimumSpanningTree(graph);
          od;
          t := t + Runtime();
          n := n * 5;
      od;
      Print("mst ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n");

      # Shortest paths.
      n := 1;
      t := 0;
      while t < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");

          t := -Runtime();
          for j in [1..n] do
            ShortestPath(graph, 1);
          od;
          t := t + Runtime();
          n := n * 5;
      od;
      Print("sp ", vertexCount, " ", density, " ", Int(Float(1000000*t/n)), "\n"); 
    od;
  od;
od;

QUIT;
