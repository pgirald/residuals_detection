addpath ../segmentation;
clear;
clc;
close all;

%--------Programm configuration start
featuresfile = '../features_sim.mat';

ftnames = {'KTD','Shape','FrecuencyDomainStats',...
'TimeDomainStats','SplinesClasses','BendingEnergy', 'Downsampling'};

bestfeats = dictionary(["Shape"], [2]);

ftlabels = ftnames;

clusters = 4;

colors = [255 0 0
            255 255 0
            0 255 0
            0 0 255
            %255 0 255
            %0 255 255
            ];
%--------Programm configuration end

load ../data/sequence_sim.mat imgs maskind low normal high critical;

feats = load(featuresfile, ftnames{:});

centroids = cell(1, numel(ftnames));

[rows, cols] = size(imgs, [1 2]);

zoneslbs = zeros(rows * cols, 1);

zoneslbs(find(low ~= 0)) = 1;
zoneslbs(find(normal ~= 0)) = 2;
zoneslbs(find(high ~= 0)) = 3;
zoneslbs(find(critical ~= 0)) = 4;

zoneslbs = zoneslbs(zoneslbs ~= 0);

expectedR = zeros(rows, cols);
expectedG = zeros(rows, cols);
expectedB = zeros(rows, cols);

expectedR(critical ~= 0) = 255;

expectedR(high ~= 0) = 255;
expectedG(high ~= 0) = 255;

expectedG(normal ~= 0) = 255;

expectedB(low ~= 0) = 255;

expected = cat(3,expectedR, expectedG, expectedB);

bestIndices = struct;

for i = 1:numel(ftnames)
    [idx, scores] = fscmrmr(feats.(ftnames{i})(zoneslbs, :), zoneslbs);
    bestIndices.(ftnames{i}) = [feats.(ftnames{i}).Properties.VariableNames(idx);...
        num2cell(idx);num2cell(scores(idx))];
    feats.(ftnames{i}) = table2array(feats.(ftnames{i}));
    if isKey(bestfeats, {ftnames{i}})
        endfeat = bestfeats({ftnames{i}});
    else
        endfeat = numel(idx);
    end
    feats.(ftnames{i}) = feats.(ftnames{i})(:, idx(1: endfeat));
end

channels = 3;

imgIdx = 560;

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

tiledlayout('flow');

nexttile, imshow(img), title('Original');

nexttile, imshow(expected), title({'Resultado', 'esperado'});

for i = 1:numel(ftnames)
    x = feats.(ftnames{i});
    [labels, c] = kmeans(x, clusters);
    centroids{i} = c;
    img = kmeanssegm(labels, rows, cols, maskind, colors);
    nexttile, imshow(img), title(ftlabels{i});
end