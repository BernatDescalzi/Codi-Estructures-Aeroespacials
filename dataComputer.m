classdef dataComputer < handle
    
    properties (Access = public)
        x
        Tn
        Tmat
        M
        M_s
        fixNod
        g
        D
        dt
        t_end
    end

    properties (Access = private)
        Cd
        rho_s
        rho_a
        S
        t_s        
    end

    properties (Access = private)
    
    end

    methods (Access = public)

        function obj = dataComputer(cParams)
            obj.init(cParams);
            obj.computeFabricMass();
            obj.computeInputData();
        end

        function computeDrag(obj,V)
            d = 1/2*obj.rho_a*obj.S*V.^2*obj.Cd; 
            obj.D = d;            
        end

    end

    methods (Access = private)

        function init(obj,cParams)
            obj.g = cParams.g;
            obj.M = cParams.M;
            obj.S = cParams.S;
            obj.t_s = cParams.t_s;
            obj.rho_s = cParams.rho_s;
            obj.rho_a = cParams.rho_a;
            obj.Cd    = cParams.Cd;
            obj.dt = cParams.dt;
            obj.t_end = cParams.t_end;
        end

        function computeFabricMass(obj)
            density = obj.rho_s;
            thickness = obj.t_s;
            surface = obj.S;
            Mass = density*thickness*surface;
            obj.M_s = Mass;
        end

        function computeInputData(obj)
            c = inputData();
            obj.x = c.x;
            obj.Tn = c.Tn;
            obj.Tmat = c.Tmat;
            obj.fixNod = c.fixNod;
        end

    end
end