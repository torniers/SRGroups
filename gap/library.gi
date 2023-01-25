#
# SRGroups: Self-replicating groups
#
# Implementations
#
##################################################################################################################

# TODO: transgrp uses a list called TRANSLENGTHS for this; there should probably be a global list of pairs [k,n] that are available 
InstallGlobalFunction( SRGroupsAvailable,
function(k,n)
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=1) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	else
		return (k in SRDegrees() and n in SRLevels(k));
	fi;
end);

##################################################################################################################

# TODO: transgrp uses a list called TRANSLENGTHS for this; see above
InstallGlobalFunction( NrSRGroups,
function(k,n)
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=1) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	elif not SRGroupsAvailable(k,n) then
		return fail;
	else
		return Length(SRGroupsData(k,n));
	fi;
end);

##################################################################################################################

InstallGlobalFunction( SRDegrees,
function()
	local dir, file_names, degrees, file_name;
	
	# get list of file names
	dir:=DirectoriesPackageLibrary("SRGroups", "data");
	file_names:=DirectoryContents(dir[1]);
	# extract degrees
	degrees:=[];
	for file_name in file_names do
		if StartsWith(file_name,"sr_") then
			Add(degrees,EvalString(SplitString(file_name, "_")[2]));
		fi;
	od;	
	# remove duplicates and sort
	degrees:=DuplicateFreeList(degrees);
	Sort(degrees);
	
	return degrees;
end);

##################################################################################################################

InstallGlobalFunction( SRLevels,
function(k)
	local dir, file_names, levels, file_name;
	
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	else
		# get list of file names
		dir:=DirectoriesPackageLibrary("SRGroups", "data");
		file_names:=DirectoryContents(dir[1]);
		# extract levels
		levels:=[];
		for file_name in file_names do
			if StartsWith(file_name,Concatenation("sr_", String(k))) then
				Add(levels,EvalString(SplitString(file_name, ".", "_")[3]));
			fi;
		od;
		# sort
		Sort(levels);

		return levels;
	fi;
end);

##################################################################################################################

SRGroupDegreeFromName := function(name)
    return EvalString(SplitString(name,",","(")[2]);
end;
SRGroupLevelFromName := function(name)
    return EvalString(SplitString(name,",")[2]);
end;

SRGroupFromData:=function(data)
	local k, n, G;
	
	k:=SRGroupDegreeFromName(data[2]);
    n:=SRGroupLevelFromName(data[2]);
	G:=RegularRootedTreeGroup(k,n,Group(data[1]));
	SetName(G,data[2]);
    SetIsSelfReplicating(G, true);
	
	return G;
end;

##################################################################################################################
##################################################################################################################

InstallGlobalFunction( SRGroup,
function(k,n,nr)
	local data;
	
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=1) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	elif not (IsInt(nr) and nr>=1) then
		Error("input argument nr=",nr," must be an integer greater than or equal to 1");
	else
		data:=SRGroupsData(k,n);
		if not nr in [1..Length(data)] then
			Error("there are only ",Length(data)," SRGroups of degree k=",k," and depth n=",n);
		else
			return SRGroupFromData(SRGroupData(k,n,nr));
		fi;
	fi;
end);

##################################################################################################################

InstallMethod(ChildGroupsCount, "for G", [IsSelfReplicating],
function(G)
    local data, k, n, nr;
    k := Degree(G);
    n := Depth(G);
    nr := SRGroupNumber(G);
    data := SRGroupData(k, n, nr)[4];
    return Size(data);
end );

##################################################################################################################

InstallMethod(SRGroupNumber, "for G", [IsSelfReplicating],
function(G)
    local n, k, i, candidate;
    if HasName(G) and StartsWith(Name(G), "SRGroup") then
        # Just read it
        return EvalString(SplitString(SplitString(Name(G),",")[3],")")[1]);
    else
        k := Degree(G);
        n := Depth(G);
        i := 0;
        for candidate in AllSRGroups(Depth,n,Degree,k) do
            i := i + 1;
            if candidate = G then
                return i;
            fi;
        od;
    fi;
    return fail;
end );

##################################################################################################################

InstallGlobalFunction( OneSRGroup,
function(args...)
	local group;

	group:=SelectSRGroups(args,false);
	if group=[] then
		return fail;
	else
		return group;
	fi;	
end);

##################################################################################################################

InstallGlobalFunction( AllSRGroups,
function(args...)
	return SelectSRGroups(args,true);
end);

##################################################################################################################

# internal
_SelectSRGroupsCache@ := [];
InstallGlobalFunction( SelectSRGroups,
function(args,all)
	local k, n, nr, groups, degree, level, groups_temp, names, parent_groups, i, j;
	
    # TODO(cameron) more input checking
	if not IsInt(Length(args)/2) then
		Error("argument must be of the form fun1,val1,fun2,val2,...");
	else	
		# pre-select groups by desired degree(s)
        # TODO(cameron) mention if we filter out degrees or depths
		if not Position(args,Degree)=fail then
			k:=args[Position(args,Degree)+1];
			if not IsList(k) then k:=[k]; fi;
			Remove(args,Position(args,Degree)+1);
			Remove(args,Position(args,Degree));
		else
			k:=SRDegrees();
		fi;

		groups:=[];
		for degree in k do   
            if not Position(args,Depth)=fail then
                n := args[Position(args,Depth)+1];
                if not IsList(n) then n:=[n]; fi;
                n := Intersection(SRLevels(degree), n);
			    Remove(args,Position(args,Depth)+1);
			    Remove(args,Position(args,Depth));
            else
                n := SRLevels(degree);
            fi;

            if not IsBound(_SelectSRGroupsCache@[degree]) then
                _SelectSRGroupsCache@[degree] := [];
            fi;

			for level in n do
                # Grab from the cache if we can
                if IsBound(_SelectSRGroupsCache@[degree][level]) then
                    Append(groups, _SelectSRGroupsCache@[degree][level]);
                    continue;
                fi;

				# get groups from library and name them
				groups_temp:=SRGroupsData(degree,level);
				names:=ShallowCopy(groups_temp);
				Apply(names,G->G[2]);
                if level > 1 then
                    parent_groups := ShallowCopy(groups_temp);
                    Apply(parent_groups, G->EvalString(G[3]));
                fi;
				Apply(groups_temp,G->RegularRootedTreeGroup(EvalString(SplitString(G[2],",","(")[2]),EvalString(SplitString(G[2],",")[2]),Group(G[1])));
				for i in [1..Length(groups_temp)] do
                    SetName(groups_temp[i],names[i]);
                    SetIsSelfReplicating(groups_temp[i], true);
                    if level > 1 then
                        SetParentGroup(groups_temp[i], parent_groups[i]);
                    fi;
                od;
                
                _SelectSRGroupsCache@[degree][level] := groups_temp;
				Append(groups,groups_temp);
			od;
		od;

		# sieve by all remaining properties
		if not args=[] then
			for i in [1..Length(groups)] do
				for j in [1..Length(args)/2] do
                    if AbsoluteValue(NumberArgumentsFunction(args[2*j-1])) = 2 then
                        # For binary functions
                        if IsList(args[2*j]) then
                            if not ForAny(args[2*j], x->args[2*j-1](groups[i],x)) then
                                Unbind(groups[i]);
                                break;
                            fi;
                        else
                            if not args[2*j-1](groups[i], args[2*j]) then
                                Unbind(groups[i]);
                                break;
                            fi;
                        fi;
                    elif AbsoluteValue(NumberArgumentsFunction(args[2*j-1])) = 1 then
                        # For operations and unary functions
                        if not STGSelFunc(args[2*j-1](groups[i]),args[2*j]) then
                            Unbind(groups[i]);
                            break;
                        fi;
                    else
                        Error("Function at position ", 2*j-1, " requires more than two parameters.");
                    fi;
				od;
				if not all and IsBound(groups[i]) then return groups[i]; fi;
			od;
		fi;
		
		return Compacted(groups);
	fi;	
end);

##################################################################################################################

# internal
InstallGlobalFunction( SRGroupData,
function(k,n,nr)
	if not (IsInt(k) and k in SRDegrees()) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n in SRLevels(k)) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	elif not (IsInt(nr) and nr in [1..Length(SRGroupsData(k,n))]) then
		Error("there are less than nr=",nr," SRGroups of degree k=",k," and depth n=",n);
	else
		return SRGroupsData(k,n)[nr];
	fi;
end);

# internal
InstallGlobalFunction( SRGroupsData,
function(k,n)
	local dir, file_name, data;
		
	if not (IsInt(k) and k in SRDegrees()) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n in SRLevels(k)) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	else
		# extract sr_k_n from the relevant library file
		dir:=DirectoriesPackageLibrary( "SRGroups", "data" );
		file_name:=Filename(dir[1], Concatenation("sr_",String(k),"_",String(n),".grp"));
		Read(file_name);
		data:=EvalString(Concatenation("sr_",String(k),"_",String(n)));
		# unbind sr_k_n
		MakeReadWriteGlobal(Concatenation("sr_",String(k),"_",String(n)));
		UnbindGlobal(Concatenation("sr_",String(k),"_",String(n)));
		return data;
	fi;
end);


##################################################################################################################
##################################################################################################################

