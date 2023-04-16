clear;
close all;
clc;

load data\sequence.mat;

%-----Programm configuration start-----

%features to extract
feats = {'cspcoefs'};
%csphist: cubic splines coefficients histograms
%cspclasses: cubic splines classes counts
%tdstats: time domain statistics
%fsstats: frequency domain statistics
%frenetserret: frenet-serret features
%haralick: haralick features
%cspcoefs: cubic splines coefficients

%bins count for splines coefficiens histograms
cspbinscount = 25;

%bins count for frenet_serret features vector histograms
fsbinscount = 25;

%frenet_serret features to be extracted
fsfeats = {'xdir', 'ydir', 'zdir'};

%splines coefficiens taken into account  for histograms
csphistfeats = {'p'};

%splines coefficiens to be extracted
cspcoeffeats = {'a', 'p'};

%number of times that that the signal will be compressed before
%splines coefficients extraction
cspcompresstimes = 5;

%haralick features to be extracted
haralickfeats = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};


%-----Programm configuration end-----

%RGB channels count
channels = 3;

%count of classes in which splinesclasses() function classiffies cubic
%polynomials
cubic_classes = 4;

[rows, cols] = size(imgs, [1 2]);

%count of images in the sequence
imgscount = size(imgs, 4);

%count of spacial locations per image
locations = rows * cols;

%computing headers for the time domain statistics table
tdlabels = time_domain_labels();
tdlabels = [strcat(tdlabels, '_red'),...
    strcat(tdlabels, '_green'),...
    strcat(tdlabels, '_blue')];
tdtypes = cell(1, numel(tdlabels));
tdtypes(:) = {'double'};

%computing headers for the frequency domain statistics table
fdlabels = frequency_domain_labels();
fdlabels = [strcat(fdlabels, '_red'),...
    strcat(fdlabels, '_green'),...
    strcat(fdlabels, '_blue')];
fdtypes = cell(1, numel(fdlabels));
fdtypes(:) = {'double'};

%computing headers for the haralick features table
haralicklabels = [strcat(haralickfeats, '_red'),...
    strcat(haralickfeats, '_green'),...
    strcat(haralickfeats, '_blue')];
haralicktypes = cell(1, numel(haralicklabels));
haralicktypes(:) = {'double'};

%computing the size that the compressed signal will have
%(for splines coefficients extraction)
z = zeros(1, imgscount);
z = compress(z, z, cspcompresstimes);
compressedsize = numel(z);

%splines classes features matrix
cspclasses = zeros(locations, cubic_classes * channels);

%splines histogram features matrix
csphist = zeros(locations, cspbinscount * numel(csphistfeats) * channels);

%splines coefficients features matrix
cspcoefs = zeros(locations,...
    (numel(cspcoeffeats) * channels) * (compressedsize - 1));

%time domain statistics features matrix
tdstats = table('Size', [locations, numel(tdlabels)],...
    'VariableTypes', tdtypes,'VariableNames', tdlabels);

%frequency domain statistics features matrix
fsstats = table('Size', [locations, numel(fdlabels)],...
    'VariableTypes', fdtypes,'VariableNames', fdlabels);

%frenet-serret features matrix
frenetserret = zeros(locations, fsbinscount * numel(fsfeats));

%haralick features matrix
haralick = table('Size', [locations, numel(haralicklabels)],...
    'VariableTypes', haralicktypes,'VariableNames', haralicklabels);

maskedlocs = numel(maskind);

%signals per channel
r = zeros(1, imgscount);
g = zeros(1, imgscount);
b = zeros(1, imgscount);

%progress bar
h = waitbar(0,'Please wait...');

for i=1:maskedlocs
    %the current linear index
    li = maskind(i);

    r(:) = imgs(maskrow(i), maskcol(i), 1, :);
    g(:) = imgs(maskrow(i), maskcol(i), 2, :);
    b(:) = imgs(maskrow(i), maskcol(i), 3, :);


    if any(strcmp(feats,'csphist'))
        csphist(li, :) =  [splineshist(times, r, cspbinscount, csphistfeats),...
                    splineshist(times, g, cspbinscount, csphistfeats),...
                    splineshist(times, b, cspbinscount, csphistfeats)];
    end
    
    if any(strcmp(feats,'cspclasses'))
        cspclasses(li, :) =  [splinesclasses(times, r),...
                    splinesclasses(times, g),...
                    splinesclasses(times, b)];
    
    end

    if any(strcmp(feats,'tdstats'))
        tdstats(li, :) = num2cell([time_domain_stats(r, timestep),...
                    time_domain_stats(g, timestep),...
                    time_domain_stats(b, timestep)]);
    end

    if any(strcmp(feats,'fsstats'))
        fsstats(li, :) = num2cell([frequency_domain_stats(r, timestep),...
                    frequency_domain_stats(g, timestep),...
                    frequency_domain_stats(b, timestep)]);
    end

    if any(strcmp(feats,'frenetserret'))
        frenetserret(li, :) = frenet_serret(r, g, b, fsbinscount, fsfeats);
    end

    if any(strcmp(feats,'haralick'))
        haralick(li, :) = [graycofeats(r, haralickfeats),...
                    graycofeats(g, haralickfeats), graycofeats(b, haralickfeats)];
    end

    if any(strcmp(feats,'cspcoefs'))
        cspcoefs(li, :) = [splinescoefs(times, r, cspcompresstimes,...
                    cspcoeffeats), splinescoefs(times, g, cspcompresstimes,...
                    cspcoeffeats), splinescoefs(times, b, cspcompresstimes,...
                    cspcoeffeats)];
    end
    
    waitbar(i / maskedlocs);
end

if ~isfile('features.mat')
    aux = 0;
    save features.mat aux;
    clear aux;
end

if any(strcmp(feats,'csphist'))
	save features.mat csphist -append;
end

if any(strcmp(feats,'cspclasses'))
	save features.mat cspclasses -append;
end

if any(strcmp(feats,'tdstats'))
	save features.mat tdstats -append;
end

if any(strcmp(feats,'fsstats'))
	save features.mat fsstats -append;
end

if any(strcmp(feats,'frenetserret'))
	save features.mat frenetserret -append;
end

if any(strcmp(feats,'haralick'))
	save features.mat haralick -append;
end

if any(strcmp(feats,'cspcoefs'))
	save features.mat cspcoefs -append;
end

close(h);
