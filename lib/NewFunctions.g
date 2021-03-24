InstallGlobalFunction(ExtendSRGroup,function(deg,lev,num)
	local numList, initialLev, stringInitial, stringAbove, string, stringSuffixAbove, stringSuffix, dirData, dirTempFiles, dirTempSingleFiles, dirTempSingleFilesAbove, fGLocation, fExtension, groupList, groupGens, i, G;
	
	if not IsList(num) then
		numList:=[num];
	else
		numList:=num;
	fi;
	initialLev:=lev-Length(numList);
	stringInitial:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringAbove:=Concatenation("temp_",String(deg),"_",String(lev-1));
	string:=Concatenation("temp_",String(deg),"_",String(lev));
	stringSuffixAbove:="";
	stringSuffix:="";
	for i in [1..Length(numList)] do
		if i<>Length(numList) then
			stringSuffixAbove:=Concatenation(stringSuffix,"_",String(numList[i]));
		fi;
		stringSuffix:=Concatenation(stringSuffix,"_",String(numList[i]));
	od;
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	if Length(numList)=1 and IsExistingFile(Filename(dirData[1],Concatenation("sr_",String(deg),"_",String(initialLev),".grp"))) then
		if num>=1 and num<=Length(SRGroup(deg,lev-1)) then
			G:=Group(SRGroup(deg,initialLev,num)[1]);
		else
			Print("Group location does not exist. Please choose a group in the correct range (1<=num<=",Length(SRGroup(deg,lev-1)),")");
			return;
		fi;
	else
		if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(stringAbove,"/"))) then
			dirTempSingleFilesAbove:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",stringAbove,"/"));
			fGLocation:=Filename(dirTempSingleFilesAbove[1],Concatenation(stringInitial,stringSuffixAbove,"_proj.grp"));
			if IsExistingFile(fGLocation) then
				Read(fGLocation);
				G:=Group(EvalString(Concatenation(stringInitial,stringSuffixAbove,"_proj"))[numList[Length(numList)]]);
				MakeReadWriteGlobal(Concatenation(stringInitial,stringSuffixAbove,"_proj"));
				UnbindGlobal(Concatenation(stringInitial,stringSuffixAbove,"_proj"));
			else
				Print("Group location does not exist");
				return;
			fi;
		else
			Print("Group location does not exist");
			return;
		fi;
	fi;
	if not IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(string,"/"))) then
		CreateDir(Filename(dirTempFiles[1],Concatenation(string,"/")));
	fi;
	dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",string,"/"));
	fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringInitial,stringSuffix,"_proj.grp"));
	if IsExistingFile(fExtension) then
		Print("Already extended group ",num,".");
		return;
	else
		groupList:=ConjugacyClassRepsSelfReplicatingSubgroupsWithProjection(deg,lev,G);
		PrintTo(fExtension,Concatenation("BindGlobal(\"",stringInitial,stringSuffix,"_proj\",\n["));
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
	
end);

InstallGlobalFunction(CombineSRFiles,function(deg,lev)
	local stringAbove, string, dirTempFiles, dirTempSingleFiles, fExtension, fExtensions, i;
	
	stringAbove:=Concatenation("temp_",String(deg),"_",String(lev-1));
	string:=Concatenation("temp_",String(deg),"_",String(lev));
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(string,"/"))) then
		dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",string,"/"));
		for i in [1..Length(SRGroup(deg,lev-1))] do
		fExtensions:=Filename(dirTempFiles[1],Concatenation(string,".grp"));
		fExtension:=Filename(dirTempSingleFiles[1],Concatenation(stringAbove,"_",String(i),".grp"));
			if IsExistingFile(fExtension) then
				if i=1 then
					PrintTo(fExtensions,StringFile(fExtension));
				else
					AppendTo(fExtensions,"\n\n",StringFile(fExtension));
				fi;
			else
				Print("The groups are incomplete. Please continue from group ",i,".");
				return;
			fi;
		od;
	else
		Print("The groups are incomplete. Please continue from group 1.");
		return;
	fi;
	
end);

InstallGlobalFunction(ReorderSRFiles,function(deg,lev,initialLev,prevPosList)
	local stringInitial, stringInitialBelow, string, dirTempSingleFiles, fTempExtensionList, fExtensionList, listDirContents, newString, stringList, i;
	
	stringInitial:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringInitialBelow:=Concatenation("temp_",String(deg),"_",String(initialLev+1));
	string:=Concatenation("temp_",String(deg),"_",String(lev));
	dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",string,"/"));
	fTempExtensionList:=[];
	fExtensionList:=[];
	listDirContents:=DirectoryContents(dirTempSingleFiles[1]);
	Remove(listDirContents,Position(listDirContents,"."));
	Remove(listDirContents,Position(listDirContents,".."));
	for i in [1..Length(listDirContents)] do
		newString:=stringInitialBelow;
		stringList:=SplitString(listDirContents[i],"_");
		for j in [5..Length(stringList)] do
			if  j<>5 then
				newString:=Concatenation(newString,"_",stringList[j]);
			else
				newString:=Concatenation(newString,"_",String(i));
			fi;
		od;
		fTempExtensionList[i]:=Filename(dirTempSingleFiles[1],newString);
		fExtensionList[prevPosList[i]]:=Filename(dirTempSingleFiles[1],listDirContents[prevPosList[i]]);
		if IsExistingFile(fExtensionList[i]) then
			PrintTo(fTempExtensionList[i],StringFile(fExtensionList[prevPosList[i]]));
			Remove(fExtensionList[prevPosList[i]]);
		fi;
	od;

	return;
end);

