function [u,R] = solveSys(n_i,n_dof,fixNod,KG,f, ur, vr, vl)
%--------------------------------------------------------------------------
% The function takes as inputs:
%   - Dimensions:  n_i      Number of DOFs per node
%                  n_dof           Total number of DOFs
%   - fixNod  Prescribed displacements data [Npresc x 3]
%              fixNod(k,1) - Node at which the some DOF is prescribed
%              fixNod(k,2) - DOF (direction) at which the prescription is applied
%              fixNod(k,3) - Prescribed displacement magnitude in the corresponding DOF
%   - KG      Global stiffness matrix [n_dof x n_dof]
%              KG(I,J) - Term in (I,J) position of global stiffness matrix
%   - f       Global force vector [n_dof x 1]
%              f(I) - Total external force acting on DOF I
%--------------------------------------------------------------------------
% It must provide as output:
%   - u       Global displacement vector [n_dof x 1]
%              u(I) - Total displacement on global DOF I
%   - R       Global reactions vector [n_dof x 1]
%              R(I) - Total reaction acting on global DOF I
%--------------------------------------------------------------------------
% Hint: Use the relation between the DOFs numbering and nodal numbering to
% determine at which DOF in the global system each displacement is prescribed.

KLL=KG(vl,vl);
KLR=KG(vl,vr);
KRL=KG(vr,vl);
KRR=KG(vr,vr);

FLext=f(vl,1);
FRext=f(vr,1);

ul=KLL\(FLext-KLR*ur);
R=KRR*ur+KRL*ul-FRext;

u(vl,1)=ul;
u(vr,1)=ur;
 
end