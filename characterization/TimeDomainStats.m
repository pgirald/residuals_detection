classdef TimeDomainStats < Extractor
    %Class for the time domain statistics listed in featsNames
    % property.
    properties(Access=private)
        normalize
        timeStep
    end

    properties(Constant=true, Access=private)
        featsNames = ["Mean"...
                  "RMS",...
    "StandardDeviation",...
          "ShapeFactor",...
          "SINAD", ...
          "SHR",...
          "THD",...
            "PeakValue",...
          "CrestFactor",...
      "ClearanceFactor",...
        "ImpulseFactor",...
        "skewness",...
        "kurtosis"]
        colorChannels = 3;
    end
    
    methods
        function obj = TimeDomainStats(args)
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
            feature = [obj.time_domain_stats(s(:,1)),...
                obj.time_domain_stats(s(:,2)),...
                obj.time_domain_stats(s(:,3))];
        end
        function headings = getHeadings(~)
            headings = [strcat(TimeDomainStats.featsNames,"_R"),...
                strcat(TimeDomainStats.featsNames,"_G"),...
                strcat(TimeDomainStats.featsNames,"_B")];
        end
        function featsCount = getFeatsCount(~)
            featsCount = TimeDomainStats.colorChannels * ...
                numel(TimeDomainStats.featsNames);
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [stfeats] = time_domain_stats(obj,signal)
            %Computes the time domain stats for the given signal
            %   This function Computes the time domain stats for the given signal.
            %   The timestep parameter is necesary to compute the SampleRate required
            %   by the signalFrequencyFeatureExtractor() function
            m = max(abs(signal));
    
            if obj.normalize && m ~= 0
                signal = signal / m;
            end
    
            stfe = signalTimeFeatureExtractor(SampleRate=1 /obj.timeStep, ...
            Mean = true, RMS= true, SINAD = true, SNR = true, THD = true, ...
            StandardDeviation= true, ShapeFactor= true, ...
            PeakValue= true, CrestFactor= true, ClearanceFactor= true, ...
            ImpulseFactor= true);
            
            sk = skewness(signal); 
            
            kr = kurtosis(signal);
            
            stfeats = extract(stfe, signal);
    
            stfeats = [stfeats, sk, kr];
        end
    end
end

