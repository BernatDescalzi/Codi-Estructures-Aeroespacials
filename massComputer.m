classdef massComputer < handle
    
    properties (Access = public)
        m_nod
        totalMass
    end
    
    properties (Access = private)
    end

    properties (Access = private)
        dim
        data
        mat
    end

    
    methods (Access = public)
        
        function obj = massComputer(cParams)
            obj.init(cParams)
            obj.computeMass()
            obj.computeTotalMass()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
            obj.mat = cParams.mat;
        end
        
        function computeMass(obj)
            Tn = obj.data.Tn;
            M = obj.data.M;
            M_s = obj.data.M_s;
            n = obj.dim.n;
            n_el = obj.dim.n_el;
            material = obj.mat;
            mass =zeros(n,1);
            for iElem=1:n_el

                l = obj.computeLength(iElem);

                type = obj.computeElementType(iElem);
                A   = material(type,2);
                rho = material(type,3);

                m_bar = A*l*rho;

                mass(Tn(iElem,1))=mass(Tn(iElem,1))+m_bar/2;
                mass(Tn(iElem,2))=mass(Tn(iElem,2))+m_bar/2;
            end
            mass(1)=mass(1)+M;
            mass(6)=mass(6)+M_s/16;
            mass(8)=mass(8)+M_s/16;
            mass(12)=mass(12)+M_s/16;
            mass(14)=mass(14)+M_s/16;
            mass(7)=mass(7)+2*M_s/16;
            mass(9)=mass(9)+2*M_s/16;
            mass(11)=mass(11)+2*M_s/16;
            mass(13)=mass(13)+2*M_s/16;
            mass(10)=mass(10)+4*M_s/16;


            if nargin == 0
                load('tmp.mat');
            end
            
            obj.m_nod = mass;
        end

        function eType = computeElementType(obj,iElem)
            T = obj.data.Tmat;
            eType = T(iElem,1);
        end

        function l = computeLength(obj,iElem) 
            nodeA = obj.data.Tn(iElem,1);
            nodeB = obj.data.Tn(iElem,2);
            xV = obj.data.x;
            xA = xV(nodeA,1);
            yA = xV(nodeA,2);
            zA = xV(nodeA,3);
            xB = xV(nodeB,1);
            yB = xV(nodeB,2);
            zB = xV(nodeB,3);
            l=sqrt((xB-xA)^2+(yB-yA)^2+(zB-zA)^2);
        end

        function computeTotalMass(obj)
            nodeMass = obj.m_nod;
            n = obj.dim.n;
            Mtot=0;
            for i=1:n
                Mtot=Mtot+nodeMass(i,1);
            end
            obj.totalMass = Mtot;
        end
    end
    
end