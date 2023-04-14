function [cm] = coocurrence(signal)
    dim = numel(signal)^(1/2);
    cm = reshape(signal, [dim dim]);
end

