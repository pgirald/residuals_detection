function [stfeats] = time_domain_stats(signal, timeStep)
%Computes the time domain stats for the given signal
%   This function Computes the time domain stats for the given signal.
%   The timestep parameter is necesary to compute the SampleRate required
%   by the signalFrequencyFeatureExtractor() function
        stfe = signalTimeFeatureExtractor(SampleRate=1 / timeStep, ...
        Mean = true, RMS= true, StandardDeviation= true, ...
        ShapeFactor= true, SNR= true, THD= true, SINAD= true, ...
        PeakValue= true, CrestFactor= true, ClearanceFactor= true, ...
        ImpulseFactor= true);
        
        sk = skewness(signal); 
        
        kr = kurtosis(signal);
        
        stfeats = extract(stfe, signal);

        stfeats = [stfeats, sk, kr];
end

