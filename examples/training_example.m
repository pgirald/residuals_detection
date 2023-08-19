clear;
clc;
close all;

%--------Programm configuration start
featuresfile = 'features_sim.mat';

clusters = 4;

%Índice de la imagen que se mostrará
imgIdx = 320;

%Características a ser utilizadas
ftnames = {'kinetics'};

%Títulos correspondientes a las características
ftlabels = {'ktd'};
%--------Programm configuration end

maxcolor = 16777215;%0xffffff;

step = maxcolor / (clusters + 1);

colorshex = step:step:maxcolor-step;

colors = zeros(clusters, 3);

for i = 1:numel(colorshex)
    colors(i, :) = hex2rgb(['#',dec2hex(round(colorshex(i)),6)], 255);
end

colors = [255 0 0
               0 255 0
               0 0 255
               255 255 0];

feats = load(featuresfile, ftnames{:});

load data\sequence_sim.mat imgs maskind;

[rows, cols] = size(imgs, [1 2]);

for i = 1:numel(ftnames)
    if isa(feats.(ftnames{i}), 'table')
        feats.(ftnames{i}) = table2array(feats.(ftnames{i}));
    end
end

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

tiledlayout('flow');

nexttile, imshow(img), title('Original');

for i = 1:numel(ftnames)
    x = feats.(ftnames{i});
    [labels, c] = kmeans(x(maskind, :), clusters);
    img = kmeanssegm(labels, rows, cols, maskind, colors);
    nexttile, imshow(img), title(ftlabels{i});
end

%{
Sería bueno crear una matriz de características que tenga como columnas:
-número de picos
-alguna métrica que refleja la diferencia en la altura de los picos
(tal vez un ángulo o solo restarle al pico más grane el pico más pequeño)
-curvatura promedio y sus respectivas desviacioens estándar (o HOD)
%}