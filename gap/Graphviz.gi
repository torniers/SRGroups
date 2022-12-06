SRGroupNrFromName@ := function(name)
    return EvalString(SplitString(name,",",")")[3]);
end;

RecurseDotGroupHeirarchy@ := function(k, n, nr, levels, name)
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
            nr_child:=SRGroupNrFromName@(name_child);
            dot := Concatenation(dot, RecurseDotGroupHeirarchy@(k_child, n_child, nr_child, levels - 1, name_child));
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
    dot := Concatenation(dot, RecurseDotGroupHeirarchy@(k, n, nr, levels - 1, name));

    dot := Concatenation(dot, "}\n");
    return dot;
end);

##################################################################################################################

# TODO(cameron) document that we use digraphs as a dep
TransitiveReduction@ := function(groups)
    local digraph;
    digraph := Digraph(groups, IsSubgroup);
    digraph := DigraphTransitiveReduction(digraph);
    return digraph;
end;

DotSubgroupLattice@ := function(groups, colours, fill_colours, selected_groups, class)
    local dot, parent_count, group_i, shape, style, colour, fill_colour, ranks, rank, orders, order, i, edge;
    dot := "digraph {\n";

    if not class = "" then
        dot := Concatenation(dot, "class=", class, ";");
    fi;

    # Sort the groups into bins of the order
    ranks := rec();
    for group_i in groups do
        i := Order(group_i);
        if not IsBound(ranks.(i)) then
            ranks.(i) := [];
        fi;
        Add(ranks.(i), group_i);
    od;

    # Create all the nodes, each within a group specifying the rank so all the orders are on the same level.
    for order in RecNames(ranks) do
        dot := Concatenation(dot, "{rank = same;", order, "[shape=none];\n");
        for group_i in ranks.(order) do
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
            if (not Depth(group_i) = 1) and IsBound(colours[SRGroupNumber(ParentGroup(group_i))]) then
                colour := colours[SRGroupNumber(ParentGroup(group_i))];
            else
                colour := "1.0 1.0 0.0";
            fi;
            if IsBound(fill_colours[SRGroupNumber(group_i)]) then
                fill_colour := fill_colours[SRGroupNumber(group_i)];
            else
                fill_colour := "1.0 0.0 1.0";
            fi;
            dot := Concatenation(dot, "\"", Name(group_i), "\"[");
            dot := Concatenation(dot, "style=\"", style, "\" ");
            dot := Concatenation(dot, "color=\"", colour, "\" ");
            dot := Concatenation(dot, "fillcolor=\"", fill_colour, "\" ");
            dot := Concatenation(dot, "shape=", shape);
            dot := Concatenation(dot, "];\n");
        od;
        dot := Concatenation(dot, "}\n");
    od;

    # Enforce the hierarchy more strictly
    orders := Set(List(RecNames(ranks), x->Int(x))); # Convert to int, to prevent sorting lexicographically
    for i in [2..Length(orders)] do
        dot := Concatenation(dot, String(orders[i]), " -> ", String(orders[i-1]), "[style=invis];\n");
    od;

    # Create the edges
    for edge in DigraphEdges(TransitiveReduction@(groups)) do
        if not edge[1] = edge[2] then
            dot := Concatenation(dot, "\"", Name(groups[edge[1]]), "\" -> \"", Name(groups[edge[2]]), "\";\n");
        fi;
    od;

    dot := Concatenation(dot, "}\n");
    return dot;
end;

InstallGlobalFunction(DotSubgroupLattice,
function(k, n)
    return DotSubgroupLattice@(AllSRGroups(Degree, k, Depth, n), [], [], [], "");
end);

