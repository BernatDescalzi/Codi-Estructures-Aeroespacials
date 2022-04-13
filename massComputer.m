classdef massComputer < handle
    
    properties (Access = public)
        m_nod
        Mtot
    end
    
    properties (Access = private)
            x
            Tn
            M
            M_s
            Tmat
            n
            n_el
            mat
    end

    
    methods (Access = public)
        
        function obj = massComputer(cParams)
            obj.init(cParams)
            obj.computeMass()
            obj.computeTotalMass()
            
        end
        
    end
    
    methods (Access = private)
        
        function init(obj,cParams)
            obj.x = cParams.x;
            obj.Tn = cParams.Tn;
            obj.M = cParams.M;
            obj.M_s = cParams.M_s;
            obj.Tmat = cParams.Tmat;
            obj.n = cParams.n;
            obj.n_el = cParams.n_el;
            obj.mat = cParams.mat;
        end
        
        function computeMass(obj)
            x = obj.x;
            Tn = obj.Tn;
            M = obj.M;
            M_s = obj.M_s;
            Tmat = obj.Tmat;
            n = obj.n;
            n_el = obj.n_el;
            mat = obj.mat;
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
            
            obj.m_nod = m_nod;
        end


        function computeTotalMass(obj)
            m_nod = obj.m_nod;
            n = obj.n;
            Mtot=0;
            for i=1:n
                Mtot=Mtot+m_nod(i,1);
            end
            obj.Mtot = Mtot;
        end
    end
    
end