# TODO: is this how transgrp works or is it meant to work differently?
InstallGlobalFunction( SRGroupsInfo,
function(arg)
	local dir, fnam, G, list, listTemp, i, j, k, n, lastNonZero, argFunctions, argMinimums, out, max, maxArgLength, listGroups, booleanList;
	
	if IsEmpty(SRDegrees()) then
		Error("no data is available");
	fi;

	maxArgLength:=9;
	argFunctions:=["Degree","Depth/Level","Number","Projection","IsSubgroup","Size","MinimalGeneratingSet","Position/Index","IsAbelian"];
	lastNonZero:=0;
	
	for i in [1..maxArgLength] do
		if not IsBound(arg[i]) then
			arg[i]:=[0];
		elif not IsList(arg[i]) then
			arg[i]:=[arg[i]];
		fi;
		
		for j in [1..Length(arg[i])-1] do
			if not IsInt(arg[i][j]) then
				Error("input argument ",argFunctions[i],"=",arg[i][j]," in arg[",i,"] must be a non-negative integer");
			elif not arg[i][j]>=0 then
				Error("input argument ",argFunctions[i],"=",arg[i][j]," in arg[",i,"] must be a non-negative integer");
			fi;
		od;
		
		if 0 in arg[i] and Length(arg[i])>1 then
			Error("input argument ",argFunctions[i],"=",arg[i]," in arg[",i,"] cannot be zero with multiple entries");
		fi;
		
		if i<9 and arg[i][1]<>0 then
			lastNonZero:=i;
		fi;
	od;
	
	if arg[4][1]=0 then
		argMinimums:=[2,1,1,1,1,,1,1];
	else
		argMinimums:=[2,2,1,1,1,,1,1];
	fi;
	
	out:=CheckSRGroupsInputs(true,argMinimums,argFunctions,arg[1],arg[2]);
	argMinimums:=out[2];
	if arg[1]<>out[3] and not IsEmpty(out[3]) then
		arg[1]:=ShallowCopy(out[3]);
		Print("Restricting degrees to ",arg[1],"\n");
	fi;
	if arg[2]<>out[4] and not IsEmpty(out[4]) then
		arg[2]:=ShallowCopy(out[4]);
		Print("Restricting levels to ",arg[2],"\n");
	fi;
	
	max:=CallFuncList(GetSRMaximums,arg);
	
	if lastNonZero>=3 then
		for i in [3..maxArgLength] do
			for j in [1..Length(arg[i])] do
				if i=3 or i=5 then
					out:=CheckSRGroupsInputs(i,arg[i][j],argMinimums,argFunctions,arg[1],arg[2],max[1]);
				elif i=4 then
					out:=CheckSRGroupsInputs(i,arg[i][j],argMinimums,argFunctions,arg[1],arg[2],max[2]);
				else
					out:=CheckSRGroupsInputs(i,arg[i][j],argMinimums,argFunctions,arg[1],arg[2]);
				fi;
				if IsString(out) then
					Error(out);
				fi;
			od;
		od;
	fi;

	dir:= DirectoriesPackageLibrary( "SRGroups", "data" );
	list:=[];
	if arg[1][1]<>0 and arg[2][1]<>0 then
		for i in [1..Length(arg[1])] do
			for j in [1..Length(arg[2])] do
				if SRGroupsAvailable(arg[1][i],arg[2][j]) then
					listTemp:=SRGroupsData(arg[1][i],arg[2][j]);
					Append(list,listTemp);
				fi;
			od;
		od;
	elif arg[1][1]<>0 and arg[2][1]=0 then
		for i in [1..Length(arg[1])] do
			for j in [argMinimums[2]..Length(SRLevels(arg[1][i]))] do
				listTemp:=SRGroupsData(arg[1][i],SRLevels(arg[1][i])[j]);
				Append(list,listTemp);
			od;
		od;
	elif arg[1][1]=0 and arg[2][1]<>0 then
		for i in [1..Length(SRDegrees())] do
			for j in [1..Length(arg[2])] do
				if SRGroupsAvailable(SRDegrees()[i],arg[2][j]) then
					listTemp:=SRGroupsData(SRDegrees()[i],arg[2][j]);
					Append(list,listTemp);
				fi;
			od;
		od;
	else
		for i in [1..Length(SRDegrees())] do
			for j in [argMinimums[2]..Length(SRLevels(SRDegrees()[i]))] do
				listTemp:=SRGroupsData(SRDegrees()[i],SRLevels(SRDegrees()[i])[j]);
				Append(list,listTemp);
			od;
		od;
	fi;
	
	if arg[9][1]<>0 then
		listTemp:=[];
		for i in [1..Length(list)] do
			if IsAbelian(Group(list[i][1]))=arg[9][1] then
				Add(listTemp,list[i]);
			fi;
		od;
		list:=listTemp;
	fi;
	
	if lastNonZero in [0,1,2] then
		G:=list;
		return G;
	fi;
	
	if arg[3][1]<>0 then
		listTemp:=[];
		for i in [1..Length(list)] do
			if EvalString(SplitString(SplitString(SplitString(list[i][2]," = ")[1],",")[3],")")[1]) in arg[3] then
				Add(listTemp,list[i]);
			fi;
		od;
		list:=listTemp;
		if lastNonZero=3 then
			G:=list;
			return G;
		fi;
	fi;
	
	if arg[4][1]<>0 then
		listTemp:=[];
		for i in [1..Length(list)] do
			if EvalString(SplitString(SplitString(SplitString(list[i][3]," = ")[1],",")[3],")")[1]) in arg[4] then
				Add(listTemp,list[i]);
			fi;
		od;
		list:=listTemp;
		if lastNonZero=4 then
			G:=list;
			return G;
		fi;
	fi;
	
	if arg[5][1]<>0 then
		listGroups:=[];
		listTemp:=[];
		for i in [1..Length(list)] do
			if EvalString(SplitString(SplitString(SplitString(list[i][2]," = ")[1],",")[3],")")[1]) in arg[5] then
				Add(listGroups,list[i]);
			fi;
		od;
		for i in [1..Length(list)] do
			k:=EvalString(SplitString(SplitString(list[i][2],",")[1],"(")[2]);
			n:=EvalString(SplitString(list[i][2],",")[2]);
			for j in [1..Length(listGroups)] do
				if k=EvalString(SplitString(SplitString(listGroups[j][2],",")[1],"(")[2]) and n=EvalString(SplitString(listGroups[j][2],",")[2]) then
					if IsSubgroupOfConjugate(AutT(k,n),Group(listGroups[j][1]),Group(list[i][1])) then
						Add(listTemp,list[i]);
					fi;
				fi;
			od;
		od;
		list:=listTemp;
		if lastNonZero=5 then
			G:=list;
			return G;
		fi;
	fi;
	
	if arg[6][1]<>0 then
		listTemp:=[];
		for i in [1..Length(list)] do
			if Size(Group(list[i][1])) in arg[6] then
				Add(listTemp,list[i]);
			fi;
		od;
		list:=listTemp;
		if lastNonZero=6 then
			G:=list;
			return G;
		fi;
	fi;
	
	if arg[7][1]<>0 then
		listTemp:=[];
		for i in [1..Length(list)] do
			if Length(MinimalGeneratingSet(Group(list[i][1]))) in arg[7] then
				Add(listTemp,list[i]);
			fi;
		od;
		list:=listTemp;
		if lastNonZero=7 then
			G:=list;
			return G;
		fi;
	fi;
	
	if arg[8][1]<>0 then
		listTemp:=ShallowCopy(list);
		if Length(arg[8])=1 then
			Apply(listTemp,H->H[arg[8][1]]);
		elif Length(arg[8])=2 then
			Apply(listTemp,H->[H[arg[8][1]],H[arg[8][2]]]);
		elif Length(arg[8])=3 then
			Apply(listTemp,H->[H[arg[8][1]],H[arg[8][2]],H[arg[8][3]]]);
		elif Length(arg[8])=4 then
			Apply(listTemp,H->[H[arg[8][1]],H[arg[8][2]],H[arg[8][3]],H[arg[8][4]]]);
		fi;
		list:=listTemp;
		if lastNonZero=8 then
			G:=list;
			return G;
		fi;
	fi;

	if IsBound(G) then
		return G;
	else
		Error("no method exists for those arguments; check if they are conflicting");
	fi;
end);

##################################################################################################################

