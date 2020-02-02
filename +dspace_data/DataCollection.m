classdef DataCollection < handle
    % A DataCollection is a collection of several Datasources. Data-collections 
    % and datasources are explained in broad terms here:
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction to Dataspace (Dataspace Help)</a>
    %
    % A DataCollection contains: 
    % - .sources which is a struct of cell arrays that can hold datasources
    %   several "levels"; e.g.: sources.main{1} refers to the first sources on the 
    %   main level; 
    %   the levels are numbered and .sources{1}{1} returns the first source 
    %   on the first level; .sources{2}{1} returns the first source on the 
    %   second level and so on.
    %
    % To create a DataCollection use the constructor of this class (examples below). 
    % 
    % Tutorials on importing data and creating datasources and DataCollections 
    % can be found here: 
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction to Dataspace (Dataspace Help)</a>
    %
    % To load and save DataCollections use the functions:
    % <a href="matlab:doc('dspace_data.loadCollection')">dspace_data.loadCollection()</a>
    % <a href="matlab:doc('dspace_data.saveCollection')">dspace_data.saveCollection()</a>
    %
    % For a given DataCollection use collection.info(true) to print detailed 
    % information to the console (see <a href="matlab:doc('dspace_data.DataCollection/info')">dspace_data.DataCollection/info()</a>).
    %
    %
    % Examples
    % --------
    %
    % % 1. Creating a Data-collection and inserting Datasources
    %
    % % make TableDataSource with 100 datapoints:
    % source1 = dspace(randn(100, 10), randn(100, 1));         
    %
    % % insert the source into a Data-collection; the default level is called "main":
    % collection = dspace_data.DataCollection({{source1}}, [], 'MyCollection');
    %
    % % make another TableDataSource with 100 datapoints:
    % source2 = dspace(randn(100, 10), randn(100, 1));         
    %
    % % insert the new source into existing Data-collection on level "main":
    % collection.insertSource(source2, 'main');                
    %
    % % dspace(collection); % start the Dataspace GUI
    %
    % See also dspace_data.TableDataSource, dspace_data.saveCollection, dspace_data.loadCollection.
    %
    %
    % 
    %
    %<PRE>
    % This file is part of dspace-core.
    %
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen
    %
    % This program is free software: you can redistribute it and/or modify
    % it under the terms of the GNU Affero General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or
    % (at your option) any later version.
    %
    % This program is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU Affero General Public License for more details.
    %
    % You should have received a copy of the GNU Affero General Public License
    % along with this program (see LICENSE file).  If not, see <https://www.gnu.org/licenses/>.
    % </PRE>
    % <b>Dataspace on Github</b>: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a>

    
     properties (Access=public, Dependent)
        % Name of this data-collection
        Name 
        
        % Total number of datasources across all levels in this collection
        Nsources
        
        % Number of levels in this collection
        Nlevels
        
        % Names of all elvels in order
        LevelNames
        
        % Datasources in this data-collection
        Sources
        
        % Total size of the collection in megabytes (computed as the sum of the sizes of all datasources).
        Megabytes
        
        % Total size of the collection in gigabytes (computed as the sum of the sizes of all datasources).
        Gigabytes
     end
    
    % Internal and legacy properties
    properties (Access=public, Hidden=true)
        
        % A name for this Data-collection (string)
        name
        
        % Struct array where each element is a cell array of datasources
        % e.g. .main{1} ... 
        %      .summaries{1} ...
        sources = struct();
        
    end
    
    properties (Access=public, Hidden=true, Transient)
        
        % Additional information reagrding the data-collection
        % this is currently unused
        pointFilters = {};
        % Additional information reagrding the data-collection
        % this is currently unused
        pointHighlights = {};
        % Additional information reagrding the data-collection
        % this is currently unused
        dataviews = {};
        
    end
     
    % Getters and Setters
    methods
        
        function value = get.Nlevels(obj)
            value = numel(obj.getLevelNames());
        end
        function value = get.Nsources(obj)
            nsources = 0;
            levelNames = obj.getLevelNames();
            for k = 1:numel(levelNames)
                nsources = nsources + numel(obj.getSourceNames(levelNames{k}));
            end
            value = nsources;
        end
        function value = get.Name(obj)
            value = obj.name;
        end
        function value = get.Sources(obj)
            value = obj.sources;
        end
        function value = get.Megabytes(obj)
            value = obj.getMegabytes();
        end
        function value = get.Gigabytes(obj)
            value = obj.Megabytes/1024;
        end
        function value = get.LevelNames(obj)
            value = obj.getLevelNames();
        end
        function set.Name(obj, value)
            obj.name = value;
        end
        function set.Sources(obj, value)
            obj.sources = value;
        end
        
    end
        
    methods (Access=public, Hidden=true)
        
        function registry = getRegistry(obj)
            registry.storedPointFilters = obj.pointFilters;
            registry.storedPointHighlights = obj.pointHighlights;
            registry.dataviews = obj.dataviews;
        end
        
        function setRegistry(obj, registry)
            obj.pointFilters = registry.storedPointFilters;
            obj.pointHighlights = registry.storedPointHighlights;
            obj.dataviews = registry.dataviews;
        end
        
    end
    
    methods (Access=public)
    
        function obj = DataCollection(array, levelNames, name)
        % Use this constructor to create DataCollections.
        % array - cell array of cell arrays of dspace_data.DataSource
        % levelNames - cell array of strings 
        % name - name of this Data-collection (string)
            obj.name = name;
            for j = 1:numel(array)
                if nargin > 1 && ~isempty(levelNames) && numel(levelNames) >= j...
                        && ~isempty(levelNames{j})
                    levelName = levelNames{j};
                else
                    if j == 1
                        levelName = 'main';
                    else
                        levelName = sprintf('aux%i', j-1);
                    end
                end
                if numel(array{j}) > 0
                    obj.sources.(levelName) = cell(1, numel(array{j}));
                    for k = 1:numel(array{j})
                        obj.sources.(levelName){k} = array{j}{k};
                        obj.sources.(levelName){k}.parentCollection = obj;
                    end
                end
            end
        end
        
        function names = getPointFilterNames(obj)
            names = cellfun(@(x) x.name, obj.pointFilters, 'uni', false);
        end
        
        function names = getPointHighlightNames(obj)
            names = cellfun(@(x) x.name, obj.pointHighlights, 'uni', false);
        end
        
        function [pfc, i] = getPointFilterByName(obj, pfName)
            n = obj.getPointFilterNames();
            i = find(strcmp(pfName, n));
            if ismepty(i)
                pfc = [];
            else
                pfc = obj.pointFilters{i};
            end
        end
        
        function [phc, i] = getPointHighlightByName(obj, phName)
            n = obj.getPointHighlightNames();
            i = find(strcmp(phName, n));
            if ismepty(i)
                phc = [];
            else
                phc = obj.pointHighlights{i};
            end
        end
        
        function addPointFilter(obj, pfc, doReplace)
            i = obj.getPointFilterByName(pfc.name);
            if isempty(i)
                obj.pointFilters{end+1} = pfc;
            else
                if doReplace
                    obj.pointFilters{i} = pfc;
                end
            end
        end
        
        function addPointHighlight(obj, ph, doReplace)
            i = obj.getPointHighlightsByName(ph.name);
            if isempty(i)
                obj.pointHighlights{end+1} = ph;
            else
                if doReplace
                    obj.pointHighlights{i} = ph;
                end
            end
        end
        
        function [array] = getNestedCellArray(obj)
            % Returns a two-level cell array containing all datasources from all levels of this collection.
            levelNames = obj.getLevelNames();
            array = cell(1, numel(levelNames));
            for j = 1:numel(levelNames)
                array{j} = cell(1, numel(obj.sources.(levelNames{j})));
                for k = 1:numel(obj.sources.(levelNames{j}))
                    array{j}{k} = obj.sources.(levelNames{j}){k};
                end
            end
        end
        
        function names = getLevelNames(obj)
            % Returns a cell array with the names of all levels in this collection. 
            names = fieldnames(obj.sources);
            names = sort(names);
            names = obj.permuteStringOptions(names, 'main');
        end
        
        function source = fetchSource(obj, nameOrSource, levelName)
            % Returns a specific datasource or [] if the source couldn't be found.
            % nameOrSource - can be a TableDataSource or a string (the source 
            % name)
            % levelName - string specifying the level
            %
            % See also dspace_data.DataCollection/getLevel.
            if ~isfield(obj.sources, levelName)
                source = [];
                return;
            end
            for k = 1:numel(obj.sources.(levelName))
                source = obj.sources.(levelName){k};
                if dspace.isDatasource(nameOrSource)
                    if source == nameOrSource
                        return;
                    end
                else
                    if strcmp(source.getName(), nameOrSource)
                        return;
                    end
                end
            end
            source = [];
        end
        
        function [levelName] = getLevel(obj, nameOrSource)
            % Returns the level name for a specific datasource or [] if the source couldn't be found.
            % nameOrSource - can be a TableDataSource or a string (the source 
            % name)
            cnames = obj.getLevelNames();
            for j = 1:numel(cnames)
                levelName = cnames{j};
                if ~isempty(obj.fetchSource(nameOrSource, levelName))
                    return;
                end
            end
            levelName = [];
        end
        
        
        function [k] = getIndexInLevel(obj, nameOrSource, levelName)
            % Returns the index of a specific datasource in the given level or [] if the source couldn't be found.
            % nameOrSource - can be a DataSource or a string
            % levelName - string
            if isempty(levelName)
                k = [];
                return;
            end
            if dspace.isDatasource(nameOrSource)
                for k = 1:numel(obj.sources.(levelName))
                    ss = obj.sources.(levelName){k};
                    if ss == nameOrSource 
                        return;
                    end
                end
                k = [];
            else
                for k = 1:numel(obj.sources.(levelName))
                    ss = obj.sources.(levelName){k};
                    if strcmp(ss.getName(), nameOrSource)
                        return;
                    end
                end
                k = [];
            end
        end
                
        function names = getSourceNames(obj, levelName)
            % Returns a cell array with the names of all datasources in the specified level. 
            % If the level doesn't exist, {} is returned.
            % levelName - string
            if ~isfield(obj.sources, levelName)
                names = {};
                return;
            end
            names = cell(1, numel(obj.sources.(levelName)));
            for k = 1:numel(obj.sources.(levelName))
                source = obj.sources.(levelName){k};
                names{k} = source.getName();
            end
        end
        
        function index = insertSource(obj, source, levelName)
            % Inserts a new source at the end of the given level.
            % There is no check for name duplicates. The index of the newly 
            % inserted source is returned.
            if ~ismember(levelName, obj.getLevelNames())
                obj.sources.(levelName) = {};
            end
            
            sourceNames = obj.getSourceNames(levelName);
            if ismember(source.getName(), sourceNames)
                fprintf('DataCollection.insertSource: A source named %s already exists. It will be overwritten.\n',...
                    source.getName()); 
                idx = obj.getIndexInLevel(source.getName(), levelName);
                obj.sources.(levelName){idx}.parentCollection = [];
                obj.sources.(levelName){idx} = source;
                index = idx;
            else
                obj.sources.(levelName){end+1} = source;
                index = numel(obj.sources.(levelName));
            end
            source.parentCollection = obj;
        end
        
        function obj = info(obj, isVerbose)
            if nargin == 1
                isVerbose = false;
            end
            fprintf('----- DataCollection: %s (%i levels, %i sources) -----\n', obj.name, obj.Nlevels, obj.Nsources);
            %fprintf('%3i Levels, %3i Sources.\n', obj.Nlevels, obj.Nsources);
            levelNames = obj.getLevelNames();
            totalMB = 0;
            for j = 1:numel(levelNames)
                fprintf('   ----- Level .%s (%3i sources):\n', levelNames{j}, numel(obj.sources.(levelNames{j})));
                for k = 1:numel(obj.sources.(levelNames{j}))
                    s = obj.sources.(levelNames{j}){k};
                    
                    mb = s.getMegabytes(false);
                    fprintf('%3i (%8s gb): Source %s\n', k, sprintf('%.3f', mb/1024), s.getName());
                    if isVerbose
                        s.getMegabytes(true);
                    end
                    totalMB = totalMB + mb;
                end
            end
            fprintf('Number of point-filters: %i\n', numel(obj.pointFilters));
            fprintf('Number of point-highlights: %i\n', numel(obj.pointHighlights));
            fprintf('Number of dataviews: %i\n', numel(obj.dataviews));
            fprintf('Total size of collection: %.2f gb\n', totalMB/1024);
        end
        
        function totalMB = getMegabytes(obj)
            levelNames = obj.getLevelNames();
            totalMB = 0;
            for j = 1:numel(levelNames)
                %fprintf(' Level .%s:\n', levelNames{j});
                for k = 1:numel(obj.sources.(levelNames{j}))
                    s = obj.sources.(levelNames{j}){k};
                    
                    mb = s.getMegabytes(false);
                    %fprintf('  %3i: Source %s, Size: %5i mb\n', k, s.getName(), round(mb));
