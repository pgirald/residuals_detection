function [feats] = frenet_serret(x, y, z, bincounts, feats)
%Extracts frenet-serret features
%   This function extracts the frenet-serret features specified in the 
%   "feats" parameter. x, y and z make up a 3d parametric curve. bincounts
%   specify the number of bins that will have the histograms for each
%   feature.
%   Finally, "feats" is a cell array that can contain the values
%   'xdir', 'ydir', 'zdir', 'curvature' and 'torsion'. For example,
%   you can do feats = {'xdir', 'curvature'}.
%   'xdir', 'ydir' and 'zdir' refers to the angles of the unit tangent
%   vector respect x, y and z axis, respectively. 'curvature' and 'torsion'
%   just refer to the curvatures and torsions at each point of the curve,
%   respectively.
    if nargin < 5
        feats = {};
    end

    [T, N, B, k, t] = TNB(x, y, z);

    xdir = [];

    if any(strcmp(feats,'xdir'))
        
        xdir = [histcounts(T(:, 1), bincounts)];

    end

    ydir = [];

    if any(strcmp(feats,'ydir'))
        
        ydir = [histcounts(T(:, 2), bincounts)];
        
    end

    zdir = [];

    if any(strcmp(feats,'zdir'))
        
        zdir = [histcounts(T(:, 3), bincounts)];
        
    end

    khist = [];

    if any(strcmp(feats,'curvature'))

        khist = [histcounts(k, bincounts - 1)];
    
        khist(numel(khist) + 1) = sum(isnan(k));
    
        khist = khist / sum(khist);

    end

    thist = [];

    if any(strcmp(feats,'torsion'))
    
        thist = [histcounts(t, bincounts - 1)];
    
        thist(numel(thist) + 1) = sum(isnan(k));
    
        thist = thist / sum(thist);
    end

    feats = [xdir, ydir, zdir, khist, thist];
end

