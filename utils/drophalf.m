function [x, y] = drophalf(x, y, takeupper)
%Drops intermediate points
%   This function drops, for example, the even points of a signal, thus
%   compressing it.
    if nargin < 3
        takeupper = true;
    end

    if(numel(x) ~= numel(y))
        error("The domain has not the same number of values than the" + ...
            "range")
    end

    if bitand(numel(x), 1)
        x = x(2 : 2 : end - 1);
        y = y(2 : 2 : end - 1);
        return;
    end

    if takeupper
        x = x(3 : 2 : end - 1);
        y = y(3 : 2 : end - 1);
        return;
    end


        x = x(2 : 2 : end - 2);
        y = y(2 : 2 : end - 2);
end

