classdef StructuralAnalysisComputer < handle

    properties (Access = public)
        displacements
        reactions
    end

    properties (Access = private)
        cable        
        bar
    end

    methods (Access = public)

        function obj = StructuralAnalysisComputer()

        end

        function compute(obj)
            obj.computeValues();
        end
    end

    methods (Access = private)

        %         function comptueStiffnessMatrix(obj)
        %             s = StiffnessMatrixCompute();
        %             s.compute();
        %             K = s.K;
        %         end
        function createCable(obj)
            s.type  = 'Cable'; % s is a structure
            s.D     = 1.75e-3;
            s.E     = 210e9;
            s.rho   = 1550;
            s.sigY = 180e6;
            c = element.create(s);
            obj.cable = c;
        end

        function createBar(obj)
            s.type = 'Bar';
            s.D  =8.1e-3;
            s.E  = 70e9;
            s.rho = 2700;
            s.sigY = 270e6;
            e = element.create(s);
            obj.bar = e;
        end      
        

        function mat = createMaterial(obj)
            c = obj.cable;
            b = obj.bar;
            mat = [c.E,           c.A,      c.rho,        c.I,        c.Sig_y;
                  b.E,           b.A,      b.rho,        b.I,        b.Sig_y     ];
        end

        function computeValues(obj)
            %             obj.computeInitalValues();
            %             obj.computeStiffnessMatrix();
            %input_data_02;
            inputdata = inputData();
            x = inputdata.x;
            Tn = inputdata.Tn;
            Tmat = inputdata.Tmat;

            obj.createBar();
            obj.createCable();
            Data = obj.introData();
            mat = obj.createMaterial();
            [n_d,n_i,n,n_dof,n_el,n_nod] = obj.dimensions(x,Tn,Tmat);



            dVdt = Data.g;
            M_s = Data.M_s;


            % time discretization
            dt = 0.01; 
            t_end = 5 ;
            time = 0:dt:t_end;

            sig_max = zeros(1,length(time));
            sig_min = zeros(1,length(time));
            scoef_c = zeros(1,length(time));
            scoef_b = zeros(1,length(time));

            %% PREPROCESS


            fixNod = [
                2 1 0
                2 2 0
                2 3 0
                3 3 0
                3 2 0
                5 3 0
                ];




            Td = obj.connectDOFs(n_el,n_nod,n_i,Tn);
            KG = obj.stiffnessMatrix(n_el,n_nod,n_i,n_dof,x,Tn,mat,Tmat,Td);
            [m_nod] = obj.computeMass(x,Tn,mat,Tmat,Data.M,n,n_el,M_s);
            Mtot = obj.computeTotalMass(m_nod,n);
            [ur,vr,vl] = obj.fixDOFS(n_dof,n_i,fixNod);

            V=0;

            for t = 1:length(time)

                % Update Velocity
                V = V + dVdt*dt; % Modify the expression
                %Vx(t)=V(1,3);
                % Compute drag
                Data.computeDrag(V);
                % External force matrix creation
                %  Fext(k,1) = node at which the force is applied
                %  Fext(k,2) = DOF (direction) at which the force is applied (1,2,3)
                %  Fext(k,3) = force magnitude in the corresponding DOF
                Fext = obj.computeFext(m_nod,Data,dVdt);
                % Global force vector assembly
                f = computeF(n_i,n_dof,Fext);

                % System resolution
                [u,R] = solveSys(n_i,n_dof,fixNod,KG, f, ur, vr, vl);

                % Compute strain and stresses
                [eps,sig]=computeStrainStressBar(n_nod,n_i,n_el,u,Td,x,Tn,mat,Tmat);

                % Update acceleration
                dVdt = Data.g+(Data.D/Mtot); % Modify the expression

                % Store maximum and minimum stress and safety coefficients
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = computeSafetyParameters(x,Tn,Tmat,mat,sig,n_el);

            end
            obj.displacements = u;
            obj.reactions = R;


            %% POSTPROCESS

            %postprocess(x',Tn',u,sig,sig_max,sig_min,scoef_c,scoef_b,time);



        end

        function Fext = computeFext(obj,m_nod,Data,dVdt)
            D = Data.D;
            g = Data.g;
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

    end

    methods (Access = private, Static)


        function d = introData()
            s.g = [0,0,-9.81]; % m/s2
            s.M = 125;         % kg
            s.S = 17.5;        % m2
            s.t_s = 2e-3;      % m
            s.rho_s = 1650;    % kg/m3
            s.rho_a = 1.225;   % kg/m3
            s.Cd = 1.75;
            d = data(s);
        end

        function [n_d,n_i,n,n_dof,n_el,n_nod] = dimensions(x,Tn,Tmat)
            s.x = x;
            s.Tn = Tn;
            s.Tmat = Tmat;
            d = dimensionsCalculator(s);
            n_d = d.n_d;             
            n_i = d.n_i;
            n = d.n;
            n_dof = d.n_dof;
            n_el = d.n_el;
            n_nod = d.n_nod;
        end

        function Td = connectDOFs(n_el,n_nod,n_i,Tn)
            Td = zeros(n_el,n_nod*n_i);
            for e=1:n_el
                for i=1:n_nod
                    for j=1:n_i
                        I=nod2dof(i,j,n_i);
                        Td(e,I)=nod2dof(Tn(e,i),j,n_i);
                    end
                end
            end
        end

        function KG = stiffnessMatrix(n_el,n_nod,n_i,n_dof,x,Tn,mat,Tmat,Td)
            s.n_el = n_el;
            s.n_nod = n_nod;
            s.n_i = n_i;
            s.n_dof = n_dof;
            s.x = x;
            s.Tn = Tn;
            s.mat = mat;
            s.Tmat = Tmat;
            s.Td = Td;
            e = StiffnessMatrixCompute(s);
            KG = e.KG;
        end



        function [m_nod] = computeMass(x,Tn,mat,Tmat,M,n,n_el,M_s)
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

        function [Mtot] = computeTotalMass(m_nod,n)
            Mtot=0;
            for i=1:n
                Mtot=Mtot+m_nod(i,1);
            end
        end

        function [ur,vr,vl] = fixDOFS(n_dof,n_i,fixNod)
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
    end
end