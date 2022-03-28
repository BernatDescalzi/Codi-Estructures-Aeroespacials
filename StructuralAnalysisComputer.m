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
            mat = obj.createMaterial();
            obj.computeDimensions();



            Td = obj.connectDOFs();
            KG = obj.stiffnessMatrix(mat,Td);
            [m_nod] = obj.computeMass(mat);
            Mtot = obj.computeTotalMass(m_nod);
            [ur,vr,vl] = obj.fixDOFS();

            obj.computeDisplacements(m_nod,KG,ur,vr,vl,Td,mat,Mtot);
        end

        function createCable(obj)
            s = obj.cableSettings;
            s.type  = 'Cable'; % s is a structure
            c = element.create(s);
            obj.cable = c;
        end

        function createBar(obj)
            s = obj.barSettings;
            s.type = 'Bar';
            e = element.create(s);
            obj.bar = e;
        end


        function mat = createMaterial(obj)
            c = obj.cable;
            b = obj.bar;
            mat = [c.E,           c.A,      c.rho,        c.I,        c.Sig_y;
                b.E,           b.A,      b.rho,        b.I,        b.Sig_y     ];
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

        function  computeDimensions(obj)

            s.x = obj.data.x;
            s.Tn = obj.data.Tn;
            s.Tmat = obj.data.Tmat;
            d = dimensionsCalculator(s);
            obj.dimensions = d;
            %             n_d = d.n_d;
            %             n_i = d.n_i;
            %             n = d.n;
            %             n_dof = d.n_dof;
            %             n_el = d.n_el;
            %             n_nod = d.n_nod;
        end


        function Td = connectDOFs(obj)
            d = obj.dimensions;
            D = obj.data;
            n_el = d.n_el;
            n_nod = d.n_nod;
            n_i = d.n_i;
            Td = zeros(n_el,n_nod*n_i);
            for e=1:n_el
                for i=1:n_nod
                    for j=1:n_i
                        I=nod2dof(i,j,n_i);
                        Td(e,I)=nod2dof(D.Tn(e,i),j,n_i);
                    end
                end
            end
        end


        function KG = stiffnessMatrix(obj,mat,Td)
            d = obj.dimensions;
            D = obj.data;
            s.n_el = d.n_el;
            s.n_nod = d.n_nod;
            s.n_i = d.n_i;
            s.n_dof = d.n_dof;
            s.x = D.x;
            s.Tn = D.Tn;
            s.mat = mat;
            s.Tmat = D.Tmat;
            s.Td = Td;
            e = StiffnessMatrixComputer(s);
            KG = e.KG;
        end

        function [m_nod] = computeMass(obj,mat)
            d = obj.dimensions;
            D = obj.data;
            x = D.x;
            Tn = D.Tn;
            M = D.M;
            M_s = D.M_s;
            Tmat = D.Tmat;
            n = d.n;
            n_el = d.n_el;
            m_nod=zeros(n,1);
            for e=1:n_el
                x1=x(Tn(e,1),1);
                y1=x(Tn(e,1),2);
                z1=x(Tn(e,1),3);
                x2=x(Tn(e,2),1);
                y2=x(Tn(e,2),2);
                z2=x(Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);

                m_bar=mat(Tmat(e,1),2)*l*mat(Tmat(e,1),3);

                m_nod(Tn(e,1))=m_nod(Tn(e,1))+m_bar/2;
                m_nod(Tn(e,2))=m_nod(Tn(e,2))+m_bar/2;
            end
            m_nod(1)=m_nod(1)+M;
            m_nod(6)=m_nod(6)+M_s/16;
            m_nod(8)=m_nod(8)+M_s/16;
            m_nod(12)=m_nod(12)+M_s/16;
            m_nod(14)=m_nod(14)+M_s/16;
            m_nod(7)=m_nod(7)+2*M_s/16;
            m_nod(9)=m_nod(9)+2*M_s/16;
            m_nod(11)=m_nod(11)+2*M_s/16;
            m_nod(13)=m_nod(13)+2*M_s/16;
            m_nod(10)=m_nod(10)+4*M_s/16;


            if nargin == 0
                load('tmp.mat');
            end
        end


        function [Mtot] = computeTotalMass(obj,m_nod)
            n = obj.dimensions.n;
            Mtot=0;
            for i=1:n
                Mtot=Mtot+m_nod(i,1);
            end
        end

        function [ur,vr,vl] = fixDOFS(obj)
            fixNod = obj.data.fixNod;
            n_dof = obj.dimensions.n_dof;
            n_i = obj.dimensions.n_i;
            [n,m]=size(fixNod);
            ur=zeros(n,1);
            vr=zeros(n,1);
            vl=zeros(n_dof-n,1);
            for i=1:n
                I=nod2dof(fixNod(i,1),fixNod(i,2),n_i);
                ur(i)=fixNod(i,3);
                vr(i)=I;
            end

            p=1;
            for j=1:n_dof
                s=0;
                for k=1:n
                    if vr(k)==j
                        s=1;
                    end
                end
                if s==0
                    vl(p)=j;
                    p=p+1;
                end
            end
        end

        function f = computeF(obj,Fext)
            %--------------------------------------------------------------------------
            % The function takes as inputs:
            %   - Dimensions:  n_i         Number of DOFs per node
            %                  n_dof       Total number of DOFs
            %   - Fext  External nodal forces [Nforces x 3]
            %            Fext(k,1) - Node at which the force is applied
            %            Fext(k,2) - DOF (direction) at which the force acts
            %            Fext(k,3) - Force magnitude in the corresponding DOF
            %--------------------------------------------------------------------------
            % It must provide as output:
            %   - f     Global force vector [n_dof x 1]
            %            f(I) - Total external force acting on DOF I
            %--------------------------------------------------------------------------
            % Hint: Use the relation between the DOFs numbering and nodal numbering to
            % determine at which DOF in the global system each force is applied.
            n_i = obj.dimensions.n_i;
            n_dof = obj.dimensions.n_dof;
            f=zeros(n_dof,1);
            [n,m]=size(Fext);
            for i=1:n
                I=nod2dof(Fext(i,1),Fext(i,2),n_i);
                f(I)=Fext(i,5);
            end

        end

        function [u,R,eps,sig] = systemResolution(obj,KG,f,ur,vr,vl,Td,mat)
            d = obj.data;
            n_nod = obj.dimensions.n_nod;
            n_i = obj.dimensions.n_i;
            n_el = obj.dimensions.n_el;
            s.KG = KG;
            s.f = f;
            s.ur = ur;
            s.vr = vr;
            s.vl = vl;
            s.n_nod = n_nod;
            s.n_i = n_i;
            s.n_el = n_el;
            s.Td = Td;
            s.x = d.x;
            s.Tn = d.Tn;
            s.mat = mat;
            s.Tmat = d.Tmat;
            e = sysResolution(s);
            u = e.disp;
            R = e.reac;
            eps = e.eps;
            sig = e.sig;
        end

        function [sig_max,sig_min,scoef_ct,scoef_bt] = computeSafetyParameters(obj,mat,sigma)
            d = obj.data;
            x = d.x;
            Tn = d.Tn;
            Tmat = d.Tmat;
            n_el = obj.dimensions.n_el;

            sig_max=max(sigma);
            sig_min=min(sigma);
            sig_cr=zeros(n_el,1);
            for e=1:n_el
                x1=x(Tn(e,1),1);
                y1=x(Tn(e,1),2);
                z1=x(Tn(e,1),3);
                x2=x(Tn(e,2),1);
                y2=x(Tn(e,2),2);
                z2=x(Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                sig_cr(e,1)=pi^2*mat(Tmat(e,1),1)*mat(Tmat(e,1),4)/(l^2*mat(Tmat(e,1),2));
                %scoef_c(e)=mat(Tmat(e,1),5)/sig_max;
                %scoef_b(e)=sig_cr(e)/sig_min;
                scoef_c(e)=mat(Tmat(e,1),5)/abs(sigma(e));

                if sigma(e)<0
                    scoef_b(e)=sig_cr(e)/sigma(e);
                else
                    scoef_b(e)=-1000;
                end

            end
            scoef_ct=min(scoef_c);
            scoef_bt=-max(scoef_b);


        end


        function computeData(obj)
            s = obj.initData;
            obj.data = dataComputer(s);
        end

        function computeDisplacements(obj,m_nod,KG,ur,vr,vl,Td,mat,Mtot)
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
                [u,R,eps,sig] = obj.systemResolution(KG,f,ur,vr,vl,Td,mat);
                dVdt = obj.data.g+(obj.data.D/Mtot);
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = obj.computeSafetyParameters(mat,sig);

            end
            obj.displacements = u;
            obj.reactions = R;
            %postprocess(x',Tn',u,sig,sig_max,sig_min,scoef_c,scoef_b,time);
        end
    end
end