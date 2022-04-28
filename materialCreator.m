classdef materialCreator < handle
    
    properties (Access = public)
        cable
        bar
        materialMatrix
        mat
    end
    
    properties (Access = private)
        
    end
    
    properties (Access = private)
        cableSettings
        barSettings
        data
        dimensions
    end
    
    methods (Access = public)
        
        function obj = materialCreator(cParams)
            obj.init(cParams)
            obj.createCable()
            obj.createBar()
            obj.createMaterial()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.cableSettings = cParams.cableSettings;
            obj.barSettings = cParams.barSettings;
            obj.data = cParams.data;
            obj.dimensions = cParams.dimensions;
        end
        
        function createCable(obj)
            s = obj.cableSettings;
            s.type  = 'Cable'; 
            c = element.create(s);
            obj.cable = c;
        end

        function createBar(obj)
            s = obj.barSettings;
            s.type = 'Bar';
            e = element.create(s);
            obj.bar = e;
        end
        
        function createMaterial(obj)
            c = obj.cable;
            b = obj.bar;
            m = [c.E,           c.A,      c.rho,        c.I,        c.Sig_y;
                b.E,           b.A,      b.rho,        b.I,        b.Sig_y];
            Tmat = obj.data.Tmat;
            n_el = obj.dimensions.n_el;
            material=zeros(n_el,5);
            for i=1:n_el
                if Tmat(i) == 1
                    material(i,:)=m(1,:);
                elseif Tmat(i) == 2
                    material(i,:)=m(2,:);
                end
            end
            obj.materialMatrix = material;
            obj.mat = m;
        end
        
    end
    
end