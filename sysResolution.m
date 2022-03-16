classdef sysResolution < handle
    
    properties (Access = public)
        disp
        reac
        eps
        sig
    end
    
    properties (Access = private)
        KG
        f
        ur
        vr
        vl
        n_nod
        n_i
        n_el
        Td
        x
        Tn
        mat
        Tmat
    end
    
    methods (Access = public)
        
        function obj = sysResolution(cParams)
            obj.init(cParams)
            obj.solveSys(obj.KG, obj.f, obj.ur, obj.vr, obj.vl)
            obj.computeStrainStressBar(obj.n_nod, obj.n_i, obj.n_el, obj.Td, obj.x, obj.Tn, obj.mat, obj.Tmat)
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.KG = cParams.KG;
            obj.f = cParams.f;
            obj.ur = cParams.ur;
            obj.vr = cParams.vr;
            obj.vl = cParams.vl;
            obj.n_nod = cParams.n_nod;
            obj.n_i = cParams.n_i;
            obj.n_el = cParams.n_el;
            obj.Td = cParams.Td;
            obj.x = cParams.x;
            obj.Tn = cParams.Tn;
            obj.mat = cParams.mat;
            obj.Tmat = cParams.Tmat;
        end
        
        function solveSys(obj,KG,f, ur, vr, vl)

            KLL=KG(vl,vl);
            KLR=KG(vl,vr);
            KRL=KG(vr,vl);
            KRR=KG(vr,vr);

            FLext=f(vl,1);
            FRext=f(vr,1);

            ul=KLL\(FLext-KLR*ur);
            R=KRR*ur+KRL*ul-FRext;

            u(vl,1)=ul;
            u(vr,1)=ur;
            
            obj.disp = u;
            obj.reac = R;

        end
        
        function computeStrainStressBar(obj,n_nod,n_i,n_el,Td,x,Tn,mat,Tmat)
            u = obj.disp;
            sigma = zeros(n_el,1);
            epsilon = zeros(n_el,1);
            ue=zeros(n_nod*n_i,1);

            for e=1:n_el
                x1=x(Tn(e,1),1);
                y1=x(Tn(e,1),2);
                z1=x(Tn(e,1),3);
                x2=x(Tn(e,2),1);
                y2=x(Tn(e,2),2);
                z2=x(Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                Rot=1/l*[x2-x1 y2-y1 z2-z1 0 0 0;
                    0 0 0 x2-x1 y2-y1 z2-z1];

                for i=1:(n_nod*n_i)
                I=Td(e,i);
                ue(i,1)=u(I);
                end
                ue_local=Rot*ue;
                epsilon(e,1)=(1/l)*[-1 1]*ue_local;
                E=mat(Tmat(e),1);
                sigma(e,1)=E*epsilon(e,1);
            end
            obj.eps = epsilon;
            obj.sig = sigma;
        end
    end
    
end