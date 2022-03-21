clear, clc;
uSaved = load('StoredDisplacements.mat');


sC.D     = 1.75e-3;
sC.E     = 210e9;
sC.rho   = 1550;
sC.sigY = 180e6;
s.cableSettings = sC;


s = StructuralAnalysisComputer(s);
s.compute();
u = s.displacements;
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