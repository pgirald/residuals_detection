function [mat] = extractor2mat(extractor, rowsCount)
    arguments
        extractor (1,1) Extractor
        rowsCount (1,1) int64
    end
    mat = zeros(rowsCount, extractor.getFeatsCount());
end

