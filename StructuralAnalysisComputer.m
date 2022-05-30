classdef StructuralAnalysisComputer < handle

    properties (Access = public)
        displacements
        reactions
    end

    properties (Access = private)
        dimensions
        data
        material
        mass
    end

    properties (Access = private)
        cableSettings
        barSettings
        initData
    end

    methods (Access = public)

        function obj = StructuralAnalysisComputer(cParams)
            obj.init(cParams);
        end

        function compute(obj)
            obj.computeData();
            obj.computeDimensions();
            obj.createMaterial();
            obj.computeMass();
            obj.computeDynamicSolver();
        end
    end

    methods (Access = private)

        function init(obj,cParams)
            obj.cableSettings = cParams.cableSettings;
            obj.barSettings = cParams.barSettings;
            obj.initData = cParams.data;
        end

        function computeData(obj)
            s = obj.initData;
            d = DataComputer(s);
            obj.data = d.data;
        end

        function  computeDimensions(obj)
            s.data = obj.data;
            d = DimensionsCalculator(s);
            obj.dimensions = d;
        end

        function createMaterial(obj)
            s.barSettings = obj.barSettings;
            s.cableSettings = obj.cableSettings;
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            e = MaterialCreator(s);
            obj.material = e;        
        end

        function computeMass(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            e = MassComputer(s);
            obj.mass = e;
        end

        function computeDynamicSolver(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            s.mass = obj.mass;
            e = DynamicSolver(s);
            obj.displacements = e.displacements;
            obj.reactions = e.reactions;
        end

    end
end