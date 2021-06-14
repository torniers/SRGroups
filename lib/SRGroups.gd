#! @Title SRGroups: Self-replicating groups of regular rooted trees.

##################################################################################################################
#! @Abstract
##################################################################################################################

#! <Package>SRGroups</Package> is a package for searching up self-replicating groups of regular rooted trees and performing computations on these groups. This package allows the user to generate more self-replicating groups at greater depths with its in-built functions, and is an extension of the <Package>transgrp</Package> package.

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
#! The argument of this category is any permutation group, <A>G</A>. Checks whether <A>G</A> is a regular rooted tree group.
#! @Arguments G
DeclareCategory("IsRegularRootedTreeGroup", IsPermGroup);


# degree and depth are attributes of groups of this type
#! @Description
#! The argument of this attribute is any regular rooted tree group, <A>G</A>.
#! @Returns
#! The degree of <A>G</A>.
#! @Arguments G
DeclareAttribute("RegularRootedTreeGroupDegree", IsRegularRootedTreeGroup);
#! @BeginExampleSession
#! gap> RegularRootedTreeGroupDepth(AutT(2,3));
#! 3
#! @EndExampleSession


#! @Description
#! The argument of this attribute is any regular rooted tree group, <A>G</A>.
#! @Returns
#! The depth of <A>G</A>.
#! @Arguments G
DeclareAttribute("RegularRootedTreeGroupDepth", IsRegularRootedTreeGroup);
#! @BeginExampleSession
#! gap> RegularRootedTreeGroupDegree(AutT(2,3));
#! 2
#! @EndExampleSession

# a creator function asking for depth, degree, and the permutation group
#! @Description
#! The arguments of this operation are a regular rooted tree group, <A>G</A>, and its degree <A>k</A> and depth <A>n</A>.
#! @Returns
#! The regular rooted tree group <A>G</A> as an object of the category <Ref Filt="IsRegularRootedTreeGroup"/>, with attributes <Ref Attr="RegularRootedTreeGroupDegree"/> and <Ref Attr="RegularRootedTreeGroupDepth"/>.
#! @Arguments k,n,G
DeclareOperation("RegularRootedTreeGroup", [IsInt, IsInt, IsPermGroup]);

