classdef element < handle

    properties (Access = public)
        D = 0;
        d = 0;
        E = 0;
        rho = 0;
        Sig_y = 0;
        A
        I
    end

    methods (Access = public, Static)

        function obj = create(cParams)
            switch cParams.type
                case "Bar"
                    obj = Bar(cParams);
                case "Cable"
                    obj = Cable(cParams);
            end
        end

    end

    methods (Access = protected)

        function init(obj,cParams)
            obj.D    =  cParams.D;
            obj.E     = cParams.E;
            obj.rho   = cParams.rho;
            obj.Sig_y = cParams.sigY;
        end        

    end
end
