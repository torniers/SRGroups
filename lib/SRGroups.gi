#
# SRGroups: Self-replicating groups of regular rooted trees.
#
# Implementations
#

# Input::	k: integer at least 2, n: integer at least 1
# Output::	the automorphism group of the k-regular rooted tree of depth n
InstallGlobalFunction(AutT,function(k,n)
	local G, i;
	
	# iterate wreath product
	G:=SymmetricGroup(k);
	for i in [2..n] do G:=WreathProduct(SymmetricGroup(k),G); od;
	return G;
end);


# Input::	k: integer at least 2, n: integer at least 2, G: a subgroup of AutT(k,n)
# Output::	TRUE if F is self-replicating, FALSE otherwise
InstallGlobalFunction(IsSelfReplicating,function(k,n,G)
	local blocks, i, pr, G_0, gens;

	# transitivity condition
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
end);


# Input::	k: integer at least 2, n: integer at least 2, aut: an element of AutT(k,n), i: in integer in [1..k]
# Output::	the restriction of aut to the subtree below the level 1 vertex i, as an element of AutT(k,n-1)
InstallGlobalFunction(BelowAction,function(k,n,aut,i)
	local aut_i, j;
	
	# restricting to subtree below the level 1 vertex i by taking remainder mod k^(n-1)
	aut_i:=[];	
	for j in [1..k^(n-1)] do aut_i[j]:=((i-1)*k^(n-1)+j)^aut mod k^(n-1); od;
	# replace 0 with k^(n-1)
	aut_i[Position(aut_i,0)]:=k^(n-1);	
	return PermList(aut_i);
end);


# Input::	k: integer at least 2, n: integer at least 1, G: a self-replicating subgroup of AutT(k,n)
# Output::	the maximal self-replicating extension of G in AutT(k,n+1)
InstallGlobalFunction(MaximalExtension,function(k,n,G)
	local gensMG, pr, gensG, a, pre_a, b, extn, i, prG, kerG;
		
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
	return Group(gensMG);
end);


# Input::	k: integer at least 2, n: integer at least 2, G: a subgroup of AutT(k,n)
# Output::	a list of AutT(k,n)-conjugacy class representatives of maximal self-replicating subgroups of G
InstallGlobalFunction(ConjugacyClassRepsMaxSelfReplicatingSubgroups,function(k,n,G)
	local F, list, H, class, new, i;

	F:=AutT(k,n);
	list:=[];
	for class in ConjugacyClassesMaximalSubgroups(G) do
		for H in class do
			if IsSelfReplicating(k,n,H) then
				new:=true;
				for i in [Length(list),Length(list)-1..1] do
					if IsConjugate(F,H,list[i]) then new:=false; break; fi;
				od;
				if new then Add(list,H); fi;
				break;
			fi;
		od;
	od;
	return list;
end);


# Input::	k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1)
# Output::	a list of AutT(k,n)-conjugacy class representatives of maximal self-replicating subgroups of AutT(k,n) that project onto G
InstallGlobalFunction(ConjugacyClassRepsMaxSelfReplicatingSubgroupsWithProjection,function(k,n,G)
	local F, pr, list, class, H, new, i;

	F:=AutT(k,n);
	pr:=Projection(F);
	list:=[];
	for class in ConjugacyClassesMaximalSubgroups(MaximalExtension(k,n-1,G)) do
		for H in class do
			if not Image(pr,H)=G then continue; fi;
			if IsSelfReplicating(k,n,H) then
				new:=true;
				for i in [Length(list),Length(list)-1..1] do
					if IsConjugate(F,H,list[i]) then new:=false; break; fi;
				od;
				if new then Add(list,H); fi;
				break;
			fi;
		od;
	od;	
	return list;
end);


# Input:: k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1)
# Output:: a list of AutT(k,n)-conjugacy class representatives of self-replicating subgroups of G
InstallGlobalFunction(ConjugacyClassRepsSelfReplicatingSubgroups,function(k,n,G)
	local F, list, listtemp, H, new, listHcheck, listH, add, I, J;

	F:=AutT(k,n);
	list:=ShallowCopy(ConjugacyClassRepsMaxSelfReplicatingSubgroups(k,n,G));
	listtemp:=ShallowCopy(list);
	while not IsEmpty(listtemp) do
		for H in listtemp do
			new:=true;
			if IsTrivial(MaximalSubgroupClassReps(H)) then new:=false; fi;
			listHcheck:=ShallowCopy(ConjugacyClassRepsMaxSelfReplicatingSubgroups(k,n,H));
			listH:=[];
			if new then
				for I in listHcheck do
					add:=true;
					for J in list do
						if IsConjugate(F,I,J) then add:=false; break; fi;
					od;
					if add then Add(listH,I); fi;
				od;
				Append(listtemp,listH);
				Append(list,listH);
			fi;
			Remove(listtemp,Position(listtemp,H));
		od;
	od;
	Add(list,G);
	return list;
end);

# Input:: k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1)
# Output:: a list of AutT(k,n)-conjugacy class representatives of self-replicating subgroups of AutT(k,n) that project onto G
InstallGlobalFunction(ConjugacyClassRepsSelfReplicatingSubgroupsWithProjection,function(k,n,G)
	local F, pr, list, listtemp, H, new, listHcheck, listH, add, I, J;

	F:=AutT(k,n);
	pr:=Projection(F);
	list:=ShallowCopy(ConjugacyClassRepsMaxSelfReplicatingSubgroupsWithProjection(k,n,G));
	listtemp:=ShallowCopy(list);
	while not IsEmpty(listtemp) do
		for H in listtemp do
			new:=true;
			if IsTrivial(MaximalSubgroupClassReps(H)) then new:=false; fi;
			listHcheck:=ShallowCopy(ConjugacyClassRepsMaxSelfReplicatingSubgroups(k,n,H));
			listH:=[];
			if new then
				for I in listHcheck do
					add:=true;
					if not Image(pr,I)=G then continue; fi;
					for J in list do
						if IsConjugate(F,I,J) then add:=false; break; fi;
					od;
					if add then Add(listH,I); fi;
				od;
				Append(listtemp,listH);
				Append(list,listH);
			fi;
			Remove(listtemp,Position(listtemp,H));
		od;
	od;
	Add(list,MaximalExtension(k,n-1,G));
	return list;
end);