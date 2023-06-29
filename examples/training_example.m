clear;
clc;
close all;

clusters = 4;

colors = [255 0 0
            0 255 0
            0 0 255
            255 255 0
            %255 0 255
            %0 255 255
            ];

ftnames = {'tdstats', 'haralick', 'shape'};

ftlabels = {'Estadísticas', 'Haralick', {'Descriptores', 'de Forma'}};
%{
ftnames = {'cspclasses', 'sampledsignal', 'utvangs'};

ftlabels = {'Splines naturales', 'Muestreo de señal', 'Ángulos VTU'};
%}

aux = [ftnames, 'be'];

feats = load('features_sim.mat', aux{:});
feats.shape = feats.shape(:, {'Elongation', 'Major axis length', 'Entropy'});
feats.shape.be_r = feats.be(:, 1);
feats.shape.be_g = feats.be(:, 2);
feats.shape.be_b = feats.be(:, 3);
load data\sequence_sim.mat imgs maskind low normal high critical;

%feats.shape = feats.shape(:, {'Total curvature'});

centroids = cell(1, numel(ftnames));

%feats.cspclasses = feats.cspclasses(:, [1 2 4 5 6 8 9 10 12]); 

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

for i = 1:numel(ftnames)
    if isa(feats.(ftnames{i}), 'table')
        feats.(ftnames{i}) = table2array(feats.(ftnames{i}));
    end
end


channels = 3;

imgIdx = 560;

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

tiledlayout('flow');

nexttile, imshow(img), title('Original');

[rows, cols] = size(imgs, [1 2]);

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