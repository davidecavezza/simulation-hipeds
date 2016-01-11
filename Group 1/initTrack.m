function track = initTrack()

% p1 = StraightPiece(2);
% p2 = CurvePiece(1,1);
% p3 = CurvePiece(2,1);
% p4 = StraightPiece(4);
% p5 = CurvePiece(3,1);
% p6 = CurvePiece(4,1);
p1 = 1;
p2=2;
p3=3;


pieces = {p1,p2,p3};

track = parameterise_track(pieces);

k = 27;

plot_track(track);