InstallGlobalFunction(AllSRGroupsInfo,function(arg)
	local inputArgs, i;
	
	if IsInt(Length(arg)/2) then
		for i in [1..Length(arg)/2] do
			if not (IsOperation(arg[2*i-1]) or IsFunction(arg[2*i-1]) or Level=arg[2*i-1]) then
				Error("input argument arg[",2*i-1,"] must be a valid function or operation");
			fi;
		od;
	else
		Error("argument must be of the form (fun1,val1,fun2,val2,...)");
	fi;
	
	inputArgs:=[];

	if IsInt(Position(arg,Degree)) then
		Add(inputArgs,arg[Position(arg,Degree)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,Depth)) then
		Add(inputArgs,arg[Position(arg,Depth)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,Number)) then
		Add(inputArgs,arg[Position(arg,Number)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,Projection)) then
		Add(inputArgs,arg[Position(arg,Projection)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,IsSubgroupOfConjugate)) then
		Add(inputArgs,arg[Position(arg,IsSubgroupOfConjugate)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,Size)) then
		Add(inputArgs,arg[Position(arg,Size)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,MinimalGeneratingSet)) then
		Add(inputArgs,arg[Position(arg,MinimalGeneratingSet)+1]);
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,Index)) or IsInt(Position(arg,Position)) then
		if IsInt(Position(arg,Index)) then
			Add(inputArgs,arg[Position(arg,Index)+1]);
		elif IsInt(Position(arg,Position)) then
			Add(inputArgs,arg[Position(arg,Position)+1]);
		fi;
	else
		Add(inputArgs,0);
	fi;
	
	if IsInt(Position(arg,IsAbelian)) then
		Add(inputArgs,arg[Position(arg,IsAbelian)+1]);
	else
		Add(inputArgs,0);
	fi;

	return CallFuncList(SRGroupsInfo,inputArgs);
end);

##################################################################################################################
##################################################################################################################

InstallGlobalFunction( GetSRMaximums,
function(arg)
	local deg, lev, max, maxAbove, errorString, i;
	
	if arg[1][1]<>0 and arg[2][1]<>0 then
		if Length(arg)>=3 and (arg[3][1]<>0 or arg[5][1]<>0) then
			for deg in arg[1] do
				for lev in arg[2] do
					if SRGroupsAvailable(deg,lev) then
						if IsBound(max) then
							if max<NrSRGroups(deg,lev) then max:=NrSRGroups(deg,lev); fi;
						else
							max:=NrSRGroups(deg,lev);
						fi;
					fi;
				od;
			od;
		else
			max:=false;
		fi;
		
		if Length(arg)>=4 and arg[4][1]<>0 then
			for deg in arg[1] do
				for lev in arg[2] do
					if SRGroupsAvailable(deg,lev) and SRGroupsAvailable(deg,lev-1) then
						if IsBound(maxAbove) then
							if maxAbove<NrSRGroups(deg,lev-1) then maxAbove:=NrSRGroups(deg,lev-1); fi;
						else
							maxAbove:=NrSRGroups(deg,lev-1);
						fi;
					fi;
				od;
			od;
			if not IsBound(maxAbove) then
				Error("no data available containing two consecutive levels of degree ",String(arg[1])," and level ",String(arg[2])," groups");
			fi;
		else
			maxAbove:=false;
		fi;
	elif arg[1][1]<>0 and arg[2][1]=0 then
		if Length(arg)>=3 and (arg[3][1]<>0 or arg[5][1]<>0) then
			for deg in arg[1] do
				if IsBound(max) then
					if max<NrSRGroups(deg,Maximum(SRLevels(deg))) then max:=NrSRGroups(deg,Maximum(SRLevels(deg))); fi;
				else
					max:=NrSRGroups(deg,Maximum(SRLevels(deg)));
				fi;
			od;
		else
			max:=false;
		fi;
		
		if Length(arg)>=4 and arg[4][1]<>0 then
			for deg in arg[1] do
				if Length(SRLevels(deg))>=2 then
					for i in [2..Length(SRLevels(deg))] do
						if SRLevels(deg)[i]-1=SRLevels(deg)[i-1] then
							if IsBound(maxAbove) then
								if maxAbove<NrSRGroups(deg,SRLevels(deg)[i-1]) then maxAbove:=NrSRGroups(deg,SRLevels(deg)[i-1]); fi;
							else
								maxAbove:=NrSRGroups(deg,SRLevels(deg)[i-1]);
							fi;
						fi;
					od;
				fi;
			od;
			if not IsBound(maxAbove) then
				Error("no data available containing two consecutive levels of degree ",String(arg[1]));
			fi;
		else
			maxAbove:=false;
		fi;
	elif arg[1][1]=0 and arg[2][1]<>0 then
		if Length(arg)>=3 and (arg[3][1]<>0 or arg[5][1]<>0) then
			for deg in SRDegrees() do
				for lev in arg[2] do
					if lev in SRLevels(deg) then
						if IsBound(max) then
							if max<NrSRGroups(deg,lev) then max:=NrSRGroups(deg,lev); fi;
						else
							max:=NrSRGroups(deg,lev);
						fi;
					fi;
				od;
			od;
		else
			max:=false;
		fi;
		
		if Length(arg)>=4 and arg[4][1]<>0 then
			for deg in SRDegrees() do
				for lev in arg[2] do
					if lev in SRLevels(deg) and lev-1 in SRLevels(deg) then
						if IsBound(maxAbove) then
							if maxAbove<NrSRGroups(deg,lev-1) then maxAbove:=NrSRGroups(deg,lev-1); fi;
						else
							maxAbove:=NrSRGroups(deg,lev-1);
						fi;
					fi;
				od;
			od;
			if not IsBound(maxAbove) then
				Error("no data available containing level ",String(arg[1])," and level ",String(arg[1]-1)," groups");
			fi;
		else
			maxAbove:=false;
		fi;
	else
		if Length(arg)>=3 and (arg[3][1]<>0 or arg[5][1]<>0) then
			max:=1;
			for deg in SRDegrees() do
				for lev in SRLevels(deg) do
					if NrSRGroups(deg,lev)>max then
						max:=NrSRGroups(deg,lev);
					fi;
				od;
			od;
		else
			max:=false;
		fi;
		
		if Length(arg)>=4 and arg[4][1]<>0 then
			maxAbove:=0;
			for deg in SRDegrees() do
				if Length(SRLevels(deg))>=2 then
					for i in [2..Length(SRLevels(deg))] do
						if SRLevels(deg)[i]-1=SRLevels(deg)[i-1] then
							if NrSRGroups(deg,SRLevels(deg)[i-1])>maxAbove then
								maxAbove:=NrSRGroups(deg,SRLevels(deg)[i-1]);
							fi;
						fi;
					od;
				fi;
			od;
			if maxAbove=0 then
				Error("no data available containing two consecutive levels");
			fi;
		else
			maxAbove:=false;
		fi;
	fi;
	
	return [max,maxAbove];
end);

##################################################################################################################

InstallGlobalFunction( CheckSRGroupsInputs,
function(arg)
	local deg, lev, newDegs, newLevs, cont, errorString, i, j, k, argMinimums, argFunctions, degs, levs, max;
	
	if arg[1]=true then
		argMinimums:=arg[2];
		argFunctions:=arg[3];
		degs:=arg[4];
		levs:=arg[5];
		for deg in degs do
			if deg<>0 then
				if not (IsInt(deg) and (deg>=argMinimums[1] or deg=0)) then
					Error("input argument ",argFunctions[1],"=",deg," in arg[1] must be an integer greater than or equal to ", argMinimums[1]," or zero");
				fi;
			fi;
		od;
		
		for lev in levs do
			if lev<>0 then
				if not (IsInt(lev) and (lev>=argMinimums[2] or lev=0)) then
					if argMinimums[2]=2 then
						Error("input argument ",argFunctions[2],"=",lev," in arg[2] must be an integer greater than or equal to ", argMinimums[2]," or zero when the ",argFunctions[5]," argument is being used");
					else
						Error("input argument ",argFunctions[2],"=",lev," in arg[2] must be an integer greater than or equal to ", argMinimums[2]," or zero");
					fi;
				fi;
			fi;
		od;
		
		cont:=false;
		newDegs:=[];
		newLevs:=[];
		for deg in degs do
			for lev in levs do
				if deg<>0 and lev<>0 then
					if IsBound(argMinimums[6]) then
						if deg^lev<argMinimums[6] then argMinimums[6]:=deg^lev; fi;
					else
						argMinimums[6]:=deg^lev;
					fi;
					if SRGroupsAvailable(deg,lev) then
						cont:=true;
						if not deg in newDegs then Add(newDegs,deg); fi;
						if not lev in newLevs then Add(newLevs,lev); fi;
					fi;
				elif deg<>0 and lev=0 then
					if IsBound(argMinimums[6]) then
						if deg<argMinimums[6] then argMinimums[6]:=deg; fi;
					else
						argMinimums[6]:=deg;
					fi;
					if deg in SRDegrees() then
						Add(newDegs,deg);
						cont:=true;
					fi;
				elif deg=0 and lev<>0 then
					if not IsBound(argMinimums[6]) then argMinimums[6]:=2; fi;
					for i in [1..Length(SRDegrees())] do
						if lev in SRLevels(SRDegrees()[i]) then
							Add(newLevs,lev);
							cont:=true;
							break;
						fi;
					od;
				else
					cont:=true;
					argMinimums[6]:=2;
				fi;
			od;
		od;
		
		if cont then
			StableSort(newDegs);
			StableSort(newLevs);
			return [cont,argMinimums,newDegs,newLevs];
		else
			if degs[1]<>0 and levs[1]<>0 then
				Error("no data containing degree ",String(degs)," and level ",String(levs)," is available");
			elif degs[1]<>0 and levs[1]=0 then
				Error("no data containing degree ",String(degs)," is available");
			elif degs[1]=0 and levs[1]<>0 then
				Error("no data containing level ",String(levs)," is available");
			fi;
		fi;
	else
		i:=arg[1];
		argMinimums:=arg[3];
		argFunctions:=arg[4];
		degs:=arg[5];
		levs:=arg[6];
		if i in [3,4,5] then
			max:=arg[7];
		fi;
		arg:=arg[2];
		
		if i<9 then
			if arg<>0 then
				if i in [3,4,5,8] or not arg>=argMinimums[i] then
					if i in [3,5] then
						if arg>=argMinimums[i] and arg<=max then
							return true;
						else
							errorString:=Concatenation("input argument ",String(argFunctions[i]),"=",String(arg)," in arg[",String(i),"] must be an integer in [",String(argMinimums[i]),"..",String(max),"] or zero");
						fi;
					elif i=4 then
						if arg>=argMinimums[i] and arg<=max then
							return true;
						else
							errorString:=Concatenation("input argument ",String(argFunctions[i]),"=",String(arg)," in arg[",String(i),"] must be an integer in [",String(argMinimums[i]),"..",String(max),"] or zero");
						fi;
					elif i=8 then
						if arg>=argMinimums[i] and arg<=4 then
							return true;
						else
							errorString:=Concatenation("input argument ",String(argFunctions[i]),"=",String(arg)," in arg[",String(i),"] must be an integer in [1..4] or zero");
						fi;
					else
						errorString:=Concatenation("input argument ",String(argFunctions[i]),"=",String(arg)," in arg[",String(i),"] must be an integer greater than or equal to ",String(argMinimums[i])," or zero");
					fi;
				else
					return true;
				fi;
			else
				return true;
			fi;
		else 
			if not (IsBool(arg) or arg=0) then
				errorString:=Concatenation("input argument ",String(argFunctions[i]),"=",String(arg)," in arg[",String(i),"] must be a boolean or zero");
			else
				return true;
			fi;
		fi;
		
		return errorString;
	fi;
end);

