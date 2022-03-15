clear, clc;
uSaved = load('StoredDisplacements.mat');

s = StructuralAnalysisComputer();
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
% delete comments
% classes max 100 lines
% maximize cohesion 
% delete standalone functions