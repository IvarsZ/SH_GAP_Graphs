LoadPackage("AutoDoc");

AutoDoc(
    "Graphs" : 
    autodoc := true,
    scaffold := rec(
        includes := [
            ]
    )
);

# Create VERSION file for "make towww"
PrintTo( "VERSION", PackageInfo( "Graphs" )[1].Version );

QUIT;
