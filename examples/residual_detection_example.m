close all;
clear;
clc;

feats = {'cspclasses','cspcoefs','csphist','frenetserret',...
    'fsstats','haralick','tdstats','sampledsignal'};

data = {'imgs', 'maskind'};

trainfeats = load('features_rtrain.mat', feats{:});
traindata = load('data\sequence_rtrain.mat', data{:});

testfeats = load('features_rtest.mat', feats{:});
testdata = load('data\sequence_rtest.mat', data{:});

for i = 1:numel(feats)
    if isa(trainfeats.(feats{i}), 'table')
        trainfeats.(feats{i}) = table2array(trainfeats.(feats{i}));
    end
end

for i = 1:numel(feats)
    if isa(testfeats.(feats{i}), 'table')
        testfeats.(feats{i}) = table2array(testfeats.(feats{i}));
    end
end

msk = imread('data\imgs_residuals\Plant.bmp');
rmsk = imread('data\imgs_residuals\Residual_mask.bmp');
linds = find(msk-rmsk);
labels = zeros(size(msk, 1) * size(msk, 2), 1) -1;
labels(linds) = 0;
linds = find(rmsk);
labels(linds) = 1;
labels = labels(traindata.maskind);

testimgs = testdata.imgs;

out = zeros(size(testimgs, 1) * size(testimgs, 2), 1);

last = size(testimgs, 4);

img = cat(3, testimgs(:, :, 1, last), testimgs(:, :, 2, last), testimgs(:, :, 3, last));

img = uint8(img);

masks = zeros(size(testimgs, 1), size(testimgs, 2), numel(feats));

figure, tiledlayout('flow');
nexttile;
imshow(img);
title('Original');
for i = 1:numel(feats)
    featmat = trainfeats.(feats{i});
    mdl = fitclinear(featmat(traindata.maskind), labels);
    featmat = testfeats.(feats{i});
    out(testdata.maskind) = predict(mdl, featmat(testdata.maskind));
    masks(:, :, i) = reshape(out, size(testimgs, [1, 2]));
    nexttile;
    imshow(masks(:, :, i) * 255);
    title(feats{i});
end

figure, tiledlayout('flow');

for i = 1:numel(feats)
    mask = uint8(masks(:, :, i));
    mask = cat(3, mask, mask, mask);
    nexttile;
    imshow(img .* mask);
    title(feats{i});
end