##################################################################################################################
##################################################################################################################
##################################################################################################################

InstallGlobalFunction( StringVariables, function(arg)
	local Superstring, i;

	for i in [1..Length(arg)] do
		if i=1 then
			Superstring:=Concatenation("varArg",String(i),":=",String(arg[i]),";");
		else
			Superstring:=Concatenation(Superstring,"\nvarArg",String(i),":=",String(arg[i]),";");
		fi;
	od;

	return Superstring;
end);

##################################################################################################################

InstallGlobalFunction( UnbindVariables,
function(arg)
	local k;

	for k in [1..Length(arg)] do
		UnbindGlobal(arg[k]);
	od;
	
	return;
end);

##################################################################################################################

# Input:: deg: degree of the tree (integer at least 2), lev: level of the tree (integer at least 1; if lev=1, then the unformatted "sr_deg_1.grp" file must already exist) (requires "sr_deg_lev+1.grp" file to exist)
# Output:: Formatted version of the file "sr_deg_lev.grp"
InstallGlobalFunction(FormatSRFile, function(deg,lev)
	local pr, fSingleGroup, fCumulative, numGroupsAbove, numProj, i, groupInfo, projBelow, prBelow, aboveCount, k, fNew, dirData, dirTempFiles,reEntry, reEntryCheck, fVariables, numGroups, gens, gensAbove, gensAboveTemp, currentGens, j, fGens, fGensAbove, groupNum, groupsLevel1, checkLevel1;

	if not (IsInt(deg) and deg>=2) then
		Error("input argument deg=",deg," must be an integer greater than or equal to 2");
	elif not (IsInt(lev) and lev>=1) then
		Error("input argument deg=",deg," must be an integer greater than or equal to 1");
	fi;
	
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
		numGroups:=EvalString(SplitString(SplitString(SRGroupsInfo(deg,lev+1)[Length(SRGroupsInfo(deg,lev+1))][3],",")[3],")")[1]); # Number of groups on level lev (using file "sr_deg_lev+1.grp").
		numGroupsAbove:=0;
		aboveCount:=1;
		j:=1;
		i:=1;
	fi;
	# 2.2. Generate lists containing the same projections from lev+1 to lev, stored in projBelow[groupNum].
	projBelow:=[];
	for groupNum in [1..numGroups] do
		projBelow[groupNum]:=SRGroupsInfo(deg,lev+1,0,groupNum);
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
				numGroupsAbove:=EvalString(SplitString(SplitString(SRGroupsInfo(deg,lev)[Length(SRGroupsInfo(deg,lev))][3],",")[3],")")[1]); # Number of groups on level lev-1 (using file "sr_deg_lev.grp").
				for i in [1..numGroupsAbove] do
					if i>1 then
						numProj[i]:=numProj[i-1]+Length(SRGroupsInfo(deg,lev,0,i));
					else
						numProj[i]:=Length(SRGroupsInfo(deg,lev,0,i));
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
	checkLevel1:=false;
	while j<=numGroups do
		# 4.1. Create entries containing individual group information.
		groupInfo[j]:=[];
		groupInfo[j][1]:=gens[j];
		if lev=1 then
			if not checkLevel1 then
				groupsLevel1:=AllSRGroups(Degree,deg,Depth,lev);
				checkLevel1:=true;
			fi;
			for k in [1..Length(groupsLevel1)] do
				if Group(gens[j])=groupsLevel1[k] then
					groupInfo[j][2]:=Concatenation("\"",SRGroupsInfo(deg,lev,k)[2],"\"");
					Remove(groupsLevel1,Position(groupsLevel1,groupsLevel1[k]));
				fi;
			od;
		else
			groupInfo[j][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(j),")\"");
		fi;
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

##################################################################################################################

# Input:: Any integer in the range [0,31], which denotes the degree of the regular rooted tree being organised. If the input is 0 or 1, the degree is chosen to be the lowest degree not stored.
# Output:: The file containing all self-replicating groups of the rooted k-tree at the lowest level not stored.
InstallGlobalFunction(SRGroupFile, function(degree)
	local count, fNew, dirData, k, prevLev, srDegrees, i, x, dataContents, list2, groupGens, deg, lev, fExtensions, groupList, entryPoint, breakPoint, fBreakPointCheck, groupInfo, unsortedLists, sortedList, prevPosLists, yCount, w, yVisited, vCount, fLevelAboveSingle, groupInfoAbove, v, fSingleGroup, fCumulative, fVariables, fLevelAboveCumulative, reEntry, initialz, initialx, reEntryCheck, wCount, y, z, sortedLists, unsortedList, posList, dirTempFiles, fNewAbove, breakPointCheckExist, prevPosList, prevPosListBelow, j, srLevels, incompleteLevels, m, projectionProtocol, levGap, formatAbove, dirTempFilesContents, dirTempSingleFilesContents, stringFolder, dirTempSingleFiles, levReorder;
	
	if not (IsInt(degree) and degree>=0) then
		Error("input argument degree=",degree," must be an integer greater than or equal to zero");
	fi;
	
	# 0. Create directories to be used (dirData: storage of final group files, dirTempFiles: storage of temporary files).
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	dataContents:=DirectoryContents(dirData[1]); # Creates a list of strings with names of the files/folders stored in dirData.

	# 1. First check if the input argument is 0 or 1. If so, the tree level is automatically set to 1.
	if degree in [0,1] then
		deg:=2;
		# 1.1. Set the degree=deg to be 1 higher than the highest degree stored that is consecutive with 2.
		while SRGroupsAvailable(deg,1) do
			deg:=deg+1;
		od;
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
			groupInfo[wCount][1]:=GeneratorsOfGroup(TransitiveGroup(deg,wCount));
			groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",1,",String(wCount),") = ",ViewString(TransitiveGroup(deg,wCount)),"\"");
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
		if SRGroupsAvailable(deg,2) then
			FormatSRFile(deg,1);
		fi;
		Print("Done.");
		
	# 2. Case where the input argument is in [2,31].
	else 
		# 2.1. Set the degree to be the input argument.
		deg:=degree;
		Print("You have requested to make group files for degree ", deg, ".");
		
		# 2.2. Finding the level to begin. If an element of list begins with "sr_arg[1]_", then store it in srLevels.
		srLevels:=SRLevels(deg);
		
		# 2.2.1. Scan currently stored levels for any incomplete files (i.e. group files with index 4 of the group information that say "the classes it extends to").
		# Store any incomplete files which have an existing group file on the level srLevels[count]+1 in the list incompleteLevels.
		incompleteLevels:=[];
		m:=1;
		if not IsEmpty(srLevels) then
			for count in [1..Length(srLevels)] do
				if SRGroupsInfo(deg,srLevels[count])[1][4]=["the classes it extends to"] then
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
		
		# 2.2.3. If srLevels is not empty, then using list of currently stored levels, srLevels, check for any gaps by evaluating srLevels[count]. A gap is found when srLevels[count]=/=count.
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
					break;
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
				groupInfo[wCount][1]:=GeneratorsOfGroup(TransitiveGroup(deg,wCount));
				groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",1,",String(wCount),") = ",ViewString(TransitiveGroup(deg,wCount)),"\"");
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
				RemoveFile(fBreakPointCheck);
			fi;
			
			# 2.5.3. This is where the group information is gathered. Two protocols exist: the normal protocol; and the projection protocol.
			if not projectionProtocol then
				# 2.5.3.1. Normal protocol: Extend each group on level lev-1 to all conjugacy class representatives and store their generators in the file "temp_deg_lev.grp".
				groupGens:=[];
				if entryPoint<=Length(SRGroupsInfo(deg,lev-1)) then
					Print("\nEvaluating groups extending from:");
					if entryPoint=1 then
						Print("\n",Concatenation("SRGroup(",String(deg),",",String(lev-1),",1)"),"  (",1,"/",Length(SRGroupsInfo(deg,lev-1)),")");
					fi;
					for i in [entryPoint..Length(SRGroupsInfo(deg,lev-1))] do
						groupList:=ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection(SRGroup(deg, lev-1, i));
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
						if entryPoint<>Length(SRGroupsInfo(deg,lev-1)) then
							Print("\n",Concatenation("SRGroup(",String(deg),",",String(lev-1),",",String(i+1),")"),"  (",i+1,"/",Length(SRGroupsInfo(deg,lev-1)),")");
						fi;
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
				if SRGroupsInfo(deg,lev)[1][4]=["the classes it extends to"] then
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
				if SRGroupsInfo(deg,lev-1)[1][4]=["the classes it extends to"] then
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
					prevPosListBelow:=EvalString("varArg4");
					sortedList:=EvalString("varArg5");
					unsortedList:=EvalString("varArg6");
					vCount:=EvalString("varArg7");
					wCount:=EvalString("varArg8");
					w:=EvalString("varArg9");
					y:=EvalString("varArg10");
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
					for y in [1..Length(SRGroupsInfo(deg, lev-1))] do
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
					prevPosListBelow:=[];
				fi;
				
				# 2.5.5.3. Loop through every group on level 1 to extract extension information and format group files.
				# A while loop has been used here since y can iterate more than once per loop due to the variable posList.
				while y<=Length(SRGroupsInfo(deg, lev-1)) do
				
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
							# 2.5.5.3.3.1.
							prevPosListBelow[wCount]:=w;
							for count in [1..prevPosList[y]-1] do
								prevPosListBelow[wCount]:=prevPosListBelow[wCount]+unsortedList[count];
							od;
							# 2.5.5.3.3.2. Create entries containing individual group information.
							groupInfo[wCount]:=[];
							groupInfo[wCount][1]:=EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"))[w];
							groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(wCount),")\"");
							groupInfo[wCount][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(y),")\"");
							groupInfo[wCount][4]:="[\"the classes it extends to\"]";
							# 2.5.5.3.3.3. Print all individual group information (in correct format) to "temp_deg_2_indiv.grp".
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
							# 2.5.5.3.3.4. If fCumulative does not exist, it must be created and the first lines populated.
							if not IsExistingFile(fCumulative) then
								PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev),"\",\n["));
							fi;
							# 2.5.5.3.3.5. Print formatted individual group information to "temp_deg_2_full.grp" and save this point.
							AppendTo(fCumulative,StringFile(fSingleGroup));
							PrintTo(fVariables,StringVariables(z, posList, prevPosList, prevPosListBelow, sortedList, unsortedList, vCount, wCount, w, y)); # Save-point
							# 2.5.5.3.3.6. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
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
							groupInfoAbove[y]:=SRGroupsInfo(deg, lev-1)[prevPosList[y]];
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
							if y=Length(SRGroupsInfo(deg,lev-1)) then
								AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),"\n]);");
							else
								AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),",\n");
							fi;
							PrintTo(fVariables,StringVariables(z, posList, prevPosList, prevPosListBelow, sortedList, unsortedList, vCount, wCount, w, y)); # Save-point
							# 2.5.5.3.4.7. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
							if reEntry then
								reEntry:=false;
								initialz:=1;
							fi;
						fi;
						# 2.5.5.3.5. Check and declare if re-entry was completed (by setting reEntry to false, resetting initialz, and unbinding temp_deg_1_prevPosList[y]_proj).
						# This is required if both level 2 and level 1 formatting has already been completed, but has not yet looped to the next group's save-point.
						if reEntry then
							initialz:=1;
							reEntry:=false;
						fi;
						if IsBoundGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj")) then
							MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
							UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(prevPosList[y]),"_proj"));
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
					prevPosList:=EvalString("varArg5");
					prevPosListBelow:=EvalString("varArg6");
					sortedLists:=EvalString("varArg7");
					unsortedList:=EvalString("varArg8");
					unsortedLists:=EvalString("varArg9");
					vCount:=EvalString("varArg10");
					wCount:=EvalString("varArg11");
					yCount:=EvalString("varArg12");
					yVisited:=EvalString("varArg13");
					w:=EvalString("varArg14");
					y:=EvalString("varArg15");
					# 2.5.6.1.1. Unbind temp_deg_lev-1_num_proj variables which have already been completely used from previous run.
					# x denotes group number on level lev-2, k denotes group number on level lev-1 extending from group x.
					# Start by looping through all groups on level lev-2, then groups on level lev-1 extending from group x.
					for x in [1..initialx] do
						if x<>initialx then
							for k in [1..Length(prevPosLists[x])] do
								MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
								UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
							od;
						else
							for k in [1..y-1] do
								MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
								UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][k]),"_proj"));
							od;
						fi;
					od;
				
				# 2.5.6.2. No re-entry condition. Start from beginning by initialising required variables.
				else
					reEntry:=false;
					reEntryCheck:=false;
					# 2.5.6.2.1. Create a list which measures the cumulative number of branches extending from all groups on level lev-2 prior to group x.
					yVisited:=[];
					for x in [1..Length(SRGroupsInfo(deg,lev-2))] do
						if x>1 then
							yVisited[x]:=yVisited[x-1]+Length(SRGroupsInfo(deg,lev-1,0,x-1));
						else
							yVisited[x]:=0;
						fi;
					od;
					# 2.5.6.2.2. Create a list containing the number of extensions from each group on level lev-1.
					unsortedList:=[];
					for y in [1..Length(SRGroupsInfo(deg,lev-1))] do
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
					prevPosList:=[];
					prevPosListBelow:=[];
				fi;
				
				# 2.5.6.3. Groups on level lev-1 must be re-arranged, but can only be re-arranged if they extend from a common group.
				# Therefore, divide the lists into lists containing lists to capture this, from which each list within the lists is sorted in the required order.
				# x denotes group number on level lev-2, y denotes group number on level lev-1 extending from group x.
				for x in [initialx..Length(SRGroupsInfo(deg,lev-2))] do
					# 2.5.6.3.1. Upon re-entry these variables are already defined.
					if not reEntry then
						# 2.5.6.3.1.1. Initialise list entries within ...Lists variables.
						unsortedLists[x]:=[];
						sortedLists[x]:=[];
						prevPosLists[x]:=[];
						# 2.5.6.3.1.2. Divide unsortedList into unsortedLists indexed by x (i.e. the groups on level lev-2), since you can only re-arrange groups extending from a common group.
						for y in [1..Length(SRGroupsInfo(deg,lev-1,0,x))] do
							unsortedLists[x][y]:=unsortedList[yVisited[x]+y];
						od;
						y:=1;
						# 2.5.6.3.1.3. Sort unsortedLists[x] so that the groups can be formatted based on this revised order.
						sortedLists[x]:=SortedList(unsortedLists[x]);
					fi;
					
					# 2.5.6.3.2 Loop through every group on level lev-1 to extract extension information and format group files.
					# A while loop has been used here since y can iterate more than once per loop due to the variable posList.
					while y<=Length(SRGroupsInfo(deg,lev-1,0,x)) do
					
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
								prevPosList[yCount]:=yVisited[x]+prevPosLists[x][y];
								w:=1;
							fi;
							
							# 2.5.6.3.2.2.2. Store the formatted information of all groups extending from group number prevPosLists[x][y]. See any "sr_deg_lev.grp" file for how this formatting is done.
							# A while loop is used here so that if w=sortedList[x][y]+1 from reading fVariables, it will skip the loop due to already having completed all formatting for these groups.
							while w<=sortedLists[x][y] do
								# 2.5.6.3.2.2.2.1.
								prevPosListBelow[wCount]:=w;
								for count in [1..prevPosList[yCount]-1] do
								prevPosListBelow[wCount]:=prevPosListBelow[wCount]+unsortedList[count];
								od;
								# 2.5.6.3.2.2.2.2. Create entries containing individual group information.
								groupInfo[wCount]:=[];
								groupInfo[wCount][1]:=EvalString(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"))[w];
								groupInfo[wCount][2]:=Concatenation("\"SRGroup(",String(deg),",",String(lev),",",String(wCount),")\"");
								groupInfo[wCount][3]:=Concatenation("\"SRGroup(",String(deg),",",String(lev-1),",",String(yVisited[x]+y),")\"");
								groupInfo[wCount][4]:="[\"the classes it extends to\"]";
								# 2.5.6.3.2.2.2.3. Print all individual group information (in correct format) to "temp_deg_lev_indiv.grp".
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
								# 2.5.6.3.2.2.2.4. If fCumulative does not exist, it must be created and the first lines populated.
								if not IsExistingFile(fCumulative) then
									PrintTo(fCumulative, Concatenation("##This contains a list of the self-replicating groups on the rooted regular-", String(deg), " tree on level", " ", String(lev), "##\n\nBindGlobal(\"sr_",String(deg),"_",String(lev),"\",\n["));
								fi;
								# 2.5.6.3.2.2.2.5. Print formatted individual group information to "temp_deg_lev_full.grp" and save this point.
								AppendTo(fCumulative,StringFile(fSingleGroup));
								PrintTo(fVariables,StringVariables(x, z, posList, prevPosLists, prevPosList, prevPosListBelow, sortedLists, unsortedList, unsortedLists, vCount, wCount, yCount, yVisited, w, y)); # Save-point
								# 2.5.6.3.2.2.2.6. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
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
								groupInfoAbove[x][y]:=SRGroupsInfo(deg,lev-1)[yVisited[x]+prevPosLists[x][y]];
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
								if yVisited[x]+y=Length(SRGroupsInfo(deg,lev-1)) then
									AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),"\n]);");
								else
									AppendTo(fLevelAboveCumulative,StringFile(fLevelAboveSingle),",\n");
								fi;
								PrintTo(fVariables,StringVariables(x, z, posList, prevPosLists, prevPosList, prevPosListBelow, sortedLists, unsortedList, unsortedLists, vCount, wCount, yCount, yVisited, w, y)); # Save-point
								# 2.5.6.3.2.2.3.8. Check and declare if re-entry was completed (by setting reEntry to false and resetting initialz).
								if reEntry then
									reEntry:=false;
									initialz:=1;
								fi;
							fi;
							# 2.5.6.3.2.2.4. Check and declare if re-entry was completed (by setting reEntry to false, resetting initialz, and unbinding temp_deg_lev-1_num_proj).
							# This is required if both level lev and level lev-1 formatting has already been completed, but has not yet looped to the next group's save-point.
							if reEntry then
								initialz:=1;
								reEntry:=false;
							fi;
							if IsBoundGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj")) then
								MakeReadWriteGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
								UnbindGlobal(Concatenation("temp_",String(deg),"_",String(lev-1),"_",String(yVisited[x]+prevPosLists[x][y]),"_proj"));
							fi;
							# 2.5.6.3.2.2.5. Loop y within the loop for z (since more than one group could extend to the same number of groups).
							y:=y+1;
							yCount:=yCount+1; # Counter for y that never resets
						od;
					od;
				od;
			fi;
		fi;
		
		if not projectionProtocol then
			# 2.5.7. Append end of list containing groups.
			if not EndsWith(StringFile(fCumulative),"\n]);") then
				AppendTo(fCumulative,"\n]);");
			fi;
			
			# 2.6. Reorder all individual temporary file numbering
			Print("\nReordering individual files.");
			dirTempFilesContents:=DirectoryContents(dirTempFiles[1]);
			for levReorder in [1..Length(dirTempFilesContents)] do
				stringFolder:=Concatenation("temp_",String(deg),"_",String(levReorder));
				if stringFolder in dirTempFilesContents then
					dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups",Concatenation("data/temp_files/",stringFolder,"/"));
					dirTempSingleFilesContents:=DirectoryContents(dirTempSingleFiles[1]);
					Remove(dirTempSingleFilesContents,Position(dirTempSingleFilesContents,"."));
					Remove(dirTempSingleFilesContents,Position(dirTempSingleFilesContents,".."));
					for j in [1..Length(dirTempSingleFilesContents)] do
						if StartsWith(dirTempSingleFilesContents[j],Concatenation("temp_",String(deg),"_",String(lev-1))) then
							ReorderSRFiles(deg,levReorder,lev-1,prevPosList,prevPosListBelow,unsortedList);
							break;
						fi;
					od;
				fi;
			od;
			
			# 2.7. Print all group information to final sr_deg_lev.grp file (and sr_deg_lev-1.grp in the case for level>1), remove all associated temporary files, and unbind all residual variables.
			PrintTo(fNew,StringFile(fCumulative));
			RemoveFile(fExtensions);
			RemoveFile(fSingleGroup);
			RemoveFile(fCumulative);
			RemoveFile(fVariables);
			if reEntryCheck and lev>2 then
				UnbindVariables("varArg1", "varArg2", "varArg3", "varArg4", "varArg5", "varArg6", "varArg7", "varArg8", "varArg9", "varArg10", "varArg11", "varArg12", "varArg13", "varArg14", "varArg15");
			elif reEntryCheck and lev=2 then
				UnbindVariables("varArg1", "varArg2", "varArg3", "varArg4", "varArg5", "varArg6", "varArg7", "varArg8", "varArg9", "varArg10");
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
		if lev=1 and SRGroupsAvailable(deg,2) then
			FormatSRFile(deg,1);
		fi;
		Print("\nDone.");
	fi;
	
	return;
