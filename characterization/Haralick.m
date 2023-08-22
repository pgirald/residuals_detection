classdef Haralick < Extractor
    %Class for the haralick texuture features listed in the featsNames
    %property
    properties(Access=private)
        selectedFeats
        featsIdxs
    end

    properties(Constant=true, Access = private)
        featsNames = ["asm", "contrast", "correlation",...
                    "variance", "idm", "saverage", "svariance", "sentropy",...
                    "entropy", "dvariance", "dentropy", "imc1", "imc2", "mcc"];
        featsMap = containers.Map(Haralick.featsNames,...
            1:numel(Haralick.featsNames));
        colorChannels = 3
    end
    
    methods
        function obj = Haralick(args)
            arguments
                args.selectedFeats {mustBeMember(args.selectedFeats,...
                    ["asm", "contrast", "correlation",...
                    "variance", "idm", "saverage", "svariance", "sentropy",...
                    "entropy", "dvariance", "dentropy", "imc1", "imc2", "mcc"])} = Haralick.featsNames;
                %Specified features to be computed
            end
            obj.selectedFeats = string(args.selectedFeats);
            checkmebership(obj.selectedFeats, Haralick.featsNames);
            obj.featsIdxs = ...
                sort(cell2mat(values(Haralick.featsMap, cellstr(obj.selectedFeats))));
            obj.selectedFeats = Haralick.featsNames(obj.featsIdxs);
        end
        function feature = extract(obj, s)
            feature = [obj.graycofeats(s(:,1)), obj.graycofeats(s(:,2)),...
                 obj.graycofeats(s(:,3))];
        end
        function headings = getHeadings(obj)
            headings = [strcat(obj.selectedFeats, '_red'),...
                strcat(obj.selectedFeats, '_green'),...
                strcat(obj.selectedFeats, '_blue')];
        end
        function featsCount = getFeatsCount(obj)
            featsCount = numel(obj.selectedFeats) * Haralick.colorChannels;
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [glcmf] = graycofeats(obj, signal)
            %Computes haralick features for the given signal
            %  This function Computes, for the given signal, the haralick features
            %  specified in the feats parameter. feats is a cell array that can contain
            %   the values specified in aviablefeats at the start of the code. For 
            %   example, you can do feats = {'contrast', 'asm', 'entropy'}.
            
                glcm = graycomatrix(signal, "GrayLimits", [0 255],...
                    "NumLevels", 256, "Offset", [1 0], "Symmetric",  true);
            
                glcmf = haralickTextureFeatures(glcm, obj.featsIdxs)';
                glcmf = glcmf(obj.featsIdxs);
        end
    end
end
