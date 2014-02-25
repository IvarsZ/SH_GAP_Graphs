LoadPackage("Graphs");

g := Graph([[3, 4, 5], [3], [1, 2, 4], [1, 3, 5, 6], [1, 4, 6], [4, 5]]);

colouring := PColouring(g, 3);
Print(colouring, "\n");

colouring := PColouring(g, 2);
Print(colouring, "\n");

g := Graph([[2, 3, 5, 6], [1, 3, 5], [1, 2, 4, 6], [3, 5], [1, 2, 4, 6], [1, 3, 5]]);
colouring := PColouring(g, 3);
Print(colouring, "\n");
