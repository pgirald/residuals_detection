function [class_count] = splinescoefs(x, y, tolerance)
    if nargin < 3
        tolerance = 0.0001;
    end
    csp = csape(x, y, 'periodic');
    a_lt_0 = csp.coefs(:, 1) < 0;
    csp.coefs(a_lt_0, [1 3]) = csp.coefs(a_lt_0, [1 3]) * -1;
    p = csp.coefs(:, 3) - ((csp.coefs(:, 2) .^ 2) ./ (3 .* (csp.coefs(:, 1))));
    cases = zeros(size(p, 1), 1);
    cases(p < 0) = 1;
    cases(p > 0) = 2;
    cases(p > - tolerance & p < tolerance | p == 0) = 3;
    class_count = histcounts(cases, [1, 2, 3, 4]);
    %{
    class_count = histcounts(csp.coefs,  binscount, ...
        'Normalization', 'probability');
    %}
end

