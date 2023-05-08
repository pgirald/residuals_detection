clear;
clc;
close all;

load features_sim.mat;
load data\sequence_sim.mat imgs maskind;

channels = 3;

imgIdx = 560;

img = cat(3, imgs(:, :, 1, imgIdx), imgs(:, :, 2, imgIdx), imgs(:, :, 3, imgIdx));

img = uint8(img);

tiledlayout('flow');

nexttile, imshow(img), title('Original');

[rows, cols] = size(imgs, [1 2]);

img1 = kmeanssegm(table2array(tdstats), rows, cols, maskind);

nexttile, imshow(img1), title('Time domain statistics');

img2 = kmeanssegm(table2array(fsstats), rows, cols, maskind);

nexttile, imshow(img2), title('Frequency domain statistics');

%There are features "in the way" for cubic splines classes
img3 = kmeanssegm(cspclasses(:, [1 2 5 6 9 10]), rows, cols, maskind);

nexttile, imshow(img3), title('splines classes');

img4 = kmeanssegm(frenetserret, rows, cols, maskind);

nexttile, imshow(img4), title('Frenet serret (unit tangent vector)');

img5 = kmeanssegm(csphist, rows, cols, maskind);

nexttile, imshow(img5), title('Splines histogram');

img6 = kmeanssegm(table2array(haralick), rows, cols, maskind);

nexttile, imshow(img6), title('Haralick');

%There are features "in the way" for cubic splines classes!!!
img7 = kmeanssegm(cspcoefs, rows, cols, maskind);

nexttile, imshow(img7), title('Splines coefficients');

img8 = kmeanssegm(sampledsignal, rows, cols, maskind);

nexttile, imshow(img8), title('sampled');
%{
Sería bueno crear una matriz de características que tenga como columnas:
-número de picos
-alguna métrica que refleja la diferencia en la altura de los picos
(tal vez un ángulo o solo restarle al pico más grane el pico más pequeño)
-curvatura promedio y sus respectivas desviacioens estándar (o HOD)
%}