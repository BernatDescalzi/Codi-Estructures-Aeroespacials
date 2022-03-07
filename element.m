classdef element


    properties
            D = 0;
            d = 0;
            E = 0;
            A = 0;
            rho = 0;
            Sig_y = 0;
            I = 0;
    end

    methods
        function obj = element()
        end

        function obj = computeData(obj,tipus_element)
            if tipus_element == "Bar"
            obj.d=obj.D-2*1.6e-3;
            obj.A = pi*((obj.D/2)^2-(obj.d/2)^2);
            obj.I = pi/4*((obj.D/2)^4-(obj.d/2)^4); 

            elseif tipus_element == "Cable"
            obj.A = pi*(obj.D/2)^2;
            obj.I = pi/4*(obj.D/2)^4;

            else
                disp("Wrong Input Argument")
            end
        end
    end
end