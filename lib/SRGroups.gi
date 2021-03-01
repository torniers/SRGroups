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
	local F, F_0, pr, a;

	if n=1 or HasSufficientRigidAutomorphisms(k,n,G) then
		return G;
	fi;
	
	F:=AutT(k,n);
	F_0:=Stabilizer(F,[1..k^(n-1)],OnSets);
	pr:=Projection(F);
	# if the projection of G has sufficient rigid automorphisms, preserve it
	if HasSufficientRigidAutomorphisms(k,n-1,Image(pr,G)) then
		for a in Intersection(Kernel(pr),F_0) do
			if not Image(pr,a)=BelowAction(k,n,a,1) then continue; fi;
			if IsSelfReplicating(k,n,G^a) and HasSufficientRigidAutomorphisms(k,n,G^a) then return G^a; fi;
		od;
	else
		for a in F_0 do
			if not Image(pr,a)=BelowAction(k,n,a,1) then continue; fi;
			if IsSelfReplicating(k,n,G^a) and HasSufficientRigidAutomorphisms(k,n,G^a) then return G^a; fi;
		od;
	fi;
end);


# Input::	k: integer at least 2, n: integer at least 2, G: a subgroup of AutT(k,n)
# Output::	a list of AutT(k,n)-conjugacy class representatives of maximal self-replicating subgroups of G with sufficient rigid automorphisms
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
				if new then Add(list,RepresentativeWithSufficientRigidAutomorphisms(k,n,H)); fi;
				break;
			fi;
		od;
	od;
	return list;
end);


# Input::	k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1) with sufficient rigid automorphisms
# Output::	a list of AutT(k,n)-conjugacy class representatives of maximal self-replicating subgroups of AutT(k,n) with sufficient rigid automorphisms that project onto G
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
				if new then Add(list,RepresentativeWithSufficientRigidAutomorphisms(k,n,H)); fi;
				break;
			fi;
		od;
	od;	
	return list;
end);


# Input:: k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1)
# Output:: a list of AutT(k,n)-conjugacy class representatives of self-replicating subgroups of G with sufficient rigid automorphisms
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
					if add then Add(listH,RepresentativeWithSufficientRigidAutomorphisms(k,n,I)); fi;
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

# Input:: k: integer at least 2, n: integer at least 2, G: a self-replicating subgroup of AutT(k,n-1) with sufficient rigid automorphisms
# Output:: a list of AutT(k,n)-conjugacy class representatives of self-replicating subgroups of AutT(k,n) with sufficient rigid automorphisms that project onto G
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
					if add then Add(listH,RepresentativeWithSufficientRigidAutomorphisms(k,n,I)); fi;
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










