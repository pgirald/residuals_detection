close all;
clear;
clc;

%---Programm configuration start

%Path to the folder containing a sequence of n photoelasticity images
% numbered from 1 to n, according to the time in which they were captured.
directory = 'imagenes_normales_fluo';

%Name of the file in which will be stored the images properly for further
% processing
out = 'sequence_nrf.mat';

%The number of images inside the folder
imgscount = 561;

%The extension of all the images files
extension = 'bmp';

%The file name of the mask to get the ROI of the images. It is assumed that
% the mask is located in the same folder than the rest of the images
maskname = 'Plant';

%How frecuently wehre the images taken (in seconds)
timestep = 0.1;

%If a smoothing preprocessing should be applied
smooth = false;

%If the non-smooth images should be stored
keeporiginals = false;

%The name of the files for the masks that corresponds to  zones with
% different stress levels. It is assumed that they are located in the same
% folder than the rest of the images
% e.g zones = {'low', 'normal', 'high', 'critical'};

zones = {};

%---Programm configuration end

mask = imread([directory, '/', maskname, '.', extension]);
[rows, cols] = size(mask, [1 2]);
oimgs = zeros(rows, cols, 3, imgscount);
times = 0 : 0.1 : 0.1 * (imgscount - 1);
times = times';

for i = 1:imgscount
    img = imread([directory, '/', num2str(i), '.', extension]);
    oimgs(:, :, :, i) = img(:, :, :);
end

li = 1;
locations = rows * cols;
if smooth
    h = waitbar(0,'Smoothing signals...');
    imgs = zeros(rows, cols, 3, imgscount);
    for i = 1:cols
        for j = 1:rows
            imgs(j, i, 1, :) = smoothdata(oimgs(j, i, 1, :),....
                'sgolay','SamplePoints',times);
            imgs(j, i, 2, :) = smoothdata(oimgs(j, i, 2, :),....
                'sgolay','SamplePoints',times);
            imgs(j, i, 3, :) = smoothdata(oimgs(j, i, 3, :),....
                'sgolay','SamplePoints',times);
            waitbar(li / locations);
            li = li + 1;
        end
    end
    close(h);
else
    imgs = oimgs;
end

mask(mask ~= 0) = 1;
if(size(mask, 3) == 3)
    mask = mask(:, :, 1) & mask(:, :, 2) & mask(:, :, 3);
end
maskind = find(mask);
[maskrow, maskcol] = ind2sub([rows cols], maskind);

save(out, 'imgs', 'times', 'maskind', 'maskrow', 'maskcol');

if keeporiginals
    save(out, 'oimgs', '-append');
end

zonesmasks = struct;

for i=1:numel(zones)
    mask = imread([zones{i},'.',extension]);
    zonesmasks.(zones{i}) = mask;
end

if ~isempty(zones)
    save(out, '-struct', 'zonesmasks', zones{:}, '-append');
end