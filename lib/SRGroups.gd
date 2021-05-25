## SRGroups: Self-replicating groups of regular rooted trees.
#
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

####################################################################################################################
####################################################################################################################
#! @Chapter Introduction
####################################################################################################################
####################################################################################################################

#! SRGroups is a package which does some interesting and cool things. To be continued...

####################################################################################################################
#! @Chapter Framework
####################################################################################################################

# a new "category" for the groups acting on regular rooted trees that we study, based on the category of permutation groups
DeclareCategory("IsRegularRootedTreeGroup", IsPermGroup);

# a creator function asking for depth, degree, and the permutation group
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
#! @Chapter Methods
####################################################################################################################

#! This section explains the methods of this package.

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

# DeclareGlobalFunction( "IsSelfReplicating" );

DeclareGlobalFunction( "BelowAction" );

# DeclareGlobalFunction( "MaximalExtension" );
# DeclareGlobalFunction( "HasSufficientRigidAutomorphisms" );
# DeclareGlobalFunction( "RepresentativeWithSufficientRigidAutomorphisms" );

DeclareGlobalFunction( "RemoveConjugates" );
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingGroupsWithProjection" );
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingGoupsWithConjugateProjection" );
