function [be] = bendingenergy2(x, y)
%BENDINGENERGY2 Summary of this function goes here
%   Detailed explanation goes here
    dy = y(2:end)-y(1:end-1);
    dx = x(2:end)-x(1:end-1);
    theta = atan(dy./dx);
    cc = theta;
    cc(theta < 0) = theta(theta < 0) + 2*pi;
    cc = round(4 * cc / pi);
    cc(cc == 8) = 0;
    d = mod(cc(2:end)-cc(1:end-1), 4);
    be = sum(d.^2);
end

