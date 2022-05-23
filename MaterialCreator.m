classdef MaterialCreator < handle
    
    properties (Access = public)
        materialMatrix
    end
    
    properties (Access = private)
        cable
        bar
    end
    
    properties (Access = private)
        cableSettings
        barSettings
        data
        dimensions
    end
    
    methods (Access = public)
        
        function obj = MaterialCreator(cParams)
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
            nElem = obj.dimensions.n_el;
            material=zeros(nElem,5);
            for iElem=1:nElem
                 m = obj.obtainMaterial(iElem);
                 material(iElem,:) = [m.E,m.A,m.rho,m.I,m.Sig_y];
            end            
            obj.materialMatrix = material;
        end
        
        function m = obtainMaterial(obj,iElem)
            if obj.isBar(iElem)
                m = obj.bar;
            elseif obj.isCable(iElem)
                m = obj.cable;
            end
        end

        function itIs = isCable(obj,iElem)
            itIs = obj.data.Tmat(iElem) == 2;
        end

        function itIs = isBar(obj,iElem)
            itIs = obj.data.Tmat(iElem) == 1;
        end
        
    end
    
end