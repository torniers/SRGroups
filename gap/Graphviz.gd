
#! @Description
#! Creates dot code to visualise the groups that project back onto this one.
#! <A>degree</A> is the degree of tree the self-replicating group acts on
#! <A>depth</A> is the depth of the tree that the group acts on
#! <A>nr</A> is the number of the group in this library
#! <A>levels</A> is the number of levels to visualise
#!
#! @Returns
#! A string containing dot code
#!
#! @Arguments degree, depth, nr, levels
#!
DeclareGlobalFunction("DotGroupHeirarchy");

##################################################################################################################

# PrintTo("fun_t.dot", DotSubgroupLattice(2,4));
DeclareGlobalFunction("DotSubgroupLattice");

