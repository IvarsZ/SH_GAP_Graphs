LoadPackage("Graphs");
LoadPackage("PGraphs");

graph := EmptyGraph();
for i in [1..3] do
  AddVertex(graph);
od;
graph!.successors;

AddEdge(graph, 1, 2);
AddEdge(graph, 2, 1);
AddEdge(graph, 2, 3);
graph!.successors;

# Same for parallel graphs except append P to end of method names.

graph := Graph([[2, 3, 4, 5, 6], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [], [], [], [], []]);
BFS(graph, 1);

graphP := GraphP(graph!.successors);
res := BFSP(graphP, 1);
for level in res do
  for partition in level do
    Print(FromAtomicList(partition), " ");
  od;
  Print("\n");
od;

w := WeightedGraph([[2, 3, 4, 5], [1, 5], [1, 4, 6, 7], [1, 3, 5, 7], [1, 2, 4, 7, 8], [3, 7], [3, 4, 5, 6, 8], [5, 7]], [[2, 2, 5, 5], [2, 1], [2, 2, 10, 5], [5, 2, 10, 3], [5, 1, 10, 10, 10], [10, 9], [5, 3, 10, 3, 3], [10, 3]]);
MinimumSpanningTree(w);

wP := WeightedGraphP(w!.successors, w!.weights);
MinimumSpanningTreeP(wP);


