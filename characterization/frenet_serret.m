function [feats] = frenet_serret(x, y, z, bincounts)
    [T, N, B, k, t] = TNB(x, y, z);

    dirs = [histcounts(T(:, 1), bincounts),...
        histcounts(T(:, 2), bincounts),...
        histcounts(T(:, 3), bincounts)];

    feats = [dirs, k', t'];
end

