function [ur,vr,vl] = fixDOFS(n_dof,n_i,fixNod)
[n,m]=size(fixNod);
ur=zeros(n,1);
vr=zeros(n,1);
vl=zeros(n_dof-n,1);
for i=1:n
    I=nod2dof(fixNod(i,1),fixNod(i,2),n_i);
    ur(i)=fixNod(i,3);
    vr(i)=I;
end

    p=1;
    for j=1:n_dof
        s=0;
        for k=1:n
            if vr(k)==j
                s=1;
            end
        end
        if s==0
            vl(p)=j;
            p=p+1;
        end
    end

end