end);

##################################################################################################################

# Input:: arg[1]: degree of tree (int > 1), arg[2]: highest level of tree where the file "sr_k_n.grp" exists (int > 1), (arg[3],arg[4],...): sequence of group numbers to extend from
# Output:: File named "temp_deg_initialLev_arg[3]_arg[4]_..._arg[Length(arg)]_proj.grp" that contains extension information of group
InstallGlobalFunction( ExtendSRGroup, 
function(arg)
	local deg, lev, groupPosition, groupPositionAbove, initialLev, stringPrefix, stringFolder, stringFolderAbove, stringSuffix, stringSuffixAbove, dirData, dirTempFiles, dirTempSingleFiles, dirTempSingleFilesAbove, fExtension, fExtensionAbove, G,  groupList, groupGens, i;
	
	if not (IsInt(arg[1]) and arg[1]>=2) then
		Error("input argument arg[1]=",arg[1]," must be an integer greater than or equal to 2");
	else
		for i in [2..Length(arg)] do
			if not (IsInt(arg[i]) and arg[i]>=1) then
				Error("input argument arg[i]=",arg[i]," must be an integer greater than or equal to 1");
			fi;
		od;
	fi;
	
	# 1. Initialise degree, levels, and group position.
	deg:=arg[1];
	initialLev:=arg[2];
	groupPosition:=[];
	for i in [3..Length(arg)] do
		groupPosition[i-2]:=arg[i];
	od;
	groupPositionAbove:=ShallowCopy(groupPosition);
	Remove(groupPositionAbove,Length(groupPosition));
	lev:=initialLev+Length(groupPosition);
	
	# 2. Initialise strings that refer to file and variable names, and initialise first two directories.
	stringPrefix:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringFolder:=Concatenation("temp_",String(deg),"_",String(lev));
	stringFolderAbove:=Concatenation("temp_",String(deg),"_",String(lev-1));
	stringSuffix:=Concatenation("_",JoinStringsWithSeparator(List(groupPosition,String),"_"));
	stringSuffixAbove:=Concatenation("_",JoinStringsWithSeparator(List(groupPositionAbove,String),"_"));
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	
	# 3. Determine the group, G, to extend.
	# 3.1. Case 1: The group can be called directly from the file "sr_deg_initialLev.grp" using SRGroup(deg,initialLev,groupPosition[1]), if the file exists.
	if Length(groupPosition)=1 and IsExistingFile(Filename(dirData[1],Concatenation("sr_",String(deg),"_",String(initialLev),".grp"))) then
		# 3.1.1. Check whether the group position is within the range of groups available, and if so, initialise G.
		if groupPosition[1]>=1 and groupPosition[1]<=Length(SRGroupsInfo(deg,lev-1)) then
			G:=SRGroup(deg,initialLev,groupPosition[1]);
		else
			Print("Group location does not exist (group number). Please choose a group in the correct range (1<=num<=",Length(SRGroupsInfo(deg,lev-1)),")");
			return;
		fi;
	# 3.2. Case 2: The group must be called from an individual extension file "temp_deg_initialLev_arg[3]_arg[4]_..._arg[Length(arg)-1]_proj.grp".
	else
		# 3.2.1. Check whether directory to individual extension file exists, and if so, initialise the directory and filename (named as in Step 3.2).
		if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(stringFolderAbove,"/"))) then
			dirTempSingleFilesAbove:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringFolderAbove,"/"));
			fExtensionAbove:=Filename(dirTempSingleFilesAbove[1],Concatenation(stringPrefix,stringSuffixAbove,"_proj.grp"));
			# 3.2.1.1. Check whether file exists (named as in Step 3.2), and if so, read the file and initialise G (then unbind residual variable).
			if IsExistingFile(fExtensionAbove) then
				Read(fExtensionAbove);
				G:=RegularRootedTreeGroup(deg,lev-1,Group(EvalString(Concatenation(stringPrefix,stringSuffixAbove,"_proj"))[groupPosition[Length(groupPosition)]]));
				MakeReadWriteGlobal(Concatenation(stringPrefix,stringSuffixAbove,"_proj"));
				UnbindGlobal(Concatenation(stringPrefix,stringSuffixAbove,"_proj"));
			else
				Print("Group location does not exist (missing file).");
				return;
			fi;
		else
			Print("Group location does not exist (missing directory).");
			return;
		fi;
	fi;
	
	# 4. Check whether directory to new file already exists (it will exist in the case other groups on the same level have already been extended).
	# If it doesn't exist, create the directory and then initialise its corresponding variable name.
	if not IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(stringFolder,"/"))) then
		CreateDir(Filename(dirTempFiles[1],Concatenation(stringFolder,"/")));
	fi;
	dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringFolder,"/"));
	
	
	# 5. Initialise new filename variable.
	# 5.1. Case 1: If the file already exists, the group has already been extended.
	fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringPrefix,stringSuffix,"_proj.grp"));
	if IsExistingFile(fExtension) then
		Print("Already extended group ",groupPosition[1],".");
		return;
	# 5.2. Case 2: If the file does not exist, extend the group and print/append to new file.
	else
		groupList:=ConjugacyClassRepsSelfReplicatingSubgroupsWithConjugateProjection(G);
		PrintTo(fExtension,Concatenation("BindGlobal(\"",stringPrefix,stringSuffix,"_proj\",\n["));
		groupGens:=[];
		for i in [1..Length(groupList)] do
			groupGens[i]:=GeneratorsOfGroup(groupList[i]);
			if i=Length(groupList) then
				AppendTo(fExtension,Concatenation("\n\t",String(groupGens[i]),"\n]);"));
			else
				AppendTo(fExtension,Concatenation("\n\t",String(groupGens[i]),","));
			fi;
		od;
	fi;
	
	return;
