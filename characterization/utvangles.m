function [angles] = utvangles(x, y, z, feats)
%Computes the angles alpha, beta and gamma of unit tangent vectors of the
%given 3d curve with respect to the x, y and z axis, respectively.
%The feats cell vector specifies the angles to be computed. For example,
%you can do feats = {'alpha', 'beta, 'gamma'}.
    if nargin < 4
        feats = {};
    end

    dr = [gradient(x(:)) , gradient(y(:)) , gradient(z(:))];

	ds = sum(dr.^2,2).^(0.5);
	
	T = dr ./ ds;

    alpha = [];

    if any(strcmp(feats,'alpha'))
        alpha = histcounts(round(acosd(T(:, 1))), 0:(360 + 1));
    end

    beta = [];

    if any(strcmp(feats,'beta'))
        beta = histcounts(round(acosd(T(:, 2))), 0:(360 + 1));
    end

    gamma = [];

    if any(strcmp(feats,'gamma'))
        gamma = histcounts(round(acosd(T(:, 3))), 0:(360 + 1));
    end

    angles = [alpha, beta, gamma];
end

