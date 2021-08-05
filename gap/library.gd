# SRGroups: Self-replicating groups
#
#! @Chapter Introduction
#! @Chapter Preliminaries
#! @Chapter Self-replicating groups
#! @Chapter The library of self-replicating groups

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
#! This function has no arguments.

#! @Returns
#! A list of all degrees $k\in\mathbb{N}_{\ge 2}$ for which self-replicating groups are available at depth $1$, and possibly greater depth.
#!
#! @Arguments
#!
DeclareGlobalFunction( "SRDegrees" );
#!
#! @BeginExampleSession
#! gap> SRDegrees();
#! [ 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 ]
#! @EndExampleSession

##################################################################################################################

#! @Description
#! The argument of this function is a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$.
#!
#! @Returns
#! A list of all depth $n\in\mathbb{N}$ for which self-replicating groups of degree <A>k</A> and depth <A>n</A> are available.
#!
#! @Arguments k
#!
DeclareGlobalFunction( "SRLevels" );
#!
#! @BeginExampleSession
#! gap> SRLevels(2);
#! [ 1, 2, 3, 4, 5 ]
#! gap> SRLevels(17);
#! [  ]
#! @EndExampleSession

##################################################################################################################
#! @Section Selection functions
##################################################################################################################

#! @Description
#! The arguments of this function are a degree <A>k</A> $\in\mathbb{N}_{\ge 2}$, a depth <A>n</A> $\in\mathbb{N}$ and a number <A>nr</A> $\in$ <C>[1..NrSRGroups(k,n)]</C>.
#!
#! @Returns
#! The <A>nr</A>-th self-replicating group of degree <A>k</A> and depth <A>n</A> stored in the library.
#!
#! @Arguments k,n,nr
#!
DeclareGlobalFunction( "SRGroup" );
#!
#! @BeginExampleSession
#! gap> SRGroup(4,1,2);
#! SRGroup(4,1,2) = E(4) = 2[x]2
#! gap> SRGroup(2,3,1);
#! SRGroup(2,3,1)
#! gap> IsRegularRootedTreeGroup(last);
#! true
#! @EndExampleSession

##################################################################################################################

# TODO, seems to allow a variable number of parameters. Could have a version for "k, n", and one for "k, n, nr"?
# or only allow "k, n, nr" delegate the other option to AllSRGroupsInfo?
DeclareGlobalFunction( "SRGroupsInfo" );

##################################################################################################################

DeclareSynonym( "Level" , "Depth" );

#! @Description
#! The arguments of this function are a non-zero number of pairs of a function applicable to self-replicating groups and a value, or list of values, that the function may return. It acts analogously to the function <C>AllTransitiveGroups</C> from the package <Package>transgrp</Package> of transitive groups. Special examples of applicable functions are:
#!
#! <A>Degree</A>: short hand for <Ref Attr="RegularRootedTreeGroupDepth" Label="for IsRegularRootedTreeGroup"/>.
#!
#! <A>Depth</A> (or <A>Level</A>): short hand for <Ref Attr="RegularRootedTreeGroupDepth" Label="for IsRegularRootedTreeGroup"/>.
#!
# TODO perhaps a more useful filter would be the number of children?
#! <A>Number</A>: the index <C>nr</C> in the library.
#!
#! <A>Projection</A>: the index <C>nr</C> of <Ref Attr="ParentGroup" Label="for IsRegularRootedTreeGroup"/> in the library.
#!
# TODO is there a bug here?
# gap> AllSRGroups(Degree,2,Depth,2,IsSubgroup,1);
# [ SRGroup(2,2,1), SRGroup(2,2,2), SRGroup(2,2,3) ]
#! <A>IsSubgroup</A> (int > 0) := groups that are a subgroup of the group number provided
#!
# TODO this should be MinimalGeneratingSetSize to avoid conflict with the function MinimalGeneratingSet
#! <A>MinimalGeneratingSet</A> (int > 0) := size of the group's minimal generating set
#!
#! @Returns
#! A list of all self-replicating groups that satisfy the parameters.
#!
#! @Arguments fun1, val1, fun2, val2, ...
#!
DeclareGlobalFunction("AllSRGroups");
#!
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
#! The arguments of this function are a non-zero number of pairs of a function applicable to self-replicating groups and a value, or list of values, that the function may return. It acts analogously to the function <Ref Func="AllSRGroups"/> above. One additional special example of an applicable function is
#!
#! <A>Position</A>: An integer <A>pos</A> in <C>[0..4]</C>, isolating the <A>pos</A>-th entry of the raw data list.
#!
#! @Returns
#! A list of all self-replicating groups that satisfy the parameters as raw library data, i.e. each group is given by a list of the form [<A>Generators</A>, <A>Name</A>, <A>Parent Name</A>, <A>Children Name(s)</A>]. If the <A>Position</A> function is used, only the corresponding index of this list is returned.
#!
#! @Arguments fun1, val1, fun2, val2, ...
#!
DeclareGlobalFunction( "AllSRGroupsInfo" );
#!
#! @BeginExampleSession
#! gap> AllSRGroupsInfo(Degree,2,Depth,2);
#! [ [ [ (1,2)(3,4), (1,3,2,4) ], "SRGroup(2,2,1)", "SRGroup(2,1,1)", 
#!       [ "SRGroup(2,3,1)", "SRGroup(2,3,2)" ] ], 
#!   [ [ (1,2)(3,4), (1,3)(2,4) ], "SRGroup(2,2,2)", "SRGroup(2,1,1)", 
#!       [ "SRGroup(2,3,3)", "SRGroup(2,3,4)", "SRGroup(2,3,5)", "SRGroup(2,3,6)" ] ], 
#!   [ [ (1,3)(2,4), (1,4)(2,3), (3,4) ], "SRGroup(2,2,3)", "SRGroup(2,1,1)", 
#!       [ "SRGroup(2,3,7)", "SRGroup(2,3,8)", "SRGroup(2,3,9)", "SRGroup(2,3,10)", 
#!           "SRGroup(2,3,11)", "SRGroup(2,3,12)", "SRGroup(2,3,13)", "SRGroup(2,3,14)",
#!           "SRGroup(2,3,15)" ] ] ]
#! gap> AllSRGroupsInfo(Degree,2,Depth,2,Position,1);
#! [ [ (1,2)(3,4), (1,3,2,4) ], [ (1,2)(3,4), (1,3)(2,4) ], 
#!   [ (1,3)(2,4), (1,4)(2,3), (3,4) ] ]
#! @EndExampleSession

##################################################################################################################


# internal?
DeclareGlobalFunction( "GetSRData" );
DeclareGlobalFunction( "GetSRMaximums" );
DeclareGlobalFunction( "CheckSRGroupsInputs" );
DeclareGlobalFunction( "StringVariables" );
DeclareGlobalFunction( "UnbindVariables" );



##################################################################################################################
#! @Section Extending the library
##################################################################################################################

DeclareGlobalFunction( "FormatSRFile" );

##################################################################################################################

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

##################################################################################################################

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

##################################################################################################################

DeclareGlobalFunction( "ReorderSRFiles" );

##################################################################################################################

DeclareGlobalFunction( "NumberExtensionsUnformatted" );

##################################################################################################################

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

##################################################################################################################
