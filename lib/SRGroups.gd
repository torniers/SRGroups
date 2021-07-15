#! @Title SRGroups

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

##################################################################################################################
##################################################################################################################
#! @Chapter Introduction
##################################################################################################################
##################################################################################################################

#! Let $G$ be a subgroup of the regular rooted k-tree, $\textrm{Aut}(T_{k})$ with its group action, $\alpha$, defined as $\alpha(g,x)=g(x)$, where $g\in G$ are the automorphisms of $G$ and $x\in X$ the vertices of $T_{k}$. Let $\textrm{stab}_{G}(0)=\{g\in G : \alpha(g,0) = 0\}$, and $T_0\subset T_{k}$ be the set of all vertices below and including the vertex 0. Additonally, let $\varphi_0 : \textrm{stab}_G(0)\rightarrow G$ be a group homomorphism with the mapping $g\mapsto g|_{T_0}$. Then $G$ is called self-replicating if and only if the following two conditions, $\mathcal{R}_k$, are satisfied: $G$ is vertex transitive on level 1 of $T_{k}$, and $\varphi_0\left(\textrm{stab}_{G}(0)\right)=G$.
#!
#! A group $G\leq\mathrm{Aut}(T_{k})$ acting greater than level 1 is said to have sufficient rigid automorphisms if for each pair of vertices $u$ and $v$ on level $1$ of the tree, $T_{k,1}$, there exists an automorphism $g\in G$ such that $g(u)=v$ and $g|_u=e$, where $g$ is called $(u,v)$-rigid. For a self-replicating group $G$ on level $n$ of the tree, $T_{k,n}$, with sufficient rigid automorphisms, the maximal extension of $G$, $\mathcal{M}(G)$, is the largest self-replicating group (not necessarily with sufficient rigid automorphisms) on $\textrm{Aut}(T_{k,n+1})$ that projects onto $G$, defined as:
#! $$\mathcal{M}(G):= \{x\in\mathrm{Aut}(T_{k,n+1}) : \varphi_{n+1}(x)\in G and x|_v\in G \textrm{for all v on level 1}\}.$$
#! The self-replicating property is preserved across conjugacy. For a group $H\leq\mathrm{Aut}(T_{k,n})$ with sufficient rigid automorphisms, and a self-replicating group $G\leq\mathrm{Aut}(T_{k,n+1})$, there exists a conjugate of $G$ in $\mathrm{Aut}(T_{k,n+1})$ with sufficient rigid automorphisms. Since groups on level 1 inherently have sufficient rigid automorphisms, then self-replicating groups with sufficient rigid automorphisms can be found on all levels of the tree.
#!
#! The <Package>SRGroups</Package> package serves to provide a library of these self-replicating groups to further the ongoing studies of infinite networks and group theory. By using the above definitions and conditions, several GAP methods and functions have been built to allow computations of these groups and expand the understanding of their behaviour.
#!
#! First, this package acts as a library for searching currently known self-replicating groups for varying degrees and levels of regular rooted trees. This package also acts as a regular GAP package with functions that allow the expansion of the library and addition of attributes/properties relevant to self-replicating groups. Additional functions also exist in this package that are compatible with GraphViz, to plot diagrams of the extension behaviour of these self-replicating groups and their corresponding Hasse diagrams at different depths.

##################################################################################################################
#! @Section Purpose
##################################################################################################################

#! Research and educational purpose. To do.

##################################################################################################################
##################################################################################################################
#! @Chapter Preliminaries
##################################################################################################################
##################################################################################################################

#! Introductory text. To do.

##################################################################################################################
#! @Section Regular rooted tree groups
##################################################################################################################

