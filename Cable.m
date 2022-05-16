classdef Cable < element

    properties
    end

    methods (Access = public)
        function obj = Cable(cParams)
            init(obj,cParams);
            obj.A = pi*(obj.D/2)^2;
            obj.I = pi/4*(obj.D/2)^4; 
        end

    end
end