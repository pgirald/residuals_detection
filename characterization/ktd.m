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
        
            dR = [x(2:end)-x(1:end-1),y(2:end)-y(1:end-1),z(2:end)-z(1:end-1)];
            ds = sqrt(sum(dR.^2,2));
            s = [0;cumsum(ds)];%arc lengths
            
            dRds = [gradient(x,s),gradient(y,s),gradient(z,s)];
            
            T = dRds./sqrt(sum(dRds.^2,2));%unit tangent vector.
            
            dTds = [gradient(T(:,1),s),gradient(T(:,2),s),gradient(T(:,3),s)];
            
            N = dTds./sqrt(sum((dTds).^2,2));%unit normal vector.
            
            B = cross(T,N);%unit bi-normal vector.
        
            fsframe = [T,N,B];
        
            for i = 1:numel(obj.selectedFeats)
                %{
                angs = acos(fsframe(:, KTD.featsMap(obj.selectedFeats(i))));
                angs(angs < 0) = angs(angs < 0) + 2*pi;
                angs = round(obj.bins * (angs / (2*pi)));
                angs(angs == obj.bins) = 0;
                hists(j:j + obj.bins - 1) = histcounts(angs, 0:obj.bins, "Normalization", obj.normalization);
                %}
                hists(j:j + obj.bins - 1) = histcounts(fsframe(:, KTD.featsMap(obj.selectedFeats(i))), obj.bins,"Normalization",obj.normalization);
                j = j + obj.bins;
            end
        end
    end
end

