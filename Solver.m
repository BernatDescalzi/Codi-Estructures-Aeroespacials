classdef Solver < handle
    
    properties (Access = public)
        solution
        ur
        KLL
        KLR
        FLext
    end
    
    properties (Access = private)
    end
    
    properties (Access = private)
    end
    
    methods (Access = public, Static)
        
        function obj = create(cParams)
            switch cParams.solverType
                case "Direct"
                    obj = DirectSolver(cParams);
                case "Iterative"
                    obj = IterativeSolver(cParams);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function init(obj,cParams)
            obj.ur = cParams.ur;
            obj.KLL = cParams.KLL;
            obj.KLR = cParams.KLR;
            obj.FLext = cParams.FLext;
        end
        
    end
    
end