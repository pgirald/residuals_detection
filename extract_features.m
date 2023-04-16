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
3.  Si se especifica, por ejemplo, feats = {'compressed', 'csphist'};,
    entonces, igualmente se reserva almacenamiento para las estructuras
    destinadas para almacenar los seis tipos de caracaterísticas restantes.
    Esto se corregira al utilizar POO (ver 1).
%}

clear;
close all;
clc;

load data\sequence.mat;

%-----Programm configuration start-----

%features to extract
feats = {'compressed'};
%{
feats = {'csphist', 'cspclasses', 'tdstats', 'fsstats', 'frenetserret',...
    'haralick', 'cspcoefs'};
%}
%csphist: cubic splines coefficients histograms
%cspclasses: cubic splines classes counts
%tdstats: time domain statistics
%fsstats: frequency domain statistics
%frenetserret: frenet-serret features
%haralick: haralick features
%cspcoefs: cubic splines coefficients
%compressed: compressed and normalized curve

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

%number of times that the normalized signal will be compressed
%(to get the compressed signal feature)
compresstimes = 5;

%number of times that that the signal will be compressed before
%splines coefficients extraction
cspcompresstimes = 3;

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
cspcompressedsize = numel(z);

%computing the size that the compressed signal will have
%(for the compressed signal feature)
z = zeros(1, imgscount);
z = compress(z, z, compresstimes);
compressedsize = numel(z);

%splines classes features matrix
cspclasses = zeros(locations, cubic_classes * channels);

%splines histogram features matrix
csphist = zeros(locations, cspbinscount * numel(csphistfeats) * channels);

%splines coefficients features matrix
cspcoefs = zeros(locations,...
    (numel(cspcoeffeats) * channels) * (cspcompressedsize - 1));

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
compressedsignal = zeros(locations, compressedsize * channels);

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
        cspcoefs(li, :) = [splinescoefs(times, r, cspcompresstimes,...
                    cspcoeffeats), splinescoefs(times, g, cspcompresstimes,...
                    cspcoeffeats), splinescoefs(times, b, cspcompresstimes,...
                    cspcoeffeats)];
    end

    if any(strcmp(feats,'compressed'))
        compressedsignal(li, :) = [compressedcurve(times, r, compresstimes),...
            compressedcurve(times, g, compresstimes),...
            compressedcurve(times, b, compresstimes)];
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

if any(strcmp(feats,'compressed'))
    save features.mat compressedsignal -append;
end

close(h);