end);

##################################################################################################################

# Input:: deg: degree of tree (int > 1), lev: level of tree (int > 0)
# Output:: The combined file "temp_deg_lev.grp" containing all extended groups on level lev-1 (for use with the SRGroupFile function)
InstallGlobalFunction( CombineSRFiles, 
function(deg,lev)
	local stringFolder, stringFolderAbove, dirTempFiles, dirTempSingleFiles, fExtension, fExtensions, i;
	
	if not (IsInt(deg) and deg>=2) then
		Error("input argument deg=",deg," must be an integer greater than or equal to 2");
	elif not (IsInt(lev) and lev>=1) then
		Error("input argument lev=",lev," must be an integer greater than or equal to 1");
	fi;
	
	# 1. Initialise strings that refer to file and variable names, and initialise directory to contain file "temp_deg_lev.grp" (pkg/SRGroups/data/temp_files/).
	stringFolderAbove:=Concatenation("temp_",String(deg),"_",String(lev-1));
	stringFolder:=Concatenation("temp_",String(deg),"_",String(lev));
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	
	# 2. Check if directory to individual files (temp_files/temp_deg_lev) exists. 
	# 2.1. Case 1: If it does exist, begin combining files.
	if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(stringFolder,"/"))) then
		# 2.1.1. Initialise directory containing "temp_deg_lev-1_i.grp" files.
		dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringFolder,"/"));
		# 2.1.2. For each file containing an individual group's extensions, fExtension ("temp_deg_lev-1_i.grp"), print the file contents to the new file, fExtensions ("temp_deg_lev.grp"). 
		fExtensions:=Filename(dirTempFiles[1],Concatenation(stringFolder,".grp"));
		for i in [1..Length(SRGroupsInfo(deg,lev-1))] do
			fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringFolderAbove,"_",String(i),"_proj.grp"));
			# 2.1.2.1. Case 1: File exists, so print/append to new file.
			if IsExistingFile(fExtension) then
				if i=1 then
					PrintTo(fExtensions,StringFile(fExtension));
				else
					AppendTo(fExtensions,"\n\n",StringFile(fExtension));
				fi;
			# 2.1.2.2. Case 2: File does not exist, meaning the new file should not be completed, so break the loop and delete the new file.
			else
				Print("The groups are incomplete (no file found). Please continue from group ",i,".");
				RemoveFile(fExtensions);
				break;
			fi;
		od;
		# 2.1.3. Remove residual files and directory if all of the group extensions were appended to the new file.
		if IsExistingFile(fExtensions) then
			for i in [1..Length(SRGroupsInfo(deg,lev-1))] do
				fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringFolderAbove,"_",String(i),"_proj.grp"));
				RemoveFile(fExtension);
			od;
			RemoveDir(Filename(dirTempFiles[1],Concatenation(stringFolder,"/")));
		fi;
	# 2.2. Case 2: If directory does not exist, then no files can be combined - return.
	else
		Print("The groups are incomplete (no directory found). Please continue from group 1.");
	fi;
	
	return;
