#! @Chapter Graphs
#! @Section Graphs

#! @Description
#!
#! The representation is a record with an adjacency list called successors where each vertex v has a list of end vertices for each edge starting at v.
#!
if IsBound(IsGraphAdjacencyListRep) = false then
  DeclareRepresentation("IsGraphAdjacencyListRep", IsComponentObjectRep, ["successors"]);
fi;

InstallGlobalFunction(GraphP, function(successorsLists)
  local atomicSuccessorsList, successors;

  # Make the successors lists atomic.
  atomicSuccessorsList := AtomicList([]);
  for successors in successorsLists do
    Add(atomicSuccessorsList, AtomicList(successors));
  od;

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := atomicSuccessorsList));
end);

InstallGlobalFunction(EmptyGraphP,  function()

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(successors := AtomicList([])));
end);

#
# Adds a new vertex to the given graph.
#
InstallGlobalFunction(AddVertexP, function(graph)

  # New vertex has no successors.
  Add(graph!.successors, AtomicList([]));
end);

#
# Adds an edge to the given graph from the given start vertex to the given end vertex.
#
InstallGlobalFunction(AddEdgeP, function(graph, start, end_)

  # The end vertex becomes a successor of the start vertex, as the edge connects them.
  Add(VertexSuccessorsP(graph, start), end_);
end);

#
# Returns successor vertices of the given vertex in the given graph.
#
InstallGlobalFunction(VertexSuccessorsP, function(graph, vertex)

  return graph!.successors[vertex];
end);

InstallGlobalFunction(VertexSuccessorP, function(graph, vertex, edgeIndex)
  return graph!.successors[vertex][edgeIndex];
end);

#
# Returns the number of vertices in the given graph.
#
InstallGlobalFunction(VertexCountP, function(graph)

  return Length(graph!.successors);
end);

# Record for private members.
PBFS_REC := rec();
PColouring_REC := rec();
PBFS_REC.TASKS_COUNT := 7;

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
  while (PBFS_REC.isEmpty2DList(currentVertices) = false) do

    # prepare lists for children vertices.
    nextVertices := FixedAtomicList(PBFS_REC.TASKS_COUNT);
    MakeWriteOnceAtomic(nextVertices);
    for i in [1..PBFS_REC.TASKS_COUNT] do
      nextVertices[i] := AtomicList(1);
    od;

    # visit all vertices in the current layer partition by partition.
    tasks := [];
    for partition in currentVertices do
      task := RunTask(PBFS_REC.visitPartition, graph, partition, isVisited, nextVertices);
      Add(tasks, task);
    od;

    WaitTasks(tasks);
    currentVertices := nextVertices;
    Add(order, nextVertices);
  od;
  
  Remove(order, Length(order)); # The last level is empty.
  return order;
end);

PBFS_REC.visitPartition := function(graph, partition, isVisited, nextVertices)
  local vertex, successor, partitionIndex, offset;

  # TODO The id seems to often stay the same.
  Print("Partition: ", ThreadID(CurrentThread()), "\n");

  for vertex in partition do
    PBFS_REC.visitVertex(graph, vertex, isVisited, nextVertices);
  od;
end;

PBFS_REC.visitVertex := function(graph, vertex, isVisited, nextVertices)
  local successor, partitionIndex, offset;

  offset := ThreadID(CurrentThread()) mod PBFS_REC.TASKS_COUNT + 1;
  partitionIndex := offset;

  for successor in VertexSuccessorsP(graph, vertex) do
    if IsBound(isVisited[successor]) = false then

      #Print(partitionIndex, "\n");
      Add(nextVertices[partitionIndex], successor);
      isVisited[successor] := true;

      partitionIndex := (partitionIndex + offset) mod PBFS_REC.TASKS_COUNT + 1;
    fi;
  od;
end;

InstallGlobalFunction(ColorVerticesP, function(graph, numberOfColours)
  local order, colouring, orderIndex, vertex, isColourUsed, successor;

  order := PColouring_REC.orderVerticesForColouring(graph, numberOfColours);
  MakeImmutable(order);

  colouring := EmptyPlist(VertexCountP(graph));
  MakeImmutable(colouring);

  colouring := PColouring_REC.colourVertex(graph, numberOfColours, order, colouring, 1);
  colouring := ShallowCopy(colouring);

  if colouring <> false then
    # Greedy colour the rest low degree vertices.
    # Loop over part of a list.
    for orderIndex in [(order[2]+1)..Length(order[1])] do

      vertex := order[1][orderIndex];
      isColourUsed := BlistList([1..numberOfColours], []);
      for successor in VertexSuccessorsP(graph, vertex) do
        if IsBound(colouring[successor]) then
          isColourUsed[colouring[successor]] := true;
        fi;
      od;
      
      colouring[vertex] := Position(isColourUsed, false);
    od;
  fi;

  return colouring;
end);

PColouring_REC.colourVertex := function(graph, numberOfColours, order, colouring, vertexIndex)
  local colour, isValid, successor, vertex, task, tasks, colouringCopy, taskIndex, result;

  if vertexIndex > order[2] then
    return colouring;
  fi;

  tasks := [];
  vertex := order[1][vertexIndex];

  for colour in [1..numberOfColours] do
    isValid := true;
    for successor in VertexSuccessorsP(graph, vertex) do
      if IsBound(colouring[successor]) and colouring[successor] = colour then
        isValid := false;
        break;
      fi;
    od;

    if isValid  = true then
      colouringCopy := ShallowCopy(colouring);
      colouringCopy[vertex] := colour;
      MakeImmutable(colouringCopy);
      task := RunTask(PColouring_REC.colourVertex, graph, numberOfColours, order, colouringCopy, vertexIndex + 1);
      Add(tasks, task);
    fi;
  
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

# TODO if keeping wait for all, then don't create new task for last colour.
# TODO bunch few last vertices together.

# Preordes vertices for coluring a graph by taking the vertices of degree smaller than the number of colours last. Note in such case the vertex does not contribute to the degree of other vertices anymore.
PColouring_REC.orderVerticesForColouring := function(graph, numberOfColours)
 local order, position, isOrderChanged, degrees, verticesToOrderEnd, i, vertex, successor; 
 
  # Have a list of vertex degrees and their order.
  order := EmptyPlist(VertexCountP(graph));
  degrees := EmptyPlist(VertexCountP(graph));
  for vertex in [1..VertexCountP(graph)] do
    order[vertex] := vertex;
    degrees[vertex] := Length(VertexSuccessorsP(graph, vertex));
  od;

  verticesToOrderEnd := VertexCountP(graph);

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
        for successor in VertexSuccessorsP(graph, vertex) do
          degrees[successor] := degrees[successor] - 1;
        od;

        verticesToOrderEnd := verticesToOrderEnd - 1;
        isOrderChanged := true;

      else
        i := i + 1;
      fi;
    od;
  od;

  return [order, verticesToOrderEnd];
end;

MakeImmutable(PBFS_REC); # To have access to task count in threads.
