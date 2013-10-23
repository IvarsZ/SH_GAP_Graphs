DeclareRepresentation("IsDHeapRep", IsComponentObjectRep, ["d", "heap"]);

#TODO add size?
InstallGlobalFunction(EmptyDHeap,  function(d)

  return Objectify(NewType(NewFamily("Graphs"), IsGraph and IsGraphAdjacencyListRep),
                   rec(d := d, heap := []));
end);

# PRIVATE FUNCTIONS AND VARIABLES RECORD
D_HEAP := rec();

InstallGlobalFunction(Add, function(node)

end);

InstallGlobalFunction(Remove, function()

end);
