#! @AutoDoc
#! @Chapter Graphs
#! @Section D-ary Heaps

#! TODO : heap description.
DeclareCategory("IsDHeap", IsObject);


#! @Description
#!
#! Constructs an empty d ary heap.
#!
#!  @Arguments d, isLarger
#!  <List>
#!  <Mark><A>d</A></Mark>
#!  <Item>
#!    The number of successor nodes for each node.
#!  </Item>
#!
#!  <Mark><A>isLarger</A></Mark>
#!  <Item>
#!    Function comparing two nodes of the heap, returning true if the first is larger.
#!  </Item>
#!  </List>
#!
#! @Returns the empty d-ary heap. 
#!
DeclareGlobalFunction("EmptyDHeap");

#! @Description
#!
#! Adds a node to a heap in its proper place.
#!
#!  @Arguments node
#!  <List>
#!  <Mark><A>node</A></Mark>
#!  <Item>
#!    The node to add to the heap.
#!  </Item>
#!  </List>
#!
#! @Returns nothing.
#!
DeclareGlobalFunction("Enqueue");

#!
#! Removes the smallest element of a heap.
#!
#! @Returns the smallest element of the heap.
#!
DeclareGlobalFunction("Dequeue");
