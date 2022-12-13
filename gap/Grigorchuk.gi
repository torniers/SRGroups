InstallGlobalFunction("_a@", function(subtree)
    local l;
    Print("a ", subtree, "\n");
    l := Length(subtree);
    if l = 0 then
        return ();
    fi;
    if l = 2 then
        return (subtree[1], subtree[2]);
    fi;
    return PermList(Flat([[1..subtree[1]-1], subtree{[l/2+1..l]}, subtree{[1..l/2]}]));
end);

InstallGlobalFunction(_d@, function(subtree)
    local l;
    l := Length(subtree);
    if l <= 2 then
        return ();
    fi;
    return () * _b@(subtree{[l/2+1..l]});
end);

InstallGlobalFunction(_c@, function(subtree)
    local l;
    l := Length(subtree);
    if l <= 2 then
        return ();
    fi;
    return _a@(subtree{[1..l/2]}) * _d@(subtree{[l/2+1..l]});
end);

InstallGlobalFunction(_b@, function(subtree)
    local l;
    l := Length(subtree);
    if l <= 2 then
        return ();
    fi;
    return _a@(subtree{[1..l/2]}) * _c@(subtree{[l/2+1..l]});
end);

InstallGlobalFunction("GrigorchukProjectedGroup", 
function(depth)
    local a, b, c, d, g, number_of_leaves;
    number_of_leaves := 2^depth;
    a := _a@([1..number_of_leaves]);
    b := _b@([1..number_of_leaves]);
    c := _c@([1..number_of_leaves]);
    d := _d@([1..number_of_leaves]);
    g := Group(a, b, c, d);

	SetName(g, Concatenation("GrigorchukProjectedGroup(", String(depth), ")"));
    SetFilterObj(g, IsRegularRootedTreeGroup);
    Setter(RegularRootedTreeGroupDegree)(g, 2);
    Setter(RegularRootedTreeGroupDepth)(g, depth);
    SetIsSelfReplicating(g, true);

    return g;
end);

