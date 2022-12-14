projected_sign := function(perm, depth, phi_depth)
    local r, i, d;
    if phi_depth = depth then
        return SignPerm(perm);
    fi;

    d := depth - phi_depth;
    if d <= 0 then
        Error("depth of phi cannot be greater than depth");
    fi;
    
    r := 1;
    for i in [1..2^(phi_depth-1)] do
        # Checks if the rightmost of the left subtree is mapped greater than the rightmost of the right subtree
        if (2^d*(2*i-1))^perm > (2^d*2*i)^perm then
            r := r * -1;
        fi;
    od;
    return r;
end;

InstallGlobalFunction("KernelGroupOfSign@",
function(depth, l)
    local perms, perm, group;
    perms := [];

    for perm in AutT(2,depth) do
        if Product(l, phi_depth->projected_sign(perm, depth, phi_depth)) = 1 then
            Add(perms, perm);
        fi;
    od;

    group := Group(perms);
    SetName(group, Concatenation("KernelGroupOfSign(", String(l), ")"));
    SetFilterObj(group, IsRegularRootedTreeGroup);
    Setter(RegularRootedTreeGroupDegree)(group, 2);
    Setter(RegularRootedTreeGroupDepth)(group, depth);
    SetIsSelfReplicating(group, true);

    return group;
end);

InstallGlobalFunction("SignRegularRootedTreeGroup@",
function(group, l)
    local depth;
    depth := Depth(group);
    if ForAll(GeneratorsOfGroup(group), i->Product(l, phi_depth->projected_sign(i, depth, phi_depth)) = 1) then
        return 1;
    else
        return -1;
    fi;
end);

InstallGlobalFunction("ClassifyRegularRootedTreeGroupSign@",
function(group)
    local depth, to_check, x;
    depth := Depth(group);
    to_check := List(Combinations([1..depth-1]), x->Union(x,[depth]));
    for x in to_check do
        if SignRegularRootedTreeGroup@(group, x) = 1 then
            return x;
        fi;
    od;
    return fail;
end);
