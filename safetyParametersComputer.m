classdef safetyParametersComputer < handle
    
    properties (Access = public)
        sig_max
        sig_min
        scoef_ct
        scoef_bt
    end
    
    properties (Access = private)
        coordA
        coordB
        length
    end
    
    properties (Access = private)
        dim
        data
        sigma
        materialMatrix
    end
    
    methods (Access = public)
        
        function obj = safetyParametersComputer(cParams)
            obj.init(cParams)
            obj.compute()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dim = cParams.dimensions;
            obj.data = cParams.data;
            obj.sigma = cParams.sigma;
            obj.materialMatrix = cParams.material.materialMatrix;
        end
        
        function compute(obj)
            x = obj.data.x;
            Tn = obj.data.Tn;
            n_el = obj.dim.n_el;
            sig = obj.sigma;
            mat = obj.materialMatrix;
            obj.sig_max=max(sig);
            obj.sig_min=min(sig);
            sig_cr=zeros(n_el,1);
            for iElem=1:n_el
                obj.computeNodesCoord(iElem)
                l = obj.computeLength();
                sig_cr(iElem,1) = pi^2*mat(iElem,1)*mat(iElem,4)/(l^2*mat(iElem,2));
                scoef_c(iElem) = mat(iElem,5)/abs(sig(iElem));

                if sig(iElem)<0
                    scoef_b(iElem)=sig_cr(iElem)/sig(iElem);
                else
                    scoef_b(iElem)=-1000;
                end

            end
            obj.scoef_ct=min(scoef_c);
            obj.scoef_bt=-max(scoef_b);
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
    end
    
end