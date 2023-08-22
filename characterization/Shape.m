classdef Shape < Extractor
    %Class for the shape descriptors listed in featsNames property.
    
    properties(Access=private)
        selectedFeats
        entropyDelta
    end

    properties(Constant=true, Access=private)
        featsNames = ["Bending energy", "Elongation", "Entropy",...
                "Major axis length", "Total curvature"];
        featsMap = containers.Map(Shape.featsNames, ...
            {@bendingenergy, @elongation, @radentropy,...
                @majoraxlen, @totalcurvature});
    end
    
    methods
        function obj = Shape(args)
            arguments
                args.entropyDelta = 0.1;
                %Delta value for the probability histogram of radial
                %distances
                args.selectedFeats {mustBeMember(args.selectedFeats,...
                    ["Bending energy", "Elongation", "Entropy",...
                "Major axis length", "Total curvature"])} = Shape.featsNames;
                %Specified features to be computed
            end
            obj.entropyDelta = args.entropyDelta;
            obj.selectedFeats = string(args.selectedFeats);
            checkmebership(obj.selectedFeats, Shape.featsNames);
        end
        function feature = extract(obj, s)
            feature = obj.trayectorydescs(s(:,1),s(:,2),s(:,3));
        end
        function headings = getHeadings(obj)
            headings = obj.selectedFeats;
        end
        function featsCount = getFeatsCount(obj)
            featsCount = numel(obj.selectedFeats);
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function feats = trayectorydescs(obj, x, y, z)
            %This function computes the specified shape descriptores in the
            %parameter descs. The five feautres that can be computed with this
            %function are 'Bending energy', 'Elongation', 'Entropy',
            % 'Major axis length' and 'Total curvature'.
            feats = zeros(1, numel(obj.selectedFeats));
            for i = 1:numel(obj.selectedFeats)
                featFunc = Shape.featsMap(obj.selectedFeats(i));
                feat = featFunc(obj, x, y, z);
                feats(i) = feat;
            end
        end
    end
end

function [elg] = elongation(~, x, y, z)
    %For the smallest paralelipipede that fully contains the curve, the
    %elongation equals the shortest side divided by the longest one.
    dx = max(x) - min(x);
    dy = max(y) - min(y);
    dz = max(z) - min(z);
    elg = min([dx, dy, dz]) / max([dx, dy, dz]);
end
function [be] = bendingenergy(~, x, y, z)
    %Computes an aproximation for the bending energy proposed in:
    %"An Analysis Technique for Biological Shape. I*"
    [kappa, ds, S] = curvature(x, y, z);
    if all(isnan(kappa))
        be = nan;
        return;
    end
    kappa = kappa(1:end-1);
    ds = ds(~isnan(kappa));
    kappa = kappa(~isnan(kappa));
    be = sum((kappa .^ 2) .* ds, 1) / S;
end
function [ent] = radentropy(obj, x, y, z)
    %Computes the entropy using the values of a probability histogram of
    %radial distances.
    cx = mean(x);
    cy = mean(y);
    cz = mean(z);
    r = ((cx - x).^2 + (cy - y).^2 + (cz - z).^2).^(1/2);
    r_max = max(r);
    if r_max == 0
        edges = [0, 1];
    else
        edges = min(r):obj.entropyDelta:r_max;
        if edges(end) ~= r_max
            edges(end + 1) = r_max;
        end
    end
    h = histcounts(r, edges, 'Normalization','probability');
    ha = h(h~=0);
    ent = sum(ha .* log10(ha));
end
function [mal] = majoraxlen(~, x, y, z)
    %This function computes the the two points separated by the longest
    %possible euclidian distance in the curve R.
    R = [x, y, z];
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
    mal = sqrt(sum((major(1, :) - major(2, :)).^2));
end
function [tc] = totalcurvature(~, x, y, z)
    %Computes an aproximation to the total curvature for a 3D curve.
    %This metric is well known in differential geometry.
    [kappa, ds, ~] = curvature(x, y, z);
    if all(isnan(kappa))
        tc = nan;
        return;
    end
    kappa = kappa(1:end-1);
    ds = ds(~isnan(kappa));
    kappa = kappa(~isnan(kappa));
    tc = sum(kappa .* ds, 1);
end
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