# Input:: deg: degree of the tree (integer at least 2), lev: level of the tree (integer at least 1; if lev=1, then the unformatted "sr_deg_1.grp" file must already exist) (requires "sr_deg_lev+1.grp" file to exist)
# Output:: Formatted version of the file "sr_deg_lev.grp"
InstallGlobalFunction(FormatSRFile, function(deg,lev)
	local pr, fSingleGroup, fCumulative, numGroupsAbove, numProj, i, groupInfo, projBelow, prBelow, aboveCount, k, fNew, dirData, dirTempFiles,reEntry, reEntryCheck, fVariables, numGroups, gens, gensAbove, gensAboveTemp, currentGens, j, fGens, fGensAbove, groupNum;

	# 0. Create directories to be used (dirData: storage of final group files, dirTempFiles: storage of temporary files).
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");

	# 1. Create required filenames.
	fSingleGroup:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_indiv.grp"));
	fCumulative:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_full.grp"));
	fNew:=Filename(dirData[1],Concatenation("sr_",String(deg),"_",String(lev),".grp"));
	fVariables:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_format_var.grp"));

	# 2. Initialise required variables.
	if lev>1 then
		pr:=Projection(AutT(deg,lev));
	fi;
	prBelow:=Projection(AutT(deg,lev+1));
	groupInfo:=[]; # List of lists containing formatted group information
	# 2.1. Check if formatting has already been partially completed (re-entry condition). If so, read file "temp_deg_lev_format_var.grp" for previously bound variables. Otherwise, continue initialising variables.
	if IsExistingFile(fVariables) then
		reEntry:=true;
		reEntryCheck:=true;
		Read(fVariables);
		if IsExistingFile(fNew) then
			numGroups:=EvalString("varArg1");
			gens:=EvalString("varArg2");
			numProj:=EvalString("varArg3");
			numGroupsAbove:=EvalString("varArg4");
			aboveCount:=EvalString("varArg5");
			j:=EvalString("varArg6");
			UnbindVariables("varArg1","varArg2","varArg3","varArg4","varArg5","varArg6");
		else
			numGroups:=EvalString("varArg1");
			i:=EvalString("varArg2");
			gens:=EvalString("varArg3");
			numProj:=EvalString("varArg4");
			numGroupsAbove:=EvalString("varArg5");
			gensAbove:=EvalString("varArg6");
			UnbindVariables("varArg1","varArg2","varArg3","varArg4","varArg5","varArg6");
			if i>numGroups then
				aboveCount:=EvalString("varArg7");
				j:=EvalString("varArg8");
				UnbindVariables("varArg7","varArg8");
			fi;
		fi;
	else
		reEntry:=false;
		reEntryCheck:=false;
		numProj:=[];
		numGroups:=EvalString(SplitString(SplitString(SRGroup(deg,lev+1)[Length(SRGroup(deg,lev+1))][3],",")[3],")")[1]); # Number of groups on level lev (using file "sr_deg_lev+1.grp").
		numGroupsAbove:=0;
		aboveCount:=1;
		j:=1;
		i:=1;
	fi;
	# 2.2. Generate lists containing the same projections from lev+1 to lev, stored in projBelow[groupNum].
	projBelow:=[];
	for groupNum in [1..numGroups] do
		projBelow[groupNum]:=SRGroup(deg,lev+1,0,groupNum);
	od;

	# 3. Gather data to store in groupInfo. This has to be separated into the case where "sr_deg_lev.grp" (unformatted) exists and when it doesn't.
	if IsExistingFile(fNew) then
		# 3.1. Case when "sr_deg_lev.grp" exists. The following variables already exist upon re-entry, so this part can be skipped in this case.
		if not reEntry then
			# 3.1.1. Obtain generators of group (in correct order) on level lev, stored in gens. 
			gens:=[];
			for i in [1..numGroups] do
				gens[i]:=GeneratorsOfGroup(Image(prBelow,Group(projBelow[i][1][1]))); # Generators of the projected image of the first group from projBelow[i].
			od;
			# 3.1.2. Calculate the number of projections from lev to lev-1 for each group (cumulatively), stored in numProj.
			if lev>1 then
				numGroupsAbove:=EvalString(SplitString(SplitString(SRGroup(deg,lev)[Length(SRGroup(deg,lev))][3],",")[3],")")[1]); # Number of groups on level lev-1 (using file "sr_deg_lev.grp").
				for i in [1..numGroupsAbove] do
					if i>1 then
						numProj[i]:=numProj[i-1]+Length(SRGroup(deg,lev,0,i));
					else
						numProj[i]:=Length(SRGroup(deg,lev,0,i));
					fi;
				od;
			fi;
		fi;
	else
		# 3.2. Case when "sr_deg_lev.grp" does not exist.
		# First create required filenames. fGens stores the generators of each group on level lev in file "temp_deg_lev_gens.grp", fGensAbove stores the generators of each group on level lev-1 in file "temp_deg_lev-1_gens.grp".
		# Both of these are stored under the variable name gensTemp. fGensAbove is stored to be used in the next iteration (i.e. when lev=lev-1).
		fGens:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_gens.grp"));
		fGensAbove:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev-1),"_gens.grp"));
		# 3.2.1. The following variables already exist upon re-entry.
		if not reEntry then
			# 3.2.1.1. currentGens stores a temporary generating set for a group, which is used to compare with generators on level lev-1 for unique groups. Initialise as trivial.
			currentGens:=[()]; 
			gens:=[];
			gensAbove:=[];
			# 3.2.1.2. If "temp_deg_lev_gens.grp" already exists (from previous iteration), then read the file to obtain variable gensTemp and set gens to this value. Otherwise, gens needs to be created from projections.
			if IsExistingFile(fGens) then
				Read(fGens);
				gens:=EvalString("gensTemp");
			else
				gens:=[];
			fi;
		fi;
		# 3.2.2. Loop to obtain the generators of groups on levels lev and lev-1, and the number of projections from lev to lev-1 for each group on level lev.
		while i<=numGroups do
			# 3.2.2.1. For each group projecting to a distinct group on lev from lev+1, calculate the unique generators.
			# Then, calculate the generators after projecting from each group on lev to lev-1 (not necessarily distinct).
			if not (IsExistingFile(fGens) and reEntry) then
				gens[i]:=GeneratorsOfGroup(Image(prBelow,Group(projBelow[i][1][1]))); # Generators of the projected image of the first group from projBelow[i].
			fi;
			gensAboveTemp:=GeneratorsOfGroup(Image(pr,Group(gens[i]))); # Generators of the projected image of the group on level lev generated by gens[i].
			# 3.2.2.2. Calculate the number of projections from lev to lev-1 for each group (cumulatively), stored in numProj.
			if Group(gensAboveTemp)=Group(currentGens) then
				# 3.2.2.2.1. If the generated group is not unique (always the case when i=1 since currentGens is initialised as trivial), currentGens stays the same and the number of identical groups in numProj[numGroupsAbove] is increased by 1.
				numProj[numGroupsAbove]:=numProj[numGroupsAbove]+1;
			else
				# 3.2.2.2.2. If the generated group is unique, increase numGroupsAbove by 1 and store the cumulative number of groups in numProj[numGroupsAbove].
				# Additionally, set currentGens and gensAbove[numGroupsAbove] to gensAboveTemp, and store gensAboveTemp in "temp_deg_lev-1_gens.grp" for use in the next iteration.
				numGroupsAbove:=numGroupsAbove+1;
				gensAbove[numGroupsAbove]:=gensAboveTemp;
				currentGens:=gensAbove[numGroupsAbove];
				if i>1 then
					numProj[numGroupsAbove]:=numProj[numGroupsAbove-1]+1;
					AppendTo(fGensAbove,",\n\t",gensAbove[numGroupsAbove]);
				else
					numProj[numGroupsAbove]:=1;
					PrintTo(fGensAbove,"BindGlobal(\"gensTemp\",\n[\n\t",gensAbove[numGroupsAbove]);
				fi;
			fi;
			# 3.2.2.3. Append final closing statement for gensTemp variable in "temp_deg_lev-1_gens.grp".
			if i=numGroups then
				AppendTo(fGensAbove,"\n]);");
			fi;
			i:=i+1;
			# 3.2.2.4. Save this point.
			PrintTo(fVariables,StringVariables(numGroups,i,gens,numProj,numGroupsAbove,gensAbove)); # Save-point
			# 3.2.2.5. Check and declare if re-entry was completed (by setting reEntry to false).
			if reEntry then
				reEntry:=false;
			fi;
		od;
	fi;

	# 4. Store and print formatted group information.
	while j<=numGroups do
		# 4.1. Create entries containing individual group information.
		groupInfo[j]:=[];
		groupInfo[j][1]:=gens[j];
		groupInfo[j][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(j),")\"");
		# 4.1.1. Index 3 must reflect the known groups each group on level lev projects to (using numProj[aboveCount]).
		if lev>1 then
			if j<=numProj[aboveCount] then
				groupInfo[j][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(aboveCount),")\"");
			else
				aboveCount:=aboveCount+1;
				groupInfo[j][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(aboveCount),")\"");
			fi;
		else
			groupInfo[j][3]:="\"emptyset\"";
		fi;
		# 4.2. Print all individual group information (in correct format) to "temp_deg_lev_indiv.grp".
		PrintTo(fSingleGroup, "\n\t", "[");
		AppendTo(fSingleGroup, "\n\t\t", groupInfo[j][1], ",");
		AppendTo(fSingleGroup, "\n\t\t", groupInfo[j][2], ",");
		AppendTo(fSingleGroup, "\n\t\t", groupInfo[j][3], ",");
		# 4.2.1. Index 4 must reflect the known groups each group on level lev extends to (using projBelow[j]).
		groupInfo[j][4]:=[];
		for k in [1..Length(projBelow[j])] do
			groupInfo[j][4][k]:=projBelow[j][k][2];
			if Length(projBelow[j])=1 then
				AppendTo(fSingleGroup,"\n\t\t", "[\"", groupInfo[j][4][k], "\"]\n\t]");
			elif k=1 then
				AppendTo(fSingleGroup, "\n\t\t", "[\"", groupInfo[j][4][k], "\",");
			elif k=Length(projBelow[j]) then
				AppendTo(fSingleGroup, "\n\t\t\"", groupInfo[j][4][k], "\"]\n\t]");
			else 
				AppendTo(fSingleGroup, "\n\t\t\"", groupInfo[j][4][k], "\",");
			fi;
		od;
		# 4.3. If fCumulative does not exist, it must be created and the first lines populated.
		if not IsExistingFile(fCumulative) then
		PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev),"\",\n["));
		fi;
		# 4.4. If the very final group has been successfully formatted, then append the final line of fCumulative.
		# Otherwise, append a new line indicating another group entry will be added.
		if j=numGroups then
			AppendTo(fCumulative,StringFile(fSingleGroup),"\n]);");
		else
			AppendTo(fCumulative,StringFile(fSingleGroup),",\n");
		fi;
		j:=j+1;
		# 4.5. Save this point.
		if IsExistingFile(fNew) then
			PrintTo(fVariables,StringVariables(numGroups,gens,numProj,numGroupsAbove,aboveCount,j)); # Save-point (case 1)
		else
			PrintTo(fVariables,StringVariables(numGroups,i,gens,numProj,numGroupsAbove,gensAbove,aboveCount,j)); # Save-point (case 2)
		fi;
		# 4.6. Check and declare if re-entry was completed (by setting reEntry to false).
		if reEntry then
			reEntry:=false;
		fi;
	od;

	# 5. Remove "temp_deg_lev_gens.grp" file and gensTemp variable if required.
	if not IsExistingFile(fNew) then
		if IsExistingFile(fGens) then
			RemoveFile(fGens);
		fi;
		if IsBound(gensTemp) then
			MakeReadWriteGlobal("gensTemp");
			UnbindGlobal("gensTemp");
		fi;
	fi;

	# 6. Print all group information to final sr_deg_lev.grp file and remove other associated temporary files.
	PrintTo(fNew,StringFile(fCumulative));
	RemoveFile(fSingleGroup);
	RemoveFile(fCumulative);
	RemoveFile(fVariables);
	return;
end);


