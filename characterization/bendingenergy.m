classdef BendingEnergy < Extractor
    %Class for computing the bending energy of signal.
    
    properties(Access=private)
        time
    end
    
    methods
        function obj = BendingEnergy(time)
            arguments
                time (:, 1) double
                %Time at which each point of the signal was taken,
                % respectively.
            end
            obj.time = time;
        end
        function feature = extract(obj, s)
            if(size(s, 1) ~= numel(obj.time))
                error("Time dimensions do not match with the signal" + ...
                    " dimensions");
            end
            feature = [obj.bendingenergy(s(:, 1)),...
                obj.bendingenergy(s(:, 2)),...
                obj.bendingenergy(s(:, 3))];
        end
        function headings = getHeadings(~)
            headings = strcat("Benging Energy(",["R","G","B"],")");
        end
        function featsCount = getFeatsCount(~)
            featsCount = 3;
            %One feature per color channel
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [be] = bendingenergy(obj, signal)
            dy = signal(2:end)-signal(1:end-1);
            dx = obj.time(2:end)-obj.time(1:end-1);
            theta = atan(dy./dx);
            cc = theta;
            cc(theta < 0) = theta(theta < 0) + 2*pi;
            cc = round(4 * cc / pi);
            cc(cc == 8) = 0;
            d = mod(cc(2:end)-cc(1:end-1), 4);
            be = sum(d.^2);
        end

    end
end

