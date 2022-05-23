classdef SysResolution < handle
    
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
        stiffnessMatrix
        forceVector
        materialMatrix
        dofComputer
    end
    
    methods (Access = public)
        
        function obj = SysResolution(cParams)
            obj.init(cParams)
            obj.solveSys()
            obj.computeStrainStressBar()
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
            obj.stiffnessMatrix = cParams.KG;
            obj.forceVector = cParams.f;
            obj.dofComputer = cParams.dofComputer;
            obj.materialMatrix = cParams.material.materialMatrix;

        end
        
        function solveSys(obj)
            ul = obj.computeFreeDisplacements();
            R = obj.computeReactions(ul);
            u = obj.computeDisplacementsVector(ul);

            obj.disp = u;
            obj.reac = R;
        end
        
        function computeStrainStressBar(obj)
            n_el = obj.dim.n_el;
            
            for iElem=1:n_el
                obj.computeNodesCoord(iElem);
                obj.computeLength();
                ue_local = obj.computeLocalDisplacements(iElem);
                obj.computeStrains(iElem,ue_local);
                obj.computeStresses(iElem);
            end
        end
        
        function ul = computeFreeDisplacements(obj)
            ur = obj.dofComputer.ur;
            vr = obj.dofComputer.vr;
            vl = obj.dofComputer.vl;
            f = obj.forceVector;
            KG = obj.stiffnessMatrix;

            KLL=KG(vl,vl);
            KLR=KG(vl,vr);
            FLext=f(vl,1);
            ul=KLL\(FLext-KLR*ur);

        end

        function R = computeReactions(obj,ul)
            ur = obj.dofComputer.ur;
            vr = obj.dofComputer.vr;
            vl = obj.dofComputer.vl;
            f = obj.forceVector;
            KG = obj.stiffnessMatrix;

            KRL=KG(vr,vl);
            KRR=KG(vr,vr);
            FRext=f(vr,1);
            R=KRR*ur+KRL*ul-FRext;
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

        function u = computeDisplacementsVector(obj,ul)
            ur = obj.dofComputer.ur;
            vr = obj.dofComputer.vr;
            vl = obj.dofComputer.vl;

            u(vl,1)=ul;
            u(vr,1)=ur;
        end

        function ue_local = computeLocalDisplacements(obj,iElem)
            Td = obj.dofComputer.Td;
            n_nod = obj.dim.n_nod;
            n_i = obj.dim.n_i;
            nDofElem = n_nod*n_i;
            u = obj.disp;
            ue=zeros(n_nod*n_i,1);
            
                for iDof=1:(nDofElem)
                    globalDof = Td(iElem,iDof);
                    ue(iDof,1) = u(globalDof);
                end
            rot=obj.computeRotationMatrix();
            ue_local=rot*ue;
        end

        function computeStrains(obj,iElem,ue_local)
            n_el = obj.dim.n_el;
            epsilon = zeros(n_el,1);
            l=obj.length;
            epsilon(iElem,1)=(1/l)*[-1 1]*ue_local;
            obj.eps = epsilon;
        end

        function computeStresses(obj,iElem)
            mat = obj.materialMatrix;
            n_el = obj.dim.n_el;
            epsilon = obj.eps;
            sigma = zeros(n_el,1);
            E=mat(iElem,1);
            sigma(iElem,1)=E*epsilon(iElem,1);
            obj.sig = sigma;
        end

    end
    
end