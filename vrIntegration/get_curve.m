function [ curve_obj ] = get_curve( r_in,r_out,theta_start,theta_end,delta,y0,y1 )

coordPoints = get_curve_pts(r_in, r_out, theta_start, theta_end, delta, y0, y1);

curve_obj.coordPoints = coordPoints;
curve_obj.coordIndex = get_curve_coordIndex(coordPoints);

end

