addpath ../segmentation;
clear;
clc;
close all;

%--------Programm configuration start
featuresfile = '../features_sim.mat';

%Índice de la imagen que se mostrará
imgIdx = 320;

%Características a ser utilizadas
%Opciones válidas son: {'KTD','Shape','Haralick','FrecuencyDomainStats',...
%'TimeDomainStats','SplinesClasses','BendingEnergy', 'Downsampling'}
ftnames = {'KTD','Shape','FrecuencyDomainStats',...
'TimeDomainStats','SplinesClasses','BendingEnergy', 'Downsampling'};

%Títulos correspondientes a las características
ftlabels = ftnames;

clusters = 4;

colors = [255 0 0
               0 255 0
               0 0 255
               255 255 0];
%--------Programm configuration end

%{
maxcolor = 16777215;%0xffffff;

step = maxcolor / (clusters + 1);

colorshex = step:step:maxcolor-step;

colors = zeros(clusters, 3);

for i = 1:numel(colorshex)
    colors(i, :) = hex2rgb(['#',dec2hex(round(colorshex(i)),6)], 255);
end
%}

load ../data/sequence_sim.mat imgs maskind;

feats = load(featuresfile, ftnames{:});

[rows, cols] = size(imgs, [1 2]);

for i = 1:numel(ftnames)
    feats.(ftnames{i}) = table2array(feats.(ftnames{i}));
end

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

tiledlayout('flow');

nexttile, imshow(img), title('Original');

for i = 1:numel(ftnames)
    x = feats.(ftnames{i});
    [labels, c] = kmeans(x, clusters);
    img = kmeanssegm(labels, rows, cols, maskind, colors);
    nexttile, imshow(img), title(ftlabels{i});
end