#! @Description
#! Groups acting on the regular rooted trees $T_{k,n}$ are stored together with their degree $k\in\mathbb{N}_{\ge 2}$ (see <Ref Attr="RegularRootedTreeGroupDegree" Label="for IsRegularRootedTreeGroup"/>) and depth $n\in\mathbb{N}$ (see <Ref Attr="RegularRootedTreeGroupDepth" Label="for IsRegularRootedTreeGroup"/>) as well as other attributes and properties in this category.
#!
DeclareCategory("IsRegularRootedTreeGroup", IsPermGroup);

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A>.
#!
#! @Returns
#! The degree of <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("RegularRootedTreeGroupDegree", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> RegularRootedTreeGroupDegree(AutT(2,3));
#! 2
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A>.
#!
#! @Returns
#! The depth of <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("RegularRootedTreeGroupDepth", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> RegularRootedTreeGroupDepth(AutT(2,3));
#! 3
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this method are a permutation group <A>G</A> $\le\mathrm{Aut}(T_{k,n})$, its degree <A>k</A> and its depth <A>n</A>.
#!
#! @Returns
#! The regular rooted tree group <A>G</A> as an object of the category <Ref Filt="IsRegularRootedTreeGroup" Label="for IsPermGroup"/>, together with its degree <A>k</A> (see <Ref Attr="RegularRootedTreeGroupDegree" Label="for IsRegularRootedTreeGroup"/>) and its depth <A>n</A> (see <Ref Attr="RegularRootedTreeGroupDepth" Label="for IsRegularRootedTreeGroup"/>).
#!
#! @Arguments k,n,G
#!
DeclareOperation("RegularRootedTreeGroup", [IsInt, IsInt, IsPermGroup]);

##################################################################################################################
#! @Section Auxiliary functions
##################################################################################################################

#! @Description
#! The arguments of this function are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth <A>n</A> $\in\mathbb{N}$, an element <A>aut</A> of $\mathrm{Aut}(T_{k,n})$ (see <Ref Func="AutT"/>), and a depth 1 vertex <A>i</A> $\in\{1,\cdots,k\}$ of $T_{k,n}$.
#!
#! @Returns
#! The restriction of <A>aut</A> to the subtree below the level 1 vertex <A>i</A>, as an element of $\mathrm{Aut}(T_{k,n-1})$.
#!
#! @Arguments k,n,aut,i
#!
DeclareGlobalFunction( "BelowAction" );
#!
#! @BeginExampleSession
#! gap> BelowAction(2,2,(1,2)(3,4),2);
#! (1,2)
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this function are a group <A>G</A> and a list <A>subgroups</A> of subgroups of <A>G</A>.
#!
#! @Returns
#! Removes <A>G</A>-conjugates from the list <A>subgroups</A>.
#!
#! @Arguments G, subgroups
#!
DeclareGlobalFunction( "RemoveConjugates" );
#!
#! @BeginExampleSession
#! gap> G:=SymmetricGroup(3);
#! Sym( [ 1 .. 3 ] )
#! gap> subgroups:=[Group((1,2)),Group((2,3)),Group((1,3))];
#! [ Group([ (1,2) ]), Group([ (2,3) ]), Group([ (1,3) ]) ]
#! gap> RemoveConjugates(G,subgroups);
#! gap> subgroups;
#! [ Group([ (1,2) ]) ]
#! @EndExampleSession

##################################################################################################################
##################################################################################################################
#! @Chapter Self-replicating groups
##################################################################################################################
##################################################################################################################

#! Introductory text. To do.

##################################################################################################################
#! @Section Properties and Attributes 
##################################################################################################################

