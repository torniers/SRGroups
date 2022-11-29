#
# SRGroups: Self-replicating groups

#
# Implementations
#
##################################################################################################################

InstallMethod(Degree, "for SRGroup", [IsRegularRootedTreeGroup], RegularRootedTreeGroupDegree);
InstallMethod(Depth, "for SRGroup", [IsRegularRootedTreeGroup], RegularRootedTreeGroupDepth);
InstallMethod(MinimalGeneratingSetSize, "for SRGroup", [IsRegularRootedTreeGroup],
function(G)
    return Size(MinimalGeneratingSet(G));
end );

##################################################################################################################

# Input::	k: integer at least 2, n: integer at least 2, G: a subgroup of the automorphism group of the k-regular rooted tree of depth n
# Output::	the regular rooted tree group G
InstallMethod( RegularRootedTreeGroup, "for k,n,G (creator)", [IsInt, IsInt, IsPermGroup],
function(k,n,G)
	local rrtg_G;
	
	if not k>=2 then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not n>=1 then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	else
		rrtg_G:=G;
		SetFilterObj(rrtg_G,IsRegularRootedTreeGroup);
		
		Setter(RegularRootedTreeGroupDegree)(rrtg_G,k);
		Setter(RegularRootedTreeGroupDepth)(rrtg_G,n);
	
		return rrtg_G;
	fi;
end );

##################################################################################################################

# Input::	k: integer at least 2, n: integer at least 2, aut: an element of AutT(k,n), i: an integer in [1..k]
# Output::	the restriction of aut to the subtree below the level 1 vertex i, as an element of AutT(k,n-1)
InstallGlobalFunction( BelowAction,
function(k,n,aut,i)
	local aut_i, j;
	
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=2) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	elif not IsPerm(aut) then
		Error("input argument aut=",aut," must be an automorphism of T_{k,n}");
	elif not (IsInt(i) and i in [1..k]) then
		Error("input argument i=",i," must be an integer in the range [1..",k,"]");
	else	
		# restricting to subtree below the level 1 vertex i by taking remainder mod k^(n-1)
		aut_i:=[];	
		for j in [1..k^(n-1)] do aut_i[j]:=((i-1)*k^(n-1)+j)^aut mod k^(n-1); od;
		# replace 0 with k^(n-1)
		aut_i[Position(aut_i,0)]:=k^(n-1);	
		return PermList(aut_i);
	fi;
end );

##################################################################################################################

# Input::	G: a group, subgroups: a mutable list of subgroups of G
# Output::	None. Conjugates removed from subgroups.
InstallGlobalFunction(RemoveConjugates,function(G,subgroups)
	local i, j;

	for i in [Length(subgroups),Length(subgroups)-1..2] do
		for j in [i-1,i-2..1] do
			if IsConjugate(G,subgroups[j],subgroups[i]) then
				Remove(subgroups,i);
				break;
			fi;
		od;
	od; 
end);

##################################################################################################################

# Input::	G: a regular rooted tree group
# Output::	TRUE if G is self-replicating, FALSE otherwise
InstallMethod( IsSelfReplicating, "for G", [IsRegularRootedTreeGroup],
function(G)
	local k, n, blocks, i, pr, G_0, gens;
	
	k:=RegularRootedTreeGroupDegree(G);
	n:=RegularRootedTreeGroupDepth(G);

	if n=1 then return IsTransitive(G,[1..k]); fi;

	# transitivity condition
	# TODO: use normal transitivity on [1..d^k] instead because it is equivalent?
	blocks:=[];
	for i in [1..k] do Add(blocks,[(i-1)*k^(n-1)+1..i*k^(n-1)]); od;
	if not IsTransitive(G,blocks,OnSets) then return false; fi;
	# restriction condition
	pr:=Projection(AutT(k,n));
	G_0:=Stabilizer(G,[1..k^(n-1)],OnSets);
	gens:=ShallowCopy(GeneratorsOfGroup(G_0));
	Apply(gens,aut->RestrictedPerm(aut,[1..k^(n-1)]));
	Add(gens,());
	if not Image(pr,G)=Group(gens) then return false; fi;
	# if both conditions satisfied
	return true;
end );

##################################################################################################################

# Input::	G: a regular rooted tree group
# Output::	TRUE if G has sufficient rigid automorphisms, FALSE otherwise
InstallMethod( HasSufficientRigidAutomorphisms, "for G", [IsRegularRootedTreeGroup],
function(G)
	local k, n, i;
	
	k:=RegularRootedTreeGroupDegree(G);
	n:=RegularRootedTreeGroupDepth(G);

	if n=1 then return true; fi;
	
	for i in [2..k] do
		# rigid automorphisms moving 1 to i?
		if RepresentativeAction(G,[1..k^(n-1)],[1+(i-1)*k^(n-1)..i*k^(n-1)],OnTuples)=fail then
			return false;
		fi;	
	od;	
	return true;
end);

