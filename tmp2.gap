LoadPackage("PGraphs");

#g := GraphP([[3, 4, 5], [3], [1, 2, 4], [1, 3, 5, 6], [1, 4, 6], [4, 5]]);

#colouring := ColorVerticesP(g, 3);
#Print(colouring, "\n");

#colouring := ColorVerticesP(g, 3);
#Print(colouring, "\n");

g := GraphP([[2, 3, 5, 6], [1, 3, 5], [1, 2, 4, 6], [3, 5], [1, 2, 4, 6], [1, 3, 5]]);
colouring := ColorVerticesP(g, 3);
Print(colouring, "\n");
