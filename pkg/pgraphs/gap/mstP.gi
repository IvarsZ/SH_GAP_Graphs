# Record for private members.
MSTP_REC := AtomicRecord(6); # Atomic to have access to task count in threads.
MSTP_REC.TASKS_COUNT := GAPInfo.KernelInfo.NUM_CPUS*2;

InstallGlobalFunction(MinimumSpanningTreeP, function(graph)
  local vertexCount, vertexHead, vertexParent, vertexEdge, head, heads, headEdge, newHeads, vertex, task, tasks, edge, edges, head2, edge2, headLock, vertexPartitions, startV, endV, partitionSize, vertexPartition, vertices, partitionCount;

  edges := [];

  vertexCount := VertexCountP(graph);
  vertices := [1..vertexCount];

  vertexHead := FixedAtomicList(vertexCount); 
  vertexParent := FixedAtomicList(vertexCount);
  vertexEdge := FixedAtomicList(vertexCount);
  headEdge := FixedAtomicList(vertexCount);
  headLock := FixedAtomicList(vertexCount);
  
  partitionSize := Int(Float(vertexCount/MSTP_REC.TASKS_COUNT)) + 1;
  partitionCount := Int(Float(vertexCount/partitionSize)) + 1;
  vertexPartitions := EmptyPlist(partitionCount);
  
  startV := 1;
  while startV <= vertexCount do
    endV := startV + partitionSize;
    if endV > vertexCount then
      endV := vertexCount;
    fi;
    Add(vertexPartitions, [startV..endV]);
    startV := endV + 1;
  od;

  heads := [];
  
  tasks := EmptyPlist(vertexCount);
  for vertex in vertices do

    heads[vertex] := vertex; # Initialize in parallel.
    headEdge[vertex] := MakeImmutable([]);
    headLock[vertex] := [];
    ShareObj(headLock[vertex]);

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
    tasks := EmptyPlist(partitionCount);
    for vertexPartition in vertexPartitions do
      task := RunTask(MSTP_REC.findMinEdge, graph, vertexPartition, vertexHead, vertexEdge, headEdge, headLock);
      Add(tasks, task);
    od;
    WaitTasks(tasks);
    
    # Join the edges by changing heads and merging the lists.
    tasks := [];
    for head in heads do
      edge := headEdge[head];
      if edge <> [] then
        task := RunTask(MSTP_REC.mergeParents, edge, vertexHead, vertexParent);
        Add(tasks, task);
	Add(edges, edge);
        
        # if the partition of end vertex links back remove it to avoid unneeded tasks.
        head2 := vertexHead[edge[2]];
        edge2 := headEdge[head2];
        if edge2 <> [] and vertexHead[edge2[2]] = head then
          headEdge[head2] := MakeImmutable([]);
        fi;
      fi;
    od;
    WaitTasks(tasks);
    # Compress heads.
    tasks := [];
    for head in heads do
      task := RunTask(MSTP_REC.compressHeads, head, vertexHead, vertexParent);
      Add(tasks, task);
    od;
    WaitTasks(tasks);
	
    # Update heads for vertices and get new heads.
    newHeads := [];
    for vertex in vertices do
      head := vertexHead[vertex];

      if vertex <> head then
        if vertexParent[head] > 0 then
          vertexHead[vertex] := vertexParent[head];
        fi;
      else
        if vertexParent[head] = 0 then
          Add(newHeads, head);
          headEdge[head] := MakeImmutable([]);
        else
          vertexHead[head] := vertexParent[head];
        fi;
      fi;
    od;
    
    if Length(heads) = Length(newHeads) then
      break;
    else
      heads := newHeads;
    fi;
  od;

  return edges;
end);

MSTP_REC.sortEdges := function(graph, vertex)
  local successors, weights;

  weights := FromAtomicList(graph!.weights[vertex]);
  successors := FromAtomicList(graph!.successors[vertex]);
  SortParallel(weights, successors);
  graph!.weights[vertex] := AtomicList(weights);
  graph!.successors[vertex] := AtomicList(successors);
end;

MSTP_REC.mergeParents := function(edge, vertexHead, vertexParent)
  local head1, head2, parent1, parent2;
  
  head1 := vertexHead[edge[1]];
  head2 := vertexHead[edge[2]];

  parent1 := head1;
  while vertexParent[parent1] > 0 do
    parent1 := vertexParent[parent1];
  od;

  parent2 := head2;
  while vertexParent[parent2] > 0 do
    parent2 := vertexParent[parent2];
  od;

  # Links parent1 to parent2, note the direction is important when doing it in parallel.
  vertexParent[parent1] := parent2;
end;

MSTP_REC.compressHeads := function(head, vertexHead, vertexParent)
  local parent;

  parent := head;
  while vertexParent[parent] > 0 do
    parent := vertexParent[parent];
  od;

  if head <> parent then
    vertexParent[head] := parent; # So vertices attached to this head could find parent faster.
  fi;
end;

MSTP_REC.findMinEdge := function(graph, vertices, vertexHead, vertexEdge, headEdge, headLock)
  local successors, head, minEdge, edgeIndex, successor, weight, update, minWeight, minSuccessor, vertex;
  
  for vertex in vertices do

    # Check all unpicked minimal weight edges of the vertex.
    minWeight := -1;
    minSuccessor := -1;
    head := vertexHead[vertex];
    successors := VertexSuccessorsP(graph, vertex);

    edgeIndex := vertexEdge[vertex];
    while edgeIndex <= Length(successors) do
      successor := successors[edgeIndex];

      # Consider only edges outside partition.
      if head <> vertexHead[successor] then
        
        weight := GetWeightP(graph, vertex, edgeIndex);
        if minWeight = -1 then
          minWeight := weight;
          minSuccessor := successor;
          
          # Update the first edge that could be picked again.
          vertexEdge[vertex] := edgeIndex;
        fi;
        
        if weight = minWeight then

          # Pick the one with the smallest head.
          if vertexHead[successor] < vertexHead[minSuccessor] then
            minWeight := weight;
            minSuccessor := successor;
          fi;
        else
          # stop since the list is sorted.
          break;
        fi;
      fi;

      edgeIndex := edgeIndex + 1;
    od;

    # Update min of head's partition if needed.
    if minWeight <> -1 then
      atomic headLock[head] do
        minEdge := headEdge[head];
        if
          minEdge = [] or
          minWeight < minEdge[3] or
          (minWeight = minEdge[3] and vertexHead[minSuccessor] < vertexHead[minEdge[2]])
        then
          headEdge[head] := MakeImmutable([vertex, minSuccessor, minWeight]);
        fi;
      od;
    else
      # No edge could be repicked.
      vertexEdge[vertex] := edgeIndex;
    fi;
  od;
end;
