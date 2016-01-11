classdef TrackPieceProtoVR < handle
    % Wrapper for TrackPieces to produce PROTO
    properties
        name = ''
        children = {}
    end
    
    properties
    end
    
    methods        
        function [pre, post]=get_skeleton(t)
            s = ['PROTO ' t.name ' [' '\n'];
            s = [s, '\t' 'exposedField SFVec3f trackTranslation 0 0 0' '\n'];
            s = [s, '\t' 'exposedField SFRotation trackRotation 0 0 0 0' '\n'];
            s = [s, '\t' 'exposedField SFVec3f trackScale 1 1 1 ' '\n'];
            s = [s, '\t' ']\n{\n'];
            s = [s, 'Transform {' '\n'];
            s = [s, '\t' 'translation IS trackTranslation' '\n'];
            s = [s, '\t' 'rotation IS trackRotation' '\n'];
            s = [s, '\t' 'scale IS trackScale ' '\n'];
            s = [s, '\t' 'children [' '\n'];
            pre = s;
            post = '\t]\n}\n}\n';
        end
        
        function str=generate_VRObject_from_str(t, child_str)
            [pre, post] = t.get_skeleton();
            str = [pre, child_str, post]; 
        end
        
        function str=generate_VRObject(t)
            [pre, post] = t.get_skeleton();
            child_str = '';
            for i = 1:length(t.children)
               child_str = [child_str, t.children{i}.generate_VRObject()];
            end
            str = [pre, child_str, post]; 

        end
    end
    
end