# Input:: Any integer in the range [0,31], which denotes the degree of the regular rooted tree being organised. If the input is 0 or 1, the degree is chosen to be the lowest degree not stored.
# Output:: The file containing all self-replicating groups of the rooted k-tree at the lowest level not stored.
InstallGlobalFunction(SRGroupFile, function(arg)
	local count, fNew, dirData, k, prevLev, srDegrees, i, x, dataContents, list2, groupGens, deg, lev, fExtensions, groupList, entryPoint, breakPoint, fBreakPointCheck, groupInfo, unsortedLists, sortedList, prevPosLists, yCount, w, yVisited, vCount, fLevelAboveSingle, groupInfoAbove, v, fSingleGroup, fCumulative, fVariables, fLevelAboveCumulative, reEntry, initialz, initialx, reEntryCheck, wCount, y, z, sortedLists, unsortedList, posList, dirTempFiles, fNewAbove, breakPointCheckExist, prevPosList, j, srLevels, incompleteLevels, m, projectionProtocol, levGap, formatAbove;

	# 0. Create directories to be used (dirData: storage of final group files, dirTempFiles: storage of temporary files).
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	dataContents:=DirectoryContents(dirData[1]); # Creates a list of strings with names of the files/folders stored in dirData.

	# 1. First check if the input argument is 0 or 1. If so, the tree level is automatically set to 1.
	if arg[1]=0 or arg[1]=1 then
		# 1.1. Create a list which contains the degrees already stored in the Data folder for the SRGroups package.
		srDegrees:=SRDegrees();
		deg:=2;
		# 1.1.1. Set the degree=deg to be 1 higher than the highest degree stored that is consecutive with 2.
		if not IsEmpty(srDegrees) then
			for count in [1..Length(srDegrees)] do
				if count=1 then
					if not srDegrees[count]=deg then
						break;
					fi;
				else
					if not srDegrees[count]=deg then
						deg:=deg+1;
						if srDegrees[count]>deg then
							break;
						fi;
					fi;
				fi;
			od;
		fi;
		Print("Creating degree ", deg, " file on level 1.\n");
		
		# 1.2. Create required filenames.
		fNew:=Filename(dirData[1], Concatenation("sr_", String(deg), "_1.grp"));
		fSingleGroup:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_1_indiv.grp"));
		fCumulative:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_1_full.grp"));
		fVariables:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_1_var.grp"));
		
		# 1.3. Check if the group files have already been partially created (re-entry condition). If so, read these files to continue from the previous save-point.
		if IsExistingFile(fCumulative) and IsExistingFile(fVariables) then
				reEntry:=true;
				reEntryCheck:=true;
				Read(fVariables);
				initialx:=EvalString("varArg1");
		# 1.4. No re-entry condition. Start from beginning by initialising required variables.
		else
			reEntry:=false;
			reEntryCheck:=false;
			initialx:=1;
		fi;
		
		# 1.5. Evaluate all transitive groups of the degree=deg and store their information.
		# Formatting of the group information is also completed here. For degree>1, this is done separately. See any "sr_deg_lev.grp" file for how this formatting is done.
		groupInfo:=[];
		for wCount in [initialx..NrTransitiveGroups(deg)] do
			# 1.5.1. Create entries containing individual group information.
			groupInfo[wCount]:=[];
			groupInfo[wCount][1]:=ShallowCopy(TRANSGrp(deg,wCount));
			Remove(groupInfo[wCount][1],Length(groupInfo[wCount][1]));
			groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",1,",String(wCount),")\"");
			groupInfo[wCount][3]:="\"emptyset\"";
			groupInfo[wCount][4]:="[\"the classes it extends to\"]";
			# 1.5.2. Separately print individual group information (in correct format) to "temp_deg_1_indiv.grp".
			if not wCount=1 then
				PrintTo(fSingleGroup,Concatenation("\n\n\t[\n\t\t",String(groupInfo[wCount][1])));
			else
				PrintTo(fSingleGroup,Concatenation("\n\t[\n\t\t",String(groupInfo[wCount][1])));
			fi;
			AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][2]);
			AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][3]);
			if not wCount=NrTransitiveGroups(deg) then
				AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t],");
			else
				AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t]");
			fi;
			if not IsExistingFile(fCumulative) then
				PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level 1##\n\nBindGlobal(\"sr_",String(deg),"_1\",\n["));
			fi;
			# 1.5.3. Print formatted individual group information to "temp_deg_1_full.grp" and save this point.
			AppendTo(fCumulative,StringFile(fSingleGroup));
			PrintTo(fVariables,StringVariables(wCount)); # Save-point
		od;
		# 1.5.4. Append end of list containing groups.
		AppendTo(fCumulative,"\n]);");
		
		# 1.6. Print all formatted group information to final "sr_deg_1.grp" file, remove all associated temporary files, and unbind all residual variables.
		PrintTo(fNew, StringFile(fCumulative));
		RemoveFile(fSingleGroup);
		RemoveFile(fCumulative);
		RemoveFile(fVariables);
		if reEntryCheck then
			UnbindVariables("varArg1");
		fi;
		Print("Done.");
		
	# 2. Case where the input argument is in [2,31].
	else 
		# 2.1. Set the degree to be the input argument.
		deg:=arg[1];
		Print("You have requested to make group files for degree ", deg, ".");
		
		# 2.2. Finding the level to begin. If an element of list begins with "sr_arg[1]_", then store it in srLevels.
		srLevels:=SRLevels(deg);
		
		# 2.2.1. Scan currently stored levels for any incomplete files (i.e. group files with index 4 of the group information that say "the classes it extends to").
		# Store any incomplete files which have an existing group file on the level srLevels[count]+1 in the list incompleteLevels.
		incompleteLevels:=[];
		m:=1;
		if not IsEmpty(srLevels) then
			for count in [1..Length(srLevels)] do
				if SRGroup(deg,srLevels[count])[1][4]=["the classes it extends to"] then
					if IsExistingFile(Filename(dirData[1], Concatenation("sr_", String(deg), "_", String(srLevels[count]+1), ".grp"))) then
						incompleteLevels[m]:=srLevels[count];
						m:=m+1;
					fi;
				fi;
			od;
		fi;
		
		# 2.2.2. Format all incomplete group files stored in incompleteFiles using FormatSRFile function.
		if not IsEmpty(incompleteLevels) then
			Print("\nFormatting files:");
			for j in [1..Length(incompleteLevels)] do
				Print(Concatenation("\nsr_", String(deg), "_", String(incompleteLevels[j]), ".grp"));
				FormatSRFile(deg,incompleteLevels[j]);
			od;
		fi;
		
		# 2.2.3. If srLevels is not emptu, then using list of currently stored levels, srLevels, check for any gaps by evaluating srLevels[count]. A gap is found when srLevels[count]=/=count.
		# If no gaps are found, set the level=lev to be 1 higher than the highest level stored that is consecutive with 1.
		# In this case, continue with the normal file creation protocol (uses ConjugacyClassRepsMaxSelfReplicatingSubgroupsWithProjection to generate the groups).
		# If a gap is found, set the level=srLevels[count]-1 and continue with the alternative file creation protocol (fills the gap using projections from the file on level srLevels[count]).
		# An exception occurs if srLevels is empty or srLevels[1]=/=1. In these cases, set level=1 and continue normally (this will just create the (incomplete) "sr_deg_1.grp" file).
		projectionProtocol:=false;
		if not IsEmpty(srLevels) then
			for count in [1..Length(srLevels)] do
				if srLevels[count]=count then
					lev:=count+1;
					if count=Length(srLevels) then
						Print("\nCreating level ", lev, " file.");
					fi;
				elif count=1 and (not srLevels[count]=count) then
					lev:=1;
					Print("\nGap found on level 1. Creating level 1 file.");
				else
					lev:=srLevels[count]-1;
					levGap:=lev-srLevels[count-1]; # Number of levels missing
					projectionProtocol:=true;
					if levGap>1 then
						Print("\nGap found; missing files from levels ", srLevels[count-1]+1, " to ", lev, ". Creating the missing files now.");
					else
						Print("\nGap found; missing file from level ", lev, ". Creating the missing file now.");
					fi;
					break;
				fi;
			od;
		else
			lev:=1;
			Print("\nCreating level 1 file.");
		fi;
		
		# 2.3. Create required filenames.
		fNew:=Filename(dirData[1], Concatenation("sr_", String(deg), "_", String(lev), ".grp"));
		fNewAbove:=Filename(dirData[1],Concatenation("sr_", String(deg), "_", String(lev-1), ".grp"));
		fExtensions:=Filename(dirTempFiles[1], Concatenation("temp_", String(deg), "_", String(lev), ".grp"));
		fSingleGroup:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_indiv.grp"));
		fCumulative:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_full.grp"));
		fVariables:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_var.grp"));
		breakPointCheckExist:=false;
		
		# 2.4. Level 1 case.
		if lev=1 then
			# 2.4.1. Check if the group files have already been partially created (re-entry condition). If so, read these files to continue from the previous save point.
			if IsExistingFile(fCumulative) and IsExistingFile(fVariables) then
				reEntry:=true;
				reEntryCheck:=true;
				Read(fVariables);
				initialx:=EvalString("varArg1");
			else
				reEntry:=false;
				reEntryCheck:=false;
				initialx:=1;
			fi;
			
			# 2.4.2. Evaluate all transitive groups of the degree=deg and store their information.
			# Formatting of the group information is also completed here. For degree>1, this is done separately. See any "sr_deg_lev.grp" file for how this formatting is done.
			groupInfo:=[];
			for wCount in [initialx..NrTransitiveGroups(deg)] do
				# 2.4.2.1. Create entries containing individual group information.
				groupInfo[wCount]:=[];
				groupInfo[wCount][1]:=ShallowCopy(TRANSGrp(deg,wCount));
				Remove(groupInfo[wCount][1],Length(groupInfo[wCount][1]));
				groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",1,",String(wCount),")\"");
				groupInfo[wCount][3]:="\"emptyset\"";
				groupInfo[wCount][4]:="[\"the classes it extends to\"]";
				# 2.4.2.2. Print all individual group information (in correct format) to "temp_deg_1_indiv.grp".
				if not wCount=1 then
					PrintTo(fSingleGroup,Concatenation("\n\n\t[\n\t\t",String(groupInfo[wCount][1])));
				else
					PrintTo(fSingleGroup,Concatenation("\n\t[\n\t\t",String(groupInfo[wCount][1])));
				fi;
				AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][2]);
				AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][3]);
				if not wCount=NrTransitiveGroups(deg) then
					AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t],");
				else
					AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t]");
				fi;
				if not IsExistingFile(fCumulative) then
					PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level 1##\n\nBindGlobal(\"sr_",String(deg),"_1\",\n["));
				fi;
				# 2.4.2.3. Print formatted individual group information to "temp_deg_1_full.grp" and save this point.
				AppendTo(fCumulative,StringFile(fSingleGroup));
				PrintTo(fVariables,StringVariables(wCount)); # Save-point
			od;
			
		# 2.5. Level>1 case.
		else
			# 2.5.1 Create required filenames.
			if not projectionProtocol then
				fLevelAboveSingle:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_above_indiv.grp"));
				fLevelAboveCumulative:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_above.grp"));
			fi;
			
			# 2.5.2. Check whether some (or all) groups have already been extended (stored in "temp_deg_lev.grp") and continue from this point.
			# This is done by creating a file "temp_deg_lev_check.grp" to count the number of stored variables containing the conjugacy class representatives.
			entryPoint:=1;
			if IsExistingFile(fExtensions) and (not projectionProtocol) then
				Print("\nFound existing ", Concatenation("temp_", String(deg), "_", String(lev), ".grp"), " file. Re-entering from last point.");
				Read(fExtensions);
				fBreakPointCheck:=Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_check.grp"));
				breakPointCheckExist:=true;
				breakPoint:=0;
				while breakPoint=entryPoint-1 do
					breakPoint:=entryPoint;
					# 2.5.2.1. Print a statement to this file which declares a new variable called newEntryPoint, that increments if the variable temp_deg_lev-1_initial_proj exists.
					PrintTo(fBreakPointCheck,Concatenation("newEntryPoint:=",String(entryPoint),";\n\nif IsBound(temp_",String(deg),"_",String(lev-1),"_",String(entryPoint),"_proj) then\n\tnewEntryPoint:=newEntryPoint+1;\nfi;"));
					Read(fBreakPointCheck);
					# 2.5.2.2. The variable entryPoint is then incremented by setting its new value to newEntryPoint, and loops only if this value increases.
					entryPoint:=EvalString("newEntryPoint");
					if breakPoint=entryPoint-1 then
						MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(breakPoint),"_proj"));
						UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(breakPoint),"_proj"));
					fi;
					# 2.5.2.3. Unbind residual variable newEntryPoint.
					UnbindGlobal("newEntryPoint");
					# 2.5.2.4. The loop won't repeat once it finds an unbound temp_deg_lev-1_initial_proj variable.
				od;
			fi;
			
			# 2.5.3. This is where the group information is gathered. Two protocols exist: the normal protocol; and the projection protocol.
			if not projectionProtocol then
				# 2.5.3.1. Normal protocol: Extend each group on level lev-1 to all conjugacy class representatives and store their generators in the file "temp_deg_lev.grp".
				groupGens:=[];
				Print("\nEvaluating groups extending from:"); 
				if entryPoint<=Length(SRGroup(deg,lev-1)) then
					for i in [entryPoint..Length(SRGroup(deg,lev-1))] do
						Print("\n",Concatenation("SRGroup(",String(deg),",",String(lev-1),",",String(i),")"),"  (",i,"/",Length(SRGroup(deg,lev-1)),")");
						groupList:=ConjugacyClassRepsSelfReplicatingSubgroupsWithProjection(deg, lev, Group(SRGroup(deg, lev-1, i)[1]));
						if i=1 then
							AppendTo(fExtensions,Concatenation("BindGlobal(\"temp_",String(deg),"_",String(lev-1),"_",String(i),"_proj\",\n["));
						else
							AppendTo(fExtensions,Concatenation("\n\nBindGlobal(\"temp_",String(deg),"_",String(lev-1),"_",String(i),"_proj\",\n["));
						fi;
						for j in [1..Length(groupList)] do
							groupGens[j]:=GeneratorsOfGroup(groupList[j]);
							if j=Length(groupList) then
								AppendTo(fExtensions,Concatenation("\n\t",String(groupGens[j]),"\n]);"));
							else
								AppendTo(fExtensions,Concatenation("\n\t",String(groupGens[j]),","));
							fi;
						od;
					od;
				fi;
			else
				# 2.5.3.2. Projection protocol: Use the group file from level lev+1 ("sr_deg_lev+1.grp") (which may be complete or incomplete) and project the corresponding groups to level lev.
				# The group information can be gathered from this file because it would have been previously stored in the correct ordering based on all the groups from levels above.
				# Loop this through to generate all of the formatted group files in the gap which was found.
				Print("\nCreating files:");
				for i in [1..levGap] do
					Print(Concatenation("\nsr_", String(deg), "_", String(lev), ".grp"));
					FormatSRFile(deg,lev);
					lev:=lev-1;
				od;
				# 2.5.3.2.1. Delete the residual temp file from FormatSRFile.
				RemoveFile(Filename(dirTempFiles[1],Concatenation("temp_",String(deg),"_",String(lev),"_gens.grp")));
				# 2.5.3.2.2. Check if an unformatted file exists from the newly filled gap on level=srLevels[count-1], and format this file.
				if SRGroup(deg,lev)[1][4]=["the classes it extends to"] then
					Print("\nFormatting file:", Concatenation("\nsr_", String(deg), "_", String(lev), ".grp"));
					FormatSRFile(deg,lev);
				fi;
			fi;
			
			if not projectionProtocol then # From this point, the projection protocol is complete.
				# 2.5.4. Initialise group variables and variables (lists within lists) containing formatted group information for levels lev and lev-1.
				Read(fExtensions); # Group variables (of the form temp_deg_lev-1_num_proj)
				groupInfo:=[]; # Level=lev variable
				groupInfoAbove:=[]; # Level=lev-1 variable
				# 2.5.4.1. Check if the file "sr_deg_lev-1.grp" has not already been formatted (it normally would not be).
				# If so, the normal protocol formats both files "sr_deg_lev-1.grp" and "sr_deg_lev.grp". If not, the normal protocol only formats "sr_deg_lev.grp".
				if SRGroup(deg,lev-1)[1][4]=["the classes it extends to"] then
					formatAbove:=true;
					Print("\nFormatting files ",Concatenation("sr_", String(deg), "_", String(lev), ".grp")," and ", Concatenation("sr_", String(deg), "_", String(lev-1), ".grp")," now.");
				else
					formatAbove:=false;
					Print("\nFormatting file ",Concatenation("sr_", String(deg), "_", String(lev), ".grp")," now.");
				fi;
			fi;
			
			# 2.5.5. Level=2 case.
			if lev=2 and not projectionProtocol then			
				# 2.5.5.1. Check if the group files have already been partially created (re-entry condition). If so, read these files to continue from the previous save-point.
				if IsExistingFile(fCumulative) and IsExistingFile(fVariables) then
					Print("\nFound unfinished files. Re-entering.");
					reEntry:=true;
					reEntryCheck:=true;
					Read(fVariables);
					initialz:=EvalString("varArg1");
					posList:=EvalString("varArg2");
					prevPosList:=EvalString("varArg3");
					sortedList:=EvalString("varArg4");
					unsortedList:=EvalString("varArg5");
					vCount:=EvalString("varArg6");
					wCount:=EvalString("varArg7");
					w:=EvalString("varArg8");
					y:=EvalString("varArg9");
					# 2.5.5.1.1. Unbind temp_deg_1_num_proj variables which have already been completely used from previous run.
					if y>1 then
						for k in [1..y-1] do
						MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[k]),"_proj"));
						UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[k]),"_proj"));
						od;
					fi;
				
				# 2.5.5.2. No re-entry condition. Start from beginning by initialising required variables.
				else
					reEntry:=false;
					reEntryCheck:=false;
					# 2.5.5.2.1. Create list containing the number of extensions from each group on level 1.
					unsortedList:=[];
					for y in [1..Length(SRGroup(deg, lev-1))] do
						unsortedList[y]:=Length(EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(y),"_proj")));
					od;
					sortedList:=[];
					prevPosList:=[];
					# 2.5.5.2.2. Sort unsortedList so that the groups can be formatted based on this order.
					sortedList:=SortedList(unsortedList);
					y:=1;
					wCount:=1;
					vCount:=1;
					initialz:=1;
				fi;
				
				# 2.5.5.3. Loop through every group on level 1 to extract extension information and format group files.
				# A while loop has been used here since y can iterate more than once per loop due to the variable posList.
				while y<=Length(SRGroup(deg, lev-1))do
				
					# 2.5.5.3.1. Create a list of positions from unsortedList for next lowest number of extensions. Upon re-entry, posList is already defined.
					# For each position, store it in a list which recalls the position, then format group information for each group extending from that position.
					# A for loop has been used here since the loop must be entered, no matter whether the re-entry condition is true or false (it turns off the condition upon re-enterting sucessfully).
					if not reEntry then
						posList:=Positions(unsortedList, sortedList[y]);
					fi;
					for z in [initialz..Length(posList)] do
						
						# 2.5.5.3.2. Upon re-entry these variables are already defined.
						if not reEntry then
							prevPosList[y]:=posList[z];
							w:=1;
						fi;
						
						# 2.5.5.3.3. Store the formatted information of all groups extending from group number prevPosList[y]. See any "sr_deg_lev.grp" file for how this formatting is done. 
						# A while loop is used here so that if w=sortedList[y]+1 from reading fVariables, it will skip the loop due to already having completed all formatting for these groups.
						while w<=sortedList[y] do
							# 2.5.5.3.3.1. Create entries containing individual group information.
							groupInfo[wCount]:=[];
							groupInfo[wCount][1]:=EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"))[w];
							groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(wCount),")\"");
							groupInfo[wCount][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(y),")\"");
							groupInfo[wCount][4]:="[\"the classes it extends to\"]";
							# 2.5.5.3.3.2. Print all individual group information (in correct format) to "temp_deg_2_indiv.grp".
							if not wCount=1 then
								PrintTo(fSingleGroup,Concatenation("\n\n\t[\n\t\t",String(groupInfo[wCount][1])));
							else
								PrintTo(fSingleGroup,Concatenation("\n\t[\n\t\t",String(groupInfo[wCount][1])));
							fi;
							AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][2]);
							AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][3]);
							if not wCount=Sum(unsortedList) then
								AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t],");
							else
								AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t]");
							fi;
							# 2.5.5.3.3.3. If fCumulative does not exist, it must be created and the first lines populated.
							if not IsExistingFile(fCumulative) then
								PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev),"\",\n["));
							fi;
							# 2.5.5.3.3.4. Print formatted individual group information to "temp_deg_2_full.grp" and save this point.
							AppendTo(fCumulative,StringFile(fSingleGroup));
							PrintTo(fVariables,StringVariables(z, posList, prevPosList, sortedList, unsortedList, vCount, wCount, w, y)); # Save-point
							# 2.5.5.3.3.5. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
							if reEntry then
								reEntry:=false;
								initialz:=1;
							fi;
							w:=w+1;
							wCount:=wCount+1; # Counter for w that never resets
						od;
						
						# 2.5.5.3.4. Re-arrange and re-format the group information for groups on level 1 if required (i.e. if formatAbove=true).
						# The if statement is used because upon re-entry the zCount values will dictate whether only formatting of level 2 has been completed (this is the case when wCount=/=vCount).
						if formatAbove and (not vCount = wCount) then
							# 2.5.5.3.4.1. Compile updated position of groups on level 1.
							groupInfoAbove[y]:=SRGroup(deg, lev-1)[prevPosList[y]];
							# 2.5.5.3.4.2. Index 2 of each group's information must be changed to reflect it's changed name based on the updated position.
							groupInfoAbove[y][2]:=String(Concatenation("\"SRGroup(", String(deg), ",", String(lev-1), ",", String(y), ")\""));
							PrintTo(fLevelAboveSingle, "\n\t", "[");
							AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[y][1], ",");
							AppendTo(fLevelAboveSingle, "\n\t\t", "", groupInfoAbove[y][2], ",");
							AppendTo(fLevelAboveSingle, "\n\t\t", "\"", groupInfoAbove[y][3], "\",");
							# 2.5.5.3.4.3. Index 4 of each group's information must also be changed to reflect the known groups it extends to.
							for v in [1..sortedList[y]] do
								groupInfoAbove[y][4]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(vCount),")\"");
								if sortedList[y]=1 then
									AppendTo(fLevelAboveSingle,"\n\t\t", "[", groupInfoAbove[y][4], "]\n\t]");
								elif v=1 then
									AppendTo(fLevelAboveSingle, "\n\t\t", "[", groupInfoAbove[y][4], ",");
								elif v=sortedList[y] then
									AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[y][4], "]\n\t]");
								else 
									AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[y][4], ",");
								fi;
								vCount:=vCount+1; # Counter for v that never resets
							od;
							# 2.5.5.3.4.4. Unbind temp_deg_1_y_proj since this is the last place it is needed.
							MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
							UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
							# 2.5.5.3.4.5. If fLevelAboveCumulative does not exist, it must be created and its first lines populated.
							if not IsExistingFile(fLevelAboveCumulative) then
								PrintTo(fLevelAboveCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev-1), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev-1),"\",\n["));
							fi;
							# 2.5.5.3.4.6. If the very final group has been successfully formatted, then append the final line of fLevelAboveCumulative.
							# Otherwise, append a new line indicating another group entry will be added.
							if y=Length(SRGroup(deg,lev-1)) then
								AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),"\n]);");
							else
								AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),",\n");
							fi;
							PrintTo(fVariables,StringVariables(z, posList, prevPosList, sortedList, unsortedList, vCount, wCount, w, y)); # Save-point
							# 2.5.5.3.4.7. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
							if reEntry then
								reEntry:=false;
								initialz:=1;
							fi;
						fi;
						# 2.5.5.3.5. Check and declare if re-entry was completed (by setting reEntry to false, resetting initialz, and unbinding temp_deg_1_prevPosList[y]_proj).
						# This is required if both level 2 and level 1 formatting has already been completed, but has not yet looped to the next group's save-point.
						if reEntry then
							MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
							UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
							initialz:=1;
							reEntry:=false;
						fi;
						# 2.5.5.3.6. Loop y within the loop for z (since more than one group could extend to the same number of groups).
						y:=y+1;
					od;
				od;
			
			# 2.5.6. Level>2 case.
			elif lev>2 and not projectionProtocol then
				# 2.5.6.1. Check if the group files have already been partially created (re-entry condition). If so, read these files to continue from the previous save-point.
				if IsExistingFile(fCumulative) and IsExistingFile(fVariables) then
					Print("\nFound unfinished files. Re-entering.");
					reEntry:=true;
					reEntryCheck:=true;
					Read(fVariables);
					initialx:=EvalString("varArg1");
					initialz:=EvalString("varArg2");
					posList:=EvalString("varArg3");
					prevPosLists:=EvalString("varArg4");
					sortedLists:=EvalString("varArg5");
					unsortedList:=EvalString("varArg6");
					unsortedLists:=EvalString("varArg7");
					vCount:=EvalString("varArg8");
					wCount:=EvalString("varArg9");
					yCount:=EvalString("varArg10");
					yVisited:=EvalString("varArg11");
					w:=EvalString("varArg12");
					y:=EvalString("varArg13");
					# 2.5.6.1.1. Unbind temp_deg_lev-1_num_proj variables which have already been completely used from previous run.
					# x denotes group number on level lev-2, k denotes group number on level lev-1 extending from group x.
					# Start by looping through all groups on level lev-2, then groups on level lev-1 extending from group x.
					for x in [1..initialx] do
						for k in [1..y-1] do
							MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
							UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
						od;
					od;
				
				# 2.5.6.2. No re-entry condition. Start from beginning by initialising required variables.
				else
					reEntry:=false;
					reEntryCheck:=false;
					# 2.5.6.2.1. Create a list which measures the cumulative number of branches extending from all groups on level lev-2 prior to group x.
					yVisited:=[];
					for x in [1..Length(SRGroup(deg,lev-2))] do
						if x>1 then
							yVisited[x]:=yVisited[x-1]+Length(SRGroup(deg,lev-1,0,x-1));
						else
							yVisited[x]:=0;
						fi;
					od;
					# 2.5.6.2.2. Create a list containing the number of extensions from each group on level lev-1.
					unsortedList:=[];
					for y in [1..Length(SRGroup(deg,lev-1))] do
						unsortedList[y]:=Length(EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(y),"_proj")));
					od;
					unsortedLists:=[];
					sortedLists:=[];
					prevPosLists:=[];
					yCount:=1;
					wCount:=1;
					vCount:=1;
					initialx:=1;
					initialz:=1;
				fi;
				
				# 2.5.6.3. Groups on level lev-1 must be re-arranged, but can only be re-arranged if they extend from a common group.
				# Therefore, divide the lists into lists containing lists to capture this, from which each list within the lists is sorted in the required order.
				# x denotes group number on level lev-2, y denotes group number on level lev-1 extending from group x.
				for x in [initialx..Length(SRGroup(deg,lev-2))] do
					# 2.5.6.3.1. Upon re-entry these variables are already defined.
					if not reEntry then
						# 2.5.6.3.1.1. Initialise list entries within ...Lists variables.
						unsortedLists[x]:=[];
						sortedLists[x]:=[];
						prevPosLists[x]:=[];
						# 2.5.6.3.1.2. Divide unsortedList into unsortedLists indexed by x (i.e. the groups on level lev-2), since you can only re-arrange groups extending from a common group.
						for y in [1..Length(SRGroup(deg,lev-1,0,x))] do
							unsortedLists[x][y]:=unsortedList[yVisited[x]+y];
						od;
						y:=1;
						# 2.5.6.3.1.3. Sort unsortedLists[x] so that the groups can be formatted based on this revised order.
						sortedLists[x]:=SortedList(unsortedLists[x]);
					fi;
					
					# 2.5.6.3.2 Loop through every group on level lev-1 to extract extension information and format group files.
					# A while loop has been used here since y can iterate more than once per loop due to the variable posList.
					while y<=Length(SRGroup(deg,lev-1,0,x)) do
					
						# 2.5.6.3.2.1. Create a list of positions=posList from unsortedList for next lowest number of extensions.
						# Upon re-entry, posList is already defined.
						if not reEntry then
							posList:=Positions(unsortedLists[x],sortedLists[x][y]);
						fi;
						
						# 2.5.6.3.2.2. For each position=posList[z], store it in a list which recalls the position, then format group information for each group extending from that position.
						# A for loop has been used here since the loop must be entered, no matter whether the re-entry condition is true or false (it turns off the condition upon re-enterting sucessfully).
						for z in [initialz..Length(posList)] do
							
							# 2.5.6.3.2.2.1. Upon re-entry these variables are already defined.
							if not reEntry then
								prevPosLists[x][y]:=posList[z];
								w:=1;
							fi;
							
							# 2.5.6.3.2.2.2. Store the formatted information of all groups extending from group number prevPosList[x][y]. See any "sr_deg_lev.grp" file for how this formatting is done.
							# A while loop is used here so that if w=sortedList[x][y]+1 from reading fVariables, it will skip the loop due to already having completed all formatting for these groups.
							while w<=sortedLists[x][y] do
								# 2.5.6.3.2.2.2.1. Create entries containing individual group information.
								groupInfo[wCount]:=[];
								groupInfo[wCount][1]:=EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"))[w];
								groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(wCount),")\"");
								groupInfo[wCount][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(yVisited[x]+y),")\"");
								groupInfo[wCount][4]:="[\"the classes it extends to\"]";
								# 2.5.6.3.2.2.2.2. Print all individual group information (in correct format) to "temp_deg_lev_indiv.grp".
								if not wCount=1 then
									PrintTo(fSingleGroup,Concatenation("\n\n\t[\n\t\t",String(groupInfo[wCount][1])));
								else
									PrintTo(fSingleGroup,Concatenation("\n\t[\n\t\t",String(groupInfo[wCount][1])));
								fi;
								AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][2]);
								AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][3]);
								if not wCount=Sum(unsortedList) then
									AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t],");
								else
									AppendTo(fSingleGroup,",\n\t\t",groupInfo[wCount][4],"\n\t]");
								fi;
								# 2.5.6.3.2.2.2.3. If fCumulative does not exist, it must be created and the first lines populated.
								if not IsExistingFile(fCumulative) then
									PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev),"\",\n["));
								fi;
								# 2.5.6.3.2.2.2.4. Print formatted individual group information to "temp_deg_lev_full.grp" and save this point.
								AppendTo(fCumulative,StringFile(fSingleGroup));
								PrintTo(fVariables,StringVariables(x, z, posList, prevPosLists, sortedLists, unsortedList, unsortedLists, yVisited, vCount, wCount, yCount, w, y)); # Save-point
								# 2.5.6.3.2.2.2.5. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
								if reEntry then
									reEntry:=false;
									initialz:=1;
								fi;
								w:=w+1;
								wCount:=wCount+1; # Counter for w that never resets
							od;
							
							# 2.5.6.3.2.2.3. Re-arrange and re-format the group information for groups on level lev-1 if required (i.e. if formatAbove=true).
							# The if statement is used because upon re-entry the vCount and wcount values will dictate whether only formatting of level 2 has been completed (this is the case when vCount=/=wCount).
							if formatAbove and (not vCount = wCount) then
								# 2.5.6.3.2.2.3.1. Some groups on level lev-1 (indexed by y) extending from a group on level lev-2 (indexed by x) may have already been completed, so this check is required.
								if not IsBound(groupInfoAbove[x]) then 
									groupInfoAbove[x]:=[];
								fi;
								# 2.5.6.3.2.2.3.2. Compile updated position of groups on level lev-1.
								groupInfoAbove[x][y]:=SRGroup(deg,lev-1)[yVisited[x]+prevPosLists[x][y]];
								# 2.5.6.3.2.2.3.3. Index 2 of each group's information must be changed to reflect it's changed name based on the updated position.
								groupInfoAbove[x][y][2]:=String(Concatenation("\"SRGroup(", String(deg), ",", String(lev-1), ",", String(yVisited[x]+y), ")\""));
								PrintTo(fLevelAboveSingle, "\n\t", "[");
								AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[x][y][1], ",");
								AppendTo(fLevelAboveSingle, "\n\t\t", "", groupInfoAbove[x][y][2], ",");
								AppendTo(fLevelAboveSingle, "\n\t\t", "\"", groupInfoAbove[x][y][3], "\",");
								# 2.5.6.3.2.2.3.4. Index 4 of each group's information must also be changed to reflect the known groups it extends to.
								for v in [1..sortedLists[x][y]] do
									groupInfoAbove[x][y][4]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(vCount),")\"");
									if sortedLists[x][y]=1 then
										AppendTo(fLevelAboveSingle,"\n\t\t", "[", groupInfoAbove[x][y][4], "]\n\t]");
									elif v=1 then
										AppendTo(fLevelAboveSingle, "\n\t\t", "[", groupInfoAbove[x][y][4], ",");
									elif v=sortedLists[x][y] then
										AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[x][y][4], "]\n\t]");
									else 
										AppendTo(fLevelAboveSingle, "\n\t\t", groupInfoAbove[x][y][4], ",");
									fi;
									vCount:=vCount+1; # Counter for v that never resets
								od;
								# 2.5.6.3.2.2.3.5. Unbind temp_deg_lev-1_num_proj since this is the last place it is needed.
								MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
								UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
								# 2.5.6.3.2.2.3.6. If fLevelAboveCumulative does not exist, it must be created and its first lines populated.
								if not IsExistingFile(fLevelAboveCumulative) then
									PrintTo(fLevelAboveCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev-1), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev-1),"\",\n["));
								fi;
								# 2.5.6.3.2.2.3.7. If the very final group has been successfully formatted, then append the final line of fLevelAboveCumulative.
								# Otherwise, append a new line indicating another group entry will be added.
								if yVisited[x]+y=Length(SRGroup(deg,lev-1)) then
									AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),"\n]);");
								else
									AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),",\n");
								fi;
								PrintTo(fVariables,StringVariables(x, z, posList, prevPosLists, sortedLists, unsortedList, unsortedLists, yVisited, vCount, wCount, yCount, w, y)); # Save-point
								# 2.5.6.3.2.2.3.8. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
								if reEntry then
									reEntry:=false;
									initialz:=1;
								fi;
							fi;
							# 2.5.6.3.2.2.4. Check and declare if re-entry was completed (by setting reEntry to false, resetting initialz, and unbinding temp_deg_lev-1_num_proj).
							# This is required if both level lev and level lev-1 formatting has already been completed, but has not yet looped to the next group's save-point.
							if reEntry then
								MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
								UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
								initialz:=1;
								reEntry:=false;
							fi;
							# 2.5.6.3.2.2.5. Loop y within the loop for z (since more than one group could extend to the same number of groups).
							y:=y+1;
						od;
					od;
				od;
			fi;
		fi;
		if not projectionProtocol then
			# 2.5.7. Append end of list containing groups.
			AppendTo(fCumulative,"\n]);");
			
			# 2.6. Print all group information to final sr_deg_lev.grp file (and sr_deg_lev-1.grp in the case for level>1), remove all associated temporary files, and unbind all residual variables.
			PrintTo(fNew,StringFile(fCumulative));
			RemoveFile(fExtensions);
			RemoveFile(fSingleGroup);
			RemoveFile(fCumulative);
			RemoveFile(fVariables);
			if reEntryCheck and lev>2 then
				UnbindVariables("varArg1", "varArg2", "varArg3", "varArg4", "varArg5", "varArg6", "varArg7", "varArg8", "varArg9", "varArg10", "varArg11", "varArg12", "varArg13");
			elif reEntryCheck and lev=2 then
				UnbindVariables("varArg1", "varArg2", "varArg3", "varArg4", "varArg5", "varArg6", "varArg7", "varArg8", "varArg9");
			elif reEntryCheck and lev=1 then
				UnbindVariables("varArg1");
			fi;
			if lev>1 and formatAbove then
				PrintTo(fNewAbove,StringFile(fLevelAboveCumulative));
				if breakPointCheckExist then
					RemoveFile(fBreakPointCheck);
				fi;
				RemoveFile(fLevelAboveSingle);
				RemoveFile(fLevelAboveCumulative);
			fi;
		fi;
		Print("\nDone.");
	fi;
	return;
