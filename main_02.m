
s = StructuralAnalysisComputer();
s.compute();

% %-------------------------------------------------------------------------%
% % ASSIGNMENT 02
% %-------------------------------------------------------------------------%
% % Date:
% % Author/s:
% %
% 
% clear;
% close all;
% 
% %% INPUT DATA 
% 
% %Cables
% D1=1.75e-3;
% E1 = 210e9;
% A1 = pi*(D1/2)^2;%Compute the correct value
% rho1 = 1550;
% Sig_y1 = 180e6; %268e6 to obtain a safety factor of 2
% I1 = pi/4*(D1/2)^4; %Compute the correct value
% 
% %Bars
% D2=8.1e-3; %15 No risk of buckling
% d2=D2-2*1.6e-3;
% E2 = 70e9; %600e9 No risk of buckling
% A2 = pi*((D2/2)^2-(d2/2)^2);%Compute the correct value
% rho2 = 2700;
% Sig_y2 = 270e6;
% I2 = pi/4*((D2/2)^4-(d2/2)^4); %Compute the correct value
% 
% 
% 
% % Problem data
% g = [0,0,-9.81]; % m/s2
% M = 125;         % kg
% S = 17.5;        % m2
% t_s = 2e-3;      % m
% rho_s = 1650;    % kg/m3
% rho_a = 1.225;   % kg/m3
% Cd = 1.75;
% V = [0,0,0];     % m/s
% dVdt = g;        % m/s2
% 
% %Surface
% M_s=rho_s*t_s*S;
% 
% 
% % time discretization
% dt = 0.01; % Modify the value
% t_end = 5 ; % Modify the value
% time = 0:dt:t_end;
% 
% sig_max = zeros(1,length(time));
% sig_min = zeros(1,length(time));
% scoef_c = zeros(1,length(time));
% scoef_b = zeros(1,length(time));
% 
% %% PREPROCESS
% 
% % Nodal displacement matrix, Connectivities matrix and Material connectivities are loaded from input_data_02.m
% %     x(a,j) = coordinate of node a in the dimension j
% %     Tn(e,a) = global nodal number associated to node a of element e
% %     Tmat(e) = Row in mat corresponding to the material associated to element e 
% 
% input_data_02;
% 
% % Fix nodes matrix creation
% %  fixNod(k,1) = node at which some DOF is prescribed
% %  fixNod(k,2) = DOF prescribed (1,2,3)
% %  fixNod(k,3) = prescribed displacement in the corresponding DOF (0 for fixed)
% fixNod = [% Node        DOF  Magnitude
%           % Write the data here...
%           2 1 0
%           2 2 0
%           2 3 0
%           3 3 0
%           3 2 0
%           5 3 0
% ];
% 
% 
% 
% % Material data
% %  mat(m,1) = Young modulus of material m
% %  mat(m,2) = Section area of material m 
% %  mat(m,3) = density of material m
% %  mat(m,4) = second area moment of material m 
% %  mat(m,5) = yield strength of material m 
% %  --more columns can be added for additional material properties--
% mat = [% Young M.   Section A.   Density    A. Moment    Yield S.
%            E1,           A1,      rho1,        I1        Sig_y1;  % Material (1)
% 		   E2,           A2,      rho2,        I2        Sig_y2   % Material (2)
% ];
% 
% 
% %% SOLVER
% 
% % Dimensions
% n_d = size(x,2);              % Number of dimensions
% n_i = n_d;                    % Number of DOFs for each node
% n = size(x,1);                % Total number of nodes
% n_dof = n_i*n;                % Total number of degrees of freedom
% n_el = size(Tn,1);            % Total number of elements
% n_nod = size(Tn,2);           % Number of nodes for each element
% n_el_dof = n_i*n_nod;         % Number of DOFs for each element 
% 
% % % Computation of the DOFs connectivities
% Td = connectDOFs(n_el,n_nod,n_i,Tn);
% % 
% % % Computation of element stiffness matrices
% Kel = computeKelBar(n_d,n_el,n_nod,n_i,x,Tn,mat,Tmat);
% % 
% % % Global matrix assembly
% KG = assemblyKG(n_el,n_nod,n_i,n_dof,Td,Kel);
% 
% % Compute nodal mass
% [m_nod] = computeMass(x,Tn,mat,Tmat,M,n,n_el,M_s);
% 
% % Compute total mass
% Mtot=computeTotalMass(m_nod,n);
% 
% [ur,vr,vl] = fixDOFS(n_dof,n_i,fixNod);
% 
% V=0;
% eps=zeros(n_el,length(time));
% sig=zeros(n_el,length(time));
% for t = 1:length(time)
% 
%     % Update Velocity
%     V = V + dVdt*dt; % Modify the expression
%     %Vx(t)=V(1,3);
%     % Compute drag
%     D = 1/2*rho_a*S*V.^2*Cd; % Modify the expression
% 
%     % External force matrix creation
%     %  Fext(k,1) = node at which the force is applied
%     %  Fext(k,2) = DOF (direction) at which the force is applied (1,2,3)
%     %  Fext(k,3) = force magnitude in the corresponding DOF
%     Fext = [%   Node        DOF  Magnitude   
%                 % Write the data here...
%             6 3 D/16+m_nod(6)*(g-dVdt)
%             8 3 D/16+m_nod(8)*(g-dVdt)
%             14 3 D/16+m_nod(14)*(g-dVdt)
%             12 3 D/16+m_nod(12)*(g-dVdt)
%             7 3 2*D/16+m_nod(7)*(g-dVdt)
%             9 3 2*D/16+m_nod(9)*(g-dVdt)
%             11 3 2*D/16+m_nod(11)*(g-dVdt)
%             13 3 2*D/16+m_nod(13)*(g-dVdt)
%             10 3 4*D/16+m_nod(10)*(g-dVdt)
%             2 3 +m_nod(2)*(g-dVdt)
%             3 3 +m_nod(3)*(g-dVdt)
%             4 3 +m_nod(4)*(g-dVdt)
%             5 3 +m_nod(5)*(g-dVdt)
%             1 3 +m_nod(1)*(g-dVdt)
%     ];
% 
%     % Global force vector assembly
%     f = computeF(n_i,n_dof,Fext);
% 
%     % System resolution
%     [u,R] = solveSys(n_i,n_dof,fixNod,KG, f, ur, vr, vl);
% 
%     % Compute strain and stresses
%     [eps,sig]=computeStrainStressBar(n_nod,n_i,n_el,u,Td,x,Tn,mat,Tmat);
%     
%     % Update acceleration
%     dVdt = g+(D/Mtot); % Modify the expression
% 
%     % Store maximum and minimum stress and safety coefficients
%     [sig_max(t),sig_min(t),scoef_c(t),scoef_b(t)] = computeSafetyParameters(x,Tn,Tmat,mat,sig,n_el);
% 
% end
% 
% %% POSTPROCESS
% 
% postprocess(x',Tn',u,sig,sig_max,sig_min,scoef_c,scoef_b,time);