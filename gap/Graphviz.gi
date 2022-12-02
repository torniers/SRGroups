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

# TODO(cameron) probably should just implement topological sort, rather than add digraph as a dependency
SRSubgroupLattice := function(groups)
    local digraph;
    digraph := Digraph(groups, IsSubgroup);
    digraph := DigraphTransitiveReduction(digraph);
    return digraph;
end;

_DotSubgroupLattice := function(groups, selected_groups)
    local dot, parent_count, group_i, shape, style, ranks, rank, i, bound_positions, edge;
    dot := "digraph {\n";

    # TODO(cameron) readd colour

    # Sort the groups into bins of the order
    # TODO(cameron) use an associative array, rather than a plain list
    ranks := [];
    for group_i in groups do
        i := Order(group_i);
        if not IsBound(ranks[i]) then
            ranks[i] := [];
        fi;
        Add(ranks[i], group_i);
    od;

    # Create all the nodes, each within a group specifying the rank so all the orders are on the same level.
    bound_positions := PositionsBound(ranks);
    i := 1;
    for rank in ranks do
        dot := Concatenation(dot, "{rank = same;", String(bound_positions[i]), "[shape=none];\n");
        for group_i in rank do
            # Create the node
            if IsCyclic(group_i) then
                shape := "box";
            else
                shape := "oval";
            fi;
            if group_i in selected_groups then
                style := "filled";
            else
                style := "";
            fi;
            dot := Concatenation(dot, "\"", Name(group_i), "\"[");
            dot := Concatenation(dot, "style=\"", style, "\" ");
            dot := Concatenation(dot, "shape=", shape);
            dot := Concatenation(dot, "];\n");
        od;
        dot := Concatenation(dot, "}\n");
        i := i + 1;
    od;

    # Enforce the hierarchy more strictly
    for i in [2..Length(bound_positions)] do
        dot := Concatenation(dot, String(bound_positions[i]), " -> ", String(bound_positions[i-1]), "[style=invis];\n");
    od;

    # Create the edges
    for edge in DigraphEdges(SRSubgroupLattice(groups)) do
        if not edge[1] = edge[2] then
            dot := Concatenation(dot, "\"", Name(groups[edge[1]]), "\" -> \"", Name(groups[edge[2]]), "\";\n");
        fi;
    od;

    dot := Concatenation(dot, "}\n");
    return dot;
end;

InstallGlobalFunction(DotSubgroupLattice,
function(k, n)
    return _DotSubgroupLattice(AllSRGroups(Degree, k, Depth, n), []);
end);

