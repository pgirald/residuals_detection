function diffcount = wsequals(file1, file2)
    f1vars = load(file1);
    f2vars = load(file2);
    if sum(~strcmp(fieldnames(f1vars),fieldnames(f2vars))) ~= 0
        error("The variables names in the first file do not match with" + ...
            " the names in the second file.");
    end
    nms = string(fieldnames(f1vars));
    diffcount = 0;
    for i = numel(nms)
        v1 = f1vars.(nms(i));
        v2 = f2vars.(nms(i));
        if strcmp(class(v1), class(v2)) && sum(size(v1) ~= size(v2)) == 0
            diffcount = diffcount + sum(f1vars.(nms(i)) ~= f2vars.(nms(i)), "all");
        else
            diffcount = diffcount + 1;
        end
    end
end