clear, clc;
uSaved = load('StoredDisplacements.mat');


sC.D     = 1.75e-3;
sC.E     = 210e9;
sC.rho   = 1550;
sC.sigY = 180e6;
s.cableSettings = sC;

sB.D  =8.1e-3;
sB.E  = 70e9;
sB.rho = 2700;
sB.sigY = 270e6;
s.barSettings = sB;

sD.g = [0,0,-9.81]; % m/s2
sD.M = 125;         % kg
sD.S = 17.5;        % m2
sD.t_s = 2e-3;      % m
sD.rho_s = 1650;    % kg/m3
sD.rho_a = 1.225;   % kg/m3
sD.Cd = 1.75;
sD.dt = 0.01;
sD.t_end = 5;
s.data = sD;



e = StructuralAnalysisComputer(s);
e.compute();
u = e.displacements;
u_norm=norm(u);
uSaved_norm= norm(uSaved.u);
error = u_norm-uSaved_norm;

if error < 1e-15
 disp('Test passed')
else
    disp('Test failed')
end



% atomic functions
% min number of input/output
% delete comments
% classes max 100 lines
% maximize cohesion 
% delete standalone functions


%ToDo
% delete Td, ur,vr,vl form Structural...use DOfcomputer
% 
