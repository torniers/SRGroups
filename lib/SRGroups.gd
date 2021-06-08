#! @Title SRGroups: Self-replicating groups of regular rooted trees.

##################################################################################################################
#! @Abstract
##################################################################################################################

#! To do.

##################################################################################################################
#! @Copyright
##################################################################################################################

#! <Package>SRGroups</Package> is free software; you can redistribute it and/or modify it under the terms of the <URL Text="GNU General Public License">http://www.fsf.org/licenses/gpl.html</URL> as published by the Free Software     Foundation; either version 3 of the License, or (at your option) any later version.

##################################################################################################################
#! @Acknowledgements
##################################################################################################################

#! DE210100180, FL170100032.

####################################################################################################################
####################################################################################################################
#! @Chapter Introduction
####################################################################################################################
####################################################################################################################

#! SRGroups is a package which does some interesting and cool things. To be continued...

####################################################################################################################
#! @Chapter Functionality
####################################################################################################################

#! @Section Methods
# a new "category" for the groups acting on regular rooted trees that we study, based on the category of permutation groups
#! @Description
#! Checks whether the input group is a regular-rooted tree group.
DeclareCategory("IsRegularRootedTreeGroup", IsPermGroup);


# a creator function asking for depth, degree, and the permutation group
#! @Description
#! Creates a regular-rooted tree group with attributes <A>RegularRootedTreeGroupDegree</A> and <A>RegularRootedTreeGroupDepth</A>.
DeclareOperation("RegularRootedTreeGroup", [IsInt, IsInt, IsPermGroup]);

# degree and depth are attributes of groups of this type
DeclareAttribute("RegularRootedTreeGroupDegree", IsRegularRootedTreeGroup);
DeclareAttribute("RegularRootedTreeGroupDepth", IsRegularRootedTreeGroup);

# being self-replicating and having sufficient rigid automorphisms are properties (i.e. boolean attributes)
DeclareProperty("IsSelfReplicating", IsRegularRootedTreeGroup);
DeclareProperty("HasSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);

# parent group (projection), maximal extension and representative with sufficient rigid automorphisms also become attributes
DeclareAttribute("ParentGroup", IsRegularRootedTreeGroup);
DeclareAttribute("MaximalExtension", IsRegularRootedTreeGroup);
DeclareAttribute("RepresentativeWithSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);

####################################################################################################################
#! @Section Functions
####################################################################################################################

# Library Functions
#! @Description
#! Main library search function. Has several possible input arguments such as <A>Degree</A>, <A>Level</A> (or <A>Depth</A>), <A>Number</A>, <A>Projection</A>, <A>Subgroup</A>, <A>Size</A>, <A>NumberOfGenerators</A>, and <A>IsAbelian</A>.
DeclareGlobalFunction("AllSRGroups");
#! @BeginExampleSession
#! gap> AllSRGroups(Degree, 2, Level, 4, IsAbelian, true);
#! [ SRGroup(2,4,2), SRGroup(2,4,9), SRGroup(2,4,12), SRGroup(2,4,14) ]
#! gap> Size(last[1]);
#! 16
#! gap> AllSRGroups(Degree,2,Level,4,NumberOfGenerators,4);
#! [ SRGroup(2,4,11), SRGroup(2,4,12), SRGroup(2,4,16), SRGroup(2,4,20), SRGroup(2,4,23), SRGroup(2,4,24),
#!  SRGroup(2,4,25), SRGroup(2,4,26), SRGroup(2,4,40), SRGroup(2,4,43), SRGroup(2,4,46), SRGroup(2,4,47),
#!  SRGroup(2,4,50), SRGroup(2,4,66), SRGroup(2,4,70), SRGroup(2,4,71), SRGroup(2,4,72), SRGroup(2,4,73),
#!  SRGroup(2,4,74), SRGroup(2,4,75), SRGroup(2,4,76), SRGroup(2,4,84), SRGroup(2,4,90), SRGroup(2,4,91),
#!  SRGroup(2,4,93), SRGroup(2,4,95), SRGroup(2,4,97), SRGroup(2,4,102), SRGroup(2,4,108) ]
#! @EndExampleSession
#! @Description
#!   Insert documentation for your function here
DeclareGlobalFunction( "SRGroupsInfo" );
#! @Description
#! Works the same as the main library search function <A>AllSRGroups</A>, except returns useful information about the group(s) in list form: [<A>Generators</A>, <A>Name</A>, <A>Parent Name</A>, <A>Children Names</A>].
DeclareGlobalFunction( "AllSRGroupsInfo" );
#! @BeginExampleSession
#! gap> AllSRGroupsInfo(Degree, 2, Level, 3, IsAbelian, true);
#! [ [ [ (1,5,4,8,2,6,3,7), (1,4,2,3)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,1)", "SRGroup(2,2,1)", [ "SRGroup(2,4,1)", "SRGroup(2,4,2)" ] ],
#! [ [ (1,5,2,6)(3,7,4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,4)", "SRGroup(2,2,2)", [ "SRGroup(2,4,8)", "SRGroup(2,4,9)", "SRGroup(2,4,10)" ] ], 
#! [ [ (1,3)(2,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,5)", "SRGroup(2,2,2)", [ "SRGroup(2,4,11)", "SRGroup(2,4,12)", "SRGroup(2,4,13)", "SRGroup(2,4,14)", "SRGroup(2,4,15)" ] ] ]
#! @EndExampleSession
DeclareGlobalFunction( "CheckSRProjections" );
DeclareGlobalFunction( "StringVariables" );
DeclareGlobalFunction( "UnbindVariables" );
#! @Description
#! Returns all of the degrees currently stored in the SRGroups library.
DeclareGlobalFunction( "SRDegrees" );
#! @BeginExampleSession
#! gap> SRDegrees();
#! [ 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
#! @EndExampleSession
#! @Description
#! Returns all of the levels currently stored in the SRGroups library for an input RegularRootedTreeGroupDegree, <A>deg</A>.
DeclareGlobalFunction( "SRLevels" );
#! @BeginExampleSession
#! gap> SRLevels(2);
#! [ 1, 2, 3, 4 ]
#! @EndExampleSession

# Package Functions
#! @Description
#! The arguments of this method are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! the regular rooted tree group $\mathrm{Aut}(T_{k,n})$ as a permutation group of the $k^{n}$ leaves of $T_{k,n}$.
#!
#! @Arguments k,n
DeclareGlobalFunction( "AutT" );
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,2);
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> Size(G);
#! 8
#! @EndExampleSession

DeclareGlobalFunction( "BelowAction" );
# DeclareGlobalFunction( "ConjugacyClassRepsMaxSelfReplicatingSubgroups" );
# DeclareGlobalFunction( "ConjugacyClassRepsMaxSelfReplicatingSubgroupsWithProjection" );
# DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingSubgroups" );
# DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingSubgroupsWithProjection" );
# DeclareGlobalFunction( "FormatSRFile" );
# DeclareGlobalFunction( "SRGroupFile" );
# DeclareGlobalFunction( "HasseDiagram" );
# DeclareGlobalFunction( "ExtensionsMapping" );
# DeclareGlobalFunction( "PermutationMapping" );
# DeclareGlobalFunction( "ExtendSRGroup" );
# DeclareGlobalFunction( "CombineSRFiles" );
# DeclareGlobalFunction( "ReorderSRFiles" );
# DeclareGlobalFunction( "NumberExtensionsUnformatted" );
DeclareGlobalFunction( "Level" );