function [feats] = trayectorydescs(x, y, z, descs, entropydelta)
    %This function computes the specified shape descriptores in the
    %parameter descs. The five feautres that can be computed with this
    %function are 'Bending energy', 'Elongation', 'Entropy', 'Major axis'
    %and 'Total curvature'.
    be = [];
    if any(strcmp(descs,'Bending energy'))
        be = bendingenergy(x, y, z); 
    end
    el = [];
    if any(strcmp(descs,'Elongation'))
        el = elongation(x, y, z);
    end
    en = [];
    if any(strcmp(descs,'Entropy'))
        en = radentropy(x, y, z, entropydelta);
    end
    mal = [];
    if any(strcmp(descs,'Major axis length'))
        mal = majorax([x, y, z]);
        mal = sqrt(sum((mal(1, :) - mal(2, :)).^2));
    end
    tc = [];
    if any(strcmp(descs,'Total curvature'))
        tc = totalcurvature(x, y, z);
    end
    feats = [be, el, en, mal, tc];
end