#! @Description
#! The argument of this property is aa regular rooted tree group <A>G</A>.
#!
#! @Returns
#! <K>true</K> if <A>G</A> is self-replicating, and <K>false</K> otherwise.
#!
#! @Arguments G
#!
DeclareProperty("IsSelfReplicating", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> subgroups:=AllSubgroups(AutT(2,2));
#! [ Group(()), Group([ (3,4) ]), Group([ (1,2) ]), Group([ (1,2)(3,4) ]), 
#!   Group([ (1,3)(2,4) ]), Group([ (1,4)(2,3) ]), Group([ (3,4), (1,2) ]), 
#!   Group([ (1,3)(2,4), (1,2)(3,4) ]), Group([ (1,3,2,4), (1,2)(3,4) ]), 
#!   Group([ (3,4), (1,2), (1,3)(2,4) ]) ]
#! gap> Apply(subgroups,G->RegularRootedTreeGroup(2,2,G));
#! gap> Apply(subgroups,G->IsSelfReplicating(G));
#! gap> subgroups;
#! [ false, false, false, false, false, false, false, true, true, true ]
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this property is a regular rooted tree group <A>G</A>
#!
#! @Returns
#! <K>true</K> if <A>G</A> has sufficient rigid automorphisms, and <K>false</K> otherwise.
#!
#! @Arguments G
#!
DeclareProperty("HasSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> subgroups:=AllSubgroups(AutT(2,2));
#! [ Group(()), Group([ (3,4) ]), Group([ (1,2) ]), Group([ (1,2)(3,4) ]), 
#!   Group([ (1,3)(2,4) ]), Group([ (1,4)(2,3) ]), Group([ (3,4), (1,2) ]), 
#!   Group([ (1,3)(2,4), (1,2)(3,4) ]), Group([ (1,3,2,4), (1,2)(3,4) ]), 
#!   Group([ (3,4), (1,2), (1,3)(2,4) ]) ]
#! gap> Apply(subgroups,G->RegularRootedTreeGroup(2,2,G));
#! gap> Apply(subgroups,G->HasSufficientRigidAutomorphisms(G));
#! gap> subgroups;
#! [ false, false, false, false, true, false, false, true, true, true ]
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,n})$.
#!
#! @Returns
#! The restriction of <A>G</A> to $\mathrm{Aut}(T_{k,n-1})$.
#!
#! @Arguments G
#!
DeclareAttribute("ParentGroup", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,3);;
#! gap> ParentGroup(G);
#! Group([ (1,2), (1,3)(2,4), (3,4) ])
#! gap> last=AutT(2,2);
#! true
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a self-replicating regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,n})$ with sufficient rigid automorphisms.
#! @Returns
#! The maximal extension of $M(G)\le\mathrm{Aut}(T_{k,n+1})$ of <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("MaximalExtension", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,3);;
#! gap> MaximalExtension(G);
#! <permutation group with 11 generators>
#! gap> last=AutT(2,4);
#! true
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a self-replicating regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,n})$.
#!
#! @Returns
#! A self-replicating $\mathrm{Aut}(T_{k,n})$-conjugate of <A>G</A> with sufficient rigid automorphisms. If the parent group of <A>G</A> has sufficient rigid automorphisms then the output group has the same parent group (see <Ref Attr="ParentGroup" Label="for IsRegularRootedTreeGroup"/>) as <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("RepresentativeWithSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=SRGroup(2,3,6);;
#! gap> conjugates:=ShallowCopy(AsList(G^AutT(2,3)));
#! [ Group([ (1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4) ]), 
#!   Group([ (1,5)(2,6)(3,8)(4,7), (1,3)(2,4)(5,8)(6,7), (1,2)(3,4) ]) ]
#! gap> Apply(conjugates,H->RegularRootedTreeGroup(2,3,H));
#! gap> for H in conjugates do Print(HasSufficientRigidAutomorphisms(H),"\n"); od;
#! true
#! false
#! gap> H:=conjugates[2];
#! Group([ (1,5)(2,6)(3,8)(4,7), (1,3)(2,4)(5,8)(6,7), (1,2)(3,4) ])
#! gap> IsSelfReplicating(H);
#! true
#! gap> RepresentativeWithSufficientRigidAutomorphisms(H);
#! Group([ (1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4) ])
#! gap> last=conjugates[1];
#! true
#! @EndExampleSession

##################################################################################################################
#! @Section Examples
##################################################################################################################

#! AutT. More to come. Grigorchuk, Hanoi, ...

##################################################################################################################

#! @Description
#! The arguments of this function are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! The regular rooted tree group $\mathrm{Aut}(T_{k,n})$ as a permutation group of the $k^{n}$ leaves of $T_{k,n}$.
#!
#! @Arguments k,n
#!
DeclareGlobalFunction( "AutT" );
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,2);
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> Size(G);
#! 8
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this function is a regular rooted tree group <A>G</A>.
#!
#! @Returns
#! A list of $\mathrm{Aut}(T_{k,n})$-conjugacy class representatives of all self-replicating, maximal subgroups of <A>G</A>.
#!
#! @Arguments G
#!
DeclareGlobalFunction( "ConjugacyClassRepsMaxSelfReplicatingSubgroups" );
#!
#! @BeginExampleSession
#! gap> Size(ConjugacyClassRepsMaxSelfReplicatingSubgroups(AutT(2,2)));
#! 2
#! NrSRGroups(2,2);
#! 3
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this function is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,n})$.
#!
#! @Returns
#! A list of $\mathrm{Aut}(T_{k,n+1})$-conjugacy class representatives of all self-replicating subgroups of $\mathrm{Aut}(T_{k,n+1})$ whose parent group is conjugate to $G$.
#!
#! @Arguments G
#!
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection" );
#!
#! @BeginExampleSession
#! gap> A3:=RegularRootedTreeGroup(3,1,AlternatingGroup(3));;
#! gap> S3:=RegularRootedTreeGroup(3,1,SymmetricGroup(3));;
#! gap> A3_extn:=ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection(A3);;
#! gap> S3_extn:=ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection(S3);;
#! gap> Size(A3_extn);
#! 5
#! gap> Size(S3_extn);
#! 11
#! gap> NrSRGroups(3,2);
#! 16
#! @EndExampleSession

