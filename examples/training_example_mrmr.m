clear;
clc;
close all;

clusters = 4;

colors = [255 0 0
            255 255 0
            0 255 0
            0 0 255
            %255 0 255
            %0 255 255
            ];

bestfeats = dictionary({'tdstats','haralick', 'shape'}, [5, 1, 1]);

ftnames = {'tdstats', 'haralick', 'shape'};

ftlabels = {'Estadísticas', 'Haralick', {'Descriptores', 'de Forma'}};

%{
ftnames = {'cspclasses', 'sampledsignal', 'utvangs'};

ftlabels = {'Splines naturales', 'Muestreo de señal', 'Ángulos VTU'};
%}

aux = [ftnames, 'be'];

feats = load('features_sim.mat', aux{:});
%{
feats.shape = feats.shape(:, {'Elongation', 'Major axis length', 'Entropy'});
feats.shape.be_r = feats.be(:, 1);
feats.shape.be_g = feats.be(:, 2);
feats.shape.be_b = feats.be(:, 3);
%}
load data\sequence_sim.mat imgs maskind low normal high critical;

centroids = cell(1, numel(ftnames));

%{
cols = {'Mean','RMS','StandardDeviation','ShapeFactor','SINAD','SHR',...
    'THD','PeakValue','CrestFactor','ClearanceFactor','ImpulseFactor',...
    'skewness','kurtosis'};

cols = {'PeakValue','ImpulseFactor', 'CrestFactor','ClearanceFactor'};

tdlabels = [strcat(cols, '_red'),...
    strcat(cols, '_green'),...
    strcat(cols, '_blue')];

feats.tdstats = feats.tdstats(:, tdlabels);

cols = {'MeanFrequency', 'MedianFrequency',...
    'BandPower', 'OccupiedBandwidth', 'PowerBandwidth', 'PeakAmplitude',...
    'PeakLocation'};


cols = {'MeanFrequency', 'MedianFrequency', 'PowerBandwidth'};

fslabels = [strcat(cols, '_red'),...
    strcat(cols, '_green'),...
    strcat(cols, '_blue')];
%}
%feats.fsstats = feats.fsstats(:, fslabels);

%feats.utvangs = [std(feats.utvangs(:, 1:361),0, 2), std(feats.utvangs(:, 362:722), 0,2), std(feats.utvangs(:, 723:1083),0,2)];

[rows, cols] = size(imgs, [1 2]);

zoneslbs = zeros(rows * cols, 1);

zoneslbs(find(low ~= 0)) = 1;
zoneslbs(find(normal ~= 0)) = 2;
zoneslbs(find(high ~= 0)) = 3;
zoneslbs(find(critical ~= 0)) = 4;

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
%{
[idx, scores] = fscmrmr(feats.cspclasses(zoneslbs ~= 0, :), zoneslbs(zoneslbs ~= 0));

feats.cspclasses = feats.cspclasses(: ,idx(1:2));
%}
for i = 1:numel(ftnames)
    if isa(feats.(ftnames{i}), 'table')
        [idx, scores] = fscmrmr(feats.(ftnames{i})(zoneslbs ~= 0, :), zoneslbs(zoneslbs ~= 0));
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
    [labels, c] = kmeans(x(maskind, :), clusters);
    centroids{i} = c;
    img = kmeanssegm(labels, rows, cols, maskind, colors);
    nexttile, imshow(img), title(ftlabels{i});
end

centroids = dictionary(string(ftnames), centroids);

%{
Sería bueno crear una matriz de características que tenga como columnas:
-número de picos
-alguna métrica que refleja la diferencia en la altura de los picos
(tal vez un ángulo o solo restarle al pico más grane el pico más pequeño)
-curvatura promedio y sus respectivas desviacioens estándar (o HOD)
%}