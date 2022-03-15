classdef StiffnessMatrixCompute < handle


    properties (Access = public)
        KG
    end

    properties (Access = private)
        n_el
        n_nod
        n_i
        n_dof
        x
        Tn
        mat
        Tmat
        Kel
        Td
    end

    methods (Access = public)
        function obj = StiffnessMatrixCompute(cParams)
            obj.init(cParams)
            obj.computeKelBar()
            obj.assemblyKG()
        end


    end

    methods (Access = private)
        function init(obj,cParams)
            obj.n_el = cParams.n_el;
            obj.n_nod = cParams.n_nod;
            obj.n_i = cParams.n_i;
            obj.n_dof = cParams.n_dof;
            obj.x = cParams.x;
            obj.Tn = cParams.Tn;
            obj.mat = cParams.mat;
            obj.Tmat = cParams.Tmat;
            obj.Td = cParams.Td;
        end

        function computeKelBar(obj)
            m = zeros(obj.n_nod*obj.n_i,obj.n_nod*obj.n_i,obj.n_el);
            for e = 1:obj.n_el
                x1=obj.x(obj.Tn(e,1),1);
                y1=obj.x(obj.Tn(e,1),2);
                z1=obj.x(obj.Tn(e,1),3);
                x2=obj.x(obj.Tn(e,2),1);
                y2=obj.x(obj.Tn(e,2),2);
                z2=obj.x(obj.Tn(e,2),3);
                l=sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                R=1/l*[x2-x1 y2-y1 z2-z1 0 0 0;
                    0 0 0 x2-x1 y2-y1 z2-z1];
                A=obj.mat(obj.Tmat(e),2);
                E=obj.mat(obj.Tmat(e),1);
                KT=(A*E/l)*[1 -1;
                    -1 1
                    ];
                K=R'*KT*R;
                for r=1:(obj.n_nod*obj.n_i)
                    for s=1:(obj.n_nod*obj.n_i)
                        m(r,s,e)=K(r,s);
                    end
                end
            end
            obj.Kel = m;
        end

        function assemblyKG(obj)
               kg = zeros(obj.n_dof,obj.n_dof);

                for e=1:obj.n_el
                    for i=1:(obj.n_nod*obj.n_i)
                        I=obj.Td(e,i);
                        for j=1:(obj.n_nod*obj.n_i)
                            J=obj.Td(e,j);
                            kg(I,J)=kg(I,J)+obj.Kel(i,j,e);
                        end
                    end
                end
            obj.KG = kg;
        end
    end
end