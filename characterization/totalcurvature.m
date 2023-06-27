function [tc] = totalcurvature(x, y, z)
    %Computes an aproximation to the total curvature for a 3D curve.
    %This metric is well known in differential geometry.
    [kappa, ~, ds] = curvature(x, y, z);
    tc = sum(kappa .* ds, 1);
end