##################################################################################################################
##################################################################################################################
#! @Chapter The library of self-replicating groups
##################################################################################################################
##################################################################################################################

#! Introductory text. To do.

##################################################################################################################
#! @Section Availability functions
##################################################################################################################

#! Introductory text. To do. Similarities with transitive groups library.

##################################################################################################################

#! @Description
#! The argument of this function is a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! <K>true</K> if the self-replicating groups of degree <A>k</A> and depth <A>n</A> are available, and <K>false</K> otherwise.
#!
#! @Arguments k,n
#!
DeclareGlobalFunction( "SRGroupsAvailable" );
#!
#! @BeginExampleSession
#! gap> SRGroupsAvailable(2,5);
#! true
#! gap> SRGroupsAvailable(5,2);
#! false
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this function is a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! The number of self-replicating groups of degree <A>k</A> and depth <A>n</A> stored in the library, if available, and <K>fail</K> otherwise.
#!
#! @Arguments k,n
#!
DeclareGlobalFunction( "NrSRGroups" );
#!
#! @BeginExampleSession
#! gap> NrSRGroups(2,3);
#! 15
#! gap> NrSRGroups(2,5);
#! 2436
#! gap> NrSRGroups(2,6);
#! fail
#! @EndExampleSession

##################################################################################################################

#! @Description
#! There are no inputs to this function.
#! @Returns
#! All of the degrees currently stored in the <Package>SRGroups</Package> library.
#! @Arguments 
DeclareGlobalFunction( "SRDegrees" );
#! @BeginExampleSession
#! gap> SRDegrees();
#! [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 ]
#! @EndExampleSession

##################################################################################################################

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

##################################################################################################################
#! @Section Selection functions
##################################################################################################################

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

##################################################################################################################

DeclareSynonym( "Level" , "Depth" );

#! @Description
#! Main library search function that acts analogously as the AllTransitiveGroups function from the <Package>transgrp</Package> library. Has several possible input arguments such as <A>Degree</A>, <A>Depth</A> (or <A>Level</A>), <A>Number</A>, <A>Projection</A>, <A>IsSubgroup</A>, <A>Size</A>, <A>NumberOfGenerators</A>, and <A>IsAbelian</A>. Order of the arguments do not matter. List inputs and singular inputs can be provided. The argument definitions are as follows:
#! <A>Degree</A> (int > 1) := degree of tree
#! <A>Depth</A>/<A>Level</A> (int > 0) := level of tree
#! <A>Number</A> (int > 0) := self-replicating group number
#! <A>Projection</A> (int > 0) := groups whose projected image are the group number on the level above
#! <A>IsSubgroup</A> (int > 0) := groups that are a subgroup of the group number provided
#! <A>Size</A> (int >= degree^depth or int > 1) := size of group
#! <A>MinimalGeneratingSet</A> (int > 0) := size of the group's minimal generating set
#! <A>IsAbelian</A> (boolean) := all groups that are abelian if true, and not abelian if false
#! @Returns
#! A list of self-replicating groups matching the input arguments as RegularRootedTreeGroup objects.
#! @Arguments Input1, val1, Input2, val2, ...
DeclareGlobalFunction("AllSRGroups");
#! @BeginExampleSession
#! gap> AllSRGroups(Degree, 2, Level, 4, IsAbelian, true);
#! [ SRGroup(2,4,2), SRGroup(2,4,9), SRGroup(2,4,12), SRGroup(2,4,14) ]
#! gap> AllSRGroups(Degree,[2..5],Depth,[2..5],IsSubgroup,[1..5],Projection,[1..3]);
#! Restricting degrees to [ 2, 3 ]
#! [ SRGroup(2,1,1), SRGroup(2,1,1), SRGroup(2,2,1), SRGroup(2,3,1),
#!   SRGroup(2,3,2), SRGroup(2,4,1), SRGroup(2,4,1), SRGroup(2,4,2),
#!   SRGroup(2,4,2), SRGroup(2,4,2), SRGroup(3,1,1), SRGroup(3,1,1),
#!   SRGroup(3,1,1), SRGroup(3,1,1) ]
#! @EndExampleSession

