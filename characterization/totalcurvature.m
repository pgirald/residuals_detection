function [tc] = totalcurvature(x, y, z)
    %Computes an aproximation to the total curvature for a 3D curve.
    %This metric is well known in differential geometry.
    [kappa, ds, ~] = curvature(x, y, z);
    if all(isnan(kappa))
        tc = nan;
        return;
    end
    kappa = kappa(1:end-1);
    ds = ds(~isnan(kappa));
    kappa = kappa(~isnan(kappa));
    tc = sum(kappa .* ds, 1);
end

