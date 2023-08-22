classdef KTD < Extractor
    %kinectics trayectory descriptor class.
    %Atually, the class computes something based and not exactly equal to
    %the kinectics trayectory descriptor.
    properties(Access=private)
        selectedFeats
        bins
        normalization
    end

    properties(Constant=true, Access=private)
        featsNames = ["txdir", "tydir", "tzdir", "nxdir",...
                "nydir" ,"nzdir" , "bxdir", "bydir", "bzdir"];
        featsMap = containers.Map(KTD.featsNames, 1:numel(KTD.featsNames));
    end
    methods
        function obj = KTD(args)
            arguments
                args.bins = 8;
                %Number of bins for each directions histogram
                args.selectedFeats {mustBeMember(args.selectedFeats,...
                    ["txdir", "tydir", "tzdir", "nxdir",...
                "nydir" ,"nzdir" , "bxdir", "bydir", "bzdir"])}= KTD.featsNames;
                %Specified features to be computed:
                %txdir: Unit tangent vector direction respect of x axis
                %tydir: Unit tangent vector direction respect of y axis
                %tzdir: Unit tangent vector direction respect of z axis
                %nxdir: Unit normal vector direction respect of x axis
                %nydir: Unit normal vector direction respect of y axis
                %nzdir: Unit normal vector direction respect of z axis
                %bxdir: Unit bi-normal vector direction respect of x axis
                %bydir: Unit bi-normal vector direction respect of y axis
                %bzdir: Unit bi-normal vector direction respect of z axis
                args.normalize (1,1) logical = true;
                %Specify if the directions histograms should be normalized
            end
            obj.selectedFeats = string(args.selectedFeats);
            checkmebership(obj.selectedFeats, KTD.featsNames);
            obj.bins = args.bins;
            if args.normalize
                obj.normalization = "probability";
            else
                obj.normalization = "count";
            end
        end
        function feature = extract(obj, s)
            %Extracts a feature based on the kinectics trayectory
            %descriptor
            feature = obj.ktd(s(:,1),s(:,2),s(:,3));
        end
        function headings = getHeadings(obj)
            headings = strings(1, obj.getFeatsCount());
            directions = string(0:obj.bins-1);
            j = 1;
            for i=1:numel(obj.selectedFeats)
                headings(j:j + obj.bins - 1)=...
                    strcat(obj.selectedFeats(i), "_", directions);
                j = j + obj.bins;
            end
        end
        function featsCount = getFeatsCount(obj)
            featsCount = numel(obj.selectedFeats)*obj.bins;
        end
        function type = getFeatsType(~)
            type = "double";
        end
    end
    methods (Access=private)
        function [hists] = ktd(obj, x, y, z)
            hists = zeros(1, numel(obj.selectedFeats) * obj.bins);
            j = 1;
        
            dr = [gradient(x(:)) , gradient(y(:)) , gradient(z(:))];
	        ds = sum(dr.^2,2).^(0.5); % Arc length associated with each point. ||dr||.
	        
	        T = dr ./ ds; % Unit tangent vector.
	        
	        dT = [gradient(T(:,1)) , gradient(T(:,2)) , gradient(T(:,3))]; % T'(t).
	        dTds = dT ./ ds;
	        
	        kappa = sum((dT./ds).^2,2).^(0.5);
	        
	        N = dTds ./ kappa; % Unit normal vector.
	        
	        B = cross(T,N); % Unit bi-normal vector.
        
            fsframe = [T,N,B];
        
            for i = 1:numel(obj.selectedFeats)
                angs = acos(fsframe(:, KTD.featsMap(obj.selectedFeats(i))));
                angs(angs < 0) = angs(angs < 0) + 2*pi;
                angs = round(obj.bins * (angs / (2*pi)));
                angs(angs == obj.bins) = 0;
                hists(j:j + obj.bins - 1) = histcounts(angs, 0:obj.bins, "Normalization", obj.normalization);
                %hists(j:j + obj.bins - 1) = histcounts(angs, obj.bins);
                j = j + obj.bins;
            end
        end
    end
end

