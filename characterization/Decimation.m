classdef Decimation < Extractor
    
    properties(Access = private)
        factor
        signalSize
    end
    
    methods
        function obj = Decimation(signalSize, args)
            arguments
                signalSize {mustBePositive, mustBeInteger}
                args.factor {mustBePositive, mustBeInteger}
            end
            obj.signalSize = signalSize;
            obj.factor = args.factor;
        end
        
        function feature = extract(obj, s)
            feature = [decimate(s(:, 1)', obj.factor),...
                decimate(s(:, 2)', obj.factor),...
                decimate(s(:, 3)', obj.factor)];
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
end

