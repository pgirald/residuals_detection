clear;
close all;
clc;

load data\sequence.mat;

f = 20;
c = 128;
stepTime = 0.2;

imgsCount = size(imgs, 3);

imgIdx = 300;

r = zeros(imgsCount, 1);
g = zeros(imgsCount, 1);
b = zeros(imgsCount, 1);

r(:) = imgs(f, c, :, 1);
g(:) = imgs(f, c, :, 2);
b(:) = imgs(f, c, :, 3);

figure, plot3(r, g, b, 'ro');

img = cat(3, imgs(:, :, imgIdx, 1), imgs(:, :, imgIdx, 2), imgs(:, :, imgIdx, 3));

img = uint8(img);

img(f, c, :) = [255, 0, 0];

figure, imshow(img);

signals = timetable(seconds(times(:, 1)), r, g, b);

signals.Properties.VariableNames = ["Red" "Green" "Blue"];

splines = cscvn([r, g, b]');

fnplt(splines,'b',2);

splines.coefs;

stfe = signalTimeFeatureExtractor(SampleRate=1/stepTime, Mean = true, RMS= true,...
    StandardDeviation= true, ShapeFactor= true, SNR= true, THD= true,...
    SINAD= true, PeakValue= true, CrestFactor= true,...
    ClearanceFactor= true, ImpulseFactor= true);

[stfefeats, stfeinfo] = extract(stfe, r);

sffe = signalFrequencyFeatureExtractor(SampleRate=1/stepTime, ...
    MeanFrequency=true, MedianFrequency=true, BandPower=true,...
    OccupiedBandwidth=true, PowerBandwidth=true, PeakAmplitude=true,...
    PeakLocation=true);

[sffefeats, sffeinfo] = extract(sffe, r);