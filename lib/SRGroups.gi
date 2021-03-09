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


# Input::	k: integer at least 2, n: integer at least 1, G: a self-replicating subgroup of AutT(k,n) with sufficient rigid automorphisms
# Output::	the maximal self-replicating extension of G in AutT(k,n+1)
InstallGlobalFunction(MaximalExtension,function(k,n,G)
	local gensMG, pr, gensG, a, pre_a, b, extn, i, prG, kerG;
	
	if not HasSufficientRigidAutomorphisms(k,n,G) then
		Error("Input groups needs to have sufficient rigid automorphisms.");
	fi;
		
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


# Input::	k: integer at least 2, n: integer at least 1, G: a self-replicating subgroup of AutT(k,n)
# Output::	TRUE if G has sufficient rigid automorphisms, FALSE otherwise
InstallGlobalFunction(HasSufficientRigidAutomorphisms,function(k,n,G)
	local i;

	if n=1 then return true; fi;
	
	for i in [2..k] do
		# rigid automorphisms moving 1 to i?
		if RepresentativeAction(G,[1..k^(n-1)],[1+(i-1)*k^(n-1)..i*k^(n-1)],OnTuples)=fail then
			return false;
		fi;	
	od;	
	return true;
end);


# Input::	k: integer at least 2, n: integer at least 1, G: a self-replicating subgroup of AutT(k,n)
# Output::	a self-replicating AutT(k,n)-conjugate of G with sufficient rigid automorphisms, and the same projection to T_{k,n-1} as G if the projection of G has sufficient rigid automorphisms
InstallGlobalFunction(RepresentativeWithSufficientRigidAutomorphisms,function(k,n,G)
	local F, F_0, pr, conjugators, a;

	if n=1 or HasSufficientRigidAutomorphisms(k,n,G) then return G; fi;
	
	F:=AutT(k,n);
	F_0:=Stabilizer(F,[1..k^(n-1)],OnSets);
	pr:=Projection(F);
	# if the projection of G has sufficient rigid automorphisms, preserve it (cf. Horadam, (proof of) Proposition 3.9, 3.10)
	conjugators:=F_0;
	if HasSufficientRigidAutomorphisms(k,n-1,Image(pr,G)) then
		conjugators:=Intersection(conjugators,Kernel(pr));
	fi;
		
	for a in conjugators do
		if not Image(pr,a)=BelowAction(k,n,a,1) then continue; fi;
		if HasSufficientRigidAutomorphisms(k,n,G^a) and IsSelfReplicating(k,n,G^a) then return G^a; fi;
	od;
	
	return fail;
end);


# Input:: k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1) with sufficient rigid automorphisms
# Output:: a list of AutT(k,n)-conjugacy class representatives of self-replicating subgroups of AutT(k,n) with sufficient rigid automorphisms that project onto G
InstallGlobalFunction(ConjugacyClassRepsSelfReplicatingSubgroupsWithProjection,function(k,n,G)
	local F, pr, allGroups, currentLayer, newGroups, currentGroup, subgroups, i, j;

	F:=AutT(k,n);
	pr:=Projection(F);
	allGroups:=[MaximalExtension(k,n-1,G)];
	currentLayer:=ShallowCopy(allGroups);
	while not IsEmpty(currentLayer) do
		newGroups:=[];
		for currentGroup in currentLayer do
			subgroups:=ShallowCopy(MaximalSubgroups(currentGroup));
			for i in [Length(subgroups),Length(subgroups)-1..1] do
				if not IsSelfReplicating(k,n,subgroups[i]) or not Image(pr,subgroups[i])=G then
					Remove(subgroups,i);
				fi;
			od;
			Append(newGroups,subgroups);
		od;
		# RemoveConjugates(newGroups);
		for i in [Length(newGroups),Length(newGroups)-1..2] do
			for j in [i-1,i-2..1] do
				if IsConjugate(F,newGroups[j],newGroups[i]) then
					Remove(newGroups,i);
					break;
				fi;
			od;
		od;
		currentLayer:=newGroups;
		Append(allGroups,newGroups);
	od;
	# representatives with sufficient rigid automorphisms
	Apply(allGroups,H->RepresentativeWithSufficientRigidAutomorphisms(k,n,H));
	return allGroups;
end);

