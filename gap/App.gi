SRGroupsAppSelectedProjections := [];

SRGroupsAppCallback := function(group_name)
    local groups, group, dot, pos;
    Print(group_name);
    group := EvalString(group_name);
    pos := Position(SRGroupsAppSelectedProjections, group);
    if pos = fail then
        Add(SRGroupsAppSelectedProjections, group);
    else
        Remove(SRGroupsAppSelectedProjections, pos);
    fi;
    groups := AllSRGroups(Degree, Degree(group), Depth, List(SRGroupsAppSelectedProjections, x->Depth(x)+1), ParentGroup, SRGroupsAppSelectedProjections);
    Append(groups, AllSRGroups(Degree, Degree(group), Depth, 1));
    dot := DotSubgroupLattice(groups);
    return Objectify( JupyterRenderableType, rec(source := "gap", data := rec( ("text/plain") := dot ), metadata:=rec()));
end;

InstallGlobalFunction(SRGroupsRunApp,
function(k)
    local groups;
    SRGroupsAppSelectedProjections := [];

    groups := AllSRGroups(Degree, k, Depth, 1);

    return JupyterDot(DotSubgroupLattice(groups), "SRGroupsAppCallback");
end);

##################################################################################################################

InstallGlobalFunction(JupyterDot,
function(dot, callback_name)
    local id, code;
    id:=Base64String(Concatenation("graph",String(Random(1,10000))));
    # TODO(cameron) use a local copy of the library
    # output: (data) => document.getElementById(\"",id,"\").parentElement.innerHTML = data.content.data[\"text/plain\"]\
    code := Concatenation("<div id='",id,"'></div>\n\
<script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\n\
<script type=\"module\">\n\
    const dot = `",dot,"`;\n\
    import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\n\
    if (Graphviz) {\n\
        const graphviz = await Graphviz.load();\n\
        const svg = graphviz.layout(dot, \"svg\", \"dot\");\n\
        document.getElementById(\"",id,"\").innerHTML = svg;\n\
        var callbacks = {\n\
            iopub: {\n\
                output: (data) => {\n\
                    console.log(data.content);\n\
                    document.getElementById(\"",id,"\").innerHTML = graphviz.layout(data.content.data[\"text/plain\"], \"svg\", \"dot\");\n\
                    document.querySelectorAll('[id*=\"node\"]').forEach(\n\
                        (x) => {\n\
                            x.addEventListener(\"click\", function(){\n\
                                const name = x.firstElementChild.textContent.split(\" \")[0];\n\
                                console.log(name);\n\
                                IPython.notebook.kernel.execute(`",callback_name,"(\"${name}\");`, callbacks);\n\
                            });\n\
                        }\n\
                    );\n\
                }\n\
            }\n\
        };\n\
        document.querySelectorAll('[id*=\"node\"]').forEach(\n\
            (x) => {\n\
                x.addEventListener(\"click\", function(){\n\
                    const name = x.firstElementChild.textContent.split(\" \")[0];\n\
                    console.log(name);\n\
                    IPython.notebook.kernel.execute(`",callback_name,"(\"${name}\");`, callbacks);\n\
                });\n\
            }\n\
        );\n\
    }\n\
</script>");
    return Objectify( JupyterRenderableType, rec(  source := "gap", data := rec( ("text/html") := code ), metadata:=rec() ));
end);

