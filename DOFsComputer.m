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
                        I=obj.nod2dof(iNod,iDof);
                        T_d(iElem,I)=obj.nod2dof(obj.data.Tn(iElem,iNod),iDof);
                    end
                end
            end  
            obj.Td = T_d;
        end
        

        function computeFixedDOFS(obj)
            numDofs = obj.dim.n_dof;
            fixedNod = obj.data.fixNod;
            nFixedNod=size(fixedNod,1);

            u_r=zeros(nFixedNod,1);
            v_r=zeros(nFixedNod,1);
            v_l=zeros(numDofs-nFixedNod,1);

            for i=1:nFixedNod
                numFixedNod = fixedNod(i,1);
                dofRestricted = fixedNod(i,2);

                I=obj.nod2dof(numFixedNod,dofRestricted);
                u_r(i)=fixedNod(i,3);
                v_r(i)=I;
            end

            p=1;
            for j=1:numDofs
                s=0;
                for k=1:nFixedNod
                    if v_r(k)==j
                        s=1;
                    end
                end
                if s==0
                    v_l(p)=j;
                    p=p+1;
                end
            end    
            obj.vr = v_r;
            obj.vl = v_l;
            obj.ur = u_r;
        end

        function I = nod2dof(obj,i,j)
            ni = obj.dim.n_i;
            I = ni*(i-1)+j;
        end               
        

        
    end
    
end