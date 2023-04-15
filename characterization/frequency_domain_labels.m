function [labels] = frequency_domain_labels()
%Returns the frequency domain features computed by frecuency_domain_stats()
    labels = {'MeanFrequency',...
      'MedianFrequency',...
            'BandPower',...
    'OccupiedBandwidth',...
       'PowerBandwidth',...
        'PeakAmplitude',...
         'PeakLocation'};
end

