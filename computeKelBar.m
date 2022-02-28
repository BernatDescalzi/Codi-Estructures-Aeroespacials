function Kel = computeKelBar(n_d,n_el,n_nod,n_i,x,Tn,mat,Tmat)
%--------------------------------------------------------------------------
% The function takes as inputs:
%   - Dimensions:  n_d        Problem's dimensions
%                  n_el       Total number of elements
%                  n_nod      Number of nodes per element
%                  n_i        Number of DOFs per node
%   - x     Nodal coordinates matrix [n x n_d]
%            x(a,i) - Coordinates of node a in the i dimension
%   - Tn    Nodal connectivities table [n_el x n_nod]
%            Tn(e,a) - Nodal number associated to node a of element e
%   - mat   Material properties table [Nmat x NpropertiesXmat]
%            mat(m,1) - Young modulus of material m
%            mat(m,2) - Section area of material m
%   - Tmat  Material connectivities table [n_el]
%            Tmat(e) - Material index of element e
%--------------------------------------------------------------------------
% It must provide as output:
%   - Kel   Elemental stiffness matrices [n_el_dof x n_el_dof x n_el]
%            Kel(i,j,e) - Term in (i,j) position of stiffness matrix for element e
%--------------------------------------------------------------------------
 
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