end);

##################################################################################################################

# Input:: deg: degree of tree (int > 1), lev: level of tree (int > initialLev > 1), initialLev: highest level of tree where the file "sr_k_n.grp" exists (int > 1), prevPosList: list containing previous positions, p2, of all individual group extension files ("temp_deg_initialLev_p1_p2_..._proj.grp") obtained from the function SRGroupFile (therefore also containing their new positions), unsortedList: list containing the number and order of groups which have p2 as their fifth entry of the correspondoing file name (so if groups are missing, this gap can be detected and skipped)
# Output:: the updated ordering of the individual group extension files aligned with the reordering from running the function SRGroupFile
InstallGlobalFunction( ReorderSRFiles,
function(deg,lev,initialLev,prevPosListAbove,prevPosList,unsortedList)
	local stringPrefixInitial, stringPrefixFinal, stringSuffixInitial, stringSuffixFinal, stringInitialList, stringFinal, stringFolder, dirTempSingleFiles, dirTempSingleFilesContents, fExtensionInitial, fExtensionFinal, groupPosition, groupGens, groupCount, groupCountStart, groupCountBelow, groupCountBelowSpecific, unsortedListBranches, groupCountBelowStart, posFile, posOneList, posOneListIndex, i;
	
	# 1. Initialise string prefixes that refer to file and variable names, and string for the folder containing the individual group extension files.
	stringPrefixInitial:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringPrefixFinal:=Concatenation("temp_",String(deg),"_",String(initialLev+1));
	stringFolder:=Concatenation("temp_",String(deg),"_",String(lev));
	
	# 2. Initialise directory containing individual group extension files and list the directory's contents excluding the "current directory", ., and "directory above", .., commands, and any filenames beginning with "temp_deg_lev+1" (since those files have already been updated from a previous run attempt).
	
	dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringFolder,"/"));
	dirTempSingleFilesContents:=DirectoryContents(dirTempSingleFiles[1]);
	Remove(dirTempSingleFilesContents,Position(dirTempSingleFilesContents,"."));
	Remove(dirTempSingleFilesContents,Position(dirTempSingleFilesContents,".."));
	for posFile in [1..Length(dirTempSingleFilesContents)] do
		if StartsWith(dirTempSingleFilesContents[posFile],stringPrefixFinal) then
			Remove(dirTempSingleFilesContents,posFile);
		fi;
	od;
	# 2.1. Sorting here is to ensure that the directory's contents are alphanumerically ordered (since the DirectoryContents function prioritises individual characters over what would be entire numbers; for example, "temp_2_3_15_1_proj.grp" would come before "temp_2_3_2_2_proj.grp" but we would like it to be the other way around and recognise that 15 is bigger than 2).
	StableSort(dirTempSingleFilesContents);
	for groupCountBelow in [Length(SplitString(dirTempSingleFilesContents[1],"_"))..4] do
		SortBy(dirTempSingleFilesContents, function(elm) return EvalString(SplitString(elm,"_")[groupCountBelow]); end);
	od;
	
	# 3. Evaluate the number of groups with the same fourth entry using unsortedList (i.e. p1 in "temp_deg_initialLev_p1_p2_..._proj.grp") and store numbering in the list variable unsortedListBranches. These counts must be completed in the unsorted order (the order that they are currently in) to ensure that equating files (to check if any are missing) is done correctly.
	unsortedListBranches:=[];
	groupCountBelow:=1;
	for groupCount in [1..Length(unsortedList)] do
		for groupCountBelowSpecific in [1..unsortedList[groupCount]] do
			# 3.1. The variables groupCountStart and groupCountBelowStart are important to establish the first group's position that is in "./SRGroups/data/temp_files/temp_deg_lev/".
			if EvalString(SplitString(dirTempSingleFilesContents[1],"_")[4])=groupCount and EvalString(SplitString(dirTempSingleFilesContents[1],"_")[5])=groupCountBelowSpecific then
				groupCountStart:=groupCount;
				groupCountBelowStart:=groupCountBelow;
			fi;
			unsortedListBranches[groupCountBelow]:=groupCountBelowSpecific;
			groupCountBelow:=groupCountBelow+1; # groupCountBelow is the same as groupCountBelowSpecific, except it never resets
		od;
	od;
	
	# 4. Update formatting of each file in "./SRGroups/data/temp_files/temp_deg_lev/".
	# Before the while loop, initialise required variables.
	posFile:=1;
	posOneList:=Positions(unsortedListBranches,1);
	posOneListIndex:=Position(posOneList,groupCountBelowStart-(unsortedListBranches[groupCountBelowStart]-1));
	groupPosition:=[];
	groupCount:=groupCountStart;
	groupCountBelow:=groupCountBelowStart;
	while posFile<=Length(dirTempSingleFilesContents) do
		# 4.1. Case 1: The filename contains the old formatting (i.e. starts with "temp_deg_initialLev") and the fifth entry in the filename aligns with the branch position from unsortedListBranches. The second check is completed to ensure that no gaps in the files are overlooked (i.e. since some groups may have been extended while others may have not).
		if StartsWith(dirTempSingleFilesContents[posFile],stringPrefixInitial) and EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[5])=unsortedListBranches[groupCountBelow] and EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[4])=groupCount then
			# 4.1.1. Create new strings for the updated file name. Start by splitting the old file name string into its indexed positions, then replace the fifth entry of the old string with the fourth entry of the new string.
			stringInitialList:=SplitString(dirTempSingleFilesContents[posFile],"_");
			for i in [5..Length(stringInitialList)] do
				if  i=5 then
					groupPosition[i-4]:=Position(prevPosList,groupCountBelow);
				elif i<>Length(stringInitialList) then
					groupPosition[i-4]:=EvalString(stringInitialList[i]);
				fi;
			od;
			stringSuffixFinal:=Concatenation("_",JoinStringsWithSeparator(List(groupPosition,String),"_"));
			stringFinal:=Concatenation(stringPrefixFinal,stringSuffixFinal,"_proj.grp");
			# 4.1.2. Initialise old and new filenames. Print old file information to new file, except replace the global variable name with the updated name.
			fExtensionFinal:=Filename(dirTempSingleFiles[1],stringFinal);
			fExtensionInitial:=Filename(dirTempSingleFiles[1],dirTempSingleFilesContents[posFile]);
			Read(fExtensionInitial);
			PrintTo(fExtensionFinal,Concatenation("BindGlobal(\"",SplitString(stringFinal,".")[1],"\",\n["));
			groupGens:=EvalString(SplitString(dirTempSingleFilesContents[posFile],".")[1]);
			for i in [1..Length(groupGens)] do
				if i=Length(groupGens) then
					AppendTo(fExtensionFinal,Concatenation("\n\t",String(groupGens[i]),"\n]);"));
				else
					AppendTo(fExtensionFinal,Concatenation("\n\t",String(groupGens[i]),","));
				fi;
			od;
			# 4.1.3. Unbind residual variables and remove old file.
			MakeReadWriteGlobal(SplitString(dirTempSingleFilesContents[posFile],".")[1]);
			UnbindGlobal(SplitString(dirTempSingleFilesContents[posFile],".")[1]);
			RemoveFile(fExtensionInitial);
			posFile:=posFile+1;
		# 4.2. Case 2: The file will have the old formatting but a new branch position has been reached in the folder's contents.
		else
			# 4.2.1. Align groupCount with the numbering in position 4 of the current filename. To align groupCountBelow, we must move to the corresponding branch in unsortedListBranches by moving to the next occurrence of 1 in this list (i.e. posOneList[posOneListIndex]).
			if EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[4])<>groupCount then
				posOneListIndex:=posOneListIndex+(EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[4])-groupCount);
				groupCountBelow:=posOneList[posOneListIndex];
				groupCount:=EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[4]);
			fi;
			# 4.2.2. Update groupCountBelow so the sub-branch position aligns.
			groupCountBelow:=groupCountBelow+(EvalString(SplitString(dirTempSingleFilesContents[posFile],"_")[5])-unsortedListBranches[groupCountBelow]);
		fi;
	od;

	return;
