%{
Este código aun no es muy correcto, le falta optimización:

1.  Utilizar POO. Crear por cada tipo de característica que se calcula aquí
    una clase que encapsule todo lo que se necesite para calcular los
    descriptores. Cada una de las clases debe de heredar de una clase padre
    que contenga la información común. Con esto, se pueden reemplazar los
    if de este código por bucles que ejecuten un método de los objetos de
    cada clase.
2.  Se está calculando compressedsize de una manera mediocre. Encontrar una
    fórmula.
3.  Si se especifica, por ejemplo, feats = {'sampled', 'csphist'};,
    entonces, igualmente se reserva almacenamiento para las estructuras
    destinadas para almacenar los seis tipos de caracaterísticas restantes.
    Esto se corregira al utilizar POO (ver 1).
%}

clear;
close all;
clc;

load data\sequence_sim.mat;

%-----Programm configuration start-----
%the name of the output file in which the features will be
outfile = 'features_sim.mat';
%features to extract
feats = {'cspclasses', 'sampled'};
%{
feats = {'csphist', 'cspclasses', 'tdstats', 'fsstats', 'frenetserret',...
    'haralick', 'cspcoefs', 'sampled'};
%}
%csphist: cubic splines coefficients histograms
%cspclasses: cubic splines classes counts
%tdstats: time domain statistics
%fsstats: frequency domain statistics
%frenetserret: frenet-serret features
%haralick: haralick features
%cspcoefs: cubic splines coefficients
%compressed: compressed and normalized curve
%sampled: sampled points of the signal

%bins count for splines coefficiens histograms
cspbinscount = 5;

%bins count for frenet_serret features vector histograms
fsbinscount = 5;

%frenet_serret features to be extracted
fsfeats = {'xdir', 'ydir', 'zdir'};

%splines coefficiens taken into account  for histograms
csphistfeats = {'p'};

%splines coefficiens to be extracted
cspcoeffeats = {'a', 'p'};

%number of samples that will be taken from the signal
%(to get the sampled signal feature)
samples = 25;

%number of samples to be taken from the signal before
%splines coefficients extraction
cspsamples = 12;

%haralick features to be extracted
haralickfeats = {'asm', 'contrast', 'correlation',...
        'variance', 'idm', 'saverage', 'svariance', 'sentropy',...
        'entropy', 'dvariance', 'dentropy', 'imc1', 'imc2', 'mcc'};

%normalize signal before time domain stats
normalizetd = true;

%normalize signal before frequency domain stats
normalizefd = true;

%normalize cubic spline classes histogram
normalizecspclasses = true;

%-----Programm configuration end-----

if ~strcmp(outfile(end-3:end), '.mat')
    error('The output file must have the extension .mat');
end

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

%splines classes features matrix
cspclasses = zeros(locations, cubic_classes * channels);

%splines histogram features matrix
csphist = zeros(locations, cspbinscount * numel(csphistfeats) * channels);

%splines coefficients features matrix
cspcoefs = zeros(locations,...
    (numel(cspcoeffeats) * channels) * (cspsamples - 1));

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

%compressed singal feature
sampledsignal = zeros(locations, samples * channels);

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
        cspclasses(li, :) =  [splinesclasses(times, r, normalizecspclasses),...
                    splinesclasses(times, g, normalizecspclasses),...
                    splinesclasses(times, b, normalizecspclasses)];
    
    end

    if any(strcmp(feats,'tdstats'))
        tdstats(li, :) = num2cell([time_domain_stats(r, timestep, normalizetd),...
                    time_domain_stats(g, timestep, normalizetd),...
                    time_domain_stats(b, timestep, normalizetd)]);
    end

    if any(strcmp(feats,'fsstats'))
        fsstats(li, :) = num2cell([frequency_domain_stats(r, timestep, normalizefd),...
                    frequency_domain_stats(g, timestep, normalizefd),...
                    frequency_domain_stats(b, timestep, normalizefd)]);
    end

    if any(strcmp(feats,'frenetserret'))
        frenetserret(li, :) = frenet_serret(r, g, b, fsbinscount, fsfeats);
    end

    if any(strcmp(feats,'haralick'))
        haralick(li, :) = num2cell([graycofeats(r, haralickfeats),...
                    graycofeats(g, haralickfeats), graycofeats(b, haralickfeats)]);
    end

    if any(strcmp(feats,'cspcoefs'))
        cspcoefs(li, :) = [splinescoefs(times, r, cspsamples,...
                    cspcoeffeats), splinescoefs(times, g, cspsamples,...
                    cspcoeffeats), splinescoefs(times, b, cspsamples,...
                    cspcoeffeats)];
    end

    if any(strcmp(feats,'sampled'))
        sampledsignal(li, :) = [samplecurve(r, samples),...
            samplecurve(g, samples),...
            samplecurve(b, samples)];
    end
    
    waitbar(i / maskedlocs);
end

if ~isfile(outfile)
    aux = 0;
    save(outfile, 'aux');
    clear aux;
end

if any(strcmp(feats,'csphist'))
	save(outfile, 'csphist', '-append');
end

if any(strcmp(feats,'cspclasses'))
	save(outfile, 'cspclasses', '-append');
end

if any(strcmp(feats,'tdstats'))
	save(outfile, 'tdstats', '-append');
end

if any(strcmp(feats,'fsstats'))
	save(outfile, 'fsstats', '-append');
end

if any(strcmp(feats,'frenetserret'))
	save(outfile, 'frenetserret', '-append');
end

if any(strcmp(feats,'haralick'))
	save(outfile, 'haralick', '-append');
end

if any(strcmp(feats,'cspcoefs'))
	save(outfile, 'cspcoefs', '-append');
end

if any(strcmp(feats,'sampled'))
    save(outfile, 'sampledsignal', '-append');
end

close(h);
