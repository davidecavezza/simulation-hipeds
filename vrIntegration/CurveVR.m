classdef CurveVR < NodeVR

    properties
        % Curve configuration
        r_in_t          = 12  * (1/12)
        r_out_t         = 36  * (1/12)
        line_thickness  = 1   * (1/12)
        track_height    = 1/4 * (1/12)
        line_height     = 1/8 * (1/12) % should be 1/8 but causes glitch
        
        % angles
        theta_start     = -pi/2
        theta_end       = 0;
        delta           = 0.01 
        
        % Transformation
        translation     = [0 0 0]
        rotation        = [0 0 0 0]
    end
    
    properties (Constant)
    end
    
    methods
        function obj=toVRNode(this)
            % Generate points 
            y0 = 0;
            y1 = this.track_height;
            y2 = y1 + this.line_height;
            curves{1} = get_curve(this.r_in_t,this.r_out_t, ... 
                                    this.theta_start,this.theta_end, ...
                                    this.delta, y0, y1);
            middle = (this.r_in_t + this.r_out_t) / 2;
            r_in_l = middle - this.line_thickness / 2;
            r_out_l = middle + this.line_thickness / 2;
            curves{2} = get_curve(r_in_l,r_out_l, ...
                                    this.theta_start,this.theta_end, ...
                                    this.delta, y1, y2);
            colors{1} = [0.9,0.9,0.9];
            colors{2} = [0.1,0.1,0.1];

            % Generate matlab representation for the curve piece
            t = TransformVR();
            t.name = 'CurveTrackPiece';
            t.translation = this.translation;
            t.rotation = this.rotation;
            
            for i=1:2
                curve = curves{i};

                %Create track via IndexedFaceSet
                b = IndexedFaceSetVR();
                points = curve.coordPoints;
                coordIndex = curve.coordIndex;
                coord = CoordinateVR();
                coord.point = points;
                b.coord = coord;
                b.coordIndex = coordIndex;

                % Create appearance for the track
                a = AppearanceVR;
                m = MaterialVR; 
                m.emissiveColor = colors{i};
                a.material = m;

                % Create Shape
                s = ShapeVR(a,b);
                % Append to transform object
                t.appendChild(s);
            end
            obj = t;
        end
        function s=generate_VRObject(this)
            s=this.toVRNode().generate_VRObject();
        end
    end
    
end

