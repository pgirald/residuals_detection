close all;
clear;
clc;

%---Programm configuration start
directory = 'imgs_residuals_test1';
out = 'sequence_rtest1.mat';
imgscount = 400;
extension = 'bmp';
maskname = 'Plant.bmp';
timestep = 0.1;
smooth = false;
keeporiginals = false;
haszones = false;
%---Programm configuration end

mask = imread(['data/', directory, '/', maskname]);
[rows, cols] = size(mask, [1 2]);
oimgs = zeros(rows, cols, 3, imgscount);
times = 0 : 0.1 : 0.1 * (imgscount - 1);
times = times';

for i = 1:imgscount
    img = imread(['data/', directory, '/', num2str(i), '.', extension]);
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

save(['data/', out], 'imgs', 'times', 'maskind', 'maskrow', 'maskcol');

if keeporiginals
    save(['data/', out], 'oimgs', '-append');
end

if haszones
    low = imread('low.bmp');
    normal = imread('normal.bmp');
    high = imread('high.bmp');
    critical = imread('critical.bmp');
    save(['data/', out], 'low', '-append');
    save(['data/', out], 'normal', '-append');
    save(['data/', out], 'high', '-append');
    save(['data/', out], 'critical', '-append');
end