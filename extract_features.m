clear;
close all;
clc;

load data\sequence_sim.mat;

addpath characterization;

%-----------Configuration start-------------
outfile = 'features_sim.mat';

extractors = {... 
KTD("bins",10, "normalize", true),...
Shape(),...
Haralick(),...
FrecuencyDomainStats("timeStep", timestep, "normalize",true),...
TimeDomainStats("timeStep", timestep , "normalize",true),...
SplinesClasses("normalize",true,"time",times),...
BendingEnergy(times),...
Downsampling(numel(times),"factor",10, "normalize", true, "maxValue", 255)
};
%----------- Configuration end -------------

extscount = numel(extractors);

%number of rows and columns of each image
[rows, cols] = size(imgs, [1 2]);

%count of images in the sequence
imgscount = size(imgs, 4);

%Number of pixels that match the applied mask
maskedlocs = numel(maskind);

%signals per channel
r = zeros(1, imgscount);
g = zeros(1, imgscount);
b = zeros(1, imgscount);

%The tables of features
feattables = struct;

%progress bar
wb = waitbar(0,'Please wait...');
if ~isfile(outfile)
    aux = 0;
    save(outfile, 'aux');
    clear aux;
end

tic
for i=1:extscount
    ext = extractors{i};
    featsmat = extractor2mat(ext, maskedlocs);
    waitbar((i - 1) / extscount,wb, ['Extracting ',class(ext),' features']);
    for j=1:maskedlocs
        %the current linear index
        li = maskind(j);
    
        r(:) = imgs(maskrow(j), maskcol(j), 1, :);
        g(:) = imgs(maskrow(j), maskcol(j), 2, :);
        b(:) = imgs(maskrow(j), maskcol(j), 3, :);
    
        %TODO: Avoid trasposing signals
        signal = [r', g', b'];
        featsmat(j, :) = ext.extract(signal);
        waitbar(((i - 1) / extscount) + (j / (maskedlocs*extscount)), wb);
    end
    feattables.(class(ext)) = ...
        array2table(featsmat, "VariableNames", ext.getHeadings());
    save(outfile, '-struct', 'feattables', class(ext), '-append');
    feattables = rmfield(feattables, class(ext));
end
toc

close(wb);