classdef DimensionsCalculator < handle
    
    properties (Access = public)
        numDim
        n_i
        n
        n_dof
        n_el
        n_nod
    end
    
    properties (Access = private)
        x
        Tn
    end
    
    
    methods (Access = public)
        
        function obj = DimensionsCalculator(cParams)
            obj.init(cParams)
            obj.compute()
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.x = cParams.data.x;
            obj.Tn = cParams.data.Tn;         
        end
        
        function compute(obj)
            obj.numDim = size(obj.x,2);              
            obj.n_i = obj.numDim;                    
            obj.n = size(obj.x,1);                
            obj.n_dof = obj.n_i*obj.n;                
            obj.n_el = size(obj.Tn,1);            
            obj.n_nod = size(obj.Tn,2); 
        end
        
    end
    
end