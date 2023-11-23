close all;
clear;
clc;

%Programm configuration start----------------------

%Features to be used for the residuals detection
%e.g feats = {'KTD','Shape','FrecuencyDomainStats'}
feats = {'Downsampling'};

%The columns that will be used from the features tables
%Make columns = {[]} if you dont want to specify columns.
%e.g columns = {["Shape", "KTD"],{["Entropy", "Elongation"], ["nzdir_1", "txdir_0"]}};
columns = {[]};

%Path to the features for training the residuals detection model
trainfeatspath = '../feats_sequence_r.mat';

%Path to the sequence of images with residuals from which the training
% features were extracted
residualseqpath = '../data/sequence_r.mat';

%Path to the sequence of images without residuals, that is "parallel" to
%the sequence of images with residuals used for the training
normalseqpath = '../data/sequence_nr.mat';

%Path to the features for testing the residuals detection model
testfeatspath = '../feats_sequence_rtest2.mat';

%Path to the sequence of images with residuals from which the test
% features were extracted
testseqpath = '../data/sequence_rtest2.mat';

%Let diff be the an image obtained by finding the euclidiean distance
%between each respective pixel in the last image with residuals and the
%last image without residuals. Then, it is considerd that a location (i,j)
%was affected by residuals if diff(i, j) < max(diff) * threshold
threshold = 0.5;

%Programm configuration end  ----------------------

data = {'imgs', 'maskind'};

trainfeats = load(trainfeatspath, feats{:});
residualseq = load(residualseqpath, data{:});
normalseq = load(normalseqpath, data{:});

testfeats = load(testfeatspath, feats{:});
testseq = load(testseqpath, data{:});

if sum(size(normalseq.imgs) ~= size(residualseq.imgs)) ~= 0
    error("The size of the sequence of images with residuals must be" + ...
        " equal to the size of the sequence of images without residuals.");
end

qfeats = columns{1};

for i = 1:numel(qfeats)
    trainfeats.(qfeats(i)) = trainfeats.(qfeats(i))(:, columns{2}{i});
    testfeats.(qfeats(i)) = testfeats.(qfeats(i))(:, columns{2}{i});
end

for i = 1:numel(feats)
    trainfeats.(feats{i}) = table2array(trainfeats.(feats{i}));
end

for i = 1:numel(feats)
    testfeats.(feats{i}) = table2array(testfeats.(feats{i}));
end

lnimage = normalseq.imgs(:, :, :, end);

lrimage = residualseq.imgs(:, :, :, end);

diff = sqrt((lnimage(:, :, 1) - lrimage(:, :, 1)) .^ 2 + ...
    (lnimage(:, :, 2) - lrimage(:, :, 2)) .^ 2 + ...
    (lnimage(:, :, 3) - lrimage(:, :, 3)) .^ 2);

affected = diff >= max(diff, [], 'all') * threshold;

out = zeros(size(testseq.imgs, 1) * size(testseq.imgs, 2), 1);

masks = zeros(size(testseq.imgs, 1), size(testseq.imgs, 2), numel(feats));

figure, tiledlayout('flow');

nexttile;
imshow(uint8((diff / max(diff, [],'all'))*255));
title(["Zones affected", "by residuals", "(traning sequence)"]);

nexttile;
imagesc(affected);
title(["Zones affected", "according to threshold", "(traning sequence)"]);

figure, tiledlayout('flow');
nexttile;
imshow(uint8(testseq.imgs(:,:,:,end)));
title('Original');
for i = 1:numel(feats)
    featmat = trainfeats.(feats{i});
    mdl = fitclinear(featmat, affected(residualseq.maskind));
    featmat = testfeats.(feats{i});
    out(testseq.maskind) = predict(mdl, featmat);
    masks(:, :, i) = reshape(out, size(testseq.imgs, [1, 2]));
    nexttile;
    imshow(masks(:, :, i) * 255);
    title(feats{i});
end

figure, tiledlayout('flow');

for i = 1:numel(feats)
    mask = uint8(masks(:, :, i));
    mask = cat(3, mask, mask, mask);
    nexttile;
    imshow(uint8(testseq.imgs(:,:,:,end)) .* mask);
    title(feats{i});
end