# being self-replicating and having sufficient rigid automorphisms are properties (i.e. boolean attributes)
#! @Description
#! The argument of this property is any regular rooted tree group, <A>G</A>. Tests whether <A>G</A> satisfies the self-replicating conditions.
#!
#! @Arguments G
#!
DeclareProperty("IsSelfReplicating", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> IsSelfReplicating(AutT(2,3));
#! true
#! @EndExampleSession

#! @Description
#! The argument of this property is any regular rooted tree group, <A>G</A>. Tests whether <A>G</A> has sufficient rigid automorphisms.
#!
#! @Arguments G
#!
DeclareProperty("HasSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> HasSufficientRigidAutomorphisms(AutT(2,3));
#! true
#! @EndExampleSession

# parent group (projection), maximal extension and representative with sufficient rigid automorphisms also become attributes
#! @Description
#! The argument of this attribute is any regular rooted tree group, <A>G</A>, of degree <A>k</A> and depth <A>n</A>.
#! @Returns
#! The image of <A>G</A> when projected onto the automorphism group of degree <A>k</A> and depth <A>n-1</A>.
#!
#! @Arguments G
#!
DeclareAttribute("ParentGroup", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,3); H:=AutT(2,2);
#! Group([ (1,2), (3,4), (5,6), (7,8), (1,3)(2,4), (5,7)(6,8), (1,5)(2,6)(3,7)(4,8) ])
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> ParentGroup(G);
#! Group([ (1,2), (1,3)(2,4), (3,4) ])
#! gap> H=last;
#! true
#! @EndExampleSession

#! @Description
#! The argument of this attribute is any regular rooted tree group, <A>G</A>, of degree <A>k</A> and depth <A>n</A>.
#! @Returns
#! The maximal extension of <A>G</A>, <A>M(G)</A>, that is a subgroup of the automorphism group of degree <A>k</A> and depth <A>n+1</A>.
#!
#! @Arguments G
#!
DeclareAttribute("MaximalExtension", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,3); H:=AutT(2,4);
#! Group([ (1,2), (3,4), (5,6), (7,8), (1,3)(2,4), (5,7)(6,8), (1,5)(2,6)(3,7)(4,8) ])
#! <permutation group of size 32768 with 15 generators>
#! gap> MaximalExtension(G);
#! <permutation group with 11 generators>
#! gap> H=last;
#! true
#! @EndExampleSession

#! @Description
#! The argument of this attribute is any regular rooted tree group, <A>G</A>. 
#! @Returns
#! A conjugate of <A>G</A> with sufficient rigid automorphisms.
#!
#! @Arguments G
#!
DeclareAttribute("RepresentativeWithSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap>
#! @EndExampleSession

####################################################################################################################
#! @Section Library Functions
####################################################################################################################

DeclareGlobalFunction( "SRGroupsInfo" );

#! @Description
#! Main library search function. Has several possible input arguments such as <A>Degree</A>, <A>Level</A> (or <A>Depth</A>), <A>Number</A>, <A>Projection</A>, <A>Subgroup</A>, <A>Size</A>, <A>NumberOfGenerators</A>, and <A>IsAbelian</A>. Order of the inputs do not matter.
#! @Returns
#! All of the self-replicating group(s) stored as objects satisfying all of the provided input arguments.
#! @Arguments Input1, val1, Input2, val2, ...
DeclareGlobalFunction("AllSRGroups");
#! @BeginExampleSession
#! gap> AllSRGroups(Degree, 2, Level, 4, IsAbelian, true);
#! [ SRGroup(2,4,2), SRGroup(2,4,9), SRGroup(2,4,12), SRGroup(2,4,14) ]
#! gap> Size(last[1]);
#! 16
#! gap> AllSRGroups(Degree, 2, Level, 4, NumberOfGenerators, 4);
#! [ SRGroup(2,4,11), SRGroup(2,4,12), SRGroup(2,4,16), SRGroup(2,4,20), SRGroup(2,4,23), SRGroup(2,4,24),
#!  SRGroup(2,4,25), SRGroup(2,4,26), SRGroup(2,4,40), SRGroup(2,4,43), SRGroup(2,4,46), SRGroup(2,4,47),
#!  SRGroup(2,4,50), SRGroup(2,4,66), SRGroup(2,4,70), SRGroup(2,4,71), SRGroup(2,4,72), SRGroup(2,4,73),
#!  SRGroup(2,4,74), SRGroup(2,4,75), SRGroup(2,4,76), SRGroup(2,4,84), SRGroup(2,4,90), SRGroup(2,4,91),
#!  SRGroup(2,4,93), SRGroup(2,4,95), SRGroup(2,4,97), SRGroup(2,4,102), SRGroup(2,4,108) ]
#! @EndExampleSession

#! @Description
#! Inputs work the same as the main library search function <Ref Func="AllSRGroups"/>, with one additional input: <A>Position</A>.
#! @Returns
#! Information about the self-replicating group(s) satisfying all of the provided input arguments in list form: [<A>Generators</A>, <A>Name</A>, <A>Parent Name</A>, <A>Children Name(s)</A>]. If the <A>Position</A> input is provided, only the corresponding index of this list is returned.
#! @Arguments Input1, val1, Input2, val2, ...
DeclareGlobalFunction( "AllSRGroupsInfo" );
#! @BeginExampleSession
#! gap> AllSRGroupsInfo(Degree, 2, Level, 3, IsAbelian, true);
#! [ [ [ (1,5,4,8,2,6,3,7), (1,4,2,3)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,1)", "SRGroup(2,2,1)", [ "SRGroup(2,4,1)", "SRGroup(2,4,2)" ] ],
#! [ [ (1,5,2,6)(3,7,4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,4)", "SRGroup(2,2,2)", [ "SRGroup(2,4,8)", "SRGroup(2,4,9)", "SRGroup(2,4,10)" ] ], 
#! [ [ (1,3)(2,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,5)", "SRGroup(2,2,2)", [ "SRGroup(2,4,11)", "SRGroup(2,4,12)", "SRGroup(2,4,13)", "SRGroup(2,4,14)", "SRGroup(2,4,15)" ] ] ]
#! gap> AllSRGroupsInfo(Degree, 2, Level, 3, IsAbelian, true, Position, 1);
#! [ [ (1,5,4,8,2,6,3,7), (1,4,2,3)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ],
#!   [ (1,5,2,6)(3,7,4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ],
#!   [ (1,3)(2,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,2)(3,4)(5,6)(7,8) ] ]
#! @EndExampleSession

DeclareGlobalFunction( "CheckSRProjections" );
DeclareGlobalFunction( "StringVariables" );
DeclareGlobalFunction( "UnbindVariables" );

#! @Description
#! There are no inputs to this function.
#! @Returns
#! All of the degrees currently stored in the <Package>SRGroups</Package> library (duplicates included).
#! @Arguments 
DeclareGlobalFunction( "SRDegrees" );
#! @BeginExampleSession
#! gap> SRDegrees();
#! [ 2, 2, 2, 2, 3, 3, 3, 4, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
#! @EndExampleSession

#! @Description
#! Degree of regular rooted tree, <A>k</A>.
#! @Returns
#! All of the levels currently stored in the <Package>SRGroups</Package> library for an input RegularRootedTreeGroupDegree, <A>deg</A>.
#! @Arguments k
DeclareGlobalFunction( "SRLevels" );
#! @BeginExampleSession
#! gap> SRLevels(2);
#! [ 1, 2, 3, 4 ]
#! @EndExampleSession

####################################################################################################################
#! @Section Package Functions
####################################################################################################################

#! @Description
#! The arguments of this function are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! The regular rooted tree group $\mathrm{Aut}(T_{k,n})$ as a permutation group of the $k^{n}$ leaves of $T_{k,n}$.
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

#! @Description
#! The arguments of this function are a degree, <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth, <A>n</A> $\in\mathbb{N}$, an element of <F>AutT(</F><A>k</A>,<A>n</A><F>)</F>, <A>aut</A>, and a level 1 vertex, <A>i</A> $\in\{1,\cdots,k\}$.
#!
#! @Returns
#! The restriction of <A>aut</A> to the subtree below the level 1 vertex <A>i</A>, as an element of <F>AutT(</F><A>k</A>,<A>n-1</A><F>)</F>.
#!
#! @Arguments k,n,aut,i
DeclareGlobalFunction( "BelowAction" );
#!
#! @BeginExampleSession
#! gap> BelowAction(2,2,(1,2)(3,4),2);
#! (1,2)
#! @EndExampleSession

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