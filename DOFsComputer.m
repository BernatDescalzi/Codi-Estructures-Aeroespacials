classdef DOFsComputer < handle
    
    properties (GetAccess = public, SetAccess = private)
        Td
        ur
        vr
        vl       
    end
    
    properties (Access = private)

    end
    
    properties (Access = private)
        dim
        data
    end
    
    methods (Access = public)
        
        function obj = DOFsComputer(cParams)
            obj.init(cParams);
            obj.computeTd();
            obj.computeFixedDOFS();
            
        end    
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
        end
        
        function computeTd(obj)
            nElem = obj.dim.n_el;
            nNod = obj.dim.n_nod;
            nDof = obj.dim.n_i;
            elemDofs = nNod*nDof;
            
            T_d = zeros(nElem,elemDofs);
            for iElem = 1:nElem
                for iNod=1:nNod
                    for iDof=1:nDof
                        localNumDof=obj.nod2dof(iNod,iDof);
                        globalNumDof = obj.nod2dof(obj.data.Tn(iElem,iNod),iDof);
                        T_d(iElem,localNumDof) = globalNumDof;
                    end
                end
            end  
            obj.Td = T_d;
        end
        

        function computeFixedDOFS(obj)
            [u_r,v_r] = obj.calculateRestrictedVectors();
            v_l = obj.calculateFreeDofsVector(v_r);
            obj.vr = v_r;
            obj.vl = v_l;
            obj.ur = u_r;
        end

        function [u_r,v_r] = calculateRestrictedVectors(obj)
            fixedNod = obj.data.fixNod;
            nFixedNod=size(fixedNod,1);

            u_r=zeros(nFixedNod,1);
            v_r=zeros(nFixedNod,1);

            for i=1:nFixedNod
                numFixedNod = fixedNod(i,1);
                dofRestricted = fixedNod(i,2);
                dispRestricted = fixedNod(i,3);

                globalDofRestricted=obj.nod2dof(numFixedNod,dofRestricted);
                u_r(i)=dispRestricted;
                v_r(i)=globalDofRestricted;
            end
        end

        function v_l = calculateFreeDofsVector(obj,v_r)
            totalDofs = obj.dim.n_dof;
            fixedNod = obj.data.fixNod;
            nFixedNod=size(fixedNod,1);
            
            v_l=zeros(totalDofs-nFixedNod,1);
            p=1;
            for jDof=1:totalDofs
                s=0;
                for kFixNod=1:nFixedNod
                    if v_r(kFixNod)==jDof
                        s=1;
                    end
                end
                if s==0
                    v_l(p)=jDof;
                    p=p+1;
                end
            end    
        end

        function I = nod2dof(obj,i,j)
            ni = obj.dim.n_i;
            I = ni*(i-1)+j;
        end               
        

        
    end
    
end