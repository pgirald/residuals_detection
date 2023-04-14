clear;
close all;
clc;

load data\sequence.mat;

%Programm configuration
cubic_classes = 3;%bins count for splines coefficients
fsbinscount = 25;%bins count for frenet_serret tangent unitary vector

channels = 3;
[rows, cols] = size(imgs, [1 2]);
imgscount = size(imgs, 4);
locations = rows * cols;

tdlabels = time_domain_labels();
tdlabels = [strcat(tdlabels, '_red'),...
    strcat(tdlabels, '_green'),...
    strcat(tdlabels, '_blue')];
tdtypes = cell(1, numel(tdlabels));
tdtypes(:) = {'double'};

fdlabels = frequency_domain_labels();
fdlabels = [strcat(fdlabels, '_red'),...
    strcat(fdlabels, '_green'),...
    strcat(fdlabels, '_blue')];
fdtypes = cell(1, numel(fdlabels));
fdtypes(:) = {'double'};


spcoefs = zeros(locations, cubic_classes * channels);
tdstats = table('Size', [locations, numel(tdlabels)],...
    'VariableTypes', tdtypes,'VariableNames', tdlabels);
fsstats = table('Size', [locations, numel(fdlabels)],...
    'VariableTypes', fdtypes,'VariableNames', fdlabels);
fsfeats = zeros(locations, imgscount * 2 + fsbinscount * 3);

li = 1;

r = zeros(1, imgscount);
g = zeros(1, imgscount);
b = zeros(1, imgscount);

for i=1:cols
    for j=1:rows
        r(:) = imgs(j, i, 1, :);
        g(:) = imgs(j, i, 2, :);
        b(:) = imgs(j, i, 3, :);

        spcoefs(li, :) =  [splinescoefs(times, r),...
            splinescoefs(times, g),...
            splinescoefs(times, b)];
        %{
        tdstats(li, :) = num2cell([time_domain_stats(r, timeStep),...
            time_domain_stats(g, timeStep),...
            time_domain_stats(b, timeStep)]);

        fsstats(li, :) = num2cell([frequency_domain_stats(r, timeStep),...
            frequency_domain_stats(g, timeStep),...
            frequency_domain_stats(b, timeStep)]);

        fsfeats(li, :) = frenet_serret(r, g, b, fsbinscount);
        %}

        li = li + 1;
    end
end
