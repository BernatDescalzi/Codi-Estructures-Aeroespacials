function [Mtot] = computeTotalMass(m_nod,n)
Mtot=0;
for i=1:n
    Mtot=Mtot+m_nod(i,1);
end


end


