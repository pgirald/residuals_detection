function [major] = majorax(R)
    %This function computes the the two points separated by the longest
    %possible euclidian distance in the curve R.
    dists = pdist(R);
    sq = squareform(dists);
    sq = triu(sq);
    maximum = max(max(sq));
    [i,j] = find(sq==maximum);
    i = i(1);
    j = j(1);
    %{
    [~, pos] = max(dists);
    i = (1+(((8*pos)+1)^(1/2)))/2;
    i = floor(i);
    j = pos - ((i*(i-1))/2);
    %}
    major = zeros(2, size(R, 2));
    major(1, :) = R(i, :);
    major(2, :) = R(j, :);
end

