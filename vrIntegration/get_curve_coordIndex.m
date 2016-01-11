function [ coordIndex ] = get_curve_coordIndex(coordPoints)
[L, ~] = size(coordPoints);
L = L/4;

coordIndex = [ ...
               0:L-1, 2*L-1:-1:L,0,-1, ... % Bottom Curve
               2*L:3*L-1, 4*L-1:-1:3*L, 2*L, -1, ... %Top Curve
               0,L,3*L,2*L,0,-1,L-1,2*L-1,4*L-1, ... % Start side
               3*L-1,L-1,-1, ... % End side
             ];
         
% Define inner side. render by many squares
for i = 0:L-2
    coordIndex = [coordIndex, i, i+1, 2*L+i+1, 2*L+i,i,-1];
end

% Define outer side. render by many squares
for i = 0:L-2
    coordIndex = [coordIndex, L+i, L+i+1, 3*L+i+1, 3*L+i,L+i,-1];
end

end

