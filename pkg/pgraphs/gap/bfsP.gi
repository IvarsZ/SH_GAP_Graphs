BFSP_REC := rec();
BFSP_REC.TASKS_COUNT := 7;

# TODO adjustable tasks count? What if graph doesn't have enough vertices?
# TODO some kind of iterator for the returned results.

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(BFSP, function(graph, start)
  local i, currentVertices, nextVertices, isVisited, order, partition, task, tasks;

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

    # prepare lists for children vertices.
    nextVertices := FixedAtomicList(BFSP_REC.TASKS_COUNT);
    MakeWriteOnceAtomic(nextVertices);
    for i in [1..BFSP_REC.TASKS_COUNT] do
      nextVertices[i] := AtomicList(1);
    od;

    # visit all vertices in the current layer partition by partition.
    tasks := [];
    for partition in currentVertices do
      task := RunTask(BFSP_REC.visitPartition, graph, partition, isVisited, nextVertices);
      Add(tasks, task);
    od;

    WaitTasks(tasks);
    currentVertices := nextVertices;
    Add(order, nextVertices);
  od;
  
  Remove(order, Length(order)); # The last level is empty.
  return order;
end);

BFSP_REC.visitPartition := function(graph, partition, isVisited, nextVertices)
  local vertex, successor, partitionIndex, offset;

  # TODO The id seems to often stay the same.
  Print("Partition: ", ThreadID(CurrentThread()), "\n");

  for vertex in partition do
    BFSP_REC.visitVertex(graph, vertex, isVisited, nextVertices);
  od;
end;

BFSP_REC.visitVertex := function(graph, vertex, isVisited, nextVertices)
  local successor, partitionIndex, offset;

  offset := ThreadID(CurrentThread()) mod BFSP_REC.TASKS_COUNT + 1;
  partitionIndex := offset;

  for successor in VertexSuccessorsP(graph, vertex) do
    if IsBound(isVisited[successor]) = false then

      #Print(partitionIndex, "\n");
      Add(nextVertices[partitionIndex], successor);
      isVisited[successor] := true;

      partitionIndex := (partitionIndex + offset) mod BFSP_REC.TASKS_COUNT + 1;
    fi;
  od;
end;

MakeImmutable(BFSP_REC); # To have access to task count in threads.