##################################################################################################################

# Input::	G: a regular rooted tree group
# Output::	the projection of G to the next lower depth
InstallMethod( ParentGroup, "for G", [IsRegularRootedTreeGroup],
function(G)
	local k, n, pr;
	
	k:=RegularRootedTreeGroupDegree(G);
	n:=RegularRootedTreeGroupDepth(G);
	
	if n=1 then
		return Group(());
	else	
		pr:=Projection(AutT(k,n));	
		return RegularRootedTreeGroup(k,n-1,Image(pr,G));
	fi;
end );

##################################################################################################################

# Input::	G: a self-replicating regular rooted tree group with sufficient rigid automorphisms
# Output::	the maximal self-replicating extension M(G) of G to the next depth
InstallMethod( MaximalExtension, "for G", [IsRegularRootedTreeGroup],
function(G)
	local k, n, gensMG, pr, gensG, a, pre_a, b, extn, i, prG, kerG, MG;
	
	if not (IsSelfReplicating(G) and HasSufficientRigidAutomorphisms(G)) then
		Error("Input group G=",G," must be self-replicating and have sufficient rigid automorphisms");
	else
		k:=RegularRootedTreeGroupDegree(G);
		n:=RegularRootedTreeGroupDepth(G);
		
		gensMG:=[];
		pr:=Projection(AutT(k,n+1));
		gensG:=GeneratorsOfGroup(G);	
		# add G-section
		for a in gensG do
			pre_a:=PreImages(pr,a);
			for b in pre_a do
				extn:=true;
				for i in [1..k] do
					if not BelowAction(k,n+1,b,i) in G then extn:=false; break; fi;
				od;
				if extn then Add(gensMG,b); break; fi;
			od;
		od;
		# add kernel (suffices to add below 1 as the G-section is transitive on level n)
		if n=1 then
			kerG:=G;
		else
			prG:=RestrictedMapping(Projection(AutT(k,n)),G);
			kerG:=Kernel(prG);
		fi;
		Append(gensMG,ShallowCopy(GeneratorsOfGroup(kerG)));

		MG:=RegularRootedTreeGroup(k,n+1,Group(gensMG));
		# Horadam: Theorem 6.2: MG has all the desired properties
		Setter(IsSelfReplicating)(MG,true);
		Setter(HasSufficientRigidAutomorphisms)(MG,true);
		Setter(RepresentativeWithSufficientRigidAutomorphisms)(MG,MG);
		
		return MG;
	fi;
end);

##################################################################################################################

# Input::	G: a self-replicating regular rooted tree group
# Output::	a self-replicating AutT(k,n)-conjugate of G with sufficient rigid automorphisms, and the same parent group as G if the parent group of G has sufficient rigid automorphisms
InstallMethod( RepresentativeWithSufficientRigidAutomorphisms, "for G", [IsRegularRootedTreeGroup],
function(G)
	local k, n, F, F_0, pr, conjugators, a, H;
	
	if not IsSelfReplicating(G) then
		Error("input group G=",G," must be self-replicating");
	else		
		k:=RegularRootedTreeGroupDegree(G);
		n:=RegularRootedTreeGroupDepth(G);

		if n=1 or HasSufficientRigidAutomorphisms(G) then return G; fi;
		
		F:=AutT(k,n);
		F_0:=Stabilizer(F,[1..k^(n-1)],OnSets);
		pr:=Projection(F);
		# if the projection of G has sufficient rigid automorphisms, preserve it (cf. Horadam: (proof of) Proposition 3.9, 3.10)
		conjugators:=F_0;
		if HasSufficientRigidAutomorphisms(ParentGroup(G)) then
			conjugators:=Intersection(conjugators,Kernel(pr));
		fi;
			
		for a in conjugators do
			if not Image(pr,a)=BelowAction(k,n,a,1) then continue; fi;
			H:=RegularRootedTreeGroup(k,n,G^a);
			if HasSufficientRigidAutomorphisms(H) and IsSelfReplicating(H) then return H; fi;
		od;
		
		return fail;
	fi;
end );

##################################################################################################################