end);

##################################################################################################################

# Input:: arg[1]: degree of tree (int > 1), arg[2]: highest level of tree where the file "sr_k_n.grp" exists (int > 1), (arg[3],arg[4],...): sequence of group numbers to extend from
# Output:: the number of extensions of the chosen group (or, if Length(arg)=2, the total number of extensions for that level if the combined file "temp_deg_lev.grp" is available)
InstallGlobalFunction( NumberExtensionsUnformatted,
function(arg)
	local deg, initialLev, groupPosition, lev, stringPrefix, stringSuffix, stringFolder, dirTempFiles, dirTempSingleFiles, fExtension, fExtensions, numExtensions, i;
	
	# 1. Initialise degree, levels, and group position. A specific case needs to be made when Length(arg)=2.
	deg:=arg[1];
	initialLev:=arg[2];
	groupPosition:=[];
	if Length(arg)>2 then
		for i in [3..Length(arg)] do
			groupPosition[i-2]:=arg[i];
		od;
		lev:=initialLev+Length(groupPosition);
	else
		lev:=initialLev+1;
	fi;
	
	# 2. Initialise strings that refer to file and variable names, string for the folder containing the individual group extension files, and directory containing temporary files.
	stringPrefix:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringSuffix:=Concatenation("_",JoinStringsWithSeparator(List(groupPosition,String),"_"));
	stringFolder:=Concatenation("temp_",String(deg),"_",String(lev));
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	
	# 3. Protocol for calculating the number of extensions from a single group or all groups.
	# 3.1. Case 1: The directory to files containing individual group extensions exists and a group position has been defined (by (arg[3],arg[4],...))
	if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(stringFolder,"/"))) and Length(arg)>2 then
		# Initialise directory and file containing target group information, then count the number of groups contained in that file.
		dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringFolder,"/"));
		fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringPrefix,stringSuffix,"_proj.grp"));
		if IsExistingFile(fExtension) then
			Read(fExtension);
			numExtensions:=Length(EvalString(Concatenation(stringPrefix,stringSuffix,"_proj")));
			MakeReadWriteGlobal(Concatenation(stringPrefix,stringSuffix,"_proj"));
			UnbindGlobal(Concatenation(stringPrefix,stringSuffix,"_proj"));
		else
			Print("Group location does not exist (file missing).");
			return;
		fi;
	# 3.2. Case 2: The file "temp_deg_lev.grp" exists.
	elif IsExistingFile(Filename(dirTempFiles[1],Concatenation(stringFolder,".grp"))) then
		fExtensions:=Filename(dirTempFiles[1],Concatenation(stringFolder,".grp"));
		Read(fExtensions);
		# 3.2.1. Case 2.1: Length(arg)>2, which indicates the number of extensions of a specific group number on level initialLev must be evaluated.
		if Length(arg)>2 then
			if IsBoundGlobal(EvalString(Concatenation(stringPrefix,stringSuffix,"_proj"))) then
				numExtensions:=Length(EvalString(Concatenation(stringPrefix,stringSuffix,"_proj")));
				for i in [1..Length(SRGroupsInfo(deg,initialLev))] do
					if IsBoundGlobal(Concatenation(stringPrefix,"_",String(i),"_proj")) then
						MakeReadWriteGlobal(Concatenation(stringPrefix,"_",String(i),"_proj"));
						UnbindGlobal(Concatenation(stringPrefix,"_",String(i),"_proj"));
					fi;
				od;
			else
				Print("This group has not been extended yet.");
			fi;
		# 3.2.2. Case 2.2: Length(arg)=2, which indicates the total number of extensions from all groups on level initialLev must be evaluated (in the case all groups can be accessed).
		elif Length(arg)=2 and IsBoundGlobal(Concatenation(stringPrefix,"_",String(Length(SRGroupsInfo(deg,initialLev))),"_proj")) then
			numExtensions:=0;
			for i in [1..Length(SRGroupsInfo(deg,initialLev))] do
				numExtensions:=numExtensions+Length(EvalString(Concatenation(stringPrefix,"_",String(i),"_proj")));
				MakeReadWriteGlobal(Concatenation(stringPrefix,"_",String(i),"_proj"));
				UnbindGlobal(Concatenation(stringPrefix,"_",String(i),"_proj"));
			od;
		else
			Print("Not all groups have been extended yet.");
		fi;
	# 3.3. Case 3: Some combination of the above conditions are not satisfied (see explanations in the print statements).
	else
		if Length(arg)>2 then
			Print("Group location does not exist (directory missing).");
		else
			Print("Not enough inputs provided. At least three inputs are required.");
		fi;
		return;
	fi;
	
	return numExtensions;
end);

##################################################################################################################

InstallGlobalFunction( IsSubgroupOfConjugate,
function(pr,G,H)
	local Hcon;
	
	if not IsSubgroup(pr,G) then return false; fi;
	
	if IsSubgroup(G,H) then
		return true;
	else
		for Hcon in H^pr do
			if IsSubgroup(G,Hcon) then
				return true;
			fi;
		od;
	fi;
	
	return false;
end);

##################################################################################################################

InstallGlobalFunction( CheckSRProjections,
function(k,n)
	local dir, fnam, list1, list2, pr, i, G1, G2, check, aut, autAbove;
	
	if not (IsInt(k) and k>=2) then
		Error("input argument k=",k," must be an integer greater than or equal to 2");
	elif not (IsInt(n) and n>=1) then
		Error("input argument n=",n," must be an integer greater than or equal to 1");
	else
		if not SRGroupsAvailable(k,n) then
			Print("These groups are not available (yet)!");
			return;
		else
			check:=0;
			aut:=AutT(k,n);
			autAbove:=AutT(k,n-1);
			list1:=AllSRGroups(Degree,k,Depth,n);
			list2:=AllSRGroupsInfo(Degree,k,Depth,n,Position,3);
			pr:=Projection(aut);
			for i in [1..Length(list1)] do
				G1:=Image(pr,list1[i]);
				G2:=Group(EvalString(Concatenation("SRGroupsInfo(",SplitString(list2[i],"(")[2]))[1]);
				if not (G1=G2 or IsConjugate(autAbove,G1,G2)) then
					Print("SRGroup(",String(k),",",String(n),")[",String(i),"]\n");
					check:=check+1;
				fi;
			od;

			if check=0 then
				Print("All groups project correctly.");
			else
				Print(check," groups did not project corrrectly.");
			fi;

			return;
		fi;
	fi;
end);
