function [glcmf] = graycofeats(signal, feats)
%Computes haralick features for the given signal
%  This function Computes, for the given signal, the haralick features
%  specified in the feats parameter. feats is a cell array that can contain
%   the values specified in aviablefeats at the start of the code. For 
%   example, you can do feats = {'contrast', 'asm', 'entropy'}.
    
    aviablefeats = containers.Map(["asm", "contrast", "correlation",...
        "variance", "idm", "saverage", "svariance", "sentropy",...
        "entropy", "dvariance", "dentropy", "imc1", "imc2", "mcc"], 1:14);

    if nargin < 2
        feats = {};
    end

    glcm = graycomatrix(signal, "GrayLimits", [0 255],...
        "NumLevels", 256, "Offset", [0 1], "Symmetric",  true);

    idxs = sort(cell2mat(values(aviablefeats, feats)));

    glcmf = haralickTextureFeatures(glcm, idxs)';
    glcmf = glcmf(idxs);
end