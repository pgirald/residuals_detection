function [kappa, s, ds] = curvature(x, y, z)
    dr = [gradient(x(:)) , gradient(y(:)) , gradient(z(:))];
	ds = sum(dr.^2,2).^(0.5); % Arc length associated with each point. ||dr||.
	
	T = dr ./ ds; % Unit tangent vector.

    dT = [gradient(T(:,1)) , gradient(T(:,2)) , gradient(T(:,3))]; % T'(t).

	dTds = dT ./ ds;
	
	kappa = sum((dTds).^2,2).^(0.5);

    s = sum(ds);
    
    %{
    dx = T(:, 1);
    dy = T(:, 2);
    dz = T(:, 3);
	
    theta = [dz ./ ((dx.^2+dy.^2).^(1/2)),...
        dy ./ ((dx.^2+dz.^2).^(1/2)),...
        dx ./ ((dy.^2+dz.^2).^(1/2))];

    theta = atan(theta);

    theta = theta + 2*pi;

    theta = round(theta * 4 / pi);

    d = theta(2:end,:) - theta(1:end-1,:);

    kappa = zeros(size(d, 1), size(d, 2));

    kappa(d>2) = d(d>2)-7;
    kappa(d<2) = d(d<2)+7;

    s = sum(ds);
    %}

    %{
	dT = [gradient(T(:,1)) , gradient(T(:,2)) , gradient(T(:,3))]; % T'(t).
	
	kappa = sum((dT./ds).^2,2).^(0.5);
    
    %}
end

