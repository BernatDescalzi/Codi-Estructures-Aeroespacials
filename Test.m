%uSaved = load('StoredDisplacements');

s = StructuralAnalysisComputer();
s.compute();
u = s.displacements;

error = norm(u-uSaved);

if error < 1e-15
 disp('Test passed')
else
    disp('Test failed')
end



