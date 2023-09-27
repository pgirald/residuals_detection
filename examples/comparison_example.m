clear;
close all;
clc;

%secuence.mat must contain the photoelasticity images with residuals
%secuence1.mat must contain the photoleasticity images without residual
vars = {'imgs', 'times'};

s = load('../data/sequence_r.mat', vars{:}) ;
snr = load('../data/sequence_nr.mat', vars{:});

f = 10;
c = 130;
imgsCount = size(s.imgs, 4);
imgIdx = 560;

r = zeros(imgsCount, 1);
g = zeros(imgsCount, 1);
b = zeros(imgsCount, 1);

r(:) = s.imgs(f, c, 1, :);
g(:) = s.imgs(f, c, 2, :);
b(:) = s.imgs(f, c, 3, :);

r1(:) = snr.imgs(f, c, 1, :);
g1(:) = snr.imgs(f, c, 2, :);
b1(:) = snr.imgs(f, c, 3, :);

figure, tiledlayout(2, 2)

nexttile
plot3(r, g, b, 'r');
title('With residuals')

nexttile
plot3(r1, g1, b1, 'r');
title('Without residuals')

nexttile
hold on
plot(s.times, r, 'r');
plot(s.times, g, 'g');
plot(s.times, b, 'b');
hold off
title('With residuals')

nexttile
hold on
plot(snr.times, r1, 'r');
plot(snr.times, g1, 'g');
plot(snr.times, b1, 'b');
hold off
title('Without residuals')

img = cat(3, s.imgs(:, :, 1, imgIdx), s.imgs(:, :, 2, imgIdx), s.imgs(:, :, 3, imgIdx));

img = uint8(img);

img(f, c, :) = [255, 0, 0];

img1 = cat(3, snr.imgs(:, :, 1, imgIdx), snr.imgs(:, :, 2, imgIdx), snr.imgs(:, :, 3, imgIdx));

img1 = uint8(img1);

img1(f, c, :) = [255, 0, 0];

figure, tiledlayout(1, 2)

nexttile
imshow(img);
title('With residuals')

nexttile
imshow(img1);
title('Without residuals')
