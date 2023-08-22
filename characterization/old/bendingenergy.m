function [be] = bendingenergy(x, y, z)
    %Computes an aproximation for the bending energy proposed in:
    %"An Analysis Technique for Biological Shape. I*"
    [kappa, ds, S] = curvature(x, y, z);
    if all(isnan(kappa))
        be = nan;
        return;
    end
    kappa = kappa(1:end-1);
    ds = ds(~isnan(kappa));
    kappa = kappa(~isnan(kappa));
    be = sum((kappa .^ 2) .* ds, 1) / S;
end

