LoadPackage("AutoDoc");

AutoDoc(
    "PGraphs" : 
    autodoc := true,
    scaffold := rec(
        includes := [
            ]
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "PGraphs" )[1].Version );

QUIT;
