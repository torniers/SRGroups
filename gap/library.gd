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
#! A list of all depths $n\in\mathbb{N}$ for which self-replicating groups of degree <A>k</A> and depth <A>n</A> are available.
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

#! @BeginGroup ChildGroups

#! @Description
#! Finds all the self-replicating groups that have G as a parent
#!
#! @Returns
#! The number of child groups
#!
#! @Arguments G
DeclareAttribute("ChildGroupsCount", IsSelfReplicating);

#! @EndGroup

##################################################################################################################

#! @Description
#! Finds the index of the self-replicating group G in the library
#!
#! @Returns
#! The index of G in the library
#!
#! @Arguments G
DeclareAttribute("SRGroupNumber", IsSelfReplicating);

##################################################################################################################

#! @BeginGroup AllSRGroups
#! @GroupTitle Selection Functions
#! @Description
#! The arguments of this function are a non-zero number of pairs of a function applicable to self-replicating groups and a value, or list of values, that the function may return. It is this library's version of <Ref Func="AllLibraryGroups" BookName="Reference"/>. Special examples of applicable functions are:
#!
#! <A>Degree</A> (int>1): the <Ref Attr="Degree" Label="for IsRegularRootedTreeGroup"/> of the group.
#!
#! <A>Depth</A> (or <A>Level</A>) (int>0): the <Ref Attr="Depth" Label="for IsRegularRootedTreeGroup"/> of the group.
#!
#! <A>ChildGroupsCount</A> (int>0): the number of <Ref Attr="ChildGroups" Label="for IsSelfReplicating"/>.
#!
#! <A>ParentGroup</A> (SRGroup): Restricts returned groups to have a given <Ref Attr="ParentGroup" Label="for IsRegularRootedTreeGroup"/>, this gives the projection.
#!
#! <A>IsSubgroup</A> (Group) := groups that are a subgroup of the group provided
#!
#! <A>MinimalGeneratingSetSize</A> (int > 0) := size of the group's minimal generating set
#!
#! @Returns
#! A one or a list of all self-replicating groups that satisfy the parameters.
#!
#! @Arguments fun1, val1, fun2, val2, ...
#!
DeclareGlobalFunction( "OneSRGroup" );
#!
#! @Arguments fun1, val1, fun2, val2, ...
#!
DeclareGlobalFunction("AllSRGroups");
#!
#! @BeginExampleSession
#! gap> AllSRGroups(Degree, 2, Level, 4, IsAbelian, true);
#! [ SRGroup(2,4,1), SRGroup(2,4,9), SRGroup(2,4,13), SRGroup(2,4,14) ]
#! gap> AllSRGroups(Degree,2,Depth,5,IsSubgroup,[SRGroup(2,1,1), SRGroup(2,2,1)], ParentGroup, SRGroup(2,4,118));
#! [ SRGroup(2,5,2332), SRGroup(2,5,2341), SRGroup(2,5,2342), SRGroup(2,5,2343), SRGroup(2,5,2344), SRGroup(2,5,2345),
#!   SRGroup(2,5,2346), SRGroup(2,5,2347), SRGroup(2,5,2348), SRGroup(2,5,2364), SRGroup(2,5,2366), SRGroup(2,5,2368),
#!   SRGroup(2,5,2371), SRGroup(2,5,2373), SRGroup(2,5,2375), SRGroup(2,5,2384), SRGroup(2,5,2387), SRGroup(2,5,2388),
#!   SRGroup(2,5,2410), SRGroup(2,5,2411), SRGroup(2,5,2412), SRGroup(2,5,2413), SRGroup(2,5,2422), SRGroup(2,5,2425),
#!   SRGroup(2,5,2426), SRGroup(2,5,2433), SRGroup(2,5,2434), SRGroup(2,5,2435), SRGroup(2,5,2436) ]
#! gap> AllSRGroups(Degree,[2..5],Depth,[2..5],MinimalGeneratingSetSize,1);
#! [ SRGroup(2,2,1), SRGroup(2,3,1), SRGroup(2,4,1), SRGroup(2,5,2), SRGroup(3,2,4) ]
#! @EndExampleSession
#! @EndGroup

##################################################################################################################

DeclareGlobalFunction( "SelectSRGroups" );

##################################################################################################################

# internal
DeclareGlobalFunction( "SRGroupData" );
DeclareGlobalFunction( "SRGroupsData" );

##################################################################################################################
##################################################################################################################

# TODO, seems to allow a variable number of parameters. Could have a version for "k, n", and one for "k, n, nr"?
# or only allow "k, n, nr" and delegate the other option to AllSRGroupsInfo?
DeclareGlobalFunction( "SRGroupsInfo" );

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
DeclareGlobalFunction( "GetSRMaximums" );
DeclareGlobalFunction( "CheckSRGroupsInputs" );

##################################################################################################################
#! @Section Extending the library
##################################################################################################################

# internal?
DeclareGlobalFunction( "StringVariables" );
DeclareGlobalFunction( "UnbindVariables" );

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

##################################################################################################################

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
