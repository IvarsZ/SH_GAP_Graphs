# Record for private members.
PGRAPH := rec();
PGRAPH.PBFS := rec();
PGRAPH.PColouring := rec();
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

  # TODO The id seems to often stay the same.
  Print("Partition: ", ThreadID(CurrentThread()), "\n");

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

      #Print(partitionIndex, "\n");
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

InstallGlobalFunction(PColouring, function(graph, numberOfColours)
  local order, colouring;

  # Locks
  ShareObj(graph!.successors);
  atomic readonly graph!.successors do

    order := PGRAPH.orderVerticesForColouring(graph, numberOfColours);
    MakeImmutable(order);

    colouring := EmptyPlist(VertexCount(graph));
    MakeImmutable(colouring);

    return PGRAPH.PColouring.colourVertex(graph, numberOfColours, order, colouring, 1);
  od;
end);

PGRAPH.PColouring.colourVertex := function(graph, numberOfColours, order, colouring, vertexIndex)
  local colour, isValid, successor, vertex, task, tasks, colouringCopy, taskIndex, result;
  
  atomic readonly graph!.successors do

    if vertexIndex > VertexCount(graph) then
      return colouring;
    fi;

    tasks := [];
    vertex := order[vertexIndex];

    for colour in [1..numberOfColours] do
      isValid := true;
      for successor in VertexSuccessors(graph, vertex) do
        if IsBound(colouring[successor]) and colouring[successor] = colour then
          isValid := false;
          break;
        fi;
      od;

      if isValid  = true then
        colouringCopy := ShallowCopy(colouring);
        colouringCopy[vertex] := colour;
        MakeImmutable(colouringCopy);
        task := RunTask(PGRAPH.PColouring.colourVertex, graph, numberOfColours, order, colouringCopy, vertexIndex + 1);
        Add(tasks, task);
      fi;
    od;
  
    WaitTasks(tasks);
    for task in tasks do
      result := TaskResult(task);
      if result <> false then
        return result;
      fi;
    od;
 
    return false;
  od;
end;

# TODO parallel ordering, actually use it, bunch few last vertices together.

# Preordes vertices for coluring a graph by taking the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
PGRAPH.orderVerticesForColouring := function(graph, numberOfColours)
 local order, position, isOrderChanged, degrees, verticesToOrderEnd, i, vertex, successor; 
 
  atomic readonly graph!.successors do
    
    # Have a list of vertex degrees and their order.
    order := EmptyPlist(VertexCount(graph));
    degrees := EmptyPlist(VertexCount(graph));
    for vertex in [1..VertexCount(graph)] do
      order[vertex] := vertex;
      degrees[vertex] := Length(VertexSuccessors(graph, vertex));
    od;

    verticesToOrderEnd := VertexCount(graph);
  
    # Try to reorder vertices untill no more reordering was done.
    isOrderChanged := true;
    while (isOrderChanged) do
      isOrderChanged := false;

      # For each vertex that has not been ordered, yet.
      i := 1;
      while (i <= verticesToOrderEnd) do
        vertex := order[i];

        # If it has few enough unordered adjacent vertices,
        if (degrees[vertex] < numberOfColours) then

          # colour it last - order it at the end.
          order[i] := order[verticesToOrderEnd];
          order[verticesToOrderEnd] := vertex;

          # Now each adjacent vertex has one less unordered adjacent vertex.
          for successor in VertexSuccessors(graph, vertex) do
            degrees[successor] := degrees[successor] - 1;
          od;

          verticesToOrderEnd := verticesToOrderEnd - 1;
          isOrderChanged := true;

        else
          i := i + 1;
        fi;
      od;
    od;
  od;

  return order;
end;

MakeImmutable(PGRAPH);
