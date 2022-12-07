DotGroupHeirarchy@ := function(groups_by_depth, colours, class)
    local dot, depth, i, group_i, group_j, colour;
    dot := "digraph {\n";

    # TODO(cameron) add colours

    # Add the svg-class if we are provided with one
    if not class = "" then
        dot := Concatenation(dot, "class=", class, ";");
    fi;

    for depth in groups_by_depth do
        for group_i in depth do

            dot := Concatenation(dot, "\"", Name(group_i), "\";\n");
        od;
    od;

    for i in [1..Length(groups_by_depth)-1] do
        for group_i in groups_by_depth[i] do
            for group_j in groups_by_depth[i+1] do
                if group_i = ParentGroup(group_j) then
                    if (IsBound(colours[i]) and
                        IsBound(colours[i][SRGroupNumber(group_i)]) and
                        IsBound(colours[i][SRGroupNumber(group_i)][SRGroupNumber(group_j)])) then
                        colour := colours[i][SRGroupNumber(group_i)][SRGroupNumber(group_j)];
                    else
                        colour := "1.0 1.0 0.0";
                    fi;
                    dot := Concatenation(dot, "\"", Name(group_i), "\" -> \"", Name(group_j), "\"[");
                    dot := Concatenation(dot, "color=\"", colour , "\"");
                    dot := Concatenation(dot, "];\n");
                fi;
            od;
        od;
    od;

    dot := Concatenation(dot, "}\n");
    return dot;
end;

IsSRGroupAncestor := function(group, potential_ancestor)
    local depth_g, depth_a, i, actual_ancestor;
    if not (IsSelfReplicating(group) and IsSelfReplicating(potential_ancestor)) then
        Error(Name(group), " or ", Name(potential_ancestor), " was not self-replicating.");
    fi;
    if not Degree(group) = Degree(potential_ancestor) then
        # Need same degree
        return false;
    fi;
    depth_a := Depth(potential_ancestor);
    depth_g := Depth(group);
    if not depth_a < depth_g then
        # Ancestor must be higher up
        return false;
    fi;
    actual_ancestor := group;
    for i in [1..depth_g-depth_a] do
        actual_ancestor := ParentGroup(group);
    od;
    return actual_ancestor = potential_ancestor;
end;

InstallGlobalFunction(DotGroupHeirarchy,
function(k, n, nr, levels)
    return DotGroupHeirarchy@(
        List([n..n+levels-1], x->AllSRGroups(Degree, k, Depth, x, IsSRGroupAncestor, SRGroup(k, n, nr))),
        [],
        ""
    );
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

    # Add the svg-class if we are provided with one
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
    orders := Set(List(RecNames(ranks), Int)); # Convert to int, to prevent sorting lexicographically
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

