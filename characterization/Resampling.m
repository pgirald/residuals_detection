classdef Resampling < Extractor
    
    properties (Access = private)
        samplesCount
        signalSize
        p
        q
    end
    
    methods
        function obj = Resampling(signalSize, samplesCount)
            arguments
                signalSize {mustBePositive, mustBeInteger}
                %The signal size
                samplesCount {mustBePositive, mustBeInteger}
                %The number of samples to be extracted
            end
            obj.samplesCount = samplesCount;
            obj.signalSize = signalSize;
            [obj.p, obj.q] = rat(samplesCount / signalSize);
        end       

        function feature = extract(obj, s)
            feature = [resample(s(:, 1)', obj.p, obj.q),...
                resample(s(:, 2)', obj.p, obj.q),...
                resample(s(:, 3)', obj.p, obj.q)];
        end

        function headings = getHeadings(obj)
            nums = string(1:obj.samplesCount);
            headings = [strcat(nums, "(R)"),...
                strcat(nums, "(G)"),...
                strcat(nums, "(B)")];
        end

        function featsCount = getFeatsCount(obj)
            featsCount = obj.samplesCount * 3;
            %3 per each color channel
        end

        function type = getFeatsType(~)
            type = "double";
        end

    end
end

