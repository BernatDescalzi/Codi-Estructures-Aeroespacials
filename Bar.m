classdef Bar < element


    properties
    end

    methods
        function obj = Bar(cParams)
            init(obj,cParams);
            obj.d = cParams.D-2*1.6e-3;
            obj.A = pi*((cParams.D/2)^2-(obj.d/2)^2);
            obj.I = pi/4*((cParams.D/2)^4-(obj.d/2)^4); 
        end

    end
end