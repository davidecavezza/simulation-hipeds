function [ s ] = print_value( obj, attr_name ) 
    attr = obj.(attr_name);
    typeM = getTypeMap();
    switch typeM(attr_name)
        case 'single'
            s = num2str(attr);
        case 'vector'
            s = regexprep(mat2str(attr),'\[|\]','');
        case 'string'
            s = attr;
        case 'object'
            if isempty(attr)
                s = 'NULL';
            else
                s = attr.generate_VRObject();
            end
        case 'valueArray'
            s = ['[ ', regexprep(mat2str(attr),'\[|\]',''),' ]'];
        case 'objectArray'
            s = '[ '; 
            for j = 1:length(attr)
                child_obj = attr{j};
                k = child_obj.generate_VRObject(); 
                s = [s, ' ', k, ' '];
            end
            s = [s, ' ]',];
        otherwise
            s = '';
    end
    s = [attr_name,' ', s,' '];
end

