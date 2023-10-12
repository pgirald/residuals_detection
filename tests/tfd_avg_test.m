clear;
clc;
if numel(findall(0)) > 1
    delete(findall(0));%Close all the uifigures
end

addpath ../characterization;

data = load('../data/sequence_sim.mat');

fs = 10;
timeres=0.5;

rows = size(data.imgs,1);
cols = size(data.imgs,2);
imgscount = size(data.imgs,4);
colors=["r","g","b"];
avg = zeros(imgscount,3);
zones=["low","normal",'high','critical'];
ext = SHaralick("fs",fs,"timeres",timeres);
featstables = struct;

for zone = 1:numel(zones)
    mask = data.(zones(zone));
    figure;
    tiledlayout(4,2);
    nexttile;
    imshow(uint8(data.imgs(:,:,:,end)));
    nexttile;
    imshow(mask);
    hold on;
    for channel = 1:3
        cc = zeros(rows,cols,imgscount);
        cc(:,:,:) = data.imgs(:,:,channel,:);
        cc = cc.*mask;
        avg(:,channel) = mean(cc, [1,2]);
        nexttile;
        plot(data.times,avg(:,channel),colors(channel));
        nexttile;
        pspectrum(avg(:,channel),fs,'spectrogram','TimeResolution',timeres);
    end
    hold off;
    featstables.(zones(zone)) = ...
    array2table(ext.extract(avg), "VariableNames", ext.getHeadings());
    fig = uifigure("Name",zones(zone));
    uitable(fig, "Data",featstables.(zones(zone)));
end