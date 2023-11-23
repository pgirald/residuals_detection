clear;
clc;
close all;

s=load('data\sequence_nr.mat');

points = [10,128;128,128;125,63;125,37];
fs = 50;
timeres=0.7;

%Consultar rango de Nyquist
frequency_limits = [0, fs/5];

imgsCount = size(s.imgs, 4);

frequencies = fs * (-imgsCount/2:imgsCount/2-1) / imgsCount;

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
    pr = pspectrum(r,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);
    pg = pspectrum(g,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);
    pb = pspectrum(b,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);
    img = cat(3,pr,pg,pb);
    imshow(uint8(rescale(img,0,255)))
    imshow(uint8(rescale(img,0,255)))
    
    nexttile;
    plot(times,r,'r');
    nexttile;
    pspectrum(r,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);
    nexttile;
    plot(times,g,'g');
    nexttile;
    pspectrum(g,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);
    nexttile;
    plot(times,b,'b');
    nexttile;
    pspectrum(b,fs, 'spectrogram','TimeResolution',timeres, 'FrequencyLimits', frequency_limits);

    magnitude_spectrum = abs(fftshift(fft(r)));
    nexttile;
    plot(frequencies, magnitude_spectrum);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Frequency Spectrum for R');

    magnitude_spectrum = abs(fftshift(fft(g)));
    nexttile;
    plot(frequencies, magnitude_spectrum);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Frequency Spectrum for G');

    magnitude_spectrum = abs(fftshift(fft(b)));
    nexttile;
    plot(frequencies, magnitude_spectrum);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Frequency Spectrum for B');
end
%{
x=r;

% Assume x is your input signal and Fs is the sampling frequency
% You may need to adjust the parameters based on your specific case

% Parameters
window_length = 10;
overlap = 0.5;
nfft = 1024;

% Calculate necessary parameters
hop_size = round(window_length * (1 - overlap));
num_segments = floor((length(x) - window_length) / hop_size) + 1;

% Initialize spectrogram matrix
spectrogram = zeros(nfft/2 + 1, num_segments);

% Generate Spectrogram
for i = 1:num_segments
    % Extract the current segment
    segment = x((i-1)*hop_size + 1 : (i-1)*hop_size + window_length);
    
    % Apply Fourier Transform to the segment
    segment_fft = fft(segment, nfft);
    
    % Extract magnitude (ignoring the negative frequencies)
    segment_magnitude = abs(segment_fft(1:nfft/2 + 1));
    
    % Store the magnitude spectrum in the spectrogram matrix
    spectrogram(:, i) = segment_magnitude;
end

% Create time and frequency axes
time_axis = (window_length/2 : hop_size : length(x) - window_length/2) / fs;
frequency_axis = linspace(0, fs/2, nfft/2 + 1);

% Plot Spectrogram
figure;
imagesc(time_axis, frequency_axis, 10*log10(spectrogram));
colorbar;
%axis xy;
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Spectrogram from Scratch');
%}