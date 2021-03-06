classdef InputData < handle
    
    properties (Access = public)
        x
        Tn
        Tmat
        fixNod
    end
    
    properties (Access = private)
        
    end
    
    methods (Access = public)
        
        function obj = InputData()
            obj.nodalCoordinates();
            obj.barConnectivities();
            obj.materialConnectivities();
            obj.fixedNodes();
        end
        
    end
    
    methods (Access = private)
        


        
        function nodalCoordinates(obj)
            nC = [%   X       Y       Z
                 0.000,  0.000,  0.000; % 1
                -0.725, -0.731,  3.250; % 2
                 0.725, -0.731,  3.250; % 3
                 0.725,  0.731,  3.250; % 4
                -0.725,  0.731,  3.250; % 5
                 2.900, -1.450,  5.630; % 6
                 2.900,  0.000,  5.820; % 7
                 2.900,  1.450,  5.630; % 8
                 0.000,  1.450,  6.340; % 9
                 0.000,  0.000,  6.530; % 10
                 0.000, -1.450,  6.340; % 11
                -2.900,  1.450,  5.630; % 12
                -2.900,  0.000,  5.820; % 13
                -2.900, -1.450,  5.630; % 14
            ];
        obj.x = nC;
        end
        
        function barConnectivities(obj)
            bC = [%   A     B 
                     1     2  % 1
                     1     3  % 2
                     1     4  % 3
                     1     5  % 4
                     2     3  % 5
                     3     4  % 6 
                     4     5  % 7 
                     5     2  % 8
                     2     4  % 9
                     2    10  % 10
                     2    11  % 11
                     2    13  % 12
                     2    14  % 13
                     3     6  % 14
                     3     7  % 15
                     3    10  % 16
                     3    11  % 17
                     4     7  % 18
                     4     8  % 19
                     4     9  % 20
                     4    10  % 21
                     5     9  % 22
                     5    10  % 23
                     5    12  % 24
                     5    13  % 25
                    14    11  % 26
                    11    10  % 27
                    14    10  % 28
                    14    13  % 29
                    13    10  % 30
                    13    12  % 31
                    12    10  % 32
                    12     9  % 33
                     9    10  % 34
                     9     8  % 35
                     8     7  % 36
                    10     7  % 37
                    10     8  % 38
                    11     6  % 39
                     6     7  % 40
                    10     6  % 41
            ];
        obj.Tn = bC;
        end
        
        function materialConnectivities(obj)
            mC = [% Mat. index
                     1  % 1
                     1  % 2
                     1  % 3
                     1  % 4
                     2  % 5
                     2  % 6 
                     2  % 7 
                     2  % 8
                     2  % 9
                     1  % 10
                     1  % 11
                     1  % 12
                     1  % 13
                     1  % 14
                     1  % 15
                     1  % 16
                     1  % 17
                     1  % 18
                     1  % 19
                     1  % 20
                     1  % 21
                     1  % 22
                     1  % 23
                     1  % 24
                     1  % 25
                     2  % 26
                     2  % 27
                     2  % 28
                     2  % 29
                     2  % 30
                     2  % 31
                     2  % 32
                     2  % 33
                     2  % 34
                     2  % 35
                     2  % 36
                     2  % 37
                     2  % 38
                     2  % 39
                     2  % 40
                     2  % 41
            ];
        obj.Tmat = mC;
        end

        function fixedNodes(obj)
                fN = [
                2 1 0
                2 2 0
                2 3 0
                3 3 0
                3 2 0
                5 3 0
                ];
            obj.fixNod = fN;
        end
    end
    
end