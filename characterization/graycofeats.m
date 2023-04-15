function [glcmf] = graycofeats(signal, feats)
%Computes haralick features for the given signal
%  This function Computes, for the given signal, the haralick features
%  specified in the feats parameter. feats is a cell array that can contain
%   the following values: 'Contrast', 'Correlation', 'Energy'
%   and 'Homogeneity'. For example, you can do
%   feats = {'Contrast', 'Energy'}.
    if nargin < 2
        feats = {};
    end

    glcm = graycomatrix(signal, "GrayLimits", [0 255],...
        "NumLevels", 256, "Offset", [0 1], "Symmetric",  true);

    stats = graycoprops(glcm, feats);

    glcmf = struct2cell(stats)';
end