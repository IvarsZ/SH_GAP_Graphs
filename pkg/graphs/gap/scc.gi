# Record for private functions.
SCC_REC := rec();

# 
# Finds strongly connected components of the given graph.
#
# It returns a list where each vertex is assigned its strongly connected components number,
# the numbering starts from the largest index of a vertex + 1.
#
InstallGlobalFunction(StrongComponents, function(graph)
  local p, vertex, SCC_DFS;
  p := rec(); # Global params.

  p.S := rec(top := 0, nodes := []); # Stack of visited vertices in one dfs run.
  p.B := rec(top := 0, nodes := []); # Stack of weekly visited vertices (only one direction).

  p.I := EmptyPlist(VertexCount(graph)); # Lists the components index for each vertex.
  for vertex in [1..VertexCount(graph)] do
    p.I[vertex] := 0;
  od;

  # Run dfs for each unvisited vertex.
  p.c := VertexCount(graph);
  for vertex in [1..VertexCount(graph)] do
    if (p.I[vertex] = 0) then
      SCC_REC.DFS(graph, vertex, p);
    fi;
  od;

  return p.I;
end);

 # Recursive depth first search for finding components.
SCC_REC.DFS := function(graph, vertex, p)
  local successor;

  # The vertex is visited now so push it to S and B.
  p.S.top := p.S.top + 1;
  p.S.nodes[p.S.top] := vertex;
  p.B.top := p.B.top + 1;
  p.B.nodes[p.B.top] := p.S.top;

  # Mark the vertex as visited.
  p.I[vertex] := p.S.top;

  for successor in VertexSuccessors(graph, vertex) do
   
    # Run dfs on all unvisited successor vertices recursively.
    if p.I[successor] = 0 then
      SCC_REC.DFS(graph, successor, p);
    else
      
      # If the successor has been visited in this iteration, cutoff the path after it from B.
      while p.I[successor] < p.B.nodes[p.B.top] do
        p.B.top := p.B.top - 1;
      od;
    fi;
  od;

  # If there was no cutoff, 
  #Print("I ", p.I, " at ", vertex, "\n");
  #Print("S ", p.S.nodes, " ", p.S.top, "\n");
  #Print("B ", p.B.nodes, " ", p.B.top, "\n");
  if (p.I[vertex] = p.B.nodes[p.B.top]) then

    # the vertex is in a new component.
    p.B.top := p.B.top - 1;
    p.c := p.c + 1;

    # So add all visited vertices after the vertex to the component.
    while (vertex <> p.S.nodes[p.S.top]) do
      p.I[p.S.nodes[p.S.top]] := p.c;
      p.S.top := p.S.top - 1;
    od;

    # And the vertex itself as well.
    p.I[p.S.nodes[p.S.top]] := p.c;
    p.S.top := p.S.top - 1;

    #Print("NEW COMPONENT at ", vertex, "\n");
    #Print("I ", p.I, "\n");
    #Print("S ", p.S.nodes, " ", p.S.top, "\n");
    #Print("B ", p.B.nodes, " ", p.B.top, "\n");

  fi;
end;
