#! @AutoDoc
#! @Chapter Graphs
#! @Section D-ary Heaps

#! A d-ary tree where each child node is not larger than its parent node.
DeclareCategory("IsDHeap", IsObject);

#! @Description
#! @Arguments d, isLarger
#!
#! @Returns a new empty d ary heap.
#! Constructs the empty d ary heap with the given arguments:
#!
#!  <List>
#!  <Mark><A>d</A></Mark>
#!  <Item>
#!    The number of successor nodes for each node, the very last node might have fewer.
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
#! @Arguments heap, node
#!
#! Adds a the given node to the given heap in its proper place.
#!
DeclareGlobalFunction("Enqueue");

#! @Description
#! @Arguments heap
#!
#! @Returns the smallest element of the given heap and removes it.
DeclareGlobalFunction("Dequeue");
