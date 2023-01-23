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

#! @BeginGroup RegularRootedTreeGroupDegree
#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A>.
#! You can also use <A>Degree</A>.
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
#! @EndGroup

##################################################################################################################

#! @BeginGroup RegularRootedTreeGroupDepth
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

#! @Arguments G
#!
DeclareOperation( "Depth", [IsRegularRootedTreeGroup] );

# TODO document after https://github.com/gap-packages/AutoDoc/issues/174 is resolved
DeclareSynonym( "Level", Depth );

#! @EndGroup

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A>.
#!
#! @Returns
#! The <Ref Attr="Size" BookName="Reference"/> of the <Ref Attr="MinimalGeneratingSet" BookName="Reference"/>.
#!
#! @Arguments G
#!
DeclareAttribute("MinimalGeneratingSetSize", IsRegularRootedTreeGroup);


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
#!
#! @BeginExampleSession
#! A3:=AlternatingGroup(3);
#! Alt( [ 1 .. 3 ] )
#! gap> IsRegularRootedTreeGroup(A3);
#! false
#! gap> A3:=RegularRootedTreeGroup(3,1,AlternatingGroup(3));
#! Alt( [ 1 .. 3 ] )
#! gap> IsRegularRootedTreeGroup(A3);
#! true
#! @EndExampleSession

##################################################################################################################
#! @Section Auxiliary functions
##################################################################################################################
# TODO: Extend to vertices not necessarily at level 1?
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
#! The argument of this property is a regular rooted tree group <A>G</A>.
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

# TODO Introduction
# TODO Implement more examples of prominent groups: Grigorchuk, Hanoi, ...

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

# TODO: Make this AutT(k,n)-classes?
#! @Description
#! The argument of this function is a regular rooted tree group <A>G</A>. This method calls <C>ConjugacyClassesSubgroups</C> on $G$ and may therefore be slow. Use for instructional purposes on small examples only, and use <Ref Func="ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection"/> for computations.
#!
#! @Returns
#! A list of $G$-conjugacy class representatives of all self-replicating subgroups of <A>G</A>.
#!
#! @Arguments G
#!
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingSubgroups" );
#!
#! @BeginExampleSession
#! gap> ConjugacyClassRepsSelfReplicatingSubgroups(AutT(2,2));
#! [ Group([ (1,3)(2,4), (1,2)(3,4) ]), Group([ (1,3,2,4), (1,2)(3,4) ]), 
#!   Group([ (3,4), (1,2), (1,3)(2,4) ]) ]
#! NrSRGroups(2,2);
#! 3
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

#! @Chapter The library of self-replicating groups
