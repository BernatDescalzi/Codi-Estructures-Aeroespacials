classdef StructuralAnalysisComputer < handle

    properties (Access = public)
        displacements
        reactions
    end

    properties (Access = private)

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



        function computeValues(obj)
            %             obj.computeInitalValues();
            %             obj.computeStiffnessMatrix();

            s.type  = 'Cable';
            s.D     = 1.75e-3;
            s.E     = 210e9;
            s.rho   = 1550;
            s.sigY = 180e6;

            Cable = element.create(s);


            Bar = element();
            Bar.D  =8.1e-3;
            Bar.E  = 70e9;
            Bar.rho = 2700;
            Bar.sigY = 270e6;
            Bar = Bar.computeData("Bar");


            % Problem data
            g = [0,0,-9.81]; % m/s2
            M = 125;         % kg
            S = 17.5;        % m2
            t_s = 2e-3;      % m
            rho_s = 1650;    % kg/m3
            rho_a = 1.225;   % kg/m3
            Cd = 1.75;
            dVdt = g;        % m/s2

            %Surface
            M_s=rho_s*t_s*S;


            % time discretization
            dt = 0.01; % Modify the value
            t_end = 5 ; % Modify the value
            time = 0:dt:t_end;

            sig_max = zeros(1,length(time));
            sig_min = zeros(1,length(time));
            scoef_c = zeros(1,length(time));
            scoef_b = zeros(1,length(time));

            %% PREPROCESS

            % Nodal displacement matrix, Connectivities matrix and Material connectivities are loaded from input_data_02.m
            %     x(a,j) = coordinate of node a in the dimension j
            %     Tn(e,a) = global nodal number associated to node a of element e
            %     Tmat(e) = Row in mat corresponding to the material associated to element e

            input_data_02;

            % Fix nodes matrix creation
            %  fixNod(k,1) = node at which some DOF is prescribed
            %  fixNod(k,2) = DOF prescribed (1,2,3)
            %  fixNod(k,3) = prescribed displacement in the corresponding DOF (0 for fixed)
            fixNod = [% Node        DOF  Magnitude
                % Write the data here...
                2 1 0
                2 2 0
                2 3 0
                3 3 0
                3 2 0
                5 3 0
                ];

            mat = [% Young M.   Section A.   Density    A. Moment    Yield S.
                Cable.E,           Cable.A,      Cable.rho,        Cable.I        Cable.Sig_y;  % Material (1)
      		   Bar.E,           Bar.A,      Bar.rho,        Bar.I,        Bar.Sig_y   % Material (2)
               ];


            %% SOLVER

            % Dimensions
            n_d = size(x,2);              % Number of dimensions
            n_i = n_d;                    % Number of DOFs for each node
            n = size(x,1);                % Total number of nodes
            n_dof = n_i*n;                % Total number of degrees of freedom
            n_el = size(Tn,1);            % Total number of elements
            n_nod = size(Tn,2);           % Number of nodes for each element

            % % Computation of the DOFs connectivities
            Td = connectDOFs(n_el,n_nod,n_i,Tn);
            %Td = obj.connectDOFs(n_el,n_nod,n_i,Tn);
            %
            % % Computation of element stiffness matrices
            % Kel = computeKelBar(n_d,n_el,n_nod,n_i,x,Tn,mat,Tmat);
            Kel = obj.computeKelBar(n_d,n_el,n_nod,n_i,x,Tn,mat,Tmat);


            % % Global matrix assembly
            KG = assemblyKG(n_el,n_nod,n_i,n_dof,Td,Kel);

            % Compute nodal mass
            [m_nod] = computeMass(x,Tn,mat,Tmat,M,n,n_el,M_s);

            % Compute total mass
            Mtot=computeTotalMass(m_nod,n);

            [ur,vr,vl] = fixDOFS(n_dof,n_i,fixNod);

            V=0;
            eps=zeros(n_el,length(time));
            sig=zeros(n_el,length(time));
            for t = 1:length(time)

                % Update Velocity
                V = V + dVdt*dt; % Modify the expression
                %Vx(t)=V(1,3);
                % Compute drag
                D = 1/2*rho_a*S*V.^2*Cd; % Modify the expression

                % External force matrix creation
                %  Fext(k,1) = node at which the force is applied
                %  Fext(k,2) = DOF (direction) at which the force is applied (1,2,3)
                %  Fext(k,3) = force magnitude in the corresponding DOF
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

                % Global force vector assembly
                f = computeF(n_i,n_dof,Fext);

                % System resolution
                [u,R] = solveSys(n_i,n_dof,fixNod,KG, f, ur, vr, vl);

                % Compute strain and stresses
                [eps,sig]=computeStrainStressBar(n_nod,n_i,n_el,u,Td,x,Tn,mat,Tmat);

                % Update acceleration
                dVdt = g+(D/Mtot); % Modify the expression

                % Store maximum and minimum stress and safety coefficients
                [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = computeSafetyParameters(x,Tn,Tmat,mat,sig,n_el);

            end
            obj.displacements = u;
            obj.reactions = R;


            %% POSTPROCESS

            %postprocess(x',Tn',u,sig,sig_max,sig_min,scoef_c,scoef_b,time);



        end
    end

    methods (Access = private, Static)

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

        function Kel = computeKelBar(n_d,n_el,n_nod,n_i,x,Tn,mat,Tmat)
            Kel = zeros(n_nod*n_i,n_nod*n_i,n_el);
            for e = 1:n_el
                x1=x(Tn(e,1),1);
                y1=x(Tn(e,1),2);
                z1=x(Tn(e,1),3);
                x2=x(Tn(e,2),1);
                y2=x(Tn(e,2),2);
                z2=x(Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                R=1/l*[x2-x1 y2-y1 z2-z1 0 0 0;
                    0 0 0 x2-x1 y2-y1 z2-z1];
                A=mat(Tmat(e),2);
                E=mat(Tmat(e),1);
                KT=(A*E/l)*[1 -1;
                    -1 1
                    ];
                K=R'*KT*R;
                for r=1:(n_nod*n_i)
                    for s=1:(n_nod*n_i)
                        Kel(r,s,e)=K(r,s);
                    end
                end
            end
        end
    end
end