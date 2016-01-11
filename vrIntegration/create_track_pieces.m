%%%%%%%% Create Proto for Track Pieces (curve & straight) %%%%%%%%

%%%%%%%% Create Straight Track Piece %%%%%%%%
% Parameters for the straight piece
t = StraightVR;
p = TrackPieceProtoVR;
p.name = 'StraightTrackPiece';
proto_s = p.generate_VRObject_from_str(pretty_printer(t.generate_VRObject()));


%%%%%%%% Create Curved Track Piece %%%%%%%%
% Generate VRML file
file = fopen('proto_straight.wrl','w');
fprintf(file, '#VRML V2.0 utf8\n');
fprintf(file, proto_s);
fclose(file);



% Parameters for the curve
t = CurveVR;
t.delta=0.01;

% Create PROTO and print out PROTO
p = TrackPieceProtoVR ;
p.name = 'CurvedTrackPiece';
proto_s = p.generate_VRObject_from_str(pretty_printer(t.generate_VRObject()));

% Generate VRML file
file = fopen('proto_curve.wrl','w');
fprintf(file, '#VRML V2.0 utf8\n');
fprintf(file, proto_s);
fclose(file);
