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

SRSubgroupLattice := function(groups)
    local digraph;
    digraph := Digraph(groups, IsSubgroup);
    digraph := DigraphTransitiveReduction(digraph);
    return digraph;
end;

InstallGlobalFunction(DotSubgroupLattice,
function(k, n)
    local dot, parent_count, group_i, groups, hue, shape, ranks, rank, i, bound_positions, colour, edge;
    dot := "digraph {\n";
    groups := AllSRGroups(Degree, k, Depth, n);

    if n = 1 then
        colour := false;
    else
        colour := true;
    fi;

    # Sort the groups into bins of the order
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
    if colour then
        parent_count := NrSRGroups(k, n-1);
    fi;
    i := 1;
    for rank in ranks do
        dot := Concatenation(dot, "{rank = same;", String(bound_positions[i]), "[shape=none];\n");
        for group_i in rank do
            # Create the node
            if colour then
                #TODO(cameron) use a better colourmap
                hue := String(Float(SRGroupNumber(ParentGroup(group_i))/parent_count));
            fi;
            if IsCyclic(group_i) then
                shape := "box";
            else
                shape := "oval";
            fi;
            dot := Concatenation(dot, "\"", Name(group_i), "\"[");
            if colour then
                dot := Concatenation(dot, "color=\"", hue, " 1.0 1.0\" ");
            fi;
            dot := Concatenation(dot, "shape=", shape,"];\n");
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
end);

##################################################################################################################

InstallGlobalFunction(JupyterDot,
function(dot)
    local id, code;
    id:=Base64String(Concatenation("graph",String(Random(1,10000))));
    code := Concatenation("<div id='",id,"'></div>\
        <script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\
        <script type=\"module\">\
            const dot = `", dot,"`;\
            import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\
            if (Graphviz) {\
                const graphviz = await Graphviz.load();\
                const svg = graphviz.layout(dot, \"svg\", \"dot\");\
                document.getElementById(\"", id, "\").innerHTML = svg;\
            }\
        </script>");
    return Objectify( JupyterRenderableType, rec(  source := "gap", data := rec( ("text/html") := code ), metadata:=rec() ));
end);

