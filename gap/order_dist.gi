InstallGlobalFunction(PlotOrderDistribution@,
function(degree, depth)
    local r, group, i;
    r := rec();
    for group in AllSRGroups(Degree, degree, Depth, depth) do
        i := Order(group);
        if not IsBound(r.(i)) then
            r.(i) := 0;
        fi;
        r.(i) := r.(i) + 1;
    od;
    return Plot(
        List(Set(List(RecNames(r), Int)),x->Concatenation("Order ", String(x))),
        List(Set(List(RecNames(r), Int)), x->r.(x)),
        rec(type := "bar", title := StringFormatted("Distribution of groups of degree {} and depth {}", degree, depth))
    );
end);
