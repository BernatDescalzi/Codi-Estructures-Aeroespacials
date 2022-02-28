function [m_nod] = computeMass(x,Tn,mat,Tmat,M,n,n_el,M_s)
%--------------------------------------------------------------------------
% The function takes as inputs:
%   x       Nodal coordinates matrix (n x n_d)
%   Tn      Connectivities matrix (n_el x n_nod)
%   mat     Material data (Nmat x 5)
%   Tmat    Material connectivities vector (Nelements x 1)
%   M     PL mass
%   rho_s Density of the canvas
%   S     Surface area of the canvas
%   t_s   Thickness of the canvas
%   n     number of nodes
%   n_el  number of elements
%--------------------------------------------------------------------------
% It must provide as output:
%   m_nod Mass associated to each node (n x 1)
%--------------------------------------------------------------------------
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