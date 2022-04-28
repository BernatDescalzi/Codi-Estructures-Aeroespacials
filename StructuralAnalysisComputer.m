classdef StructuralAnalysisComputer < handle

    properties (Access = public)
        displacements
        reactions
    end

    properties (Access = private)
        cable
        bar
        dimensions
        data
        dofComputer
        material
        KG

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
            obj.computeValues();
            %obj.computeInitalValues();
            %obj.computeStiffnessMatrix();
            % obj.computeForces();
            %obj.computeDisp();
        end
    end

    methods (Access = private)

        function init(obj,cParams)
            obj.cableSettings = cParams.cableSettings;
            obj.barSettings = cParams.barSettings;
            obj.initData = cParams.data;
        end

        function computeValues(obj)
            obj.computeData();
            obj.computeDimensions();
            obj.createMaterial();
            obj.computeDOFS();
            obj.computeStiffnessMatrix();
            [m_nod,Mtot] = obj.computeMass();
            obj.computeDisplacements(m_nod,Mtot);
        end

        function createMaterial(obj)
            s.barSettings = obj.barSettings;
            s.cableSettings = obj.cableSettings;
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            e = materialCreator(s);
            obj.material = e;
        
        end

        function computeData(obj)
            s = obj.initData;
            obj.data = dataComputer(s);
        end

        function  computeDimensions(obj)
            s.x = obj.data.x;
            s.Tn = obj.data.Tn;
            s.Tmat = obj.data.Tmat;
            d = dimensionsCalculator(s);
            obj.dimensions = d;
        end

        function computeDOFS(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            e = DOFsComputer(s);
            obj.dofComputer = e;
        end

        function computeStiffnessMatrix(obj)
            s.dim = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            s.dofComputer = obj.dofComputer;
            e = StiffnessMatrixComputer(s);
            obj.KG = e.KG;
        end

        function [m_nod,Mtot] = computeMass(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            s.material = obj.material;
            e = massComputer(s);
            m_nod = e.m_nod;
            Mtot = e.totalMass;
        end

       function computeDisplacements(obj,m_nod,Mtot)
           s.KG = obj.KG;
           s.dofComputer = obj.dofComputer;
           s.data = obj.data;
           s.dimensions = obj.dimensions;
           s.m_nod = m_nod;
           s.Mtot = Mtot;
           s.material = obj.material;

           e = displacementsComputer(s);
           obj.displacements = e.displacements;
           obj.reactions = e.reactions;

        end
    end
end