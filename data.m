classdef data < handle


    properties (Access = public)
        g
        M
        S
        t_s
        rho_s
        rho_a
        Cd
        D
        M_s
    end

    methods (Access = public)

        function obj = data(cParams)
            obj.init(cParams);
            obj.computeSurface();
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
        end

        function computeSurface(obj)
            s = obj.rho_s*obj.t_s*obj.S;
            obj.M_s = s;
        end

    end
end