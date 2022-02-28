function [sig_max,sig_min,scoef_ct,scoef_bt] = computeSafetyParameters(x,Tn,Tmat,mat,sigma,n_el)
%--------------------------------------------------------------------------
% The function takes as inputs:
%   x       Nodal coordinates matrix (n x n_d)
%   Tn      Connectivities matrix (n_el x n_nod)
%   Fext    Matrix with external forces data (Nforces x 3)
%   fixNod  Matrix with fixed displacement data (Nfixed x 3)
%   Tmat    Material connectivities vector (n_el x 1)
%   mat     Material data (Nmat x 5)
%--------------------------------------------------------------------------
% It must provide as output:
%   sig_max    Maximum stress value (1 x 1)
%   sig_min    Minimum stress value (1 x 1)
%   scoef_c    Safety coefficient to tension (1 x 1)
%   scoef_b    Safety coefficient to compression (1 x 1)
%--------------------------------------------------------------------------
% Hint: Compute the critial stress for buckling to determine the safety
% coeficients
sig_max=max(sigma);
sig_min=min(sigma);
sig_cr=zeros(n_el,1);
for e=1:n_el
     x1=x(Tn(e,1),1);
    y1=x(Tn(e,1),2);
    z1=x(Tn(e,1),3);
    x2=x(Tn(e,2),1);
    y2=x(Tn(e,2),2);
    z2=x(Tn(e,2),3);
    l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
sig_cr(e,1)=pi^2*mat(Tmat(e,1),1)*mat(Tmat(e,1),4)/(l^2*mat(Tmat(e,1),2));
%scoef_c(e)=mat(Tmat(e,1),5)/sig_max;
%scoef_b(e)=sig_cr(e)/sig_min;
scoef_c(e)=mat(Tmat(e,1),5)/abs(sigma(e));

if sigma(e)<0
scoef_b(e)=sig_cr(e)/sigma(e);
else
scoef_b(e)=-1000;
end

end
scoef_ct=min(scoef_c);
scoef_bt=-max(scoef_b);




 



end