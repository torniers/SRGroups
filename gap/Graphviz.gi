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
            dot := Concatenation(dot, "\"", name, "\" -> \"", name_child, "\";\n");
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
    dot := Concatenation(dot, "\"", name, "\";\n");
    dot := Concatenation(dot, RecurseDotGroupHeirarchy(k, n, nr, levels - 1, name));

    dot := Concatenation(dot, "}\n");
    return dot;
end);

##################################################################################################################

InstallGlobalFunction(DotSubgroupLattice,
function(k, n)
    local dot, i, group_i, group_j, groups, parent_groups, p_group;
    dot := "digraph {\n";

    i := 0;
    parent_groups := AllSRGroups(Degree, k, Depth, n-1);
    for p_group in parent_groups do
        i := i + 1;
        dot := Concatenation(dot, "subgraph cluster_", String(i), "{\n");
        groups := ChildGroups(p_group);
        for group_i in groups do
            if IsCyclic(group_i) then
                dot := Concatenation(dot, "\"", Name(group_i), "\"[color=\"blue\"];\n");
            else
                dot := Concatenation(dot, "\"", Name(group_i), "\";\n");
            fi;
        od;
        dot := Concatenation(dot, "}\n");
    od;

    # TODO(cameron) Find better algorithm than n^2
    groups := AllSRGroups(Degree, k, Depth, n);
    for group_i in groups do
        for group_j in groups do
            if (not group_j = group_i) and IsSubgroup(group_i, group_j) then
                dot := Concatenation(dot, "\"", Name(group_i), "\" -> \"", Name(group_j), "\";\n");
            fi;
        od;
    od;

    #TODO(cameron) Do what `tred` does, until then filter output through `tred` to remove transitive edges.
    # https://gitlab.com/graphviz/graphviz/-/blob/main/cmd/tools/tred.c

    dot := Concatenation(dot, "}\n");
    return dot;
end);

