# dot is the initial dot code to display, id is the unique id of the instance of the app
# callback_name is a string containing the name of a function that takes in the name of an sr group and the id
#   and returns a list of dot code
# Returns the javascript code to be injected into jupyter
JupyterDot@ := function(id, callback_name)
    local code;
    # TODO(cameron) use a local copy of the library
    code := Concatenation("<div id='",id,"'></div>\n\
<script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\n\
<script src=\"https://cdn.jsdelivr.net/npm/svg-pan-zoom-container@0.6.1\"></script>\n\
<script type=\"module\">\n\
    import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\n\
    if (Graphviz) {\n\
        const graphviz = await Graphviz.load();\n\
        \n\
        function register_callbacks(){\n\
            document.querySelectorAll('.",id," >[id*=\"node\"]').forEach(\n\
                (x) => {\n\
                    x.addEventListener(\"click\", function(){\n\
                        const name = x.firstElementChild.textContent.split(\"\\\\n\")[0];\n\
                        IPython.notebook.kernel.execute(`",callback_name,"(\"${name}\", \"",id,"\");`, callbacks);\n\
                    });\n\
                }\n\
            );\n\
        }\n\
        \n\
        var callbacks = {\n\
            iopub: {\n\
                output: (data) => {\n\
                    console.log(data.content);\n\
                    document.getElementById(\"",id,"\").innerHTML = \"\";\n\
                    data.content.data.forEach((dot)=>{\n\
                        document.getElementById(\"",id,"\").innerHTML += \"<div \" + \n\
                            \"data-pan-on-drag='button: right;' \" + \n\
                            \"data-zoom-on-wheel='max-scale: 10; min-scale: 1;' \"+\n\
                            \"style='border-style:solid; height: 500px;' >\" + \n\
                            graphviz.layout(dot, \"svg\", \"dot\") + \"</div>\";\n\
                        document.getElementById(\"",id,"\").innerHTML += \"<br>\";\n\
                    });\n\
                    register_callbacks();\n\
                }\n\
            }\n\
        };\n\
        \n\
        IPython.notebook.kernel.execute(`",callback_name,"(\"\", \"",id,"\");`, callbacks);\n\
    }\n\
</script>");
    return Objectify(JupyterRenderableType, rec(source := "gap", data := rec(("text/html") := code), metadata:=rec()));
end;

# A map from the unique ids, to a list corresponding to degrees each containing a list of the selected projections of
# that degree.
# AppSelectedProjections@.(id)[depth] := list of selected groups
AppSelectedProjections@ := rec();

# A map from the unique ids, to a list corresponding to degrees each containing a list corresponding to depth each
# containing a list containing what groups are projected to the group of the index
# ProjectionCache@.(id)[n][nr] := list of groups that project to SRGroup(k, n, nr)
ProjectionCache@ := rec();

# Contains the groups of depth 1
Depth1Cache@ := rec();

# 1 <= n <= total
# Returns a string for the HSV with hue being a unique value for each n
HSVColour@ := function(n, total)
    return Concatenation(String(Float((total-n+1)/total)), " 1.0 1.0");
end;

