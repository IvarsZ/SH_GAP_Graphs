BFSP_REC := AtomicRecord(2); # Atomic to have access to task count in threads.
BFSP_REC.TASKS_COUNT := NextPrimeInt(GAPInfo.KernelInfo.NUM_CPUS^2);

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(BFSP, function(graph, start)
  local i, currentVertices, nextVertices, isVisited, order, partition, task, tasks, offset;

  # Init search.
  order := [];
  order[1] := AtomicList(1, []);
  order[1][1] := FixedAtomicList(1, start);

  isVisited := FixedAtomicList(VertexCountP(graph));
  MakeWriteOnceAtomic(isVisited);

  # Start is the first vertex traversed.
  currentVertices := [[start]];
  MakeImmutable(currentVertices);
  isVisited[start] := true;

  # While there are vertices in the current level,
  while (BFSP_REC.isEmpty2DList(currentVertices) = false) do

    offset := 1;

    # prepare lists for children vertices.
    nextVertices := FixedAtomicList(BFSP_REC.TASKS_COUNT);
    MakeWriteOnceAtomic(nextVertices);
    for i in [1..BFSP_REC.TASKS_COUNT] do
      nextVertices[i] := AtomicList(1);
    od;
      
    # visit all vertices in the current layer partition by partition.
    tasks := [];
    for partition in currentVertices do

      if Length(partition) > 0 then # Don't launch unneeded tasks.
        task := RunTask(BFSP_REC.visitPartition, graph, partition, isVisited, nextVertices, offset);
        Add(tasks, task);

        # Increase offset.
        offset := offset mod (BFSP_REC.TASKS_COUNT - 1) + 1;
      fi;
    od;

    WaitTasks(tasks);
    currentVertices := nextVertices;
    Add(order, nextVertices);
  od;
  
  Remove(order, Length(order)); # The last level is empty.
  return order;
end);

BFSP_REC.isEmpty2DList := function(list)
  local sublist, element;

  for sublist in list do
    for element in sublist do
      return false;
    od;
  od;

  return true;
end;

BFSP_REC.visitPartition := function(graph, partition, isVisited, nextVertices, offset)
  local vertex, successor, partitionIndex;

  # Visits partition by visiting all its vertices.
  for vertex in partition do
    BFSP_REC.visitVertex(graph, vertex, isVisited, nextVertices, offset);
  od;
end;

BFSP_REC.visitVertex := function(graph, vertex, isVisited, nextVertices, offset)
  local successor, partitionIndex;

  partitionIndex := offset;

  # Adds all unadded adjacent vertices of the vertex.
  for successor in VertexSuccessorsP(graph, vertex) do
    if IsBound(isVisited[successor]) = false then
    
      isVisited[successor] := true;
      Add(nextVertices[partitionIndex], successor);
      
      partitionIndex := (partitionIndex + offset) mod BFSP_REC.TASKS_COUNT + 1;
    fi;
  od;
  
  return partitionIndex;
end;
