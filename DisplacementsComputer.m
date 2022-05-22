classdef DisplacementsComputer < handle
    
    properties (Access = public)
        displacements
        reactions
    end
    
    properties (Access = private)
        forceVector
        V
        dVdt
        time
        D
        epsilon
        sigma
        sig_max
        sig_min
        scoef_b
        scoef_c
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
        
        function obj = DisplacementsComputer(cParams)
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
            t = obj.time;
            obj.initialize(t);

            for t = 1:length(t)
                obj.computeVelocity()
                obj.computeDrag();
                obj.computeForces();
                obj.systemResolution();
                obj.computeSafetyParameters();
                obj.updateVelocity();
            end
        end

        function computeForces(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.m_nod = obj.mass.m_nod;
            s.dVdt = obj.dVdt;
            s.D = obj.D;
            e = forcesComputer(s);
            obj.forceVector = e.forceVector; 
        end

        function systemResolution(obj)
            s = createSystemResolution();
            e = sysResolution(s);
            obj.displacements = e.disp;
            obj.reactions = e.reac;
            obj.epsilon = e.eps;
            obj.sigma = e.sig;
        end

        function computeSafetyParameters(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.sigma = obj.sigma;
            s.material = obj.material;
            e = safetyParametersComputer(s);
            obj.sig_max = e.sig_max;
            obj.sig_min = e.sig_min;
            obj.scoef_c = e.scoef_ct;
            obj.scoef_b = e.scoef_bt;
        end  

        function computeVelocity(obj)
            dt = obj.data.dt;
            V = obj.V + obj.dVdt*dt;
            obj.V = V;
        end

        function updateVelocity(obj)
            Mtot = obj.mass.totalMass;
            obj.dVdt = obj.data.g+(obj.D/Mtot);
        end

        function initialize(obj,t)
            obj.V=0;
            obj.dVdt = obj.data.g;
            dt = obj.data.dt;
            t_end = obj.data.t_end;
            obj.time = 0:dt:t_end;

            obj.sig_max = zeros(1,length(t));
            obj.sig_min = zeros(1,length(t));
            obj.scoef_c = zeros(1,length(t));
            obj.scoef_b = zeros(1,length(t));
        end

        function computeDrag(obj)
            rho_a = obj.data.rho_a;
            S = obj.data.S;
            Cd = obj.data.Cd;
            d = 1/2*rho_a*S*obj.V.^2*Cd; 
            obj.D = d;            
        end

        function s = createSystemResolution(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.KG = obj.stifnessMatrix;
            s.f = obj.forceVector;
            s.dofComputer = obj.dofComputer;
            s.material = obj.material;
        end

    end
    
end