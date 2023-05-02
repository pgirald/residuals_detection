function [coefs] = splinescoefs(x, y, samplescount, feats)
%Extracts the coefficients of the splines of a compressed signal
%   This function compresses the given signal to then perform cubic splines
%   interpolation. Bearing in ming that any cubic polynomial can be
%   transformed in either y = ax^3, y = ax^3 - px or y = ax^3 + px, this
%   function extracts the a and p coefficients for each spline. The feats
%   parameter is a cell array that can contain the values 'a' and/or 'p',
%   to specify which coefficients should be extracted.
    if nargin < 4
        feats = {};
    end

    x = samplecurve(x, samplescount, false);
    y = samplecurve(y, samplescount);

    csp = csape(x, y, 'periodic');

    a_lt_0 = csp.coefs(:, 1) < 0;

    csp.coefs(a_lt_0, [1 3]) = csp.coefs(a_lt_0, [1 3]) * -1;

    a = [];

    if any(strcmp(feats,'a'))
        a = csp.coefs(:, 1)';
    end

    p = [];

    if any(strcmp(feats,'p'))
        p = (csp.coefs(:, 3) -...
            ((csp.coefs(:, 2) .^ 2) ./ (3 .* (csp.coefs(:, 1)))))';
        
        p(isnan(p)) = 0;
    end

    coefs = [a, p];
end