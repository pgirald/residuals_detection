classdef Downsampling < Extractor
    %Class for downsampling a signal by the specified factor.
    
    properties(Access=private)
        normalize
        factor
        signalSize
        maxValue
    end
    
    methods
        function obj = Downsampling(signalSize, args)
            arguments
                signalSize (1,1) int32
                %The size of the signal
                args.normalize (1,1) logical = true;
                %Specifies if the signal should be normalized before the
                % downsampling
                args.factor (1,1) int32 = 2;
                %The factor by which the signal will be downsampled
                args.maxValue (1,1) double = nan;
                %The max value that a point of the signal can take
            end
            obj.signalSize = signalSize;
            obj.normalize = args.normalize;
            obj.factor = args.factor;
            obj.maxValue = args.maxValue;
        end
        function feature = extract(obj, s)
            feature = [obj.samplecurve(s(:,1)'),...
                obj.samplecurve(s(:,2)'),...
                obj.samplecurve(s(:,3)')];
        end
        function headings = getHeadings(obj)
            samples = string(1:obj.factor:obj.signalSize);
            headings = [strcat(samples,"(R)"),...
                strcat(samples,"(G)"),...
                strcat(samples,"(B)")];
        end
        function featsCount = getFeatsCount(obj)
            featsCount = ceil(double(obj.signalSize) / double(obj.factor))*3;
            %3 per each color channel
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [signal] = samplecurve(obj, signal)
            %Normalizes and samples the given curve
            %   This function normalizes and splits the given points in samplescount-1 equal parts,
            %   implying that the points end separated by samplescount bounds. Thus,
            %   this function just take the points located at the mentioned bounds.

            if isnan(obj.maxValue) || obj.maxValue == 0
                m = max(signal);
            else
                m = obj.maxValue;
            end

            if obj.normalize && m ~= 0
                signal = signal / m;
            end
        
            signal = downsample(signal, obj.factor);
        end
    end
end

