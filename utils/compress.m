function [x, y] = compress(x, y, times)
%Executes drophalf() function "times" times
%   This function compresses a given signal by Executing drophalf() function
%   "times" times
    takeupper = true;
    for i = 1:times
        if ~bitand(numel(x), 1)
            takeupper = ~takeupper;
        end
        [x, y] = drophalf(x, y, takeupper);
    end
end

