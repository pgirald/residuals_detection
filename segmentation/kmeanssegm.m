function [img] = kmeanssegm(x, width, height)
    idx = kmeans(x, 4);
    sgm = reshape(idx, [width height]);
    img = zeros(width, height, 3);
    img(:, :, 1) = (sgm == 1) * 255;
    img(:, :, 2) = (sgm == 2) * 255;
    img(:, :, 3) = (sgm == 3) * 255;
    img(:, :, 2) = (sgm == 4) * 255;
    img(:, :, 3) = (sgm == 4) * 255;
end

