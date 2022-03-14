classdef data


    properties
        g
        M
        S
        t_s
        rho_s
        rho_a
        Cd
    end

    methods
        function obj = data(cParams)
            obj.g = cParams.g;
            obj.M = cParams.M;
            obj.S = cParams.S;
            obj.t_s = cParams.t_s;
            obj.rho_s = cParams.rho_s;
            obj.rho_a = cParams.rho_a;
            obj.Cd = cParams.Cd;
        end

        function M_s = surface(obj)
            M_s = obj.rho_s*obj.t_s*obj.S;
        end

    end
end