classdef ShapeVR < NodeVR
    %STRAIGHTPIECE Straight track piece
    %   Detailed explanation goes here
    properties
        appearance
        geometry
    end
    
    properties (Constant)
        type = 'Shape';
        valid_attributes = 'appearance geometry';
    end
    
    methods
        function obj=ShapeVR(appearance, geometry)
            if nargin > 0
                obj.appearance = appearance;
                obj.geometry = geometry;
            end
        end
    end
    

    
end

