classdef StraightVR < NodeVR
    %STRAIGHTPIECE Straight track piece
    %   each dimension is measured in inches but it will be scaled in ft in
    %   the end
    properties  
        track_x = 24  * (1/12);  
        track_z = 48  * (1/12);  
        line_x  = 1   * (1/12); 
        track_y = 1/4 * (1/12);
        line_y  = 1/8 * (1/12);
        
        translation     = [0 0 0]
        rotation        = [0 0 0 0]
    end
    
    properties (Constant)
    end
    
    methods
        function obj=toVRNode(this)
            track_size = [this.track_x this.track_y this.track_z];
            line_size = [this.line_x, this.line_y, this.track_z];

            % Generate matlab representation for the curve piece
            t = TransformVR();
            t.name = 'StraightTrackPiece';
            t.translation = this.translation;  
            t.rotation = this.rotation;

            % Create white background piece
            t_piece = TransformVR();
            t_piece.name = 'StraightPiece';
            t_piece.translation = [0 this.track_y/2 0];
            a = AppearanceVR;
            m = MaterialVR; 
            m.emissiveColor = [0.9 0.9 0.9];
            a.material = m;
            b = BoxVR(track_size);
            s = ShapeVR(a,b);
            t_piece.appendChild(s);
            t.appendChild(t_piece);

            % Create white background piece
            translation = [0, this.track_y+this.track_y/2, 0];
            t_line = TransformVR(translation);
            t_line.name = 'StraightLine';
            a = AppearanceVR;
            m = MaterialVR; 
            m.emissiveColor = [0.1 0.1 0.1];
            a.material = m;
            b = BoxVR(line_size);
            s = ShapeVR(a,b);
            t_line.appendChild(s);
            t.appendChild(t_line);
            obj=t;
        end
        function s=generate_VRObject(this)
            s=this.toVRNode().generate_VRObject();
        end
    end
    
end

