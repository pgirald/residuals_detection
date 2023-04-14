clear;
clc;
close all;

load coefs.mat
load tdstats.mat
load fsstats.mat
load data\sequence.mat imgs;

channels = 3;

imgIdx = 600;

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

figure, imshow(img);

[rows, cols] = size(imgs, [1 2]);

img1 = kmeanssegm(table2array(tdstats), rows, cols);

figure, imshow(img1);

img2 = kmeanssegm(table2array(fsstats), rows, cols);

figure, imshow(img2);

img2 = kmeanssegm(spcoefs, rows, cols);

figure, imshow(img2);