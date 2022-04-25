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
        material
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
            obj.material = cParams.mat;
        end
        
        function compute(obj)
            x = obj.data.x;
            Tn = obj.data.Tn;
            Tmat = obj.data.Tmat;
            n_el = obj.dim.n_el;
            sig = obj.sigma;
            mat = obj.material;
            obj.sig_max=max(sig);
            obj.sig_min=min(sig);
            sig_cr=zeros(n_el,1);
            for e=1:n_el
                x1=x(Tn(e,1),1);
                y1=x(Tn(e,1),2);
                z1=x(Tn(e,1),3);
                x2=x(Tn(e,2),1);
                y2=x(Tn(e,2),2);
                z2=x(Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                sig_cr(e,1)=pi^2*mat(Tmat(e,1),1)*mat(Tmat(e,1),4)/(l^2*mat(Tmat(e,1),2));
                scoef_c(e)=mat(Tmat(e,1),5)/abs(sig(e));

                if sig(e)<0
                    scoef_b(e)=sig_cr(e)/sig(e);
                else
                    scoef_b(e)=-1000;
                end

            end
            obj.scoef_ct=min(scoef_c);
            obj.scoef_bt=-max(scoef_b);
        end
    end
    
end