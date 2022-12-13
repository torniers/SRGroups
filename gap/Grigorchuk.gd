#! @Description
#! Creates a group which is the approximation of the Grigorchuk group onto a tree of depth <A>depth</A>.
#!
#! @Returns
#! A permutation group.
#!
#! @Arguments depth
#!
DeclareGlobalFunction("GrigorchukProjectedGroup");



#########################################################################################################
# Internal, recursive functions to create the generators of a GrigorchukGroup.
DeclareGlobalFunction("_a@");
DeclareGlobalFunction("_b@");
DeclareGlobalFunction("_c@");
DeclareGlobalFunction("_d@");
