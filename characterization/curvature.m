function [kappa, ds, S] = curvature(x, y, z)
    ds = (x(1:end -1) - x(2:end)).^2 + (y(1:end -1) - y(2:end)).^2 +...
        (z(1:end -1) - z(2:end)).^2;
    ds = sqrt(ds);
    s = cumsum([0; ds]);
    dr = [gradient(x(:), s) , gradient(y(:), s) , gradient(z(:), s)];
	T = dr ./ sqrt(sum(dr.^2, 2));
    kappa = [gradient(T(:, 1), s), gradient(T(:, 2), s), gradient(T(:, 3), s)];
    kappa = sqrt(sum(kappa.^2, 2));
    S = s(end);
end