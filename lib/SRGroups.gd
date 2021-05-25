## SRGroups: Self-replicating groups of regular rooted trees.
#
#! @Chapter Introduction
#!
#! SRGroups is a package which does some
#! interesting and cool things
#!
#! @Chapter Functionality
#!
#!
#! @Section Example Methods
#!
#! This section will describe the example
#! methods of SRGroups

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

DeclareGlobalFunction( "AutT" );

# DeclareGlobalFunction( "IsSelfReplicating" );

DeclareGlobalFunction( "BelowAction" );

#DeclareGlobalFunction( "MaximalExtension" );

# DeclareGlobalFunction( "HasSufficientRigidAutomorphisms" );
# DeclareGlobalFunction( "RepresentativeWithSufficientRigidAutomorphisms" );

DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingGroupsWithProjection" );

DeclareGlobalFunction( "RemoveConjugates" );
DeclareGlobalFunction( "ConjugacyClassRepsSelfReplicatingGoupsWithConjugateProjection" );
