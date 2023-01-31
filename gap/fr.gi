InstallGlobalFunction(FindProjectedFR@, function(fr_group, depth)
    local perm_group, degree, all_sr, position;
    perm_group := PermGroup(fr_group, depth);
    degree := Size(Alphabet(fr_group));

    all_sr := AllSRGroups(Degree, degree, Depth, depth);
    # TODO(cameron) up to conjugacy?
    position := Position(all_sr, perm_group);

    if position = fail then
        return fail;
    fi;
    return all_sr[position];
end);
