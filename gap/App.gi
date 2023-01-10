# dot is the initial dot code to display, id is the unique id of the instance of the app
# callback_name is a string containing the name of a function that takes in the name of an sr group and the id
#   and returns a list of dot code
# Returns the javascript code to be injected into jupyter
_JupyterDot@ := function(id, callback_name)
    local code;
    code := Concatenation("\
<script src=\"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/graphviz.umd.js\"></script>\n\
<script src=\"https://cdn.jsdelivr.net/npm/svg-pan-zoom-container@0.6.1\"></script>\n\
<div id='",id,"'></div>\n\
<script type=\"module\">\n\
    import { Graphviz } from \"https://cdn.jsdelivr.net/npm/@hpcc-js/wasm/dist/index.js\";\n\
    if (Graphviz) {\n\
        const graphviz = await Graphviz.load();\n\
        \n\
        function register_callbacks(){\n\
            document.querySelectorAll('.",id," >[id*=\"node\"]').forEach(\n\
                (x) => {\n\
                    x.onclick = function(){\n\
                        const name = x.firstElementChild.textContent.split(\"\\n\")[0];\n\
                        IPython.notebook.kernel.execute(`",callback_name,"(\"${name}\", \"",id,"\");`, callbacks);\n\
                    };\n\
                }\n\
            );\n\
            document.querySelectorAll('.collapsible').forEach(\n\
                (x) => {\n\
                    x.onclick = function(){\n\
                        x.classList.toggle(\"active\");\n\
                        let content = x.nextElementSibling;\n\
                        if (content.style.display === \"block\") {\n\
                          content.style.display = \"none\";\n\
                        } else {\n\
                          content.style.display = \"block\";\n\
                        }\n\
                    };\n\
                }\n\
            );\n\
        }\n\
        \n\
        var callbacks = {\n\
            iopub: {\n\
                output: (data) => {\n\
                    if(\"text\" in data.content) {\n\
                        console.log(data.content.text);\n\
                    } else {\n\
                        let container = document.getElementById(\"",id,"\");\n\
                        let i = 0;\n\
                        while(i < container.children.length || i < data.content.data.length) {\n\
                            if (i < container.children.length && i < data.content.data.length) {\n\
                                let dot = data.content.data[i];\n\
                                container.children[i].children[1].innerHTML = graphviz.layout(dot[1], \"svg\", dot[0]);\n\
                            } else if (i < container.children.length && i >= data.content.data.length){\n\
                                container.children[i].children[1].innerHTML = \"\";\n\
                            } else if (i >= container.children.length && i < data.content.data.length){\n\
                                let dot = data.content.data[i];\n\
                                container.innerHTML += \"<div>\" + \n\
                                \"<button type='button' class='collapsible' style='width:100%;'>toggle</button>\" + \n\
                                \"<div data-pan-on-drag='button: right;' \" + \n\
                                \"data-zoom-on-wheel='max-scale: 10; min-scale: 1;' \" + \n\
                                \"style='border-style:solid; height: 500px; display:block' >\" + \n\
                                graphviz.layout(dot[1], \"svg\", dot[0]) + \"</div><br></div>\";\n\
                            }\n\
                            i = i + 1;\n\
                        }\n\
                        register_callbacks();\n\
                    }\n\
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
# _AppSelectedProjections@.(id)[depth] := list of selected groups
_AppSelectedProjections@ := rec();

# A map from the unique ids, to a list corresponding to degrees each containing a list corresponding to depth each
# containing a list containing what groups are projected to the group of the index
# ProjectionCache@.(id)[n][nr] := list of groups that project to SRGroup(k, n, nr)
_ProjectionCache@ := rec();

# Contains the groups of depth 1
_Depth1Cache@ := rec();

# 1 <= n <= total
# Returns a string for the HSV with hue being a unique value for each n
_HSVColour@ := function(n, total)
    return Concatenation(String(Float((total-n+1)/total)), " 1.0 1.0");
end;

# This is the callback used for the app, see _JupyterDot@. The id is the unique id of the instance of this app
# It takes in a group_name that will be toggled between selected and not, then constructs dot code based on what is
# selected and returns a list where each element is the dot code for the depth
AppCallback@ := function(group_name, id)
    local degree, groups, group, dot, pos, i, j, k, nr_i, nr_j, colours, fill_colours;
    
    # We were called with an invalid id, perhaps leftovers from a previous session
    if not IsBound(_Depth1Cache@.(id)) then
        return Objectify( JupyterRenderableType, rec(source := "gap", data := [], metadata:=rec()));
    fi;

    if group_name = "" then
        # This is the setup call
        dot := [
            ["twopi", _DotGroupHeirarchy@([_Depth1Cache@.(id)], [], id)],
            ["dot", _DotSubgroupLattice@(_Depth1Cache@.(id), [], [], [], id)]
        ];
        return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
    fi;


    group := EvalString(group_name);
    degree := Degree(group);

    # Make sure we have a list to put the group in
    if not IsBound(_AppSelectedProjections@.(id)[Depth(group)]) then
        _AppSelectedProjections@.(id)[Depth(group)] := [];
    fi;
    # Make sure we have a list to put the child groups in
    if not IsBound(_ProjectionCache@.(id)[Depth(group)]) then
        _ProjectionCache@.(id)[Depth(group)] := [];
    fi;

    # Toggle the position of the group
    pos := Position(_AppSelectedProjections@.(id)[Depth(group)], group);
    if pos = fail then
        Add(_AppSelectedProjections@.(id)[Depth(group)], group);
        # Calculate the groups that project back onto this one, if we haven't already yet
        if not IsBound(_ProjectionCache@.(id)[Depth(group)][SRGroupNumber(group)]) then
            _ProjectionCache@.(id)[Depth(group)][SRGroupNumber(group)] := AllSRGroups(
                Degree, degree, Depth, Depth(group) + 1, ParentGroup, group
            );
        fi;
    else
        Remove(_AppSelectedProjections@.(id)[Depth(group)], pos);
        # Hide all the children of this group as well
        for i in [Depth(group)+1..Length(_AppSelectedProjections@.(id))] do
            # Iterate backwards, to prevent iterator invalidation
            for j in [Length(_AppSelectedProjections@.(id)[i]), Length(_AppSelectedProjections@.(id)[i])-1..1] do
                if IsSRGroupAncestor(_AppSelectedProjections@.(id)[i][j], group) then
                    Remove(_AppSelectedProjections@.(id)[i], j);
                fi;
            od;
        od;
    fi;

    # Overview graph
    groups := [_Depth1Cache@.(id)];
    Append(
        groups,
        List(
            [1..Length(_AppSelectedProjections@.(id))],
            n->Union(_ProjectionCache@.(id)[n]{List(_AppSelectedProjections@.(id)[n], SRGroupNumber)})
        )
    );
    Perform(groups, function(x)SortBy(x, SRGroupNumber);end);
    colours := [];
    for k in [1..Length(groups)-1] do
        colours[k] := [];
        i := 1;
        for nr_i in List(_AppSelectedProjections@.(id)[k], SRGroupNumber) do
            colours[k][nr_i] := [];
            for nr_j in List(_ProjectionCache@.(id)[k][nr_i], SRGroupNumber) do
                colours[k][nr_i][nr_j] := _HSVColour@(i, Length(_AppSelectedProjections@.(id)[k]));
            od;
            i := i + 1;
        od;
    od;
    dot := [["twopi", _DotGroupHeirarchy@(groups, colours, id)]];

    # Depth 1
    groups := _Depth1Cache@.(id);
    fill_colours := [];
    fill_colours{List(_AppSelectedProjections@.(id)[1], SRGroupNumber)} := List(
        [1..Length(_AppSelectedProjections@.(id)[1])],
        x->_HSVColour@(x, Length(_AppSelectedProjections@.(id)[1]))
    );
    Add(
        dot,
        ["dot", _DotSubgroupLattice@(groups, [], fill_colours, GetWithDefault(_AppSelectedProjections@.(id), 1, []), id)]
    );

    # Loop over all the higher depths we want to display, depth is one greater than i
    for i in [1..Length(_AppSelectedProjections@.(id))] do
        if _AppSelectedProjections@.(id)[i] = [] then
            continue;
        fi;
        groups := Union(
            _ProjectionCache@.(id)[i]{List(_AppSelectedProjections@.(id)[i], SRGroupNumber)}
        );
        if groups = [] then
            continue;
        fi;

        colours := [];
        colours{List(_AppSelectedProjections@.(id)[i], SRGroupNumber)} := List(
            [1..Length(_AppSelectedProjections@.(id)[i])],
            x->_HSVColour@(x, Length(_AppSelectedProjections@.(id)[i]))
        );

        fill_colours := [];
        if i+1 <= Length(_AppSelectedProjections@.(id)) then
            fill_colours{List(_AppSelectedProjections@.(id)[i+1], SRGroupNumber)} := List(
                [1..Length(_AppSelectedProjections@.(id)[i+1])],
                x->_HSVColour@(x, Length(_AppSelectedProjections@.(id)[i+1]))
            );
        fi;

        Add(
            dot,
            ["dot", _DotSubgroupLattice@(
                groups,
                colours,
                fill_colours,
                GetWithDefault(_AppSelectedProjections@.(id), i+1, []),
                id
            )]
        );
    od;

    return Objectify( JupyterRenderableType, rec(source := "gap", data := dot, metadata:=rec()));
end;

InstallGlobalFunction(RunApp@,
function(k)
    local id;
    # Remove '=', as it causes errors
    id := ReplacedString(Base64String(String(Random(1,10000))), "=", "");
    _AppSelectedProjections@.(id) := [];
    _ProjectionCache@.(id) := [];
    _Depth1Cache@.(id) := AllSRGroups(Degree, k, Depth, 1);
    return _JupyterDot@(id, "AppCallback@SRGroups");
end);

