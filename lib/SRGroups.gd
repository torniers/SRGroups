#! @Title SRGroups

##################################################################################################################
#! @Abstract
##################################################################################################################

#! To do.

##################################################################################################################
#! @Copyright
##################################################################################################################

#! <Package>???</Package> is free software; you can redistribute it and/or modify it under the terms of the <URL Text="GNU General Public License">http://www.fsf.org/licenses/gpl.html</URL> as published by the Free Software     Foundation; either version 3 of the License, or (at your option) any later version.

##################################################################################################################
#! @Acknowledgements
##################################################################################################################

#! DE210100180, FL170100032.

##################################################################################################################
##################################################################################################################
#! @Chapter The package
##################################################################################################################
##################################################################################################################

#! ??? is a package which does some interesting and cool things. To be continued...

##################################################################################################################
#! @Section Framework
##################################################################################################################

#! @Description
#! Groups acting on regular rooted trees are stored together with their degree (<Ref Attr="RegularRootedTreeGroupDegree"/>), depth (<Ref Attr="RegularRootedTreeGroupDepth"/>) and other attributes in this category. See also <Ref Oper="RegularRootedTreeGroup"/>.
#!
DeclareCategory("IsRegularRootedTreeGroup", IsPermGroup);
#! @BeginExampleSession
#! gap> G:=SymmetricGroup(3);
#! Sym( [ 1 .. 3 ] )
#! gap> IsRegularRootedTreeGroup(G);
#! false
#! gap> H:=RegularRootedTreeGroup(3,1,SymmetricGroup(3));
#! Sym( [ 1 .. 3 ] )
#! gap> IsRegularRootedTreeGroup(H);
#! true
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this method are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth <A>n</A> $\in\mathbb{N}$ and a subgroup <A>G</A> of $\mathrm{Aut}(T_{k,n})$.
#!
#! @Returns
#! the regular rooted tree group $G$ as an object of the category <Ref Filt="IsRegularRootedTreeGroup"/>, checking that <A>G</A> is indeed a subgroup of $\mathrm{Aut}(T_{k,n})$.
#!
#! @Arguments k,n,G
#!
DeclareOperation("RegularRootedTreeGroup", [IsInt, IsInt, IsPermGroup]);
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this method are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth <A>n</A> $\in\mathbb{N}$ and a subgroup <A>G</A> of $\mathrm{Aut}(T_{k,n})$.
#!
#! @Returns
#! the regular rooted tree group $G$ as an object of the category <Ref Filt="IsRegularRootedTreeGroup"/>, without checking that <A>G</A> is indeed a subgroup of $\mathrm{Aut}(T_{k,n})$.
#!
#! @Arguments k,n,G
#!
DeclareOperation("RegularRootedTreeGroupNC", [IsInt, IsInt, IsPermGroup]);
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>).
#!
#! @Returns
#! the degree <A>k</A> of the regular rooted tree that <A>G</A> is acting on.
#!
#! @Arguments G
#!
DeclareAttribute("RegularRootedTreeGroupDegree", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>).
#!
#! @Returns
#! the depth <A>n</A> of the regular rooted tree that <A>G</A> is acting on.
#!
#! @Arguments G
#!
DeclareAttribute("RegularRootedTreeGroupDepth", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>).
#!
#! @Returns
#! the regular rooted tree group that arises from <A>G</A> by restricting to $T_{k,n-1}$.
#!
#! @Arguments G
#!
DeclareAttribute("ParentGroup", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,4);
#! <permutation group of size 32768 with 15 generators>
#! gap> ParentGroup(G)=AutT(2,3);
#! true
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this property is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>).
#!
#! @Returns
#! <K>true</K>, if <A>G</A> is self-replicating, and <K>false</K> otherwise.
#!
#! @Arguments G
#!
DeclareProperty("IsSelfReplicating", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,2);
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> subgroups:=AllSubgroups(G);;
#! gap> Apply(subgroups,H->RegularRootedTreeGroup(2,2,H));
#! gap> for H in subgroups do Print(IsSelfReplicating(H),"\n"); od;
#! false
#! false
#! false
#! false
#! false
#! false
#! false
#! true
#! true
#! true
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this property is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>).
#!
#! @Returns
#! <K>true</K>, if <A>G</A> has sufficient rigid automorphisms, and <K>false</K> otherwise.
#!
#! @Arguments G
#!
DeclareProperty("HasSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>), which is self-replicating (<Ref Attr="IsSelfReplicating"/>).
#!
#! @Returns
#! a regular rooted tree group which is conjugate to <A>G</A> in $\mathrm{Aut}(T_{k,n})$ and which has sufficient rigid automorphisms, i.e. it satisfies <Ref Prop="HasSufficientRigidAutomorphisms"/>. This returned group is <A>G</A> itself, if <A>G</A> already has sufficient rigid automorphisms. Furthermore, the returned group has the same parent group as <A>G</A> if the parent group of <A>G</A> has sufficient rigid automorphisms.
#!
#! @Arguments G
#!
DeclareAttribute("RepresentativeWithSufficientRigidAutomorphisms", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>), which is self-replicating (<Ref Attr="IsSelfReplicating"/>) and has sufficient rigid automorphisms (<Ref Attr="HasSufficientRigidAutomorphisms"/>).
#!
#! @Returns
#! the regular rooted tree group $M($<A>G</A>$)\le\mathrm{Aut}(T_{k,n})$ which is the unique maximal self-replicating extension of <A>G</A> to $T_{k,n+1}$.
#!
#! @Arguments G
#!
DeclareAttribute("MaximalExtension", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>), which is self-replicating (<Ref Attr="IsSelfReplicating"/>) and has sufficient rigid automorphisms (<Ref Attr="HasSufficientRigidAutomorphisms"/>).
#!
#! @Returns
#! a list $\mathrm{Aut}(T_{k,n+1}$-conjugacy class representatives of regular rooted tree groups which are self-replicating, have sufficient rigid automorphisms and whose parent group is <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("ConjugacyClassRepsSelfReplicatingGroupsWithProjection", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this attribute is a regular rooted tree group <A>G</A> $\le\mathrm{Aut}(T_{k,k})$ (<Ref Filt="IsRegularRootedTreeGroup"/>), which is self-replicating (<Ref Attr="IsSelfReplicating"/>) and has sufficient rigid automorphisms (<Ref Attr="HasSufficientRigidAutomorphisms"/>).
#!
#! @Returns
#! a list $\mathrm{Aut}(T_{k,n+1}$-conjugacy class representatives of regular rooted tree groups which are self-replicating, have sufficient rigid automorphisms and whose parent group is conjugate to <A>G</A>.
#!
#! @Arguments G
#!
DeclareAttribute("ConjugacyClassRepsSelfReplicatingGroupsWithConjugateProjection", IsRegularRootedTreeGroup);
#!
#! @BeginExampleSession
#! to do
#! @EndExampleSession

##################################################################################################################
#! @Section Auxiliary methods
##################################################################################################################

#! This section explains the methods of this package.

##################################################################################################################

#! @Description
#! The arguments of this method are a group <A>G</A> and a mutable list <A>subgroups</A> of subgroups of <A>G</A>.
#!
#! @Returns
#! n/a. This method removes <A>G</A>-conjugates from the mutable list <A>subgroups</A>.
#!
#! @Arguments G,subgroups
#!
DeclareGlobalFunction( "RemoveConjugates" );
#!
#! @BeginExampleSession
#! gap> G:=SymmetricGroup(3);
#! Sym( [ 1 .. 3 ] )
#! gap> subgroups:=[Group((1,2)),Group((2,3))];
#! [ Group([ (1,2) ]), Group([ (2,3) ]) ]
#! gap> RemoveConjugates(G,subgroups);
#! gap> subgroups;
#! [ Group([ (1,2) ]) ]
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this method are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$ and a depth <A>n</A> $\in\mathbb{N}$.
#!
#! @Returns
#! the regular rooted tree group $\mathrm{Aut}(T_{k,n})$ (<Ref Filt="IsRegularRootedTreeGroup"/>) as a permutation group of the $k^{n}$ leaves of $T_{k,n}$.
#!
#! @Arguments k,n
#!
DeclareGlobalFunction( "AutT" );
#!
#! @BeginExampleSession
#! gap> G:=AutT(2,2);
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> RegularRootedTreeGroupDegree(G);
#! 2
#! gap> RegularRootedTreeGroupDepth(G);
#! 2
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The arguments of this method are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth <A>n</A> $\in\mathbb{N_{ge 2}}$, an automorphism <A>aut</A> $\in\mathrm{Aut}(T_{k,n})$ and an index <A>i</A> $\in$<C>[1..k]</C>.
#!
#! @Returns
#! the automorphism of $\mathrm{Aut}(T_{k,n})$ that arises from <A>aut</A> by restricting to the subtree below the <A>i</A>-th vertex at depth $1$.
#!
#! @Arguments k,n,aut,i
#!
DeclareGlobalFunction( "BelowAction" );
#! @BeginExampleSession
#! gap> G:=AutT(2,2);
#! Group([ (1,2), (3,4), (1,3)(2,4) ])
#! gap> a:=Random(G);
#! (1,3,2,4)
#! gap> BelowAction(2,2,a,1);
#! ()
#! gap> BelowAction(2,2,a,2);
#! (1,2)
#! @EndExampleSession

##################################################################################################################

#! @Chapter The library
