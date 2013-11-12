SetPackageInfo( rec(

  PackageName := "Graphs",

  Subtitle := "GAP package for creating and manipulating graphs",

  Version := "0.0.1",
  Date := "09/11/2013",

  PackageWWWHome := "TODO",
  ArchiveURL := "TODO",
  ArchiveFormats := "TODO",
  README_URL := "TODO",
  PackageInfoURL := "TODO",
  AbstractHTML := "TODO",
  PackageWWWHome := "TODO",

  Persons := [
    rec(
      LastName := "Ivars",
      FirstNames := "Zubkans",
      IsAuthor := true,
      IsMaintainer := true,
      Email := "iz2@st-andrews.ac.uk"
    )
  ],

  Status := "dev",

  PackageDoc := rec(
    BookName  := ~.PackageName,
    ArchiveURLSubset := ["doc"],
    HTMLStart := "doc/chap0.html",
    PDFFile   := "doc/manual.pdf",
    SixFile   := "doc/manual.six",
    LongTitle := ~.Subtitle
  ),

  Dependencies := rec(

    GAP := "4.5.3",
    NeededOtherPackages := [["GAPDoc", "1.5"]],
    SuggestedOtherPackages := [],
    ExternalConditions := []
  ),

  AvailabilityTest := function()
    return true;
  end,

  TestFile := "test/testAll.test",

  Keywords := ["Graphs", "Edge weighted graphs", "Graph algorithms"]

));
