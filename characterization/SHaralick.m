classdef SHaralick < Extractor
    %Class for the haralick texuture features listed in the featsNames
    %property. The features are computed from an spectogram
    properties(Constant=true, Access = private)
        featsNames = ["asm", "contrast", "correlation",...
                    "variance", "idm", "saverage", "svariance", "sentropy",...
                    "entropy", "dvariance", "dentropy", "imc1", "imc2", "mcc"];
        featsMap = containers.Map(SHaralick.featsNames,...
            1:numel(SHaralick.featsNames));
        colorChannels = 3
    end
    
    properties(Access=private)
        offset
        fs
        selectedFeats
        featsIdxs
        NumLevels
        timeres
    end

    methods
        function obj = SHaralick(args)
            arguments
                args.selectedFeats {mustBeMember(args.selectedFeats,...
                    ["asm", "contrast", "correlation",...
                    "variance", "idm", "saverage", "svariance", "sentropy",...
                    "entropy", "dvariance", "dentropy", "imc1", "imc2", "mcc"])} = SHaralick.featsNames;
                %Specified features to be computed
                args.offset (:,2) int32 = [0,1;-1,1;-1,0;-1,-1];
                %Co-ocurrence matrix gray levels count
                args.fs (1,1) double = 10;
                %Signal sample rate in Hertz
                args.NumLevels = 256;
                %Number of gray levels for the co-ocurrence matrix
                args.timeres = 0.5;
                %The time resolution for the spectogram
            end
            obj.selectedFeats = string(args.selectedFeats);
            checkmebership(obj.selectedFeats, SHaralick.featsNames);
            obj.featsIdxs = ...
                sort(cell2mat(values(SHaralick.featsMap, cellstr(obj.selectedFeats))));
            obj.selectedFeats = SHaralick.featsNames(obj.featsIdxs);
            obj.offset = args.offset;
            obj.fs = args.fs;
            obj.NumLevels = args.NumLevels;
            obj.timeres = args.timeres;
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
            featsCount = numel(obj.selectedFeats) * SHaralick.colorChannels;
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [glcmf] = graycofeats(obj, signal)
            %Computes haralick features for the spectogram of the given signal
            %  This function Computes, for the spectogram of the given signal, the haralick features
            %  specified in the feats parameter. feats is a cell array that can contain
            %   the values specified in aviablefeats at the start of the code. For 
            %   example, you can do feats = {'contrast', 'asm', 'entropy'}.


                %Revisar parámetros más óptimos para pspectrum
                ps = pspectrum(signal, obj.fs, 'spectrogram','TimeResolution',obj.timeres);
            
                glcm = graycomatrix(uint8(rescale(ps,0,obj.NumLevels-1)),...
                    "GrayLimits", [0,obj.NumLevels-1],...
                    "NumLevels", obj.NumLevels,...
                    "Offset", obj.offset,...
                    "Symmetric",  true);

                glcm = sum(glcm,3); 
            
                glcmf = haralickTextureFeatures(glcm, obj.featsIdxs)';
                glcmf = glcmf(obj.featsIdxs);
        end
    end
end

