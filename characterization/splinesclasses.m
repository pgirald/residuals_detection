classdef SplinesClasses < Extractor
    %Class for the splines classes features. There is a class for each
    %possible number of critic points that a cubic function can have.
    %For each pair of points of the signal, an spline (cubic function) is
    %computed, then, the number of splines that there are for each class
    %is computed to create an histogram.
    properties(Access=private)
        normalization
        time
    end

    properties(Constant=true, Access=private)
        classes = ["2 critics", "0 critics"]
        colorChannels = 3;
    end

    methods
        function obj = SplinesClasses(args)
            arguments
                args.normalize (1,1) logical = true;
                %Specifies if the splines classes histogram should be
                % normalized.
                args.time (:, 1) double
                %The time in which each point of the signal was taken,
                % respectively
            end
            if args.normalize
                obj.normalization = "probability";
            else
                obj.normalization = "count";
            end
            obj.time = args.time;
        end

        function feature = extract(obj, s)
            if size(s,1) ~= numel(obj.time)
                error("Time dimensions do not match with the signal" + ...
                    " dimensions");
            end
            feature = [obj.splinesclasses(s(:,1)),...
                obj.splinesclasses(s(:,2)),...
                obj.splinesclasses(s(:,3))];
        end
        function headings = getHeadings(~)
            headings = [strcat(SplinesClasses.classes, "(R)"),...
                strcat(SplinesClasses.classes, "(G)"),...
                strcat(SplinesClasses.classes, "(B)")];
        end
        function featsCount = getFeatsCount(~)
            featsCount = numel(SplinesClasses.classes) * ...
                SplinesClasses.colorChannels;
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods(Access=private)
        function [class_count] = splinesclasses(obj, signal)
            %For each of 4 classes, computes the number of splines that belong to a class.
            %   This function Computes, For each of the 4 possible classes, the number
            %   of splines that belong to a class. actually, a cubic polynomial y can
            %   be expressed in one of the following three forms (classes):
            %   y = ax^3, y = ax^3 - px, y = ax^3 + px.
            %   The form (class) number 4 refers to the case in wich the a coefficient
            %   equals 0. If p > - tolerance & p < tolerance, then it is assumed that
            %   p = 0.
            %{
            if nargin < 4
                tolerance = 0.01;
            end
            %}
            csp = csapi(obj.time, signal);
            a_lt_0 = csp.coefs(:, 1) < 0;
            csp.coefs(a_lt_0, [1 3]) = csp.coefs(a_lt_0, [1 3]) * -1;
            p = csp.coefs(:, 3) - ((csp.coefs(:, 2) .^ 2) ./ (3 .* (csp.coefs(:, 1))));
            cases = zeros(size(p, 1), 1);
            cases(p < 0) = 1;
            cases(p > 0) = 2;
            %cases(p > - tolerance & p < tolerance | p == 0) = 3;
            %cases(isnan(p)) = 4;
            class_count = histcounts(cases, [1, 2, 3], "Normalization", obj.normalization);
            %{
            class_count = histcounts(csp.coefs,  binscount, ...
                'Normalization', 'probability');
            %}
        end
    end
end

