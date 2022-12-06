# A map from the unique ids, to a list corresponding to degrees each containing a list of the selected projections of
# that degree.
SRGroupsAppSelectedProjections := rec();

# dot is the initial dot code to display, id is the unique id of the instance of the app
# callback_name is a string containing the name of a function that takes in the name of an sr group and the id
#   and returns a list of dot code
# Returns the javascript code to be injected into jupyter
JupyterDot@ := function(dot, id, callback_name)
    local code;
    # TODO(cameron) use a local copy of the library
    code := Concatenation("<div id='",id,"'></div>\n\
<script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\n\
<script src=\"https://cdn.jsdelivr.net/npm/svg-pan-zoom-container@0.6.1\"></script>\n\
<script type=\"module\">\n\
    const dot = `",dot,"`;\n\
    import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\n\
    if (Graphviz) {\n\
        const graphviz = await Graphviz.load();\n\
        document.getElementById(\"",id,"\").innerHTML = \"<div \
            data-pan-on-drag='modifier: Shift;' \
            data-zoom-on-wheel='max-scale: 10; min-scale: 1;' \
            style='border-style:solid; height: 500px;' >\"\
            + graphviz.layout(dot, \"svg\", \"dot\") + \"</div>\";\n\
        \n\
        function register_callbacks(){\n\
            document.querySelectorAll('.",id," >[id*=\"node\"]').forEach(\n\
                (x) => {\n\
                    x.addEventListener(\"click\", function(){\n\
                        const name = x.firstElementChild.textContent.split(\" \")[0];\n\
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
                        document.getElementById(\"",id,"\").innerHTML += \"<div \
                            data-pan-on-drag='modifier: Shift;' \
                            data-zoom-on-wheel='max-scale: 10; min-scale: 1;' \
                            style='border-style:solid; height: 500px;' >\" + \n\
                            graphviz.layout(dot, \"svg\", \"dot\") + \"</div>\";\n\
                        document.getElementById(\"",id,"\").innerHTML += \"<br>\";\n\
                    });\n\
                    register_callbacks();\n\
                }\n\
            }\n\
        };\n\
        register_callbacks();\n\
    }\n\
</script>");
    return Objectify(JupyterRenderableType, rec(source := "gap", data := rec(("text/html") := code), metadata:=rec()));
end;

# This is the callback used for the app, see JupyterDot@. The id is the unique id of the instance of this app
# It takes in a group_name that will be toggled between selected and not, then constructs dot code based on what is
# selected and returns a list where each element is the dot code for the depth
SRGroupsAppCallback := function(group_name, id)
    local groups, group, dot, pos, i, colours, fill_colours;
    group := EvalString(group_name);

    # Make sure we have a list to put the group in
    if not IsBound(SRGroupsAppSelectedProjections.id[Depth(group)]) then
        SRGroupsAppSelectedProjections.id[Depth(group)] := [];
    fi;

    # Toggle the position of the group
    pos := Position(SRGroupsAppSelectedProjections.id[Depth(group)], group);
    if pos = fail then
        Add(SRGroupsAppSelectedProjections.id[Depth(group)], group);
    else
        Remove(SRGroupsAppSelectedProjections.id[Depth(group)], pos);
    fi;

    # Depth 1
    groups := AllSRGroups(Degree, Degree(group), Depth, 1);
    fill_colours := [];
    fill_colours{List(SRGroupsAppSelectedProjections.id[1], x->SRGroupNumber(x))} := List(
        [1..Length(SRGroupsAppSelectedProjections.id[1])],
        x->Concatenation(String(Float(x/Length(SRGroupsAppSelectedProjections.id[1]))), " 1.0 1.0")
    );
    dot := [DotSubgroupLattice@(groups, [], fill_colours, GetWithDefault(SRGroupsAppSelectedProjections.id, 1, []), id)];

    # Loop over all the higher depths we want to display, depth is one greater than i
    for i in [1..Length(SRGroupsAppSelectedProjections.id)] do
        groups := AllSRGroups(Degree, Degree(group), Depth, i+1, ParentGroup, SRGroupsAppSelectedProjections.id[i]);

        colours := [];
        colours{List(SRGroupsAppSelectedProjections.id[i], x->SRGroupNumber(x))} := List(
            [1..Length(SRGroupsAppSelectedProjections.id[i])],
            x->Concatenation(String(Float(x/Length(SRGroupsAppSelectedProjections.id[i]))), " 1.0 1.0")
        );

        fill_colours := [];
        if i+1 <= Length(SRGroupsAppSelectedProjections.id) then
            fill_colours{List(SRGroupsAppSelectedProjections.id[i+1], x->SRGroupNumber(x))} := List(
                [1..Length(SRGroupsAppSelectedProjections.id[i+1])],
                x->Concatenation(String(Float(x/Length(SRGroupsAppSelectedProjections.id[i+1]))), " 1.0 1.0")
            );
        fi;

        Add(
            dot,
            DotSubgroupLattice@(
                groups,
                colours,
                fill_colours,
                GetWithDefault(SRGroupsAppSelectedProjections.id, i+1, []), id
            )
        );
    od;

    return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
end;

InstallGlobalFunction(SRGroupsRunApp,
function(k)
    local id;
    id:=Base64String(Concatenation("graph",String(Random(1,10000))));
    SRGroupsAppSelectedProjections.id := [];
    return JupyterDot@(DotSubgroupLattice@(AllSRGroups(Degree, k, Depth, 1), [], [], [], id), id, "SRGroupsAppCallback");
end);

