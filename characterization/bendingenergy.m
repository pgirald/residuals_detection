function [be] = bendingenergy(x, y, z)
    %Computes an aproximation for the bending energy proposed in:
    %"An Analysis Technique for Biological Shape. I*"
    [kappa, s, ds] = curvature(x, y, z);
    be = sum((kappa .^ 2) .* ds, 1) / s;
end

