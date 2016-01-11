classdef MaterialVR < NodeVR
    %STRAIGHTPIECE Straight track piece
    %   Detailed explanation goes here
    properties
        ambientIntensity = 0
        diffuseColor = [0 0 0]
        emissiveColor = [1 1 1]
        shininess = 0
        specularColor = [0 0 0]
        transparency = 0
    end
    
    properties (Constant)
        type = 'Material';
        valid_attributes = 'ambientIntensity diffuseColor emissiveColor shininess specularColor transparency';
    end
    
    methods
    end
    
end

