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
        drag
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
            obj.initialize();
            t = obj.time;

            for n = 1:length(t)
                obj.computeVelocity()
                obj.computeDrag();
                obj.computeForces();
                obj.systemResolution();
                obj.computeSafetyParameters();
                obj.updateVelocity();
            end
        end

        function computeForces(obj)
            s = obj.createForcesComputer();
            e = ForcesComputer(s);
            obj.forceVector = e.forceVector; 
        end

        function systemResolution(obj)
            s = obj.createSystemResolution();
            e = SysResolution(s);
            obj.displacements = e.disp;
            obj.reactions = e.reac;
            obj.epsilon = e.eps;
            obj.sigma = e.sig;
        end

        function computeSafetyParameters(obj)
            s = obj.createSafetyParametersComputer();
            e = SafetyParametersComputer(s);
            obj.sig_max = e.sig_max;
            obj.sig_min = e.sig_min;
            obj.scoef_c = e.scoef_ct;
            obj.scoef_b = e.scoef_bt;
        end  

        function computeVelocity(obj)
            dt = obj.data.dt;
            v = obj.V + obj.dVdt*dt;
            obj.V = v;
        end

        function updateVelocity(obj)
            Mtot = obj.mass.totalMass;
            obj.dVdt = obj.data.g+(obj.drag/Mtot);
        end

        function initialize(obj)
            obj.V=0;
            obj.dVdt = obj.data.g;
            dt = obj.data.dt;
            t_end = obj.data.t_end;
            obj.time = 0:dt:t_end;

            obj.sig_max = zeros(1,length(obj.time));
            obj.sig_min = zeros(1,length(obj.time));
            obj.scoef_c = zeros(1,length(obj.time));
            obj.scoef_b = zeros(1,length(obj.time));
        end

        function computeDrag(obj)
            rho_a = obj.data.rho_a;
            S = obj.data.S;
            Cd = obj.data.Cd;
            D = 1/2*rho_a*S*obj.V.^2*Cd; 
            obj.drag = D;            
        end

        function s = createSystemResolution(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.KG = obj.stifnessMatrix;
            s.f = obj.forceVector;
            s.dofComputer = obj.dofComputer;
            s.material = obj.material;
        end

        function s = createForcesComputer(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.m_nod = obj.mass.m_nod;
            s.dVdt = obj.dVdt;
            s.D = obj.drag;
        end
        
        function s = createSafetyParametersComputer(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.sigma = obj.sigma;
            s.material = obj.material;
        end
    end
    
end