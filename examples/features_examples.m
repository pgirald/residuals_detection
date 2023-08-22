clear;
close all;
clc;

load ../data/sequence_sim.mat;

%f = 48;
%c = 162;
f = 20;
c = 64;
imgsCount = size(imgs, 4);
imgIdx = 600;

r = zeros(imgsCount, 1);
g = zeros(imgsCount, 1);
b = zeros(imgsCount, 1);

r(:) = imgs(f, c, 1, :);
g(:) = imgs(f, c, 2, :);
b(:) = imgs(f, c, 3, :);

figure, plot3(r, g, b, 'ro');

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

img(f, c, :) = [255, 0, 0];

figure, imshow(img);

signals = timetable(seconds(times(:, 1)), r, g, b);

signals.Properties.VariableNames = ["Red" "Green" "Blue"];

splines = cscvn([r, g, b]');

figure, fnplt(splines,'r',2);

splines.coefs;

stfe = signalTimeFeatureExtractor(SampleRate=1/timestep, Mean = true, ...
    RMS= true, StandardDeviation= true, ShapeFactor= true, SNR= true, ...
    THD= true, SINAD= true, PeakValue= true, CrestFactor= true,...
    ClearanceFactor= true, ImpulseFactor= true);

[stfefeats, stfeinfo] = extract(stfe, r);

sffe = signalFrequencyFeatureExtractor(SampleRate=1/timestep, ...
    MeanFrequency=true, MedianFrequency=true, BandPower=true,...
    OccupiedBandwidth=true, PowerBandwidth=true, PeakAmplitude=true,...
    PeakLocation=true, WelchPSD=true);

[sffefeats, sffeinfo] = extract(sffe, r);

[T, N, B, k, t] = TNB(r, g, b);

sr = csape(times, r, 'periodic');
sg = csape(times, g, 'periodic');
sb = csape(times, b, 'periodic');

figure,
hold on; 
fnplt(sr, 'r'); 
fnplt(sg, 'g'); 
fnplt(sb, 'b'); 
hold off;

figure, plot3(fnval(sr, times), fnval(sg, times), fnval(sb, times), 'b')...
     ,xlabel('Red'), ylabel('Green'), zlabel('Blue');

pr = fit(times, r, 'poly6');
pg = fit(times, g, 'poly6');
pb = fit(times, b, 'poly6');

figure,
hold on;
plot(pr, 'r');
plot(pg, 'g');
plot(pb, 'b');
hold off;

sk = skewness(r);
kr = kurtosis(r);


coefs = zeros(size(sr.coefs, 1), size(sr.coefs, 2));
a_lt_0 = sr.coefs(:, 1) < 0;
coefs(~a_lt_0, :) = sr.coefs(~a_lt_0, :);
coefs(a_lt_0, [1 3]) = sr.coefs(a_lt_0, [1 3]) * -1;
p = coefs(:, 3) - ((coefs(:, 2) .^ 2) ./ (3 .* (coefs(:, 1))));