end);


# Input:: deg: an integer of at least 2 representing the degree of the SRGroup that one wishes to find the HasseDiagram of, lev: and integer of at least 1, representing the level of the SRGroup on the degree deg 
# Output:: a plain text file stored in the form of a .dot file, which can be run through command prompt and Graphviz  
InstallGlobalFunction(HasseDiagram, function(deg,lev)
local subgroups, nodes, abelianGroups, dir, fName, i, k, j, count, antiList, counter, sizeLists, autIndex, sizeTemp;

subgroups:=[];
nodes:=[];
abelianGroups:=[];
sizeLists:=[];
dir:=DirectoriesPackageLibrary("SRGroups","Digraphs");
fName:=Filename(dir[1],Concatenation(String(deg),"_",String(lev),".dot"));
for i in [1..Length(SRGroup(deg,lev))] do
	subgroups[i]:=[];
	k:=1;
	sizeTemp:=Size(Group(SRGroup(deg,lev,i)[1]));
	if sizeTemp=Factorial(deg)^(((deg^lev)-1)/(deg-1)) then
		autIndex:=i;
	fi;
	if IsAbelian(Group(SRGroup(deg,lev,i)[1])) then
		Add(abelianGroups,i);
	fi;
	for j in [1..Length(SRGroup(deg,lev))] do
		if i = j then
			continue;
		else
			if IsSubgroup(Group(SRGroup(deg,lev,i)[1]), Group(SRGroup(deg,lev,j)[1])) then
				subgroups[i][k]:=j;
				k:=k+1;
			fi;
		fi;
	od;
	if not IsEmpty(subgroups[i]) then 
		Add(nodes,i);
	fi;
	if IsEmpty(sizeLists) then
		sizeLists[1]:=[];
		Add(sizeLists[1], i);
	else
		for j in [1..Length(sizeLists)] do
			if sizeTemp=Size(Group(SRGroup(deg,lev,sizeLists[j][1])[1])) then
				Add(sizeLists[j],i);
				break;
			elif j=Length(sizeLists) then
				sizeLists[j+1]:=[];
				Add(sizeLists[j+1], i);
			fi;
		od;
	fi;
od;

for i in [1..Length(nodes)] do
	for j in [1..Length(nodes)] do
		if nodes[j] in subgroups[nodes[i]] then
			subgroups[nodes[i]]:=Difference(subgroups[nodes[i]],subgroups[nodes[j]]);
		fi;
	od;
	count:=1;
	antiList:=[];
	if i = 1 then
		PrintTo(fName, "digraph G {");
		AppendTo(fName, "\n\t{");
		AppendTo(fName, "\n\tnode ", "[shape=diamond", ",", " style=bold]");
		AppendTo(fName, "\n\t", autIndex, "[color=darkgreen]");
		AppendTo(fName, "\n\t}");
		AppendTo(fName, "\n\t{");
		AppendTo(fName, "\n\tnode ", "[shape=diamond", ",", " style=filled]");
		counter:=1;
		for j in [1..Length(SRGroup(deg,lev))] do
			if not j in nodes then
				antiList[counter]:= j;
				counter:=counter+1;
			fi;
		od;
		AppendTo(fName, "\n\t");
		for j in [1..Length(antiList)] do
			if j < Length(antiList) then
				AppendTo(fName, antiList[j], ", ");
			else 
				AppendTo(fName, antiList[j], " [fillcolor=grey]");
			fi;
		od;
		AppendTo(fName, "\n\t}");
		AppendTo(fName, "\n\t{");
		AppendTo(fName, "\n\tnode ", "[shape=box", ",", " width=0.5", ",", " height=0.3]");
		AppendTo(fName, "\n\t");
		for j in [1..Length(nodes)] do
			if j < Length(nodes) then
				AppendTo(fName, nodes[j], ", ");
			else
				AppendTo(fName, nodes[j]);
			fi;
		od;
		AppendTo(fName, "\n\t}");
		AppendTo(fName, "\n\t{");
		AppendTo(fName, "\n\tnode ", "[shape=diamond", ",", " style=filled]");
		AppendTo(fName, "\n\t");
		counter:=1;
		for j in [1..Length(abelianGroups)] do
			if j < Length(abelianGroups) then
				AppendTo(fName, abelianGroups[j], ", ");
			else
				AppendTo(fName, abelianGroups[j]);
			fi;
		od;
		AppendTo(fName, " [fillcolor=red]");
		AppendTo(fName, "\n\t}");
		AppendTo(fName, "\n", nodes[i], " -> ");
	else
		AppendTo(fName,"\n", nodes[i], " -> ");
	fi;
	for k in [1..Length(subgroups[nodes[i]])] do
		if count > 1 then
			AppendTo(fName,", ", subgroups[nodes[i]][k]);
			count:=count+1;
		else
			AppendTo(fName,subgroups[nodes[i]][k]);
			count:=count+1;
		fi;
	od;
od;
for j in [1..Length(sizeLists)] do
	AppendTo(fName, "\n\t", "{rank=same;");
	for k in [1..Length(sizeLists[j])] do
		if k = 1 then
			AppendTo(fName, String(sizeLists[j][k]));
		else 
			AppendTo(fName, ";", String(sizeLists[j][k]));
		fi;
	od;
	AppendTo(fName, "}");
od;
AppendTo(fName, "\n", "}");
return;
end);


