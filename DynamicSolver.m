classdef DynamicSolver < handle
    
    properties (Access = public)
        displacements
        reactions
    end
    
    properties (Access = private)
        dofComputer
        stifnessMatrix
        V
        dVdt
        time
        drag
        forceVector
        epsilon
        sigma
        sig_max
        sig_min
        scoef_c
        scoef_b
    end
    
    properties (Access = private)
        dimensions
        data
        material
        mass
    end
    
    methods (Access = public)
        
        function obj = DynamicSolver(cParams)
            obj.init(cParams)
            obj.computeDOFS();
            obj.computeStiffnessMatrix();
            obj.computeDisplacements();
        end
  
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.dimensions = cParams.dimensions;
            obj.data = cParams.data;
            obj.material = cParams.material;
            obj.mass = cParams.mass;
        end
        
        function computeDOFS(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            e = DOFsComputer(s);
            obj.dofComputer = e;
        end

        function computeStiffnessMatrix(obj)
            s.dim = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            s.dofComputer = obj.dofComputer;
            e = StiffnessMatrixComputer(s);
            obj.stifnessMatrix = e.KG;
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
        
        function computeForces(obj)
            s = obj.createForcesComputer();
            e = ForcesComputer(s);
            obj.forceVector = e.forceVector; 
        end
        
        function s = createForcesComputer(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.m_nod = obj.mass.m_nod;
            s.dVdt = obj.dVdt;
            s.D = obj.drag;
        end
        
        function systemResolution(obj)
            s = obj.createSystemResolution();
            e = SysResolution(s);
            obj.displacements = e.disp;
            obj.reactions = e.reac;
            obj.epsilon = e.eps;
            obj.sigma = e.sig;
        end
        
        function s = createSystemResolution(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.KG = obj.stifnessMatrix;
            s.f = obj.forceVector;
            s.dofComputer = obj.dofComputer;
            s.material = obj.material;
        end
        
        function computeSafetyParameters(obj)
            s = obj.createSafetyParametersComputer();
            e = SafetyParametersComputer(s);
            obj.sig_max = e.sig_max;
            obj.sig_min = e.sig_min;
            obj.scoef_c = e.scoef_ct;
            obj.scoef_b = e.scoef_bt;
        end
        
        function s = createSafetyParametersComputer(obj)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.sigma = obj.sigma;
            s.material = obj.material;
        end
    end
    
end