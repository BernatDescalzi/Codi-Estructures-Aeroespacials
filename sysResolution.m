classdef sysResolution < handle
    
    properties (Access = public)
        disp
        reac
        eps
        sig
    end
    
    properties (Access = private)
        dim
        data
        KG
        f
        materialMatrix
        dofComputer
    end
    
    methods (Access = public)
        
        function obj = sysResolution(cParams)
            obj.init(cParams)
            obj.solveSys(obj.KG, obj.f)
            obj.computeStrainStressBar()
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
            obj.KG = cParams.KG;
            obj.f = cParams.f;
            obj.dofComputer = cParams.dofComputer;
            obj.materialMatrix = cParams.material.materialMatrix;

        end
        
        function solveSys(obj,KG,f)
            ur = obj.dofComputer.ur;
            vr = obj.dofComputer.vr;
            vl = obj.dofComputer.vl;
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
        
        function computeStrainStressBar(obj)
            mat = obj.materialMatrix;
            Td = obj.dofComputer.Td;
            n_nod = obj.dim.n_nod;
            n_i = obj.dim.n_i;
            n_el = obj.dim.n_el;
            Tn = obj.data.Tn;
            x = obj.data.x;
            u = obj.disp;
            sigma = zeros(n_el,1);
            epsilon = zeros(n_el,1);
            ue=zeros(n_nod*n_i,1);

            for iElem=1:n_el
                x1=x(Tn(iElem,1),1);
                y1=x(Tn(iElem,1),2);
                z1=x(Tn(iElem,1),3);
                x2=x(Tn(iElem,2),1);
                y2=x(Tn(iElem,2),2);
                z2=x(Tn(iElem,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                Rot=1/l*[x2-x1 y2-y1 z2-z1 0 0 0;
                    0 0 0 x2-x1 y2-y1 z2-z1];

                for i=1:(n_nod*n_i)
                I=Td(iElem,i);
                ue(i,1)=u(I);
                end
                ue_local=Rot*ue;
                epsilon(iElem,1)=(1/l)*[-1 1]*ue_local;
                E=mat(iElem,1);
                sigma(iElem,1)=E*epsilon(iElem,1);
            end
            obj.eps = epsilon;
            obj.sig = sigma;
        end
    end
    
end