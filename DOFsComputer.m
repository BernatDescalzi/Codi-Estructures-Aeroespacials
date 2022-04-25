classdef DOFsComputer < handle
    
    properties (Access = public)
        Td
        ur
        vr
        vl
    end
    
    properties (Access = private)
        n_el
        n_nod
        n_i
        n_dof
        fixNod
        Tn
    end
    
    properties (Access = private)
        
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
            obj.n_el = cParams.dimensions.n_el;
            obj.n_nod = cParams.dimensions.n_nod;
            obj.n_i = cParams.dimensions.n_i;
            obj.n_dof = cParams.dimensions.n_dof;
            obj.fixNod = cParams.data.fixNod;
            obj.Tn = cParams.data.Tn;
        end
        
        function computeTd(obj)
            T_d = zeros(obj.n_el,obj.n_nod*obj.n_i);
            for iElem = 1:obj.n_el
                for i=1:obj.n_nod
                    for j=1:obj.n_i
                        I=obj.nod2dof(i,j);
                        T_d(iElem,I)=obj.nod2dof(obj.Tn(iElem,i),j);
                    end
                end
            end  
            obj.Td = T_d;
        end
        
        function computeFixedDOFS(obj)
            numDofs = obj.n_dof;
            fixedNod = obj.fixNod;
            [n,m]=size(fixedNod);
            u_r=zeros(n,1);
            v_r=zeros(n,1);
            v_l=zeros(numDofs-n,1);
            for i=1:n
                I=obj.nod2dof(fixedNod(i,1),fixedNod(i,2));
                u_r(i)=fixedNod(i,3);
                v_r(i)=I;
            end

            p=1;
            for j=1:numDofs
                s=0;
                for k=1:n
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
        
        function I = nod2dof(i,j,obj)
            ni = obj.n_i;
            I = ni*(i-1)+j;
        end
        
    end
    
end