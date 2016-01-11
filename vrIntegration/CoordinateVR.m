classdef CoordinateVR < NodeVR
    properties
        point % Nx3 Matrix: each row corresponds a 3D point
    end
    
    properties (Constant)
        type='Coordinate'
        valid_attributes = 'point'
    end
    
    methods
        function obj=BoxVR(size)
            obj.size = size;
        end
        
        function s=print_points(this)
            s=regexprep(mat2str(this.point),';',', ');
            s=regexprep(s,'[','[ ');
            s=regexprep(s,']',' ]');
            
        end
        
        function str=generate_VRObject(this)
            points = this.print_points;
            s = ['Coordinate { point ',points,' }'];  
            str = s;
        end
    end
    
end

