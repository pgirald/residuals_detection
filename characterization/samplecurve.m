function [x] = samplecurve(x, samplescount, normalize)
%Normalizes and samples the given curve
%   This function normalizes and splits the given points in samplescount-1 equal parts,
%   implying that the points end separated by samplescount bounds. Thus,
%   this function just take the points located at the mentioned bounds.
    if nargin < 3
        normalize = true;
    end

    if samplescount < 2
        error("You have to exract at least two samples");
    end

    m = max(abs(x));

    if normalize && m ~= 0
        x = x / m;
    end

    if samplescount >= numel(x)
        return
    end

    pos = 0:numel(x) / (samplescount - 1):numel(x);

    pos(1) = 1;

    pos = round(pos);

    x = x(pos);
end

