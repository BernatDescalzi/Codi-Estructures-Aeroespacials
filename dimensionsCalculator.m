classdef dimensionsCalculator < handle
    
    properties (Access = public)
        n_d
        n_i
        n
        n_dof
        n_el
        n_nod
    end
    
    properties (Access = private)
        x
        Tn
        Tmat
    end
    
    
    methods (Access = public)
        
        function obj = dimensionsCalculator(cParams)
            obj.init(cParams)
            obj.compute()
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.x = cParams.x;
            obj.Tn = cParams.Tn;
            obj.Tmat = cParams.Tmat;          
        end
        
        function compute(obj)
            obj.n_d = size(obj.x,2);              
            obj.n_i = obj.n_d;                    
            obj.n = size(obj.x,1);                
            obj.n_dof = obj.n_i*obj.n;                
            obj.n_el = size(obj.Tn,1);            
            obj.n_nod = size(obj.Tn,2); 
        end
        
    end
    
end