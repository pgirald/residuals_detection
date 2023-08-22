function [x] = samplecurve(x, factor, normalize)
%Normalizes and samples the given curve
%   This function normalizes and splits the given points in samplescount-1 equal parts,
%   implying that the points end separated by samplescount bounds. Thus,
%   this function just take the points located at the mentioned bounds.
    if nargin < 3
        normalize = true;
    end

    m = max(abs(x));

    if normalize && m ~= 0
        x = x / m;
    end

    x = downsample(x,factor);

end

