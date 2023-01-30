
# Originally by Alexander Hulpke.

SelfReplicatingDescent := function(father)
    local n,w,proj,k,cs,i,ser,u,emb,sub,pcgs,nsub,a,mo,subm,p,b,j,hom,com,
        maxb,co1,no,typ,sym,fn,start,blo,bs,bl,lw,loc,chains,reps,sizi,siz,w1,partmodul,
        want, depth, degree;

    n := NrMovedPoints(father);
    sym := SymmetricGroup(n);
    depth := Depth(father);
    degree := Degree(father);
    p := degree;

    if depth = 1 then
        typ := father;
    else
        b := Filtered(AllBlocks(father), x->Length(x) = n/p);
        if Length(b) <> 1 then
            if not [1..n/p] in b then
                Error("blocks weird?");
            fi;
            b := [1..n/p];
        else
            b := b[1];
        fi;
        typ:=Action(father,Set(Orbit(father,b,OnSets)),OnSets);
    fi;

    fn := Normalizer(sym, father);
    w := WreathProduct(typ, fn);
    w1 := Stabilizer(w, [1..n], OnSets);
    w1 := Stabilizer(w1, [n+1..degree*n], OnTuples);
    emb := List([1..n+1], x->Embedding(w, x));
    proj := Projection(w);
    k:=Kernel(proj);
    cs:=ChiefSeries(typ);
    ser:=[TrivialSubgroup(w)];
    for i in cs{[Length(cs)-1,Length(cs)-2..2]} do;
        u:=List([1..n],x->List(GeneratorsOfGroup(i),
            y->ImagesRepresentative(emb[x],y)));
        u:=Concatenation(u);
        u:=Subgroup(w,u);
        Add(ser,u);
    od;
    Add(ser,k);
    ser:=Reversed(ser);

    # determine the required sizes for replication
    # Note that we can simply intersect with the exist
    siz:=List(ser,x->Size(Intersection(x,father)));

    start:=ClosureGroup(k,Image(emb[n+1],father));
    sub:=[start];
    for i in [1..Length(ser)-1] do
        Print("Step :",i," ",Length(sub)," subgroups\n");
        pcgs:=ModuloPcgs(ser[i],ser[i+1]);
        p:=RelativeOrders(pcgs)[1];
        nsub:=[];
        partmodul:=Intersection(ser[i],w1);
        partmodul:=List(GeneratorsOfGroup(partmodul),
            x->ExponentsOfPcElement(pcgs,x));
        partmodul:=Filtered(TriangulizedMat(partmodul*One(GF(p))),x->not
        IsZero(x));
        want:=LogInt(siz[i]/siz[i+1],p);
        for a in sub do
            mo:=GModuleByMats(LinearActionLayer(a,pcgs),GF(p));
            subm:=MTX.BasesSubmodules(mo);
            for j in subm do
                # TODO: Select right projections -- onto each component
                # actually first one is sufficient b/c transitive action
                u:=ser[i+1];
                for b in j do 
                    u:=ClosureGroup(u,PcElementByExponents(pcgs,b));
                od;
                if not IsNormal(a,u) then Error("not normal?");fi;
                    no:=Normalizer(w,u);
                    hom:=NaturalHomomorphismByNormalSubgroup(no,u);
                    co1:=ComplementClassesRepresentatives(Image(hom,a),Image(hom,ser[i]));

                    if Length(co1)>1 and Size(no)>Size(a) then
                        com:=SubgroupsOrbitsAndNormalizers(Image(hom,no),co1,false);
                        co1:=List(com,x->x.representative);
                    fi;

                com:=[];
                for b in co1 do
                    u:=PreImage(hom,b);
                    Add(com,u);
                od;

                Append(nsub,com);
            od;
        od;
        sub:=nsub;
    od;

    sub:=Filtered(nsub,x->IsTransitive(x,[1..n*degree]));
    Print("Now constructed ",Length(nsub)," to ",Length(sub)," transitive gps\n");

    # block conjugators
    bs:=[];
    for i in [1..LogInt(n,p)-1] do
        Add(bs,[1..p^i]);
    od;
    # orbit/representatives
    chains:=[bs];
    reps:=[One(w)];
  
    loc:=PreImage(Projection(w),Stabilizer(fn,1));

    i:=1;
    while i<=Length(chains) do
        for j in SmallGeneratingSet(loc) do
            bl:=OnSetsSets(chains[i],ImagesRepresentative(Projection(w),j));
            if not bl in chains then
                Add(chains,bl);
                Add(reps,reps[i]*j);
            fi;
        od;
        i:=i+1;
    od;
    Print(chains,"\n");

    lw:=Stabilizer(w,[1..8],OnSets);
    bs:=Set(Orbit(w,[1..p],OnSets));
    maxb:=[1..n];
    nsub:=[];
    for i in sub do
        for bl in [1..Length(chains)] do
            loc:=i^Inverse(reps[bl]);

            u:=Action(Stabilizer(loc,[1..n],OnSets),[1..n]);
            if Size(u)=Size(father) then 
                if u=father then
                    Add(nsub,loc);
                elif n<=30 then
                    if TransitiveIdentification(u)=TransitiveIdentification(father) then
                        b:=RepresentativeAction(lw,u,father);
                        if b<>fail then
                            loc:=loc^b;
                            if Action(loc,bs,OnSets)<>father then Error("err1");fi;
                            if Action(Stabilizer(loc,[1..n],OnSets),[1..n])<>father then
                                Error("err2");
                            fi;
                            Add(nsub,loc);
                        else
                            Print("idnoteq\n");
                        fi;
                    fi;
                else
                    Error("deg>30");
                fi;
            fi;
        od;
    od;

    sub:=DuplicateFreeList(nsub);

    Print("Found ",Length(sub),"\n");

    # eliminate duplicates
    b:=SymmetricGroup(p);
    w:=b;
    while NrMovedPoints(w)<=n do
        w:=WreathProduct(w,b);
    od;

    if IsSolvableGroup(w) then
        emb:=IsomorphismSpecialPcGroup(w);
    else
        emb:=fail;
    fi;

    nsub:=[];

    b:=function(gp)
        local id;
        id:=[Size(gp)];
        if Size(gp)<2000 and not Size(gp) in [512,1024] then
            id:=ShallowCopy(IdGroup(gp));
        fi;
        if NrMovedPoints(gp)<32 then
            Add(id,TransitiveIdentification(gp));
        fi;
        return id;
    end;

    a:=List(sub,b);
    for i in Set(a) do
        com:=Filtered([1..Length(a)],x->a[x]=i);
        com:=sub{com};
        if emb=fail then
            u:=SubgroupsOrbitsAndNormalizers(w,com,false);
        else
            u:=SubgroupsOrbitsAndNormalizers(Image(emb,w),List(com,x->Image(emb,x)),false);
            u:=List(u,x->rec(representative:=PreImage(emb,x.representative)));
        fi;
        Append(nsub,List(u,x->x.representative));
    od;
    Print("=> ",Length(nsub),"\n");

  return nsub;
end;
