# Record for private members.
MSTP_REC := rec();

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexParent, vertexEdge, head, heads, headEdge, newHeads, vertex, vertices, task, tasks, edge, edges;

  edges := AtomicList([]);

  vertexCount := VertexCountP(graph);
  vertices := [1..vertexCount];

  vertexHead := FixedAtomicList(vertexCount); 
  vertexParent := FixedAtomicList(vertexCount);
  vertexEdge := FixedAtomicList(vertexCount);
  headEdge := FixedAtomicList(vertexCount);

  heads := [];
  
  tasks := [];
  for vertex in vertices do

    heads[vertex] := vertex; # Initialize in parallel.
    headEdge[vertex] := [];
    ShareObj(headEdge[vertex]);

    vertexHead[vertex] := vertex;
    vertexParent[vertex] := 0;
    vertexEdge[vertex] := 1;

    # Sort edges to find minimum edge quickly.
    task := RunTask(MSTP_REC.sortEdges, graph, vertex);
    Add(tasks, task);
  od;
  WaitTasks(tasks);

  while Length(heads) > 1 do
    
    # Find min edges.
    tasks := [];
    for vertex in vertices do
      task := RunTask(MSTP_REC.findMinEdge, graph, vertex, vertexHead, vertexEdge, headEdge);
      Add(tasks, task);
      #MSTP_REC.findMinEdge(graph, vertex, vertexHead, vertexEdge, headEdge);
    od;
    WaitTasks(tasks);

    #Print("hE ", FromAtomicList(headEdge), "\n");

    # Join the edges by changing heads and merging the lists. # TODO launch only needed ones.
    tasks := [];
    for head in heads do
      atomic readonly headEdge[head] do
        edge := headEdge[head];
        if edge <> [] then
          #task := RunTask(MSTP_REC.mergeParents, edge[1], edge[2], vertexHead, vertexParent, heads, edges);
          #Add(tasks, task);
          MSTP_REC.mergeParents(edge[1], edge[2], vertexHead, vertexParent, heads, edges);
        fi;
      od;
    od;
    #WaitTasks(tasks);

    #Print("vP ", FromAtomicList(vertexParent), "\n");
    
    # Update vertex heads list. # TODO do current heads first by linking them to parents directly. Combine with below.
    tasks := [];
    for vertex in vertices do
      task := RunTask(MSTP_REC.updateHeads, vertex, vertexHead, vertexParent);
      Add(tasks, task);
      #MSTP_REC.updateHeads(vertex, vertexHead, vertexParent);
    od;
    WaitTasks(tasks);

    #Print("vH ", FromAtomicList(vertexHead), "\n");

    # Get new heads. # TODO paralelise a bit, depending on P count.
    newHeads := [];
    for head in heads do
      if vertexHead[head] = head then
        Add(newHeads, head);
        headEdge[head] := [];
        ShareObj(headEdge[head]);
      fi;
    od;
  
    #Print("nH ", newHeads, "\n");

    if Length(heads) = Length(newHeads) then
      break;
    else
      heads := newHeads;
    fi;    
  od;

  return FromAtomicList(edges);
end);

MSTP_REC.sortEdges := function(graph, vertex)
  local successors, weights;

  weights := FromAtomicList(graph!.weights[vertex]);
  successors := FromAtomicList(graph!.successors[vertex]);
  SortParallel(weights, successors);
  graph!.weights[vertex] := AtomicList(weights);
  graph!.successors[vertex] := AtomicList(successors);
end;

MSTP_REC.mergeParents := function(startVertex, endVertex, vertexHead, vertexParent, heads, edges)
  local head1, head2, parent1, parent2, tmp; # TODO remove tmp.
  
  # TODO improve as know one head already? Could not even launch tasks for repeats.
  head1 := vertexHead[startVertex];
  head2 := vertexHead[endVertex];

  parent1 := head1;
  while vertexParent[parent1] > 0 do
    parent1 := vertexParent[parent1];
  od;

  parent2 := head2;
  while vertexParent[parent2] > 0 do
    parent2 := vertexParent[parent2];
  od;

  # TODO balance using tree depth. # Note currently makes needed check that parent1 != parent2.
  # But balancing might break it.
  if parent1 <> parent2 then
    vertexParent[parent1] := parent2;
    tmp := [startVertex, endVertex];
    MakeImmutable(tmp);
    Add(edges, tmp);
  fi;
end;

MSTP_REC.updateHeads := function(vertex, vertexHead, vertexParent)
  local parent;

  # TODO tree compression, possibly not needed if using balancing?
  
  parent := vertexHead[vertex];
  while vertexParent[parent] > 0 do
    parent := vertexParent[parent];
  od;

  vertexHead[vertex] := parent;
end;

MSTP_REC.findMinEdge := function(graph, vertex, vertexHead, vertexEdge, headEdge)
  local successors, head, minEdge, edgeIndex, successor, weight, update;
    
  successors := VertexSuccessorsP(graph, vertex);
  head := vertexHead[vertex];
  minEdge := headEdge[head];

  edgeIndex := vertexEdge[vertex];
  while edgeIndex <= Length(successors) do
  
    successor := successors[edgeIndex];
    if head <> vertexHead[successor] then

      # Pick the next sorted edge for this vertex.
      weight := GetWeightP(graph, vertex, edgeIndex);

      # Update min if needed.
      atomic minEdge do
        if
          minEdge = [] or
          weight < minEdge[3] or
          (weight = minEdge[3] and vertexHead[successor] < vertexHead[minEdge[2]])
        then
          minEdge[1] := vertex;
          minEdge[2] := successor;
          minEdge[3] := weight;
        fi;
      od;

      # Update vertex edge for the next time and stop since the list is sorted.
      vertexEdge[vertex] := edgeIndex;
      break;
    else

      # Skip the edge creating a loop.
      edgeIndex := edgeIndex + 1;
    fi;
  od;
end;
