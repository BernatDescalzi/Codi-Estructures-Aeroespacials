classdef StiffnessMatrixComputer < handle
    
    properties (Access = public)
        KG
    end

    properties (Access = private)
        Kel
        coordA
        coordB
        length
    end

    properties (Access = private)
        dim
        data
        mat
        Td
    end

    methods (Access = public)
        function obj = StiffnessMatrixComputer(cParams)
            obj.init(cParams)
            obj.computeElementalSfittnesMatrix()
            obj.assemblyKG()
        end
    end

    methods (Access = private)
        function init(obj,cParams)
            obj.dim = cParams.dim;
            obj.data = cParams.data;
            obj.mat = cParams.material.materialMatrix;
            obj.Td = cParams.dofComputer.Td;
        end

        function computeElementalSfittnesMatrix(obj)
            ndof  = obj.dim.n_nod*obj.dim.n_i;
            nElem = obj.dim.n_el;
            kel = zeros(ndof,ndof,nElem);
            for iElem = 1:nElem
                obj.computeNodesCoord(iElem);
                obj.computeLength();                
                R = obj.computeRotationMatrix();
                KT = obj.createElementalStifnessMatrix(iElem);
                K  = obj.rotateElementalStiffnesMatrix(KT,R);
                kel(:,:,iElem) = K;
            end
            obj.Kel = kel;
        end

        function KT = createElementalStifnessMatrix(obj,iElem)
                l = obj.length;
                A = obj.mat(iElem,2);
                E = obj.mat(iElem,1);
                KT=(A*E/l)*[1 -1;-1 1];
        end

        function K = rotateElementalStiffnesMatrix(obj,KT,R)
           K=R'*KT*R;
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

        function assemblyKG(obj)
               ndof  = obj.dim.n_nod*obj.dim.n_i;            
               kg = zeros(obj.dim.n_dof,obj.dim.n_dof);
               connec = obj.Td;
                for iElem = 1:obj.dim.n_el
                    for idof=1:ndof
                        inode = connec(iElem,idof);
                        for jdof=1:ndof
                            jnode = connec(iElem,jdof);
                            kelem = obj.Kel(idof,jdof,iElem);
                            kg(inode,jnode)=kg(inode,jnode)+kelem;
                        end
                    end
                end
            obj.KG = kg;
        end
    end
end