classdef FrecuencyDomainStats < Extractor
    %Class for the frecuency domain statistics listed in featsNames
    % property.
    properties(Access=private)
        normalize
        timeStep
    end

    properties(Constant=true, Access=private)
        featsNames = ["MeanFrequency",...
      "MedianFrequency",...
            "BandPower",...
    "OccupiedBandwidth",...
       "PowerBandwidth",...
        "PeakAmplitude",...
         "PeakLocation"]
        colorChannels = 3;
    end
    
    methods
        function obj = FrecuencyDomainStats(args)
            arguments
                args.timeStep (1,1) double = 1;
                %In time units, how frecuently a sample was taken to form
                %the signal
                args.normalize (1,1) logical = true;
                %Specifies if the signal should be normalized before the
                %statistics extraction
            end
            obj.timeStep = args.timeStep;
            obj.normalize = args.normalize;
        end
        function feature = extract(obj, s)
            feature = [obj.frequency_domain_stats(s(:,1)),...
                obj.frequency_domain_stats(s(:,2)),...
                obj.frequency_domain_stats(s(:,3))];
        end
        function headings = getHeadings(~)
            headings = [strcat(FrecuencyDomainStats.featsNames,"_R"),...
                strcat(FrecuencyDomainStats.featsNames,"_G"),...
                strcat(FrecuencyDomainStats.featsNames,"_B")];
        end
        function featsCount = getFeatsCount(~)
            featsCount = FrecuencyDomainStats.colorChannels * ...
                numel(FrecuencyDomainStats.featsNames);
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [stfeats] = frequency_domain_stats(obj, signal)
            %Computes the frequency domain stats for the given signal
            %   This function Computes the frequency domain stats for the given signal.
            %   The timestep parameter is necesary to compute the SampleRate requiered
            %   by the signalFrequencyFeatureExtractor() function
            m = max(abs(signal));
        
            if obj.normalize && m ~=0
                    signal = signal / m;
            end
        
            sffe = signalFrequencyFeatureExtractor(SampleRate=1/obj.timeStep, ...
            MeanFrequency=true, MedianFrequency=true, BandPower=true,...
            OccupiedBandwidth=true, PowerBandwidth=true, PeakAmplitude=true,...
            PeakLocation=true);
        
            stfeats = extract(sffe, signal);
        end
    end
end

