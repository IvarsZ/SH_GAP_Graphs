# Record for private members.
PGRAPH := rec();
PGRAPH.PBFS := rec();
PGRAPH.PBFS.TASKS_COUNT := 7;

# TODO adjustable tasks count? What if graph doesn't have enough vertices?
# TODO some kind of iterator for the returned results.

#
# Returns the vertices of the given graph in a breadth first search order
# starting at the given start vertex.
#
InstallGlobalFunction(PBFS, function(graph, start)
  local i, currentVertices, nextVertices, isVisited, order, partition, task, tasks;

  # Locks.
  ShareObj(graph!.successors);
  atomic readonly graph!.successors do

    # Init search.
    order := [];
    order[1] := AtomicList(1, []);
    order[1][1] := FixedAtomicList(1, start);

    isVisited := FixedAtomicList(VertexCount(graph));
    MakeWriteOnceAtomic(isVisited);

    # Start is the first vertex traversed.
    currentVertices := [[start]];
    MakeImmutable(currentVertices);
    isVisited[start] := true;

    # While there are vertices in the current level,
    while (PGRAPH.PBFS.isEmpty2DList(currentVertices) = false) do

      # prepare lists for children vertices.
      nextVertices := FixedAtomicList(PGRAPH.PBFS.TASKS_COUNT);
      MakeWriteOnceAtomic(nextVertices);
      for i in [1..PGRAPH.PBFS.TASKS_COUNT] do
        nextVertices[i] := AtomicList(1);
      od;

      # visit all vertices in the current layer partition by partition.
      tasks := [];
      for partition in currentVertices do
        task := RunTask(PGRAPH.PBFS.visitPartition, graph, partition, isVisited, nextVertices);
        Add(tasks, task);
      od;

      WaitTasks(tasks);
      currentVertices := nextVertices;
      Add(order, nextVertices);
    od;
  od;
  
  Remove(order, Length(order)); # The last level is empty.
  return order;
end);

PGRAPH.PBFS.visitPartition := function(graph, partition, isVisited, nextVertices)
  local vertex, successor, partitionIndex, offset;

  #Print("Partition: ", ThreadID(CurrentThread()), "\n");

  atomic readonly graph!.successors do
    for vertex in partition do
      PGRAPH.PBFS.visitVertex(graph, vertex, isVisited, nextVertices);
    od;
  od;
end;

PGRAPH.PBFS.visitVertex := function(graph, vertex, isVisited, nextVertices)
  local successor, partitionIndex, offset;

  offset := ThreadID(CurrentThread()) mod PGRAPH.PBFS.TASKS_COUNT + 1;
  partitionIndex := offset;

  for successor in VertexSuccessors(graph, vertex) do
    if IsBound(isVisited[successor]) = false then

      Add(nextVertices[partitionIndex], successor);
      isVisited[successor] := true;

      partitionIndex := (partitionIndex + offset) mod PGRAPH.PBFS.TASKS_COUNT + 1;
    fi;
  od;
end;

PGRAPH.PBFS.isEmpty2DList := function(list)
  local sublist, element;
  for sublist in list do
    for element in sublist do
      return false;
    od;
  od;

  return true;
end;

MakeImmutable(PGRAPH);
