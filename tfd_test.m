clear;
clc;
close all;

s=load('data\sequence_nr.mat');

points = [10,128;128,128;125,63;125,37];
fs = 10;
timeres=0.5;

imgsCount = size(s.imgs, 4);

r = zeros(imgsCount, 1);
g = zeros(imgsCount, 1);
b = zeros(imgsCount, 1);
times = 1:imgsCount;

for i=1:size(points,1)
    row=points(i,1);
    col=points(i,2);

    r(:)=s.imgs(row,col,1,:);
    g(:)=s.imgs(row,col,2,:);
    b(:)=s.imgs(row,col,3,:);

    figure,tiledlayout('flow');
    
    nexttile;
    imshow(uint8(s.imgs(:,:,:,end)));
    hold on;
    plot(col,row,'xc');
    hold off;

    nexttile;
    pr = pspectrum(r,fs, 'spectrogram','TimeResolution',timeres);
    pg = pspectrum(g,fs, 'spectrogram','TimeResolution',timeres);
    pb = pspectrum(b,fs, 'spectrogram','TimeResolution',timeres);
    img = cat(3,pr,pg,pb);
    imshow(uint8(rescale(img,0,255)))
    imshow(uint8(rescale(img,0,255)))
    
    nexttile;
    plot(times,r,'r');
    nexttile;
    pspectrum(r,fs, 'spectrogram','TimeResolution',timeres);
    nexttile;
    plot(times,g,'g');
    nexttile;
    pspectrum(g,fs, 'spectrogram','TimeResolution',timeres);
    nexttile;
    plot(times,b,'b');
    nexttile;
    pspectrum(b,fs, 'spectrogram','TimeResolution',timeres);
end