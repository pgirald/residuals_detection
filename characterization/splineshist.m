function [hists] = splineshist(x, y, binscount, feats)
%Computes histograms of splines coefficients of a normalized signal.
%   This function normalizes the given signal to then perform cubic splines
%   interpolation. Bearing in ming that any cubic polynomial can be
%   transformed in either y = ax^3, y = ax^3 - px or y = ax^3 + px, this
%   function extracts the a and p coefficients for each spline. Then, The
%   function computes an histogram with a number of "binscount" bins for
%   each of the two set of coefficients (a and p). the feats parameter is a
%   cell cell array that can contain the values 'a' and/or 'p', to specify 
%   which coefficients should be extracted.
    if nargin < 4
        feats = {};
    end

    m = max(abs(y));
    
    if(m ~= 0)
        y = y / m;
    end
    
    csp = csape(x, y, 'periodic');

    a_lt_0 = csp.coefs(:, 1) < 0;

    csp.coefs(a_lt_0, [1 3]) = csp.coefs(a_lt_0, [1 3]) * -1;

    p = csp.coefs(:, 3) - ((csp.coefs(:, 2) .^ 2) ./ (3 .* (csp.coefs(:, 1))));

    ahist = [];

    if any(strcmp(feats,'a'))

        ahist = histcounts(abs(csp.coefs(:, 1)),  binscount);

    end

    phist = [];

    if any(strcmp(feats,'p'))

        phist = histcounts(abs(p),  binscount - 1);
    
        phist(numel(phist) + 1) = sum(isnan(p));

    end

    hists = [ahist, phist];
end

