function [ent] = radentropy(x, y, z, delta)
    %Computes the entropy using the values of a probability histogram of
    %radial distances.
    if nargin < 4
        delta = 0.01;
    end
    cx = mean(x);
    cy = mean(y);
    cz = mean(z);
    r = ((cx - x).^2 + (cy - y).^2 + (cz - z).^2).^(1/2);
    r_max = max(r);
    edges = min(r):delta:r_max;
    if edges(end) ~= r_max
        edges(end + 1) = r_max;
    end
    h = histcounts(r, edges, 'Normalization','probability');
    ha = h(h~=0);
    ent = sum(ha .* log10(ha));
end

