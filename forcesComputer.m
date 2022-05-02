classdef forcesComputer < handle
    
    properties (Access = public)
        forceVector
    end
    
    properties (Access = private)
        Fexterior
    end
    
    properties (Access = private)
        mNod
        dvdt
        data
        dimensions
    end
    
    methods (Access = public)
        
        function obj = forcesComputer(cParams)
            obj.init(cParams)
            obj.computeFext()
            obj.computeForceVector()
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.mNod = cParams.m_nod;
            obj.dvdt = cParams.dVdt;
            obj.data = cParams.data;
            obj.dimensions = cParams.dimensions;
        end
        
        function computeFext(obj)
            m_nod = obj.mNod;
            dVdt = obj.dvdt;
            D = obj.data.D;
            g = obj.data.g;
            Fext = [
                6 3 D/16+m_nod(6)*(g-dVdt)
                8 3 D/16+m_nod(8)*(g-dVdt)
                14 3 D/16+m_nod(14)*(g-dVdt)
                12 3 D/16+m_nod(12)*(g-dVdt)
                7 3 2*D/16+m_nod(7)*(g-dVdt)
                9 3 2*D/16+m_nod(9)*(g-dVdt)
                11 3 2*D/16+m_nod(11)*(g-dVdt)
                13 3 2*D/16+m_nod(13)*(g-dVdt)
                10 3 4*D/16+m_nod(10)*(g-dVdt)
                2 3 +m_nod(2)*(g-dVdt)
                3 3 +m_nod(3)*(g-dVdt)
                4 3 +m_nod(4)*(g-dVdt)
                5 3 +m_nod(5)*(g-dVdt)
                1 3 +m_nod(1)*(g-dVdt)
                ];
            obj.Fexterior = Fext;
        end
        
        function computeForceVector(obj)
            Fext = obj.Fexterior;
            totalDof = obj.dimensions.n_dof;

            f=zeros(totalDof,1);
            n=size(Fext,1);

            for iNode=1:n
                nodeApplied = Fext(iNode,1);
                localDofApplied = Fext(iNode,2);
                forceMagnitude = Fext(iNode,5);
                globalDof=obj.nod2dof(nodeApplied,localDofApplied);
                f(globalDof)=forceMagnitude;
            end
            obj.forceVector = f;
        end
        
        function I = nod2dof(obj,i,j)
            n_i = obj.dimensions.n_i;
            I = n_i*(i-1)+j;
        end
    
    end
end