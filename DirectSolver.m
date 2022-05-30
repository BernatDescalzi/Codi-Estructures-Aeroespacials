classdef DirectSolver < Solver
    
    properties (Access = public)
    end
    
    properties (Access = private)   
    end
    
    properties (Access = private) 
    end
    
    methods (Access = public)
        
        function obj = DirectSolver(cParams)
            obj.init(cParams)
            obj.solution = obj.KLL\(obj.FLext-obj.KLR*obj.ur);
        end
        
    end

    
end