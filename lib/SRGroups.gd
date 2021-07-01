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

#! Let $G$ be a subgroup of the regular rooted k-tree, $\textrm{Aut}(T_{k})$ with its group action, $\alpha$, defined as $\alpha(g,x)=g(x)$, where $g\in G$ are the automorphisms of $G$ and $x\in X$ the vertices of $T_{k}$. Let $\textrm{stab}_{G}(0)=\{g\in G : \alpha(g,0) = 0\}$, and $T_0\subset T_{k}$ be the set of all vertices below and including the vertex 0. Additonally, let $\varphi_0 : \textrm{stab}_G(0)\rightarrow G$ be a group homomorphism with the mapping $g\mapsto g|_{T_0}$. Then $G$ is called self-replicating if and only if the following two conditions, $\mathcal{R}_k$, are satisfied: $G$ is vertex transitive on level 1 of $T_{k}$, and $\varphi_0\left(\textrm{stab}_{G}(0)\right)=G$.
#!
#! A group $G\leq\mathrm{Aut}(T_{k})$ acting greater than level 1 is said to have sufficient rigid automorphisms if for each pair of vertices $u$ and $v$ on level $1$ of the tree, $T_{k,1}$, there exists an automorphism $g\in G$ such that $g(u)=v$ and $g|_u=e$, where $g$ is called $(u,v)$-rigid. For a self-replicating group $G$ on level $n$ of the tree, $T_{k,n}$, with sufficient rigid automorphisms, the maximal extension of $G$, $\mathcal{M}(G)$, is the largest self-replicating group (not necessarily with sufficient rigid automorphisms) on $\textrm{Aut}(T_{k,n+1})$ that projects onto $G$, defined as:
#! $$\mathcal{M}(G):= \{x\in\mathrm{Aut}(T_{k,n+1}) : \varphi_{n+1}(x)\in G and x|_v\in G \textrm{for all v on level 1}\}.$$
#! The self-replicating property is preserved across conjugacy. For a group $H\leq\mathrm{Aut}(T_{k,n})$ with sufficient rigid automorphisms, and a self-replicating group $G\leq\mathrm{Aut}(T_{k,n+1})$, there exists a conjugate of $G$ in $\mathrm{Aut}(T_{k,n+1})$ with sufficient rigid automorphisms. Since groups on level 1 inherently have sufficient rigid automorphisms, then self-replicating groups with sufficient rigid automorphisms can be found on all levels of the tree.
#!
#! The <Package>SRGroups</Package> package serves to provide a library of these self-replicating groups to further the ongoing studies of infinite networks and group theory. By using the above definitions and conditions, several GAP methods and functions have been built to allow computations of these groups and expand the understanding of their behaviour.
#!
#! First, this package acts as a library for searching currently known self-replicating groups for varying degrees and levels of regular rooted trees. This package also acts as a regular GAP package with functions that allow the expansion of the library and addition of attributes/properties relevant to self-replicating groups. Additional functions also exist in this package that are compatible with GraphViz, to plot diagrams of the extension behaviour of these self-replicating groups and their corresponding Hasse diagrams at different depths.

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

DeclareGlobalFunction( "GetSRData" );

DeclareGlobalFunction( "NumberSRGroups" );

DeclareGlobalFunction( "SRGroupsInfo" );


#! @Description
#! The argument of this function is a degree, <A>k</A>, a depth, <A>n</A>, and a designated number of the stored self-replicating group, <A>num</A>.
#! @Returns
#! The <A>num</A>th self-replicating group of degree <A>k</A> and depth <A>n</A> stored in the <Package>SRGroups</Package> library.
#!
#! @Arguments k,n,num
#!
DeclareGlobalFunction( "SRGroup" );
#!
#! @BeginExampleSession
#! gap> SRGroup(2,3,1);
#! SRGroup(2,3,1)
#! gap> Size(last);
#! 8
#! @EndExampleSession


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


#! @Description
#! The arguments of this function are a degree, <A>k</A>, and a level, <A>n</A>.
#! @Returns
#! Whether all of the self-replicating groups of degree <A>k</A> and level <A>n</A> project correctly to level <A>n-1</A>.
#! @Arguments k,n
DeclareGlobalFunction( "CheckSRProjections" );
#! @BeginExampleSession
#! gap> CheckSRProjections(2,4);
#! All groups project correctly.
#! @EndExampleSession


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
#! The input to this function is the degree of the regular rooted tree, <A>k</A>.
#! @Returns
#! All of the levels currently stored in the <Package>SRGroups</Package> library for an input RegularRootedTreeGroupDegree, <A>deg</A>.
#! @Arguments k
DeclareGlobalFunction( "SRLevels" );
#! @BeginExampleSession
#! gap> SRLevels(2);
#! [ 1, 2, 3, 4 ]
#! @EndExampleSession


DeclareGlobalFunction( "SRGroupsAvailable" );

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


#! @Description
#! The arguments of this function are a group, <A>G</A>, and a list of groups, grouplist. For every group H1 in grouplist, this function removes all conjugate groups H2 such that H2\in H1^G.
#!
#! @Arguments G, grouplist
DeclareGlobalFunction( "RemoveConjugates" );
#!
#! @BeginExampleSession
#! gap> 
#! @EndExampleSession