##################################################################################################################

#! @Description
#! Inputs work the same as the main library search function <Ref Func="AllSRGroups"/>, with one additional input: <A>Position</A> (or <A>Index</A>).
#! Position/Index :=  (int in [1..4])
#! @Returns
#! Information about the self-replicating group(s) satisfying all of the provided input arguments in list form: [<A>Generators</A>, <A>Name</A>, <A>Parent Name</A>, <A>Children Name(s)</A>]. If the <A>Position</A> input is provided, only the corresponding index of this list is returned.
#! @Arguments Input1, val1, Input2, val2, ...
DeclareGlobalFunction( "AllSRGroupsInfo" );
#! @BeginExampleSession
#! gap> AllSRGroupsInfo(Degree, 2, Depth, [2,3], IsAbelian, true);
#! [ [ [ (1,2)(3,4), (1,3,2,4) ], "SRGroup(2,2,1)", "SRGroup(2,1,1)",
#!       [ "SRGroup(2,3,1)", "SRGroup(2,3,2)" ] ],
#!   [ [ (1,2)(3,4), (1,3)(2,4) ], "SRGroup(2,2,2)", "SRGroup(2,1,1)",
#!       [ "SRGroup(2,3,3)", "SRGroup(2,3,4)", "SRGroup(2,3,5)",
#!           "SRGroup(2,3,6)" ] ],
#!   [ [ (1,5,4,8,2,6,3,7), (1,4,2,3)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ]
#!         , "SRGroup(2,3,1)", "SRGroup(2,2,1)",
#!       [ "SRGroup(2,4,1)", "SRGroup(2,4,2)" ] ],
#!   [
#!       [ (1,5,2,6)(3,7,4,8), (1,3)(2,4)(5,7)(6,8),
#!           (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,4)",
#!       "SRGroup(2,2,2)",
#!       [ "SRGroup(2,4,8)", "SRGroup(2,4,9)", "SRGroup(2,4,10)" ] ],
#!   [ [ (1,3)(2,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8),
#!           (1,2)(3,4)(5,6)(7,8) ], "SRGroup(2,3,5)",
#!       "SRGroup(2,2,2)",
#!       [ "SRGroup(2,4,11)", "SRGroup(2,4,12)", "SRGroup(2,4,13)",
#!           "SRGroup(2,4,14)", "SRGroup(2,4,15)" ] ] ]
#! gap> AllSRGroupsInfo(Degree, 2, Level, [2,3], IsAbelian, true, Position, 1);
#! [ [ (1,2)(3,4), (1,3,2,4) ], [ (1,2)(3,4), (1,3)(2,4) ],
#!   [ (1,5,4,8,2,6,3,7), (1,4,2,3)(5,8,6,7), (1,2)(3,4)(5,6)(7,8) ],
#!   [ (1,5,2,6)(3,7,4,8), (1,3)(2,4)(5,7)(6,8), (1,2)(3,4)(5,6)(7,8) ],
#!   [ (1,3)(2,4)(5,7)(6,8), (1,5)(2,6)(3,7)(4,8), (1,2)(3,4)(5,6)(7,8) ] ]
#! @EndExampleSession

##################################################################################################################


# internal?
DeclareGlobalFunction( "GetSRData" );
DeclareGlobalFunction( "CheckSRGroupsInputs" );
DeclareGlobalFunction( "GetSRMaximums" );
DeclareGlobalFunction( "SRGroupsInfo" );
DeclareGlobalFunction( "StringVariables" );
DeclareGlobalFunction( "UnbindVariables" );



##################################################################################################################
#! @Section Extending the library
##################################################################################################################

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


DeclareGlobalFunction( "IsSubgroupOfConjugate" );

#! @Description
#! The arguments of this function are a degree, <A>k</A>, and a level, <A>n</A>.
#! @Returns
#! Whether all of the self-replicating groups of degree <A>k</A> and level <A>n</A> project correctly to level <A>n-1</A>. This is mainly used after obtaining new data to check that it has been formatted correctly (see <Ref Func="SRGroupFile"/>).
#! @Arguments k,n
DeclareGlobalFunction( "CheckSRProjections" );
#! @BeginExampleSession
#! gap> CheckSRProjections(2,4);
#! All groups project correctly.
#! @EndExampleSession



