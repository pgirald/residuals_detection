function [stfeats] = frequency_domain_stats(signal, timestep, normalize)
%Computes the frequency domain stats for the given signal
%   This function Computes the frequency domain stats for the given signal.
%   The timestep parameter is necesary to compute the SampleRate requiered
%   by the signalFrequencyFeatureExtractor() function
    if normalize
            signal = signal / max(abs(signal));
    end

    sffe = signalFrequencyFeatureExtractor(SampleRate=1/timestep, ...
    MeanFrequency=true, MedianFrequency=true, BandPower=true,...
    OccupiedBandwidth=true, PowerBandwidth=true, PeakAmplitude=true,...
    PeakLocation=true);

    stfeats = extract(sffe, signal);
end