%                     if isVerbose
%                         s.getMegabytes(true);
%                     end
                    totalMB = totalMB + mb;
                end
            end
        end
        
        function forceDeletion(obj)
            if ~isempty(obj.sources) && isstruct(obj.sources)
                f = fieldnames(obj.sources);
                for k = 1:numel(f)
                    lev = obj.sources.(f{k});
                    if ~isempty(lev) && iscell(lev)
                        for j = 1:numel(lev)
                            if ~isempty(lev{j}) && isa(lev{j}, 'dspace_data.TableDataSource')
                                lev{j}.forceDeletion();
                                lev{j} = [];
                            end
                        end
                    end
                end
                obj.sources = [];
            end
        end
        
    end
    
    % Internal methods
    methods
         function varargout = subsref(obj,S)
            switch S(1).type
                case '{}'
                    if numel(S) == 1
                        levelNames = obj.getLevelNames();
                        assert(numel(S(1).subs) == 1);
                        varargout{1} = obj.sources.(levelNames{S(1).subs{1}});
                    elseif numel(S) >= 2 && strcmp(S(2).type, '{}')
                        levelNames = obj.getLevelNames();
                        assert(numel(S(1).subs) == 1 && numel(S(2).subs) == 1);
                        src = obj.sources.(levelNames{S(1).subs{1}}){S(2).subs{1}};
                        if numel(S) > 2
                            [varargout{1:nargout}] = subsref(src, S(3:end));
                        else
                            varargout{1} = src;
                        end
                    end
                otherwise
                    [varargout{1:nargout}] = builtin('subsref', obj, S);
            end
         end
    end
   
    % Internal methods
    methods (Access=private)
        
        function stringCell = permuteStringOptions(obj, options, primary)
            if size(options, 2) == 1
                options = options';
            end
            if isempty(primary)
                stringCell = options;
                return
            end
            idx = find(strcmp(options, primary), 1);
            if isempty(idx)
                stringCell = options;
                return;
            end
            stringCell = [options(idx), options([1:idx-1 idx+1:end])];
        end
        
    end

     % Hide handle class methods
    methods (Hidden=true)
        function lh = addlistener(varargin)
            lh = addlistener@handle(varargin{:});
        end
        function notify(varargin)
            notify@handle(varargin{:});
        end
        function delete(obj)
            delete@handle(obj);
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@handle(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@handle(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
    end
   
    
end

