close all;

load coefs.mat
load tdstats.mat
load data\sequence.mat;

channels = 3;

[rows, cols] = size(imgs, [1 2]);

img = kmeanssegm(table2array(tdstats), rows, cols);

figure, imshow(img);