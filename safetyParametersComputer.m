classdef safetyParametersComputer < handle
    
    properties (Access = public)
        sig_max
        sig_min
        scoef_ct
        scoef_bt
    end
    
    properties (Access = private)
        
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
                x1=x(Tn(iElem,1),1);
                y1=x(Tn(iElem,1),2);
                z1=x(Tn(iElem,1),3);
                x2=x(Tn(iElem,2),1);
                y2=x(Tn(iElem,2),2);
                z2=x(Tn(iElem,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
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
    end
    
end