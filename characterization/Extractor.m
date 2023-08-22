classdef Extractor
    methods (Abstract)
        feature = extract(obj, s)
        %Method that extracts a feature vector from something s (like a
        % signal, an image, etc).
        headings = getHeadings(obj)
        %The names (in the same order) of the features computed in the
        % extract method.
        featsCount = getFeatsCount(obj)
        %Number of features computed by the extract method
        type = getFeatsType(obj)
        %The type of the features computed by the extract method (double,
        % int32, int64, etc).
    end
end

