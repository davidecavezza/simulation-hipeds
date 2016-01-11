classdef (Abstract) NodeVR < handle
    %Subclasses hanld object for ability to use oop-reference 
    properties
        name = ''
    end
    
    properties
    end
    
    methods
        function bool=isValidAttribute(this, field_name)
            bool = ~isempty(strfind(this.valid_attributes, field_name));
        end
        
        function str=generate_VRObject(t)
            def_s = ''; % Optionally put definition
            if ~strcmp(t.name,'')  
                def_s = [def_s, 'DEF ', t.name, ' '];
            end
            attr_s = '';
            fields = fieldnames(t);
            for i = 1:length(fields)
                if isValidAttribute(t, fields{i})
                    attr_s = [attr_s, print_value(t, fields{i})];
                end
            end
            str = [def_s, t.type, ' { ',attr_s,'}'];
        end
    end
    
end

