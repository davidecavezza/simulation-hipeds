classdef IndexedFaceSetVR < NodeVR
    %or < GeometryVR
    %       
    properties
        solid = 'FALSE'
        convex = 'FALSE'
        coord
        coordIndex
    end
    
    properties (Constant)
        type='IndexedFaceSet';
        valid_attributes = 'solid convex coord coordIndex';
    end
    
    methods        
    end
    
end

