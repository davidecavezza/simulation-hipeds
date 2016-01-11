function [ curves ] = get_curve_pts(r_in, r_out, theta_start, theta_end, delta, y0, y1)

% bottom inner curve, bottom outer curve, top inner curve, top outer curve
curves = cell(1,4);
theta = theta_start:delta:theta_end;  

if ismember(theta_start, theta) == 0
    theta = [theta_start, theta];
end

if ismember(theta_end, theta) == 0 
    theta = [theta, theta_end];
end

% Generate coordinate points in the curve
L = length(theta);

% inner curve
x_in = r_in * cos(theta);
z_in = r_in * sin(theta);

% outer curve
x_out = r_out * cos(theta);
z_out = r_out * sin(theta);

curves{1} = [x_in; zeros(1,L)+y0; z_in]';
curves{2} = [x_out; zeros(1,L)+y0; z_out]';
curves{3} = [x_in; zeros(1,L)+y1; z_in]';
curves{4} = [x_out; zeros(1,L)+y1; z_out]';

coordPoints = zeros(4*L,3);
for i = 1:4
    c = curves{i};
    coordPoints((i-1)*L+1:i*L,:) = c;
end

curves = coordPoints;

end

