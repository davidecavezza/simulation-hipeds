classdef BoxVR < NodeVR
    %or < GeometryVR
    %       
    properties
        size = [1 1 1];
    end
    
    properties (Constant)
        type = 'Box'
        valid_attributes = 'size'
    end
    
    methods
        function obj=BoxVR(size)
            obj.size = size;
        end        
    end
    
end

