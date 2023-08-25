addpath ../segmentation;
addpath ../external;
clear;
clc;
close all;

%--------Programm configuration start

featurespath = '../feats_sequence_sim.mat';
sequencepath = '../data/sequence_sim.mat';

%Features to be used for clustering
%e.g feats = {'KTD','Shape','FrecuencyDomainStats'}
feats = {'KTD','Shape','FrecuencyDomainStats',...
'TimeDomainStats','SplinesClasses','BendingEnergy', 'Downsampling',...
'Decimation', 'Resampling', 'Haralick'};

%The features for which its centroid will be saved.
%Let it empty if you dont want to store centroids
%e.g centfeats = {'Downsampling', 'Decimation'};
centfeats = {};

%Path to the file in which the centroids will be stored
%e.g centpath = "centroids_sequence_sim.mat";
centroidspath = "";

%The columns that will be used from the features tables
%e.g columns = {["Shape", "KTD"],{["Entropy", "Elongation"], ["nzdir_1",
%"txdir_0"]}};
columns = {"Haralick", {["idm_blue", "imc1_green"]}};

%The headings that will be disaplayed per each feature segmentation
%e.g ftheadings = {["Spline", " classes"], 'Time statistics'}
ftheadings = feats;

%The clustering algorithm to be used.
%The function must have the same signature than kmeans function
%e.g kalgorithm = @kmeans;
kalgorithm = @kmeans;

%Number of clusters for the clustering algorithm
clusters = 4;

%The color that will be displayed for each zone with different stress
% levels. There has to be one color for each cluster
% If the array is empty, default values are computed
% e.g for two clusters: colors = [255,0,0; 255,255,0]
colors = [255 0 0
            255 255 0
            0 255 0
            0 0 255
            ];

%--------Programm configuration end

%--------Features ranking configuration start (optional)

%A callback to a function that implements a feature selection algorithm
%The function must have the same signature than fscmrmr function.
%If fsalgorithm = [], all the configuration in this section is not applied
%e.g fsalgorithm = @fscmrmr
fsalgorithm = [];

%Names of the masks per each zone with different stress levels
%It is assumed that such masks are in the workspace
%For example, you could save the masks in the file of sequence of images
%The masks are used as labels for the fsalgorithm
%e.g masks = {'critical', 'high', 'normal', 'low'};
masks = {'critical', 'high', 'normal', 'low'};

%Specifies to use for the clustering the nth best metrics according to
% fsalgorithm.
%do topfeats = containers.Map() if you dont want this to have effect
%e.g topfeats = containers.Map(["Shape", "TimeDomainStats"], [2, 2]);
topfeats = containers.Map(["Shape", "TimeDomainStats", "Haralick"], [2, 2, 2]);

%--------  Features ranking configuration end (optional)

if isempty(colors)
    maxcolor = 16777215;%0xffffff;
    
    step = maxcolor / (clusters + 1);
    
    colorshex = step:step:maxcolor-step;
    
    colors = zeros(clusters, 3);
    
    for i = 1:numel(colorshex)
        colors(i, :) = hex2rgb(['#',dec2hex(round(colorshex(i)),6)], 255);
    end
end
seqvars = [{'imgs'}, {'maskind'}, masks(:)'];

seqdata = load(sequencepath,  seqvars{:});

featsdata = load(featurespath, feats{:});

[rows, cols] = size(seqdata.imgs, [1 2]);

qfeats = columns{1};

for i = 1:numel(qfeats)
    featsdata.(qfeats(i)) = featsdata.(qfeats(i))(:, columns{2}{i});
end

if isa(fsalgorithm, 'function_handle')

    zoneslbs = zeros(rows * cols, 1);
    
    expectedR = zeros(rows, cols);
    expectedG = zeros(rows, cols);
    expectedB = zeros(rows, cols);
    
    masks = string(masks);
    
    for i = 1:numel(masks)
        mask = seqdata.(masks(i));
        zoneslbs(find(mask ~= 0)) = i;
        expectedR(mask ~= 0) = colors(i, 1);
        expectedG(mask ~= 0) = colors(i, 2);
        expectedB(mask ~= 0) = colors(i, 3);
    end
    
    zoneslbs = zoneslbs(zoneslbs ~= 0);
    
    expected = cat(3,expectedR, expectedG, expectedB);
    
    bestIndices = struct;
    
    for i = 1:numel(feats)
        [idx, scores] = fsalgorithm(featsdata.(feats{i}), zoneslbs);
        bestIndices.(feats{i}) = [featsdata.(feats{i}).Properties.VariableNames(idx);...
            num2cell(idx);num2cell(scores(idx))];
        if isKey(topfeats, {feats{i}})
            endfeat = topfeats(feats{i});
        else
            endfeat = numel(idx);
        end
        featsdata.(feats{i}) = featsdata.(feats{i})(:, idx(1: endfeat));
    end
end

for i = 1:numel(feats)
    featsdata.(feats{i}) = table2array(featsdata.(feats{i}));
end

centroids = struct;

img = uint8(seqdata.imgs(:, :, :, end));

tiledlayout('flow');

nexttile, imshow(img), title('Original');

if isa(fsalgorithm, 'function_handle')
    nexttile, imshow(expected), title({'Expected', 'result'});
end

for i = 1:numel(feats)
    x = featsdata.(feats{i});
    [labels, c] = kalgorithm(x, clusters);
    if ismember(feats{i}, centfeats)
        centroids.(string(feats{i})) = c;
    end
    img = kmeanssegm(labels, rows, cols, seqdata.maskind, colors);
    nexttile, imshow(img), title(ftheadings{i});
end

if centroidspath ~= "" && (~isempty(centroidspath)) && (~isfile(centroidspath))
    aux = 0;
    save(centroidspath, 'aux');
    clear aux;
end

if centroidspath ~= "" && (~isempty(centroidspath))
    save(centroidspath, '-struct', 'centroids', centfeats{:}, '-append');
end