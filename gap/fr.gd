#! @Description
#! This function finds the self-replicating group from the library that is equal to a functionally recursive group
#! restricted to depth <A>depth</A>. <Ref Attr="PermGroup" BookName="fr"/>
#!
#! @Returns
#! A SRGroup that is equivalent to the functionally recursive group when restricted to <A>depth</A>.
#!
#! @Arguments fr_group, depth
#!
#! @BeginExampleSession
#! gap> FindProjectedFR@SRGroups(GrigorchukGroup, 5);
#! SRGroup(2,5,2187)
#! gap> FindProjectedFR@SRGroups(GuptaSidkiGroup, 2);
#! SRGroup(3,2,2)
#! gap> FindProjectedFR@SRGroups(GuptaSidkiGroups(5), 1);
#! SRGroup(5,1,1) = C(5) = 5
#! @EndExampleSession
DeclareGlobalFunction("FindProjectedFR@");
