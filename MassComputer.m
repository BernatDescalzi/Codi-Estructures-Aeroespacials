classdef MassComputer < handle
    
    properties (Access = public)
        m_nod
        totalMass
    end
    
    properties (Access = private)
    end

    properties (Access = private)
        dim
        data
        materialMatrix
    end

    
    methods (Access = public)
        
        function obj = MassComputer(cParams)
            obj.init(cParams)
            obj.computeMass()
            obj.computeTotalMass()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
            obj.materialMatrix = cParams.material.materialMatrix;
        end
        
        function computeMass(obj)
            mass = obj.computeElementMass();
            mass = obj.computeExternalMass(mass);
            obj.m_nod = mass;
        end
        
        function mass = computeExternalMass(obj,mass)
            M = obj.data.M;
            M_s = obj.data.M_s;
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
        end
        
        function mass = computeElementMass(obj)
            Tn = obj.data.Tn;
            n_el = obj.dim.n_el;
            mat = obj.materialMatrix;
            totalNodes = obj.dim.n;
            mass =zeros(totalNodes,1);

            for iElem=1:n_el

                l = obj.computeLength(iElem);
                A   = mat(iElem,2);
                rho = mat(iElem,3);

                m_bar = A*l*rho;
                node1 = Tn(iElem,1);
                node2 = Tn(iElem,2);

                mass(node1)=mass(node1)+m_bar/2;
                mass(node2)=mass(node2)+m_bar/2;
            end
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