clear;
close all;
clc;

addpath characterization;

%-----------Configuration start-------------
sequencepath = 'data/sequence_rftest.mat';
load(sequencepath);

%The .mat file where the features tables will be stored
%If an empty string is speficied, the name feats_<sequencepath> is given by
%default
outfile = "";

%The feature extractors
extractors = {... 
...Shape(),...
KTD("bins",10, "normalize", true),...
Haralick("selectedFeats","variance"),...
...FrecuencyDomainStats("timeStep", timestep, "normalize",true),...
...TimeDomainStats("timeStep", timestep , "normalize",true),...
...SplinesClasses("normalize",true,"time",times),...
...BendingEnergy(times),...
Downsampling(numel(times),"factor",5, "normalize", true, "maxValue", 255),...
...Decimation(numel(times), "factor", 14),...
...Resampling(numel(times), 20)
};
%----------- Configuration end -------------

if outfile == "" || isempty(outfile)
    matches = regexp(sequencepath,'[^\\\/\n\t \.<>:"|?*]+\.mat', 'match');
    
    if isempty(matches)
        error('The path to the sequence of images must refer to a .mat file');
    end
    
    outfile = ['feats_',matches{1}];
end

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