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
    local perms, perm;
    perms := [];

    for perm in AutT(2,depth) do
        if Product(l, phi_depth->projected_sign(perm, depth, phi_depth)) = 1 then
            Add(perms, perm);
        fi;
    od;

    return Group(perms);
end);

