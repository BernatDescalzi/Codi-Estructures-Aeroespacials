function f = computeF(n_i,n_dof,Fext)
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

f=zeros(n_dof,1);
[n,m]=size(Fext);
    for i=1:n
        I=nod2dof(Fext(i,1),Fext(i,2),n_i);
        f(I)=Fext(i,5);
    end

end