# Input::
# Output::
InstallGlobalFunction(ExtensionsMapping, function(deg)
local dirData, dirDigraphs, list, levelCounter, levels, fName, numberCounter, i, j, k, abelianGroups, count;

dirData:= DirectoriesPackageLibrary( "SRGroups", "data" );
dirDigraphs:= DirectoriesPackageLibrary( "SRGroups", "Digraphs" );

list:=[];
levelCounter:=1;
levels:=[];
count:=1;
abelianGroups:=[];
while levelCounter > 0 do
	list[levelCounter]:=[];
	levels[levelCounter]:=levelCounter;
	if IsExistingFile(Filename(dirData[1],Concatenation("sr_", String(deg), "_", String(levelCounter), ".grp"))) then
		if not IsExistingFile(Filename(dirData[1],Concatenation("sr_", String(deg), "_", String(levelCounter + 1), ".grp"))) then 
			levelCounter:=0;
			break;
		else
			for numberCounter in [1..Length(SRGroup(deg, levelCounter))] do
				list[levelCounter][numberCounter]:=SRGroup(deg, levelCounter,numberCounter)[4];
				if IsAbelian(Group(SRGroup(deg,levelCounter,numberCounter)[1])) then
					Add(abelianGroups, Concatenation("\"", "(", String(deg), ",", String(levelCounter), ",", String(numberCounter), ")", "\""));
				fi;
			od;
			levelCounter:=levelCounter+1;
		fi;
	else
		break;
	fi;
od;



fName:=Filename(dirDigraphs[1], Concatenation("sr_", String(deg), "_", "Extensions_Mapping.dot"));
for i in [1..Length(levels)] do
	for j in [1..Length(list[i])] do
		if i = 1 and j=1 then
			PrintTo(fName, "digraph G {");
			count:=1;
			AppendTo(fName, "\n\t{");
			AppendTo(fName, "\n\tnode ", "[shape=diamond", ",", " style=filled]");
			AppendTo(fName, "\n\t");
			for count in [1..Length(abelianGroups)] do
				if count < Length(abelianGroups) then
					AppendTo(fName, abelianGroups[count], ", ");
				else
					AppendTo(fName, abelianGroups[count]);
				fi;
			od;
			AppendTo(fName, " [fillcolor=red]");
			AppendTo(fName, "\n\t}");
			AppendTo(fName,"\n", Concatenation("\"(", String(deg), ",", String(i), ",", String(j), ")\""), " -> ");
			for k in [1..Length(list[i][j])] do
				if k < Length(list[i][j]) then
					AppendTo(fName, "\"", String(SplitString(list[i][j][k], "SRGroup")[Length(SplitString(list[i][j][k], "SRGroup"))]), "\"", ", ");
				else
					AppendTo(fName, "\"", String(SplitString(list[i][j][k], "SRGroup")[Length(SplitString(list[i][j][k], "SRGroup"))]), "\"");
				fi;
			od;
		else
			AppendTo(fName,"\n", Concatenation("\"(", String(deg), ",", String(i), ",", String(j), ")\""), " -> ");
			for k in [1..Length(list[i][j])] do
				if k < Length(list[i][j]) then
					AppendTo(fName, "\"", String(SplitString(list[i][j][k], "SRGroup")[Length(SplitString(list[i][j][k], "SRGroup"))]), "\"", ", ");
				else
					AppendTo(fName, "\"", String(SplitString(list[i][j][k], "SRGroup")[Length(SplitString(list[i][j][k], "SRGroup"))]), "\"");
				fi;
			od;
		fi;
	od;
od;
AppendTo(fName, "\n", "}");
end);
