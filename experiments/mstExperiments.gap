# Minimum spanning tree.
compareMST := function()
  local vertexCount, vertexCounts, edgeCount, edgesPerVertex, t, times, graph, graphP, weight1, weight2, isOver;

  isOver := false;
  vertexCounts := [10, 100, 1000, 10000, 50000, 100000, 500000, 1000000];
  edgesPerVertex := [1, 5, 10, 50, 100, 500, 5000];
  times := 1;

  for i in [1..Length(vertexCounts)] do
    vertexCount := vertexCounts[i];
    edgeCount := edgesPerVertex[i];
    for t in [0..times-1] do
        
      if isOver then
        break;
      fi;

      filename := JoinStringsWithSeparator(["/scratch2/iz2/graphs/scwg", vertexCount, edgeCount, i], "_");
      Read(filename);
      graphP := GraphP(graph!.successors);

      if GAPInfo.KernelInfo.NUM_CPUS = 1 then
        weight1 := testMST(graph, vertexCount, edgeCount);
        weight2 := testMSTP(graphP, vertexCount, edgeCount);

        if weight1 <> weight2 then
          Print(graph!.successors, " ", graph!.weights, "\n");
          Print(weight1, " not eq ", weight2);
          isOver := true;
        fi;
      else
        testMSTP(graphP, vertexCount, edgeCount);
      fi;
    od;
  od;
end;