#! @Description
#! The argument of this function is any regular rooted tree group, <A>G</A>
#!
#! @Returns
#! A list containing conjugacy class representatives of all maximal self-replicating subgroups of <A>G</A>.
#!
#! @Arguments G
DeclareGlobalFunction( "ConjugacyClassRepsMaxSelfReplicatingSubgroups" );
#!
#! @BeginExampleSession
#! gap> ConjugacyClassRepsMaxSelfReplicatingSubgroups(AutT(2,2));
#! [ Group([ (1,3)(2,4), (1,2)(3,4) ]), Group([ (1,3,2,4), (1,2)(3,4) ]) ]
#! @EndExampleSession


#! @Description
#! The argument of this function is any regular rooted tree group, <A>G</A>
#!
#! @Returns
#! A list containing conjugacy class representatives of all self-replicating subgroups of the maximal extension of <A>G</A>, <A>M(G)</A>.
#!
#! @Arguments G
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection" );
#!
#! @BeginExampleSession
#! gap> gap> ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection(AutT(2,2));
#! [ Group([ (1,3)(2,4), (5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,2), (3,4) ]),
#!   Group([ (1,5)(2,6)(3,7)(4,8), (1,3)(2,4), (3,4)(7,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (1,3)(2,4)(7,8), (1,5)(2,6)(3,7)(4,8), (3,4)(7,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4), (1,2)(3,4)(5,6)(7,8) ])
#!     , Group([ (1,5)(2,6)(3,7,4,8), (1,3)(2,4), (3,4)(7,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (1,3)(2,4)(7,8), (1,5,3,7)(2,6,4,8), (3,4)(7,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(7,8), (5,6)(7,8), (1,4,2,3)(5,7,6,8), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (3,4)(5,7,6,8), (1,5)(2,6)(3,7)(4,8), (5,6)(7,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (3,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,3,2,4)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ]),
#!   Group([ (1,5,2,6)(3,7,4,8), (3,4)(5,7)(6,8), (1,3,2,4)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ]) ]
#! @EndExampleSession


DeclareGlobalFunction( "FormatSRFile" );


#! @Description
#! The arguments of this function are a degree, <A>k</A>, or <A>0</A>. If the argument is non-zero, this function creates the file containing all self-replicating groups of the regular rooted k-tree at the lowest level not stored in the <Package>SRGroups</Package> library. If the argument is <A>0</A>, this function creates the file containing all self-replicating groups of the regular rooted tree at the level 1 for the lowest degree not stored in the <Package>SRGroups</Package> library. The file naming convention is "sr_k_n.grp", and they are stored in the "data" folder of the <Package>SRGroups</Package> package. Level 1 groups are calculated using the <Package>transgrp</Package> library. If the argument is non-zero and there is a gap between files (i.e. if "sr_k_n.grp" and "sr_k_n+2.grp" exists, but "sr_k_n+1.grp" does not exist), then this function creates the files in this gap.
#!
#! @Arguments k
DeclareGlobalFunction( "SRGroupFile" );
#!
#! @BeginExampleSession
#! gap> SRGroupFile(2);
#! You have requested to make group files for degree 2.
#! Creating level 3 file.
#! Evaluating groups extending from:
#! SRGroup(2,2,1)  (1/3)
#! SRGroup(2,2,2)  (2/3)
#! SRGroup(2,2,3)  (3/3)
#! SRGroup(2,2,4)  (4/3)
#! Formatting file sr_2_3.grp now.
#! Reordering individual files.
#! Done.
#! gap> SRGroupFile(0);
#! Creating degree 5 file on level 1.
#! Done.
#! gap> SRGroupFile(2);
#! You have requested to make group files for degree 2.
#! Gap found; missing file from level 2. Creating the missing file now.
#! Creating files:
#! sr_2_2.grp
#! Done.
#! @EndExampleSession


# DeclareGlobalFunction( "HasseDiagram" );
# DeclareGlobalFunction( "ExtensionsMapping" );
# DeclareGlobalFunction( "PermutationMapping" );

#! @Description
#! The arguments of this function are: arg[1]: degree of tree (int > 1), <A>k</A>, arg[2]: highest level of tree where the file "sr_k_n.grp" exists (int > 1), <A>n</A>, (arg[3],arg[4],...): sequence of group numbers to extend from using the files "temp_k_n_arg[3]_arg[4]_...arg[Length(arg)-1].grp". This function creates the file of the group number arg[Length(arg)] stored in the file "temp_k_n_arg[3]_arg[4]_...arg[Length(arg)-1].grp", and saves it as "temp_k_n_arg[3]_arg[4]_...arg[Length(arg)].grp".
#!
#! @Arguments arg
DeclareGlobalFunction( "ExtendSRGroup" );

#! @Description
#! The arguments of this function are a degree, <A>k</A>, and a level, <A>n</A>, of a regular rooted tree, <A>n-1</A> is the highest level stored as the file "sr_k_n-1.grp" in the <Package>SRGroups</Package> library, and all of the files "temp_k_n-1_i_proj.grp" for every SRGroup(k,n-1,i) are stored in the "data/temp_k_n" folder of the <Package>SRGroups</Package> library. This function combines each of the "temp_k_n-1_i_proj.grp" files into the complete "temp_k_n.grp" file to be used by the <Ref Func="SRGroupFile"/> function.
#!
#! @Arguments k,n
DeclareGlobalFunction( "CombineSRFiles" );


DeclareGlobalFunction( "ReorderSRFiles" );


DeclareGlobalFunction( "NumberExtensionsUnformatted" );


DeclareSynonym( "Level" , "Depth" );