# This is the callback used for the app, see JupyterDot@. The id is the unique id of the instance of this app
# It takes in a group_name that will be toggled between selected and not, then constructs dot code based on what is
# selected and returns a list where each element is the dot code for the depth
AppCallback@ := function(group_name, id)
    local degree, groups, group, dot, pos, i, j, k, nr_i, nr_j, colours, fill_colours;
    
    if group_name = "" then
        # This is the setup call
        dot := [
            DotGroupHeirarchy@([Depth1Cache@.(id)], [], id),
            DotSubgroupLattice@(Depth1Cache@.(id), [], [], [], id)
        ];
        return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
    fi;


    group := EvalString(group_name);
    degree := Degree(group);

    # Make sure we have a list to put the group in
    if not IsBound(AppSelectedProjections@.(id)[Depth(group)]) then
        AppSelectedProjections@.(id)[Depth(group)] := [];
    fi;
    # Make sure we have a list to put the child groups in
    if not IsBound(ProjectionCache@.(id)[Depth(group)]) then
        ProjectionCache@.(id)[Depth(group)] := [];
    fi;

    # Toggle the position of the group
    pos := Position(AppSelectedProjections@.(id)[Depth(group)], group);
    if pos = fail then
        Add(AppSelectedProjections@.(id)[Depth(group)], group);
        # Calculate the groups that project back onto this one, if we haven't already yet
        if not IsBound(ProjectionCache@.(id)[Depth(group)][SRGroupNumber(group)]) then
            ProjectionCache@.(id)[Depth(group)][SRGroupNumber(group)] := AllSRGroups(
                Degree, degree, Depth, Depth(group) + 1, ParentGroup, group
            );
        fi;
    else
        Remove(AppSelectedProjections@.(id)[Depth(group)], pos);
        # Hide all the children of this group as well
        for i in [Depth(group)+1..Length(AppSelectedProjections@.(id))] do
            # Iterate backwards, to prevent iterator invalidation
            for j in [Length(AppSelectedProjections@.(id)[i]), Length(AppSelectedProjections@.(id)[i])-1..1] do
                Print(i, ",", j, " ", AppSelectedProjections@.(id)[i][j], ", ", group, "\n");
                if IsSRGroupAncestor(AppSelectedProjections@.(id)[i][j], group) then
                    Remove(AppSelectedProjections@.(id)[i], j);
                fi;
            od;
        od;
    fi;

    # Overview graph
    groups := [Depth1Cache@.(id)];
    Append(
        groups,
        List(
            [1..Length(AppSelectedProjections@.(id))],
            n->Union(ProjectionCache@.(id)[n]{List(AppSelectedProjections@.(id)[n], SRGroupNumber)})
        )
    );
    Perform(groups, function(x)SortBy(x, SRGroupNumber);end);
    colours := [];
    for k in [1..Length(groups)-1] do
        colours[k] := [];
        i := 1;
        for nr_i in List(AppSelectedProjections@.(id)[k], SRGroupNumber) do
            colours[k][nr_i] := [];
            for nr_j in List(ProjectionCache@.(id)[k][nr_i], SRGroupNumber) do
                colours[k][nr_i][nr_j] := HSVColour@(i, Length(AppSelectedProjections@.(id)[k]));
            od;
            i := i + 1;
        od;
    od;
    dot := [DotGroupHeirarchy@(groups, colours, id)];

    # Depth 1
    groups := Depth1Cache@.(id);
    fill_colours := [];
    fill_colours{List(AppSelectedProjections@.(id)[1], SRGroupNumber)} := List(
        [1..Length(AppSelectedProjections@.(id)[1])],
        x->HSVColour@(x, Length(AppSelectedProjections@.(id)[1]))
    );
    Add(
        dot,
        DotSubgroupLattice@(groups, [], fill_colours, GetWithDefault(AppSelectedProjections@.(id), 1, []), id)
    );

    # Loop over all the higher depths we want to display, depth is one greater than i
    for i in [1..Length(AppSelectedProjections@.(id))] do
        if AppSelectedProjections@.(id)[i] = [] then
            continue;
        fi;
        groups := Union(
            ProjectionCache@.(id)[i]{List(AppSelectedProjections@.(id)[i], SRGroupNumber)}
        );
        if groups = [] then
            continue;
        fi;

        colours := [];
        colours{List(AppSelectedProjections@.(id)[i], SRGroupNumber)} := List(
            [1..Length(AppSelectedProjections@.(id)[i])],
            x->HSVColour@(x, Length(AppSelectedProjections@.(id)[i]))
        );

        fill_colours := [];
        if i+1 <= Length(AppSelectedProjections@.(id)) then
            fill_colours{List(AppSelectedProjections@.(id)[i+1], SRGroupNumber)} := List(
                [1..Length(AppSelectedProjections@.(id)[i+1])],
                x->HSVColour@(x, Length(AppSelectedProjections@.(id)[i+1]))
            );
        fi;

        Add(
            dot,
            DotSubgroupLattice@(
                groups,
                colours,
                fill_colours,
                GetWithDefault(AppSelectedProjections@.(id), i+1, []), id
            )
        );
    od;

    return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
end;

InstallGlobalFunction(RunApp@,
function(k)
    local id;
    id:=Base64String(Concatenation("graph",String(Random(1,10000))));
    AppSelectedProjections@.(id) := [];
    ProjectionCache@.(id) := [];
    Depth1Cache@.(id) := AllSRGroups(Degree, k, Depth, 1);
    return JupyterDot@(id, "AppCallback@SRGroups");
end);

