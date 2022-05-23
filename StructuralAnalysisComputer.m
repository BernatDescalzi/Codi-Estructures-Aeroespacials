classdef StructuralAnalysisComputer < handle

    properties (Access = public)
        displacements
        reactions
    end

    properties (Access = private)
        dimensions
        data
        dofComputer
        material
        stifnessMatrix
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
            obj.computeDOFS();
            obj.computeMass();
            obj.computeStiffnessMatrix();
            obj.computeDisplacements();
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

        function computeDOFS(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            e = DOFsComputer(s);
            obj.dofComputer = e;
        end

        function computeMass(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            e = MassComputer(s);
            obj.mass = e;
        end

        function computeStiffnessMatrix(obj)
            s.dim = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            s.dofComputer = obj.dofComputer;
            e = StiffnessMatrixComputer(s);
            obj.stifnessMatrix = e.KG;
        end

        function computeDisplacements(obj)
           s.KG = obj.stifnessMatrix;
           s.dofComputer = obj.dofComputer;
           s.data = obj.data;
           s.dimensions = obj.dimensions;
           s.mass = obj.mass;
           s.material = obj.material;

           e = DisplacementsComputer(s);
           obj.displacements = e.displacements;
           obj.reactions = e.reactions;
         end
    end
end