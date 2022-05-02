classdef sysResolution < handle
    
    properties (Access = public)
        disp
        reac
        eps
        sig
    end
    
    properties (Access = private)
        coordA
        coordB
        length
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
            u = obj.disp;
            sigma = zeros(n_el,1);
            epsilon = zeros(n_el,1);
            ue=zeros(n_nod*n_i,1);

            for iElem=1:n_el
                obj.computeNodesCoord(iElem);
                obj.computeLength();
                Rot=obj.computeRotationMatrix();
                ndofElem = n_nod*n_i;
                for iDof=1:(ndofElem)
                    I=Td(iElem,iDof);
                    ue(iDof,1)=u(I);
                end
                ue_local=Rot*ue;
                l=obj.length;
                epsilon(iElem,1)=(1/l)*[-1 1]*ue_local;
                E=mat(iElem,1);
                sigma(iElem,1)=E*epsilon(iElem,1);
            end
            obj.eps = epsilon;
            obj.sig = sigma;
        end

        function computeNodesCoord(obj,iElem)
            Tn = obj.data.Tn;
            coord = obj.data.x;
            nodeA = Tn(iElem,1);
            nodeB = Tn(iElem,2);
            obj.coordA.x = coord(nodeA,1);
            obj.coordA.y = coord(nodeA,2);
            obj.coordA.z = coord(nodeA,3);
            obj.coordB.x = coord(nodeB,1);
            obj.coordB.y = coord(nodeB,2);
            obj.coordB.z = coord(nodeB,3);
        end
        
        function l = computeLength(obj)
            xA = obj.coordA.x;
            xB = obj.coordB.x;
            yA = obj.coordA.y;
            yB = obj.coordB.y;
            zA = obj.coordA.z;
            zB = obj.coordB.z;            
            l = sqrt((xB-xA)^2+(yB-yA)^2+(zB-zA)^2);
            obj.length = l;
        end

        function R = computeRotationMatrix(obj)
            xA = obj.coordA.x;
            xB = obj.coordB.x;
            yA = obj.coordA.y;
            yB = obj.coordB.y;
            zA = obj.coordA.z;
            zB = obj.coordB.z;
            l  = obj.length;
            R=1/l*[xB-xA yB-yA zB-zA 0 0 0;
                0 0 0 xB-xA yB-yA zB-zA];
        end

    end
    
end