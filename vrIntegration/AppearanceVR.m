classdef AppearanceVR < NodeVR
    % Matlab representation of Appearance object for VRML 2.0
    
    properties
        material            % class: MaterialVR
        texture             % class: TextureVR(?)
        textureTransform    % class: ??
    end
    
    properties (Constant)
        type = 'Appearance';
        valid_attributes = 'material texture textureTransform';
    end
    
    methods
        function obj=AppearanecVR(material, texture, textureTransform)
            if nargin > 0
                obj.material = material;
                obj.texture = texture;
                obj.textureTransform = textureTransform;
            end
        end
    end
    
end

