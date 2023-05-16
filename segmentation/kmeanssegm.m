function [img, labels] = kmeanssegm(labels, width, height, maskind, colors)
%Classifies each row of features in four different classes
%   This function classifies each row as one correspondeing to either a 
%   low, mean, high or critical zone
    sgm = zeros(width * height, 1);
    sgm(maskind) = labels;
    labels = sgm;
    sgm = reshape(sgm, [width height]);
    img = uint8(zeros(width, height, 3));
    lbs = unique(labels(labels>=1));
    for i = 1:numel(lbs)
        img(:, :, 1) = img(:, :, 1) + (uint8(sgm == lbs(i)) * uint8(colors(i, 1)));
        img(:, :, 2) = img(:, :, 2) + (uint8(sgm == lbs(i)) * uint8(colors(i, 2)));
        img(:, :, 3) = img(:, :, 3) + (uint8(sgm == lbs(i)) * uint8(colors(i, 3)));
    end
end

