classdef displacementsComputer < handle
    
    properties (Access = public)
        displacements
        reactions
    end
    
    properties (Access = private)
        forceVector
    end

    properties (Access = private)
        dofComputer
        stifnessMatrix
        data
        dimensions
        material
        mass
    end
    

    methods (Access = public)
        
        function obj = displacementsComputer(cParams)
            obj.init(cParams)
            obj.computeDisplacements()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dofComputer = cParams.dofComputer;
            obj.stifnessMatrix = cParams.KG;
            obj.data = cParams.data;
            obj.dimensions = cParams.dimensions;
            obj.mass = cParams.mass;
            obj.material = cParams.material;
        end
        
        function computeDisplacements(obj)
            Mtot = obj.mass.totalMass;
            V=0;
            dVdt = obj.data.g;
            dt = obj.data.dt;
            t_end = obj.data.t_end;

            time = 0:dt:t_end;
            sig_max = zeros(1,length(time));
            sig_min = zeros(1,length(time));
            scoef_c = zeros(1,length(time));
            scoef_b = zeros(1,length(time));

            for t = 1:length(time)

                V = V + dVdt*dt;
                obj.data.computeDrag(V);
                obj.computeForces(dVdt);
                [u,R,eps,sig] = obj.systemResolution();
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = obj.computeSafetyParameters(sig);
                dVdt = obj.data.g+(obj.data.D/Mtot);

            end
            obj.displacements = u;
            obj.reactions = R;
        end

        function computeForces(obj,dVdt)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.m_nod = obj.mass.m_nod;
            s.dVdt = dVdt;
            e = forcesComputer(s);
            obj.forceVector = e.forceVector; 
        end

        function [u,R,eps,sig] = systemResolution(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.KG = obj.stifnessMatrix;
            s.f = obj.forceVector;
            s.dofComputer = obj.dofComputer;
            s.material = obj.material;
            e = sysResolution(s);
            u = e.disp;
            R = e.reac;
            eps = e.eps;
            sig = e.sig;
        end

        function [sig_max,sig_min,scoef_ct,scoef_bt] = computeSafetyParameters(obj,sigma)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.sigma = sigma;
            s.material = obj.material;
            e = safetyParametersComputer(s);
            sig_max = e.sig_max;
            sig_min = e.sig_min;
            scoef_ct = e.scoef_ct;
            scoef_bt = e.scoef_bt;
        end  

    end
    
end