classdef displacementsComputer < handle
    
    properties (Access = public)
        
    end
    
    properties (Access = private)
        
    end
    

    methods (Access = public)
        
        function obj = displacementsComputer(cParams)
            obj.init(cParams)
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            
        end
        
        function computeDisplacements(obj,m_nod,KG,ur,vr,vl,Td,mat,Mtot)
            V=0;
            dVdt = obj.data.g;
            dt = 0.01;
            t_end = 5 ;
            time = 0:dt:t_end;
            sig_max = zeros(1,length(time));
            sig_min = zeros(1,length(time));
            scoef_c = zeros(1,length(time));
            scoef_b = zeros(1,length(time));
            for t = 1:length(time)

                V = V + dVdt*dt;
                obj.data.computeDrag(V);
                Fext = obj.computeFext(m_nod,dVdt);
                f = obj.computeF(Fext);
                [u,R,eps,sig] = obj.systemResolution(KG,f,ur,vr,vl,Td,mat);
                dVdt = obj.data.g+(obj.data.D/Mtot);
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = obj.computeSafetyParameters(mat,sig);

            end
            obj.displacements = u;
            obj.reactions = R;
        end

                
        
    end
    
end