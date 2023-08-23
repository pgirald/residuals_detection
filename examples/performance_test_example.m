clear;
clc;
close all;

%--------Programm configuration start

ftnames = {'cspclasses',...
    'fsstats','sampledsignal'};

zonesnames = {'low','normal','high','critical'};
varsnames = [zonesnames, {'maskind', 'imgs'}];

load kmeansresults.mat labels centroids;
vars = load('../data/sequence_sim.mat', varsnames{:});
feats = load('../features_sim.mat', ftnames{:});

cols = {'MeanFrequency', 'MedianFrequency', 'PowerBandwidth'};

fslabels = [strcat(cols, '_red'),...
    strcat(cols, '_green'),...
    strcat(cols, '_blue')];

feats.fsstats = feats.fsstats(:, fslabels);

[width, height] = size(vars.imgs, [1, 2]);
results = cell(numel(zonesnames) * numel(ftnames), 2);

for i = 1:numel(ftnames)
    if isa(feats.(ftnames{i}), 'table')
        feats.(ftnames{i}) = table2array(feats.(ftnames{i}));
    end
end

tiledlayout(numel(ftnames) + 1, numel(zonesnames));

for i=1:numel(zonesnames)
    nexttile,
    imshow(vars.(zonesnames{i})),
    title(['original',' ',zonesnames{i}]);
end

for i=1:numel(ftnames)
    x = feats.(ftnames{i});
    clusters = cell2mat(centroids(ftnames{i}));
    lbs = kmeans(x(vars.maskind, :), size(clusters, 1),Start = clusters);
    sgm = zeros(width * height, 1);
    sgm(vars.maskind) = lbs;
    lbs = sgm;
    sgm = reshape(sgm, [width height]);
    for j=1:numel(zonesnames)
        zone = vars.(zonesnames{j});
        lbzones = cell2mat(labels(ftnames{i}));
        prediction = (sgm == lbzones(j));
        precision = (2 * sum(sum(zone & prediction))) /...
            (sum(sum(zone)) + sum(sum(prediction)));
        nexttile,
        imshow(sgm == lbzones(j)),
        title([ftnames{i},' ',zonesnames{j},'(',num2str(precision),')']);
    end
end
