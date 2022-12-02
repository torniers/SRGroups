SRGroupsAppSelectedProjections := [];

SRGroupsAppCallback := function(group_name)
    local groups, group, dot, pos, i, colours;
    group := EvalString(group_name);

    # Make sure we have a list to put the group in
    if not IsBound(SRGroupsAppSelectedProjections[Depth(group)]) then
        SRGroupsAppSelectedProjections[Depth(group)] := [];
    fi;

    # Toggle the position of the group
    pos := Position(SRGroupsAppSelectedProjections[Depth(group)], group);
    if pos = fail then
        Add(SRGroupsAppSelectedProjections[Depth(group)], group);
    else
        Remove(SRGroupsAppSelectedProjections[Depth(group)], pos);
    fi;

    # Depth 1
    groups := AllSRGroups(Degree, Degree(group), Depth, 1);
    dot := [_DotSubgroupLattice(groups, [], GetWithDefault(SRGroupsAppSelectedProjections, 1, []))];

    # Loop over all the higher depths we want to display
    for i in [1..Length(SRGroupsAppSelectedProjections)] do
        groups := AllSRGroups(Degree, Degree(group), Depth, i+1, ParentGroup, SRGroupsAppSelectedProjections[i]);
        colours := [];
        colours{List(SRGroupsAppSelectedProjections[i], x->SRGroupNumber(x))} := List([1..Length(SRGroupsAppSelectedProjections[i])], x->Concatenation(String(Float(x/Length(SRGroupsAppSelectedProjections[i]))), " 1.0 1.0"));
        Add(dot, _DotSubgroupLattice(groups, colours, GetWithDefault(SRGroupsAppSelectedProjections, i+1, [])));
    od;

    return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
end;

InstallGlobalFunction(SRGroupsRunApp,
function(k)
    SRGroupsAppSelectedProjections := [];
    return JupyterDot(DotSubgroupLattice(k, 1), "SRGroupsAppCallback");
end);

##################################################################################################################

InstallGlobalFunction(JupyterDot,
function(dot, callback_name)
    local id, code;
    id:=Base64String(Concatenation("graph",String(Random(1,10000))));
    # TODO(cameron) use a local copy of the library
    code := Concatenation("<div id='",id,"'></div>\n\
<script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\n\
<script type=\"module\">\n\
    const dot = `",dot,"`;\n\
    import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\n\
    if (Graphviz) {\n\
        const graphviz = await Graphviz.load();\n\
        const svg = graphviz.layout(dot, \"svg\", \"dot\");\n\
        document.getElementById(\"",id,"\").innerHTML = svg;\n\
        function register_callbacks(){\n\
            document.querySelectorAll('[id*=\"node\"]').forEach(\n\
                (x) => {\n\
                    x.addEventListener(\"click\", function(){\n\
                        const name = x.firstElementChild.textContent.split(\" \")[0];\n\
                        IPython.notebook.kernel.execute(`",callback_name,"(\"${name}\");`, callbacks);\n\
                    });\n\
                }\n\
            );\n\
        }\n\
        var callbacks = {\n\
            iopub: {\n\
                output: (data) => {\n\
                    console.log(data.content);\n\
                    document.getElementById(\"",id,"\").innerHTML = \"\";\n\
                    data.content.data.forEach((dot)=>{\n\
                        document.getElementById(\"",id,"\").innerHTML += graphviz.layout(dot, \"svg\", \"dot\");\n\
                        document.getElementById(\"",id,"\").innerHTML += \"<br>\";\n\
                    });\n\
                    register_callbacks();\n\
                }\n\
            }\n\
        };\n\
        register_callbacks();\n\
    }\n\
</script>");
    return Objectify( JupyterRenderableType, rec(  source := "gap", data := rec( ("text/html") := code ), metadata:=rec() ));
end);

