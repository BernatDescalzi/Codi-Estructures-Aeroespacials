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
        Td
        ur
        vr
        vl
        dofComputer
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

        %         function comptueStiffnessMatrix(obj)
        %             s = StiffnessMatrixCompute();
        %             s.compute();
        %             K = s.K;
        %         end


        function computeValues(obj)
            obj.createBar();
            obj.createCable();
            obj.computeData();
            obj.computeDimensions();
            mat = obj.createMaterial();
            obj.computeDOFS();
            KG = obj.computeStiffnessMatrix(mat);
            [m_nod,Mtot] = obj.computeMass(mat);
            obj.computeDisplacements(m_nod,KG,mat,Mtot);
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

        function m = createMaterial(obj)
            c = obj.cable;
            b = obj.bar;
            m = [c.E,           c.A,      c.rho,        c.I,        c.Sig_y;
                b.E,           b.A,      b.rho,        b.I,        b.Sig_y];
            Tmat = obj.data.Tmat;
            n_el = obj.dimensions.n_el;
            mat=zeros(n_el,5);
            for i=1:n_el
                if Tmat(i) == 1
                    mat(i,:)=m(1,:);
                elseif Tmat(i) == 2
                    mat(i,:)=m(2,:);
                end
            end
        end

        function I = nod2dof(obj,i,j,n_i)
            I = n_i*(i-1)+j;
        end

        function computeDOFS(obj)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            e = DOFsComputer(s);
            obj.dofComputer = e;
        end

        function KG = computeStiffnessMatrix(obj,mat)
            s.dim = obj.dimensions;
            s.data = obj.data;
            s.mat = mat;
            s.Td = obj.dofComputer.Td;
            e = StiffnessMatrixComputer(s);
            KG = e.KG;
        end

        function [m_nod,Mtot] = computeMass(obj,mat)
            s.dimensions = obj.dimensions;
            s.data = obj.data;
            s.mat = mat;
            e = massComputer(s);
            m_nod = e.m_nod;
            Mtot = e.totalMass;
        end

       
        function Fext = computeFext(obj,m_nod,dVdt)
            D = obj.data.D;
            g = obj.data.g;
            Fext = [%   Node        DOF  Magnitude
                % Write the data here...
                6 3 D/16+m_nod(6)*(g-dVdt)
                8 3 D/16+m_nod(8)*(g-dVdt)
                14 3 D/16+m_nod(14)*(g-dVdt)
                12 3 D/16+m_nod(12)*(g-dVdt)
                7 3 2*D/16+m_nod(7)*(g-dVdt)
                9 3 2*D/16+m_nod(9)*(g-dVdt)
                11 3 2*D/16+m_nod(11)*(g-dVdt)
                13 3 2*D/16+m_nod(13)*(g-dVdt)
                10 3 4*D/16+m_nod(10)*(g-dVdt)
                2 3 +m_nod(2)*(g-dVdt)
                3 3 +m_nod(3)*(g-dVdt)
                4 3 +m_nod(4)*(g-dVdt)
                5 3 +m_nod(5)*(g-dVdt)
                1 3 +m_nod(1)*(g-dVdt)
                ];
        end

        function f = computeF(obj,Fext)
            n_i = obj.dimensions.n_i;
            n_dof = obj.dimensions.n_dof;
            f=zeros(n_dof,1);
            [n,m]=size(Fext);
            for i=1:n
                I=obj.nod2dof(Fext(i,1),Fext(i,2),n_i);
                f(I)=Fext(i,5);
            end

        end

        function [u,R,eps,sig] = systemResolution(obj,KG,f,mat)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.KG = KG;
            s.f = f;
            s.ur = obj.dofComputer.ur;
            s.vr = obj.dofComputer.vr;
            s.vl = obj.dofComputer.vl;
            s.Td = obj.dofComputer.Td;
            s.mat = mat;
            e = sysResolution(s);
            u = e.disp;
            R = e.reac;
            eps = e.eps;
            sig = e.sig;
        end

        function [sig_max,sig_min,scoef_ct,scoef_bt] = computeSafetyParameters(obj,mat,sigma)
            s.data = obj.data;
            s.dimensions = obj.dimensions;
            s.sigma = sigma;
            s.mat = mat;
            e = safetyParametersComputer(s);
            sig_max = e.sig_max;
            sig_min = e.sig_min;
            scoef_ct = e.scoef_ct;
            scoef_bt = e.scoef_bt;
        end

       function computeDisplacements(obj,m_nod,KG,mat,Mtot)
            V=0;
            dVdt = obj.data.g;
            dt = 0.01;
            t_end = 5 ;
            time = 0:dt:t_end;
            sig_max = zeros(1,length(time));
            sig_min = zeros(1,length(time));
            scoef_c = zeros(1,length(time));
            scoef_b = zeros(1,length(time));
            for t = 1:length(time)

                V = V + dVdt*dt;
                obj.data.computeDrag(V);
                Fext = obj.computeFext(m_nod,dVdt);
                f = obj.computeF(Fext);
                [u,R,eps,sig] = obj.systemResolution(KG,f,mat);
                dVdt = obj.data.g+(obj.data.D/Mtot);
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = obj.computeSafetyParameters(mat,sig);

            end
            obj.displacements = u;
            obj.reactions = R;
            %postprocess(x',Tn',u,sig,sig_max,sig_min,scoef_c,scoef_b,time);
        end
    end
end