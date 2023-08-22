function tbl = extractor2table(extractor, rowsNumber)
    arguments
        extractor (1,1) Extractor
        rowsNumber (1,1) int64
    end
    types = strings(1,extractor.getFeatsCount());
    types(:) = extractor.getFeatsType();
    tbl = table('Size', [rowsNumber, extractor.getFeatsCount()],...
    'VariableTypes', types,'VariableNames', extractor.getHeadings());
end

