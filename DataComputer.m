classdef DataComputer < handle
    
    properties (Access = public)
        data
    end

    properties (Access = private)
        x
        Tn
        Tmat
        M_s
        fixNod
        D
    end

    properties (Access = private)
        g
        M
        S
        t_s
        rho_s
        rho_a
        Cd
        dt
        t_end
    end

    properties (Access = private)
    
    end

    methods (Access = public)

        function obj = DataComputer(cParams)
            obj.init(cParams);
            obj.computeFabricMass();
            obj.computeInputData();
            obj.groupData();
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
            c = InputData();
            obj.x = c.x;
            obj.Tn = c.Tn;
            obj.Tmat = c.Tmat;
            obj.fixNod = c.fixNod;
        end

        function groupData(obj)
            obj.data.x = obj.x;
            obj.data.Tn = obj.Tn;
            obj.data.Tmat = obj.Tmat;
            obj.data.M = obj.M;
            obj.data.M_s = obj.M_s;
            obj.data.fixNod = obj.fixNod;
            obj.data.g = obj.g;
            obj.data.D = obj.D;
            obj.data.dt = obj.dt;
            obj.data.t_end = obj.t_end;
            obj.data.rho_a = obj.rho_a;
            obj.data.S = obj.S;
            obj.data.Cd = obj.Cd;
        end

    end
end