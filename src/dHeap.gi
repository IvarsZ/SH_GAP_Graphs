DeclareRepresentation("IsDHeapRep", IsComponentObjectRep, ["d", "heap"]);

InstallGlobalFunction(EmptyDHeap,  function(d, isLarger)

  return Objectify(NewType(NewFamily("DHeaps"), IsDHeap and IsDHeapRep),
                   rec(d := d, nodes := [], isLarger := isLarger));
end);

D_HEAP := rec(
  
  size := function(dHeap)
    return Length(dHeap!.nodes);
  end,

  isEmpty := function(dHeap)
    return D_HEAP.size(dHeap) = 0;
  end,

  sink :=  function(dHeap, position)
    local i, min;

    while (dHeap!.d * (position - 1) + 2 <= D_HEAP.size(dHeap)) do
    
      # Picks the smallest child.
      i := dHeap!.d * (position - 1) + 2;
      min := i;
      while (i < dHeap!.d * position + 2 and i <= D_HEAP.size(dHeap)) do

        # TODO use proper smaller.
        if (D_HEAP.larger(dHeap, min, i)) then
          min := i;
        fi;
      
        i := i + 1;
      od;

      # If the element is greater than or equal to its smallest child,
      if (D_HEAP.larger(dHeap, position, min)) then
        
        # Otherwise swaps them.
        D_HEAP.swap(dHeap, min, position);
        position := min;
      else
        return;
      fi;
    od;
  end,

  swim := function(dHeap, position)
    local next;

    # Keeps exchanging the element at k-th position with its parent till it isn't smaller than its parent.
    while (position > 1 and D_HEAP.larger(dHeap, Int(Ceil(Float((position - 1)/ dHeap!.d))), position)) do
     
      next := Int(Ceil(Float((position - 1)/dHeap!.d)));
      D_HEAP.swap(dHeap, position, next);
      position := next;
    od;
  end,

  
  larger := function(dHeap, i, j)
    return dHeap!.isLarger(dHeap!.nodes[i], dHeap!.nodes[j]);
  end,
        
  swap := function(dHeap, firstPosition, secondPosition)
    local tmp;
    
    tmp := dHeap!.nodes[secondPosition];
    dHeap!.nodes[secondPosition] := dHeap!.nodes[firstPosition];
    dHeap!.nodes[firstPosition] := tmp;
  end
);

InstallGlobalFunction(Enqueue, function(dHeap, node)

  # Adds the element at the end of the array, the heap might become improper,
  # as the element could be bigger than its parent.
  Add(dHeap!.nodes, node);

  # Makes the heap proper again, by making the added element to swim up
  # to a position in the heap, where it is not greater than its parent.
  D_HEAP.swim(dHeap, D_HEAP.size(dHeap));

end);

InstallGlobalFunction(Dequeue, function(dHeap)
  local top;

  top := dHeap!.nodes[1];
  dHeap!.nodes[1] := dHeap!.nodes[D_HEAP.size(dHeap)];
  Remove(dHeap!.nodes, D_HEAP.size(dHeap));

  # Makes the heap proper again, by sinking the element placed at the top
  # to a position in the heap, where it not larger than its children.
  D_HEAP.sink(dHeap, 1);

  return top;
end);