# Input::	k: integer at least 2, n: integer at least 1
# Output::	the automorphism group of the k-regular rooted tree of depth n
InstallGlobalFunction( AutT,
function(k,n)
	local G, i;
	
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=1) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	else
		# iterate wreath product
		G:=SymmetricGroup(k);
		for i in [2..n] do G:=WreathProduct(SymmetricGroup(k),G); od;

		G:=RegularRootedTreeGroup(k,n,G);
		Setter(IsSelfReplicating)(G,true);
		Setter(HasSufficientRigidAutomorphisms)(G,true);
		Setter(RepresentativeWithSufficientRigidAutomorphisms)(G,G);

		return G;
	fi;
end );

##################################################################################################################

# Input::	G: a regular rooted tree group
# Output::	a list of G-conjugacy class representatives of self-replicating subgroups of G
InstallGlobalFunction( ConjugacyClassRepsSelfReplicatingSubgroups,
function(G)
	local k, n, reps, H, class;
		
	k:=RegularRootedTreeGroupDegree(G);
	n:=RegularRootedTreeGroupDepth(G);
	
	if k=0 then
		return fail;	
	else
		reps:=[];
		for class in ConjugacyClassesSubgroups(G) do
			for H in class do
				if IsSelfReplicating(RegularRootedTreeGroup(k,n,H)) then
					Add(reps,RegularRootedTreeGroup(k,n,H));
					break;
				fi;
			od;
		od;
		return reps;
	fi;
end );

##################################################################################################################

# Input::	G: a self-replicating regular rooted tree group with sufficient rigid automorphisms
# Output::	a list of AutT(k,n)-conjugacy class representatives of maximal self-replicating subgroups of G with sufficient rigid automorphisms
InstallGlobalFunction( ConjugacyClassRepsMaxSelfReplicatingSubgroups,
function(G)
	local k, n, F, list, H, class, new, i;
	
	if not (IsSelfReplicating(G) and HasSufficientRigidAutomorphisms(G)) then
		Error("Input group G=",G," must be self-replicating and have sufficient rigid automorphisms");
	else
		k:=RegularRootedTreeGroupDegree(G);
		n:=RegularRootedTreeGroupDepth(G);
		
		F:=AutT(k,n);
		list:=[];
		for class in ConjugacyClassesMaximalSubgroups(G) do
			for H in class do
				H:=RegularRootedTreeGroup(k,n,H);
				if IsSelfReplicating(H) then
					new:=true;
					for i in [Length(list),Length(list)-1..1] do
						if IsConjugate(F,H,list[i]) then new:=false; break; fi;
					od;
					if new then Add(list,RepresentativeWithSufficientRigidAutomorphisms(H)); fi;
					break;
				fi;
			od;
		od;
		
		return list;
	fi;
end);

##################################################################################################################

# Input::	G: a self-replicating regular rooted tree group with sufficient rigid automorphisms
# Output::	a list of conjugacy class representatives of self-replicating regular rooted tree groups with sufficient rigid automorphisms and parent group G
InstallGlobalFunction( ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection,
function(G)
	local k, n, F, prF, pr, list, listtemp, H, new, listHcheck, listH, add, I, J;

	if not (IsSelfReplicating(G) and HasSufficientRigidAutomorphisms(G)) then
		Error("Input group G=",G," must be self-replicating and have sufficient rigid automorphisms");
	else
		k:=RegularRootedTreeGroupDegree(G);
		n:=RegularRootedTreeGroupDepth(G);
		
		F:=AutT(k,n+1);
		prF:=AutT(k,n);
		pr:=Projection(F);
		list:=[];
		for H in G^prF do
			H:=RegularRootedTreeGroup(k,n,H);
			if IsSelfReplicating(H) and HasSufficientRigidAutomorphisms(H) then
				Add(list,RegularRootedTreeGroup(k,n+1,MaximalExtension(H)));
			fi;
		od;
		RemoveConjugates(F,list);
		
		listtemp:=ShallowCopy(list);
		while not IsEmpty(listtemp) do
			for H in listtemp do
				H:=RegularRootedTreeGroup(k,n,H);
				new:=true;
				if IsTrivial(MaximalSubgroupClassReps(H)) then new:=false; fi;
				listHcheck:=ShallowCopy(ConjugacyClassRepsMaxSelfReplicatingSubgroups(H));
				listH:=[];
				if new then
					for I in listHcheck do
						add:=true;
						if not IsConjugate(prF,Image(pr,I),G) then continue; fi;
						for J in list do
							if IsConjugate(F,I,J) then add:=false; break; fi;
						od;
						if add then Add(listH,RepresentativeWithSufficientRigidAutomorphisms(I)); fi;
					od;
					Append(listtemp,listH);
					Append(list,listH);
				fi;
				Remove(listtemp,Position(listtemp,H));
			od;
		od;
		
		return list;
	fi;
end);
