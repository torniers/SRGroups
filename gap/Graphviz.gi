SRGroupNrFromName := function(name)
    return EvalString(SplitString(name,",",")")[3]);
end;

RecurseDotGroupHeirarchy := function(k, n, nr, levels, name)
    local dot, i, name_child, k_child, n_child, nr_child;
    dot := "";
    i := 0;

    if levels <= 0 then
        return "";
    fi;

    # TODO(cameron) stop rereading the same file over and over again
    for name_child in SRGroupData(k, n, nr)[4] do
        i := i + 1;
        if not name_child = "the classes it extends to" then
            dot := Concatenation(dot, "\"", name, "\"", " -> ", "\"", name_child, "\"", ";\n");
            k_child:=SRGroupDegreeFromName(name_child);
	        n_child:=SRGroupLevelFromName(name_child);
            nr_child:=SRGroupNrFromName(name_child);
            dot := Concatenation(dot, RecurseDotGroupHeirarchy(k_child, n_child, nr_child, levels - 1, name_child));
        fi;
    od;

    return dot;
end;

InstallGlobalFunction(DotGroupHeirarchy,
function(k, n, nr, levels)
    local dot, name;
    dot := "digraph {\n";

    name := Concatenation("SRGroup(", String(k), ",", String(n), ",", String(nr), ")");
    dot := Concatenation(dot, "\"", name, "\"", ";\n");
    dot := Concatenation(dot, RecurseDotGroupHeirarchy(k, n, nr, levels - 1, name));

    dot := Concatenation(dot, "}");
    return dot;
end);

##################################################################################################################

InstallGlobalFunction(DotSubgroupLattice,
function(k, n)
    local dot, group_i, group_j, groups;
    dot := "digraph {\n";
    
    # TODO(cameron) Find better algorithm than n^2
    groups := AllSRGroups(Degree, k, Depth, n);
    for group_i in groups do
        dot := Concatenation(dot, "\"", Name(group_i), "\"", ";\n");
    od;

    dot := Concatenation(dot, "}");
    return dot;
end);

