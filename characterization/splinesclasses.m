function [class_count] = splinesclasses(x, y, normalize, tolerance)
%For each of 4 classes, computes the number of splines that belong to a class.
%   This function Computes, For each of the 4 possible classes, the number
%   of splines that belong to a class. actually, a cubic polynomial y can
%   be expressed in one of the following three forms (classes):
%   y = ax^3, y = ax^3 - px, y = ax^3 + px.
%   The form (class) number 4 refers to the case in wich the a coefficient
%   equals 0. If p > - tolerance & p < tolerance, then it is assumed that
%   p = 0.
    if nargin < 4
        tolerance = 0.0001;
    end
    csp = csapi(x, y);
    a_lt_0 = csp.coefs(:, 1) < 0;
    csp.coefs(a_lt_0, [1 3]) = csp.coefs(a_lt_0, [1 3]) * -1;
    p = csp.coefs(:, 3) - ((csp.coefs(:, 2) .^ 2) ./ (3 .* (csp.coefs(:, 1))));
    cases = zeros(size(p, 1), 1);
    cases(p < 0) = 1;
    cases(p > 0) = 2;
    cases(p > - tolerance & p < tolerance | p == 0) = 3;
    cases(isnan(p)) = 4;
    class_count = histcounts(cases, [1, 2, 3, 4, 5]);
    if normalize
        class_count = class_count / sum(class_count);
    end
    %{
    class_count = histcounts(csp.coefs,  binscount, ...
        'Normalization', 'probability');
    %}
end

