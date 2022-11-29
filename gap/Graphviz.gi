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
    local dot, parent_count, group_i, group_j, groups, hue, shape, ranks, rank, i;
    dot := "digraph {\n";
    groups := AllSRGroups(Degree, k, Depth, n);

    # Sort the groups into bins of the order
    ranks := [];
    for group_i in groups do
        i := LogInt(Order(group_i), k);
        if not IsBound(ranks[i]) then
            ranks[i] := [];
        fi;
        Add(ranks[i], group_i);
    od;

    # Create all the nodes, each within a group specifying the rank so all the orders are on the same level.
    i := PositionBound(ranks);
    parent_count := NrSRGroups(k, n-1);
    for rank in ranks do
        dot := Concatenation(dot, "{rank = same;", String(k^i), "[shape=none];\n");
        for group_i in rank do
            # Create the node   
            hue := String(Float(SRGroupNumber(ParentGroup(group_i))/parent_count)); #TODO(cameron) use a better colourmap
            if IsCyclic(group_i) then
                shape := "box";
            else
                shape := "oval";
            fi;
            dot := Concatenation(dot, "\"", Name(group_i), "\"[color=\"", hue, " 1.0 1.0\" shape=", shape,"];\n");
        od;
        dot := Concatenation(dot, "}\n");
        i := i + 1;
    od;

    # Create the edges
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

