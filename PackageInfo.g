#
# SRGroups: Self-replicating groups of regular rooted trees.
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "SRGroups",
Subtitle := "Self-replicating groups of regular rooted trees.",
Version := "0.1",
Date := "17/12/2020", # dd/mm/yyyy format
License := "GPL-2.0-or-later",

Persons := [
  rec(
    FirstNames := "Sam",
    LastName := "King",
    #WWWHome := TODO,
    Email := "sam.king@newcastle.edu.au",
    IsAuthor := true,
    IsMaintainer := true,
    PostalAddress := "University Drive, Callaghan NSW 2308",
    Place := "Newcastle, Australia",
    Institution := "The University of Newcastle",
  ),
  rec(
    FirstNames := "Sarah",
    LastName := "Shotter",
    #WWWHome := TODO,
    Email := "sarah.shotter@newcastle.edu.au",
    IsAuthor := true,
    IsMaintainer := true,
    PostalAddress := "University Drive, Callaghan NSW 2308",
    Place := "Newcastle, Australia",
    Institution := "The University of Newcastle",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/SamSGKing/SRGroups",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://SamSGKing.github.io/SRGroups/",
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "SRGroups",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Self-replicating groups of regular rooted trees.",
),

Dependencies := rec(
  GAP := ">= 4.10",
  NeededOtherPackages := [ ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


