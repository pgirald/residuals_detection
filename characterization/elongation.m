function [elg] = elongation(x, y, z)
    %For the smallest paralelipipede that fully contains the curve, the
    %elongation equals the shortest side divided by the longest one.
    dx = max(x) - min(x);
    dy = max(y) - min(y);
    dz = max(z) - min(z);
    elg = min([dx, dy, dz]) / max([dx, dy, dz]);
end