InstallGlobalFunction(LengthSingleExtension,function(deg,lev,numList)
	local initialLev, stringInitial, string, stringSuffix, dirData, dirTempFiles, dirTempSingleFilesAbove, fGLocation, length, i;

	initialLev:=lev-Length(numList);
	stringInitial:=Concatenation("temp_",String(deg),"_",String(initialLev));
	string:=Concatenation("temp_",String(deg),"_",String(lev));
	stringSuffix:="";
	for i in [1..Length(numList)] do
		stringSuffix:=Concatenation(stringSuffix,"_",String(numList[i]));
	od;
	dirData:=DirectoriesPackageLibrary("SRGroups", "data");
	dirTempFiles:=DirectoriesPackageLibrary("SRGroups", "data/temp_files");
	if IsDirectoryPath(Filename(dirTempFiles[1],Concatenation(string,"/"))) then
		dirTempSingleFilesAbove:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",string,"/"));
		fGLocation:=Filename(dirTempSingleFilesAbove[1],Concatenation(stringInitial,stringSuffix,"_proj.grp"));
		if IsExistingFile(fGLocation) then
			Read(fGLocation);
			length:=Length(EvalString(Concatenation(stringInitial,stringSuffixAbove,"_proj")));
			MakeReadWriteGlobal(Concatenation(stringInitial,stringSuffixAbove,"_proj"));
			UnbindGlobal(Concatenation(stringInitial,stringSuffixAbove,"_proj"));
		else
			Print("Group location does not exist");
			return;
		fi;
	else
		Print("Group location does not exist");
		return;
	fi;
	
	return length;
end);

InstallGlobalFunction(ReorderSRFiles,function(deg,lev,initialLev,prevPosList,unsortedList)
	local stringInitial, stringInitialBelow, string, dirTempSingleFiles, fNewExtension, fExtension, listDirContents, newString, stringList, groupList, count, j, i, countAboveList, countAbove;
	
	stringInitial:=Concatenation("temp_",String(deg),"_",String(initialLev));
	stringInitialBelow:=Concatenation("temp_",String(deg),"_",String(initialLev+1));
	string:=Concatenation("temp_",String(deg),"_",String(lev));
	dirTempSingleFiles:=DirectoriesPackageLibrary("SRGroups", Concatenation("data/temp_files/",string,"/"));
	listDirContents:=DirectoryContents(dirTempSingleFiles[1]);
	Remove(listDirContents,Position(listDirContents,"."));
	Remove(listDirContents,Position(listDirContents,".."));
	countAboveList:=[];
	for count in [1..Length(unsortedList)] do
		for j in [1..unsortedList[count]] do
			if EvalString(SplitString(listDirContents[1],"_")[4])=count and EvalString(SplitString(listDirContents[1],"_")[5])=j then
				i:=countAbove;
			fi;
			countAboveList[countAbove]:=j;
			countAbove:=countAbove+1;
		od;
	od;
	j:=1;
	
	while i<=Length(prevPosList) and j<=Length(listDirContents) do
		if StartsWith(listDirContents[j],stringInitial) and EvalString(SplitString(listDirContents[j],"_")[5])=countAboveList[i] then
			newString:=stringInitialBelow;
			stringList:=SplitString(listDirContents[j],"_");
			for k in [5..Length(stringList)] do
				if  k<>5 then
					newString:=Concatenation(newString,"_",stringList[k]);
				else
					newString:=Concatenation(newString,"_",String(Position(prevPosList,i)));
				fi;
			od;
			fNewExtension:=Filename(dirTempSingleFiles[1],newString);
			fExtension:=Filename(dirTempSingleFiles[1],listDirContents[j]);
			if IsExistingFile(fExtension) then
				Read(fExtension);
				PrintTo(fNewExtension,Concatenation("BindGlobal(\"",SplitString(newString,".")[1],"\",\n["));
				groupList:=EvalString(SplitString(listDirContents[j],".")[1]);
				for k in [1..Length(groupList)] do
					if k=Length(groupList) then
						AppendTo(fNewExtension,Concatenation("\n\t",String(groupList[k]),"\n]);"));
					else
						AppendTo(fNewExtension,Concatenation("\n\t",String(groupList[k]),","));
					fi;
				od;
				# RemoveFile(fExtension);
			fi;
			j:=j+1;
		elif StartsWith(listDirContents[j],stringInitialBelow) then
			break;
		else
			while EvalString(SplitString(listDirContents[j],"_")[5])<>countAboveList[i] do
				i:=i+1;
			od;
		fi;
	od;

	return;
end);