LoadPackage("PGraphs");

g := GraphP([[2, 3, 4, 5, 6], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [7, 8, 9, 10, 11], [12, 13, 14, 15, 16], [12, 13, 14, 15, 16], [12, 13, 14, 15, 16], [12, 13, 14, 15, 16], [12, 13, 14, 15, 16], [], [], [], [], []]);

order := BFSP(g, 1);
for level in order do
  for sublist in level do
    Print(FromAtomicList(sublist));
  od;
  Print("\n");
od;
