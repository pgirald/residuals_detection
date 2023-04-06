function [coefs] = splinescoefs(x, y, binscount)
    csp = csape(x, y, 'periodic');
    coefs = histcounts(csp.coefs,  binscount, ...
        'Normalization', 'probability');
end

