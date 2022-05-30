classdef IterativeSolver < Solver
    
    properties (Access = public)
        
    end
    
    properties (Access = private)
        
    end
    
    properties (Access = private)
        
    end
    
    methods (Access = public)
        
        function obj = IterativeSolver(cParams)
            obj.init(cParams)
            obj.solution = pcg(obj.KLL,obj.FLext-obj.KLR*obj.ur);
           
        end
        
    end

    
end