Read("experimentsBase.gap");

# Test BFS and PBFS for large vertex count.
compareBFS := function()
  local vertexCounts, edgesPerVertex, times, vertexCount, edgeCount, t, graphP, result, filename;
  
  vertexCounts := [10, 100, 1000, 10000, 100000, 1000000];
  edgesPerVertex := [1, 5, 10, 50, 100, 1000];
  times := 10;

  for vertexCount in vertexCounts do
    for edgeCount in edgesPerVertex do
      if edgeCount > vertexCount then
        break;
      fi;
      for t in [0..times-1] do

        filename := JoinStringsWithSeparator(["/scratch2/iz2/graphs/scg", vertexCount, edgeCount, t], "_");
        filename := JoinStringsWithSeparator([filename, "graph"], ".");
        Read(filename);
        graphP := GraphP(graph!.successors);

        if GAPInfo.KernelInfo.NUM_CPUS = 1 then
          Print("bfs ");
          result := timeFunction(BFS, [graph, 1]);
          Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, "\n");
        fi; 

        Print("bfsp ");    
        result := timeFunction(BFSP, [graphP, 1]);
        Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, " ", "double", "\n");
        
        BFSP_REC.TASKS_COUNT := NextPrimeInt(GAPInfo.KernelInfo.NUM_CPUS);
        result := timeFunction(BFSP, [graphP, 1]);
        Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, " ", "single", "\n");
        
        BFSP_REC.TASKS_COUNT := NextPrimeInt(GAPInfo.KernelInfo.NUM_CPUS*10);
        result := timeFunction(BFSP, [graphP, 1]);
        Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, " ", "tenTimes", "\n");
        
        BFSP_REC.TASKS_COUNT := NextPrimeInt(GAPInfo.KernelInfo.NUM_CPUS^2);
        result := timeFunction(BFSP, [graphP, 1]);
        Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, " ", "square", "\n");
        
        BFSP_REC.TASKS_COUNT := NextPrimeInt(vertexCount);
        result := timeFunction(BFSP, [graphP, 1]);
        Print(vertexCount, " ", edgeCount, " ", result[1], " ", GAPInfo.KernelInfo.NUM_CPUS, " ", "one", "\n");
      od;
    od;
  od;
end;
compareBFS();
