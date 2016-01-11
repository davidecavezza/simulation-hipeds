classdef TransformVR < NodeVR
    %STRAIGHTPIECE Straight track piece
    %   Detailed explanation goes here
    properties
        translation = [0 0 0];
        center = [0 0 0];
        rotation = [0 0 0 0]; %[v a], v = vector, a = clockwise rotation around v
        scale = [1 1 1]
        % scaleOrientation = [0 0 0 1]; % this was screwing us so commented        
        children = {};
    end
    
    properties (Constant)
        type = 'Transform';
        valid_attributes = 'translation center rotation scale scaleOrientation children';
    end
    
    methods
        function obj=TransformVR(translation)
            if  nargin > 0
                obj.translation = translation;
            end
        end
        
        function appendChild(transformVR, child)
            L = length(transformVR.children);
            transformVR.children{L+1} = child;
        end
        
    end
    
end

