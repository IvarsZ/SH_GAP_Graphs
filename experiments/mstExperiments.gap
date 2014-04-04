Read("experimentsBase.gap");

# Minimum spanning tree.
compareMST := function()
  local vertexCount, vertexCounts, edgeCount, edgesPerVertex, t, times, graphP, weight1, weight2, weight3, isOver, filename;

  isOver := false;
  vertexCounts := [10, 100, 1000, 10000, 100000, 1000000];
  edgesPerVertex := [1, 5, 10, 50, 100, 1000];
  times := 10;

  for vertexCount in vertexCounts do
    for edgeCount in edgesPerVertex do
      if edgeCount > vertexCount then
        break;
      fi;
      for t in [0..times-1] do
          
        if isOver then
          break;
        fi;

        filename := JoinStringsWithSeparator(["/scratch2/iz2/graphs/scwg", vertexCount, edgeCount, t], "_");
        filename := JoinStringsWithSeparator([filename, "graph"], ".");
        Read(filename);
        graphP := WeightedGraphP(graph!.successors, graph!.weights);

        if GAPInfo.KernelInfo.NUM_CPUS = 1 then
          weight1 := testMST(graph, vertexCount, edgeCount);
          weight3 := testMSTPrims(graph, vertexCount, edgeCount);
          weight2 := testMSTP(graphP, vertexCount, edgeCount);

          if weight1 <> weight2 or weight2 <> weight3 then
            Print(graph!.successors, " ", graph!.weights, "\n");
            Print(weight1, " not eq ", weight2);
            isOver := true;
          fi;
        else
          testMSTP(graphP, vertexCount, edgeCount);
        fi;
      od;
    od;
  od;
end;
compareMST();
