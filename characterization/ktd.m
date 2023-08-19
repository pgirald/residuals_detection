function [hists] = ktd(x, y, z, bins, feats)
    feats = string(feats);
    descs =  containers.Map(["txdir", "tydir", "tzdir", "nxdir", "nydir" ,"nzdir" ,...
    "bxdir", "bydir", "bzdir"], 1:9);

    hists = zeros(1, numel(feats) * bins);
    j = 1;

    dr = [gradient(x(:)) , gradient(y(:)) , gradient(z(:))];
	ds = sum(dr.^2,2).^(0.5); % Arc length associated with each point. ||dr||.
	
	T = dr ./ ds; % Unit tangent vector.
	
	dT = [gradient(T(:,1)) , gradient(T(:,2)) , gradient(T(:,3))]; % T'(t).
	dTds = dT ./ ds;
	
	kappa = sum((dT./ds).^2,2).^(0.5);
	
	N = dTds ./ kappa; % Unit normal vector.
	
	B = cross(T,N); % Unit bi-normal vector.

    fsframe = [T,N,B];

    for i = 1:numel(feats)
        angs = acos(fsframe(:, descs(feats(i))));
        angs(angs < 0) = angs(angs < 0) + 2*pi;
        angs = round(bins * (angs / (2*pi)));
        angs(angs == bins) = 0;
        hists(j:j + bins - 1) = histcounts(angs, 0:bins);
        %hists(j:j + bins - 1) = histcounts(angs, bins);
        j = j + bins;
    end
end

