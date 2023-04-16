function [y] = compressedcurve(x, y, compresstimes)
%Normalizes and compresses the given curve
%   This function compresses the given signal to then perform cubic splines
%   interpolation. Bearing in ming that any cubic polynomial can be
%   transformed in either y = ax^3, y = ax^3 - px or y = ax^3 + px, this
%   function extracts the a and p coefficients for each spline. The feats
%   parameter is a cell array that can contain the values 'a' and/or 'p',
%   to specify which coefficients should be extracted.

    y = y / max(abs(y));

    [x, y] = compress(x, y, compresstimes);
end

