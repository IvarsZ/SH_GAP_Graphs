LoadPackage("Graphs");
Read("graphGenerator.gap");

# Set seed and minimal run length.
Reset(GlobalMersenneTwister, 495817502);
TIMERS_MIN_RUN_LENGTH := 200;
SetRecursionTrapInterval(0);

# Strong Components
for vertexCount in [10000, 25000, 50000, 75000, 100000] do
  for density in [0.0001, 0.001, 0.01, 0.05, 0.1, 0.5, 1] do

    for i in [1..100] do
      graph := GenerateSimpleDirectedGraph(vertexCount, density);

      n := 1;
      t := 0;
      total := 0;
      while total < TIMERS_MIN_RUN_LENGTH do
          GASMAN("collect");
          t := -Runtime();
          GetStrongComponents(graph);
          t := t + Runtime();
          n := n + 1;
          total := total + t;
      od;
      Print("sc ", vertexCount, " ", density, " ", Int(Float(1000*total/n)), "\n");
    od;
  od;
od;
