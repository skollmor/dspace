classdef TableDataSource < dspace_data.DataSource
    % A TableDataSource holds data in Dataspace. The concept of datasources
    % is explained in broad terms here:
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction to Dataspace (Dataspace Help)</a>.
    %
    % A TableDataSource contains:
    % - property table, for low-D properties like labels (.L)
    % - property definitions for additional information on properties in the
    %   property table (.Ldef)
    % - coordinates, for high-D representation like images (.F)
    % - directed unweighted graphs, e.g. for nearest neighbors (.G)
    %
    % To create datasources you can use the methods of this class or the convenient
    % and simple function <a href="matlab:doc('dspace')">dspace</a> (see examples below).
    %
    % Tutorials on importing data and creating datasources can be found here:
    % <a href="matlab:dspace.help('dspace.resources.docs.Importing_Data')">Tutorial on Creating Datasources and Importing Data (Dataspace-Help)</a>.
    %
    % For a given Datasource use source.info(true) to print detailed
    % information to the console.
    %
    % TableDataSources are grouped in <a href="matlab:doc('dspace_data.DataCollection')">Data-collections</a>.
    % TableDatasources are loaded and saved via Data-collections.
    %
    %
    % Properties or Labels (.L) and Property Definitions (.Ldef)
    % ------------------------------------------------
    %
    % The property table .L contains double values only. Each column is a double
    % vector. Other datatypes, such as strings are converted to double.
    % The mapping between the original strings and the new double values is
    % then given by a property definition (.Ldef.var).
    % See <a href="matlab:doc('dspace_data.PropertyDefinition')">dspace_data.PropertyDefinition</a>.
    %
    % % Example of categorical variable and corresponding property definition
    % img_label = {'cat', 'dog', 'dog', 'cat', 'dog', 'cat', 'cat', 'cat'};
    % img_id = 1:8;
    % source = dspace(img_label', img_id')
    % source.Ldef.img_label
    %
    %
    % Features (.F)
    % ----------------
    %
    % <a href="matlab:doc('dspace_features.AbstractFeatures')">dspace_features.AbstractFeatures</a>.
    % Coordinates can be accessed in multiple ways:
    % source.L('coordinate name')
    % source.L{idx}
    %
    %
    % Examples
    % --------
    %
    % % 1. Creating a TableDataSource using the dspace() function:
    % imgs = randn(10000, 100, 100);                 % make random images
    % imgs = convn(imgs, ones(1, 10, 10), 'same');   % smooth the images (looks cool)
    % random_values = randn(10000, 1);               % create some random values
    % source = dspace(random_values, imgs);          % make TableDataSource
    % source.Name = "Example Random Data";           % name the source
    %
    % % 2. Creating an equivalent source using only the TableDataSource class:
    % imgs = randn(10000, 100, 100);                                   % make random images
    % imgs = convn(imgs, ones(1, 10, 10), 'same');                     % smooth the images (looks cool)
    % random_values = randn(10000, 1);                                 % create some random values
    % source = dspace_data.TableDataSource("Example Random Data");  % make TableDataSource
    % source.addLabels(random_values);                               % add variable
    % source.addFeatures(imgs);                                      % add coordinates
    %
    % % dspace(source); % start the Dataspace GUI
    %
    % (c) 2015-2019, Sepp Kollmorgen, All Rights Reserved.
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
        % A name for this datasource. Make sure to use unique names within a collection.
        Name
        
        % Labels table (Matlab <a href="matlab:doc('table')">table</a>)
        L
        
        % Property definitions (struct with field names like variables in P). Note: not all properties need to provide a property definition.
        Ldef
        
        % Features (cell array of <a href="matlab:doc('dspace_features.AbstractFeatures')">dspace_features.AbstractFeatures</a>). Can also be accessed as .C('coordinateName').
        F
        
        % Graphs (cell array of <a href="matlab:doc('dspace_graphs.AbstractGraph')">dspace_graphs.AbstractGraph</a>). Can also be accessed as .LG('lgName').
        G
        
        % Number of datapoints (int value)
        N
        
        % An identifier that should be unique among all datasources ever created.
        UniqueIdentifier
        
        % The data-collection containing this datasource.
        ParentCollection
        
        % Can be used to store additional custom data with a datasource. The size of various should not exceed 2gb.
        Various
        
        % Log of actions taken on this datasource
        Log
        
        % The sum of the sizes of all datasources in this collection.
        Megabytes
    end
    
    % Legacy & Internal properties
    properties (Access=public, Hidden=true, Transient=true)
        % Data-collection that contains this datasource.
        parentCollection
    end
    
    properties (Access=public, Hidden=true, Dependent)
        % Size of this datasource in megabytes (double-value)
        megabytes
        % Property table (Matlab <a href="matlab:doc('table')">table</a>)
        P
        
        % Property definitions (struct with field names like variables in P). Note: not all properties need to provide a property definition.
        Pdef
        
        % Coordinates (cell array of <a href="matlab:doc('dspace_features.AbstractFeatures')">dspace_features.AbstractFeatures</a>). Can also be accessed as .C('coordinateName').
        C
        
        % "Local groups" or neighborhood definitions (cell array of <a href="matlab:doc('dspace_graphs.AbstractGraph')">dspace_graphs.AbstractGraph</a>). Can also be accessed as .LG('lgName').
        LG
    end
    
    properties (Access=public, Hidden=true, SetObservable, GetObservable)
        % name of this datasource (string or char array)
        name
        % UID this datasource (string or char array)
        uniqueIdentifier
        % struct to store various user-defined info
        various
    end
    
    properties (Access=public, Hidden=true, SetObservable, GetObservable)
        Xprops                  % table of variables. Rows are datapoints, columns are properties.
        % Currently all variables should be doubles.
        XpropDefinitions        % struct-array, additional information about some of the columns in Xprops
        coordinates             % cell array of instances of descendants of the dspace_features.AbstractFeatures class
        localGroupDefinitions   % cell array of instances of descendants of the dspace_graphs.AbstractGraph class
    end
    
    properties (GetAccess=public, SetAccess=public, Hidden=true)
        actionLog = {};
    end
    
    properties (Access=private, Hidden=true)
        Xv % deprecated
        lastLocalGroup_ids = [];
        lastLocalGroup_distances = [];
        lastLGPointId = NaN;
        lastLGGroupId = NaN;
    end
    
    % Getters and Setters
    methods
        
        function rt = get.P(obj)
            rt = obj.Xprops;
        end
        function rt = get.Pdef(obj)
            rt = obj.XpropDefinitions;
        end
        function rt = get.C(obj)
            rt = obj.coordinates;
        end
        function rt = get.LG(obj)
            rt = obj.localGroupDefinitions;
        end
        function rt = get.L(obj)
            rt = obj.Xprops;
        end
        function rt = get.Ldef(obj)
            rt = obj.XpropDefinitions;
        end
        function rt = get.F(obj)
            rt = obj.coordinates;
        end
        function rt = get.G(obj)
            rt = obj.localGroupDefinitions;
        end
        
        function rt = get.N(obj)
            rt = obj.getNumberOfPoints();
        end
        function rt = get.Name(obj)
            rt = obj.name;
        end
        function rt = get.UniqueIdentifier(obj)
            rt = obj.uniqueIdentifier;
        end
        function rt = get.ParentCollection(obj)
            rt = obj.parentCollection;
        end
        function rt = get.Various(obj)
            rt = obj.various;
        end
        function rt = get.Megabytes(obj)
            rt = obj.megabytes;
        end
        function rt = get.Log(obj)
            rt = obj.actionLog;
        end
        
        function set.P(obj, value)
            obj.Xprops = value;
        end
        function set.Pdef(obj, value)
            obj.XpropDefinitions = value;
        end
        function set.C(obj, value)
            obj.coordinates = value;
        end
        function set.LG(obj, value)
            obj.localGroupDefinitions = value;
        end
         function set.L(obj, value)
            obj.Xprops = value;
        end
        function set.Ldef(obj, value)
            obj.XpropDefinitions = value;
        end
        function set.F(obj, value)
            obj.coordinates = value;
        end
        function set.G(obj, value)
            obj.localGroupDefinitions = value;
        end
        function set.Name(obj, value)
            obj.name = value;
        end
        function set.UniqueIdentifier(obj, value)
            obj.uniqueIdentifier = value;
        end
        function set.ParentCollection(obj, value)
            obj.parentCollection = value;
        end
        function set.Various(obj, value)
            obj.various = value;
        end
        
        % Legacy & internal properties
        function rt = get.megabytes(obj)
            rt = obj.getMegabytes();
        end
        
    end
    
    % Constructor
    methods (Access=public)
        function obj = TableDataSource(inputData)
            % Constructor. You can use this constructor in various ways. The first argument:
            % can be a string, in which case an empty datasource is created with the given
            % string as name. The first argument can be a table, in which case the table
            % is used as the property table.
            %
            % It is typically more convenient to use the dspace function to create
            % datasources.
            %
            % See also dspace.
            
            if ischar(inputData)
                
                obj.name = inputData;
                obj.Xprops = table();
                obj.XpropDefinitions = [];
                
            elseif istable(inputData)
                
                obj.Xprops = inputData;
                obj.XpropDefinitions = dspace_data.PropertyDefinition.createDefaultDefinitions(obj.Xprops);
                if ~isempty(inputData.Properties.Description)
                    obj.name = inputData.Properties.Description;
                else
                    obj.name = '';
                end
                
            end
            
            % Generate UID
            try
                [~, hostname] = system('hostname');
                hostname = hostname(1:end-1); % delete \n
            catch
                hostname = 'unknownHost';
            end
            obj.uniqueIdentifier = sprintf('%s|%s|%s', obj.name, datestr(now, 'yyyy-mm-dd-HH:MM:FFF'), hostname);
            
            obj.localGroupDefinitions = {dspace_graphs.TrivialGraph()};
            obj.localGroupDefinitions{1}.initialize(obj);
            
            if isempty(obj.name)
                obj.name = obj.uniqueIdentifier;
            end
            
        end
    end
    
    methods (Access=public)
        
        function clearActionLog(obj)
            obj.actionLog = {};
        end
        
        function printActionLog(obj)
            for k = 1:numel(obj.actionLog)
                obj.actionLog{k}.printCode(k);
            end
        end
        
        function logAction(obj, actionRt)
            obj.actionLog{end+1} = actionRt;
        end
        
        function idx = addFeatures(obj, coordinates, doReplace)
            if ~isempty(obj.getCoordinatesByIdentifier(coordinates.getIdentifier()))
                if nargin == 3 && doReplace
                    [~, idx] = obj.getCoordinatesByIdentifier(coordinates.getIdentifier());
                    obj.coordinates{idx} = coordinates;
                else
                    error('TableDataSource.addCFeatures: Features with the name %s already exist.',...
                        coordinates.getIdentifier());
                end
            else
                obj.coordinates{end+1} = coordinates;
                idx = numel(obj.coordinates);
            end
            coordinates.initialize(obj);
        end
        
        function idx = addGraph(obj, graphDef, doReplace)
            if ~isempty(obj.getLocalGroupDefByName(graphDef.getName()))
                if nargin == 3 && doReplace
                    [~, idx] = obj.getLocalGroupDefByName(graphDef.getName());
                    obj.localGroupDefinitions{idx} = graphDef;
                else
                    error('TableDataSource.addGraph: A graph with the name %s already exists.',...
                        graphDef.getName());
                end
            else
                obj.localGroupDefinitions{end+1} = graphDef;
                idx = numel(obj.localGroupDefinitions);
            end
            graphDef.initialize(obj);
        end
        
        function pnames = getPropertyNames(obj)
            pnames = obj.Xprops.Properties.VariableNames;
        end
        
        function lgNames = getGraphNames(obj)
            lgDefs = obj.LG;
            lgNames = cell(1, numel(lgDefs));
            for j = 1:numel(lgDefs)
                if ~isempty(lgDefs{j})
                    lgNames{j} = lgDefs{j}.getName();
                else
                    lgNames{j} = '';
                end
            end
        end
         
        function featureNames = getFeatureNames(obj, featureClassName)
            % If called with 0 (not counting obj) arguments, this function returns the names 
            % of all features in the datasource.
            %
            % If called with the additional argument featureClassName only features that
            % are derived from/implement the given class are returned. 
            if nargin > 1 && ~isempty(featureClassName)
                valid = arrayfun(@(i) isa(obj.C{i}, featureClassName), 1:numel(obj.C));
            else
                valid = true(1, numel(obj.C));
            end
            
            featureNames = arrayfun(@(i) obj.C{i}.getIdentifier(),...
                find(valid), 'uni', false);
        end
        
        function info(obj, isVerbose)
            if nargin == 1
                isVerbose = true;
            end
            fprintf('----- %s -----\n', obj.getName);
            fprintf('#Pts: %i; UID: %s\n', obj.N, obj.getUniqueIdentifier());
            mb = obj.getMegabytes(isVerbose);
            fprintf('TOTAL: %.3f GB\n\n', mb/1024);
        end
        
    end
    
    methods (Access=public, Hidden=true)

        function addedIds = addPtsToDatasource(obj, n)
            % Adds n new datapoints to the end
            % This function extends the label table, features and graphs
            addedIds = size(obj.P, 1) + (1:n);
            newVals = mat2cell(NaN(n, size(obj.P, 2)), n, ones(1, size(obj.P, 2)));
            newVals = table(newVals{:});
            obj.P(end+1:end+n, :) = newVals;
            for cid = 1:numel(obj.C)
                obj.C{cid}.addPtsToDatasource(obj, n);
            end
            for lgid = 1:numel(obj.LG)
                obj.LG{lgid}.addPtsToDatasource(obj, n);
            end
        end
        
        function convertAllVariablesToDouble(obj)
            varnames = obj.P.Properties.VariableNames;
            for vi = 1:numel(varnames)
                obj.P.(varnames{vi}) = double(obj.P.(varnames{vi}));
            end
        end
        
        function mbytes = getMegabytes(obj, isVerbose)
            if nargin == 1
                isVerbose = false;
            end
            
            l1_indent_str = '%30';
            l2_indent_str = '%40';
            l3_indent_str = '%45';
            l4_indent_str = '%70';
            
            
            bytes = 0;
            if isVerbose
                XP = obj.Xprops; %#ok<NASGU>
                q = whos('XP'); clear XP;
                fprintf([l1_indent_str 's:\n'],  sprintf('------- LABELS (%i)',  numel(obj.P.Properties.VariableNames)));
                fprintf([l2_indent_str 's     : %10s\n'], sprintf('%i Label(s) in .L', numel(obj.P.Properties.VariableNames)),...
                    sprintf('%.3f gb', q.bytes/1024^3));
                if ~isempty(obj.XpropDefinitions)
                    XPD = obj.XpropDefinitions; %#ok<NASGU>
                    q = whos('XPD'); clear XPD;
                    fprintf([l2_indent_str 's     : %10s\n'], sprintf('%i Label Property Definition(s) in .Ldef',...
                        numel(fieldnames(obj.XpropDefinitions))), sprintf('%.3f gb', q.bytes/1024^3));
                end
            end
            
            if isVerbose
                fprintf([l1_indent_str 's:\n'],  sprintf('----- FEATURES (%i)', numel(obj.coordinates)));
            end
            for k = 1:numel(obj.coordinates)
                if isVerbose
                    fprintf([l2_indent_str 's (%2i): %10s    (%s)\n'], obj.coordinates{k}.getIdentifier, k,...
                        sprintf('%.3f gb', double(obj.coordinates{k}.getMegabytes())/1024),...
                        class(obj.coordinates{k}));
                end
                bytes = bytes + obj.coordinates{k}.getMegabytes() * 1024^2;
            end
            if isVerbose
                fprintf([l1_indent_str 's:\n'],  sprintf('------- GRPAHS (%i)', numel(obj.localGroupDefinitions)));
            end
            for k = 1:numel(obj.localGroupDefinitions)
                if isVerbose
                    fprintf([l2_indent_str 's (%2i): %10s    (%s)\n'],  obj.localGroupDefinitions{k}.getName(), k,...
                        sprintf('%.3f gb', double(obj.localGroupDefinitions{k}.getMegabytes())/1024),...
                        class(obj.localGroupDefinitions{k}));
                end
                bytes = bytes + obj.localGroupDefinitions{k}.getMegabytes() * 1024^2;
            end
            if isVerbose
                fprintf([l1_indent_str 's:\n'],  '------- OTHERS (1)');
            end
            XP = obj.Xprops; %#ok<NASGU>
            q = whos('XP'); clear XP;
            bytes = bytes + q.bytes;
            if isVerbose
                %fprintf('%60s: %.3f gb\n',  '.Xprops', q.bytes/1024^3);
            end
            Xv_ = obj.Xv; %#ok<NASGU>
            q = whos('Xv_'); clear Xv_;
            bytes = bytes + q.bytes;
            XPD = obj.XpropDefinitions; %#ok<NASGU>
            q = whos('XPD'); clear XPD;
            if isVerbose
                %fprintf('%60s: %.3f gb\n',  '.XpropDefinitions', q.bytes/1024^3);
            end
            bytes = bytes + q.bytes;
            var = obj.various; %#ok<NASGU>
            q = whos('var'); clear var;
            if isVerbose
                fprintf([l3_indent_str 's: %10s\n'],  '.various     ', sprintf('%.3f gb', q.bytes/1024^3));
            end
            bytes = bytes + q.bytes;
           
             if isVerbose
                fprintf([l1_indent_str 's:\n'],  sprintf('----- ACTIONS (%i)', numel(obj.actionLog)));
             end
            nActions = 6;
            k_min = max(1, numel(obj.actionLog)-nActions+1);
            if isVerbose && k_min > 1
                fprintf([l2_indent_str 's\n'],  '...');
            end
            for k = k_min:numel(obj.actionLog)
                if isVerbose
                    fprintf([l4_indent_str 's (%2i): %10s\n'],  obj.actionLog{k}.getDescriptor(), k,...
                        sprintf('%.3f mb', double(obj.actionLog{k}.getMegabytes()))); %,...
                        %class(obj.actionLog{k}));
                end
                bytes = bytes + obj.actionLog{k}.getMegabytes() * 1024^2;
            end
          
            mbytes = bytes / 1024^2;
        end
        
        function dsg = getSummaryGraph(obj, includeActions, includeFeatures, includeGraphs, includeLabels)
            
            nodeNames = {};
            nodeTypes = [];
            nodeObjects = {};
            
            edges_src = {};
            edges_dest = {};
            K = 0;
            if includeActions
                for i = 1:numel(obj.actionLog)
                    nodeNames{K+1} = ['FCN: ' obj.actionLog{i}.getDescriptor() '[' num2str(i) ']'];
                    nodeObjects{K+1} = obj.actionLog{i};
                    nodeTypes(K+1) = dspace_data.DataSummaryGraph.NODETYPE_MODULEFCN;
                    K = K + 1;
                end
            end
            
            if includeFeatures
                for i = 1:numel(obj.coordinates)
                    nodeNames{K+1} = ['.C: ' obj.coordinates{i}.identifier()];
                    nodeObjects{K+1} = obj.coordinates{i};
                    nodeTypes(K+1) = dspace_data.DataSummaryGraph.NODETYPE_COORDINATES;
                    K = K + 1;
                    if isprop(obj.coordinates{i}, 'ParentCoordinates')
                        if ~obj.coordinates{i}.isInitialized()
                            obj.coordinates{i}.initialize(obj);
                        end
                        if obj.coordinates{i}.isInitialized()
                            % ParentCoordinates could be found
                            p_name = obj.coordinates{i}.ParentCoordinates.identifier();
                            edges_src{end+1} = ['.C: ' p_name];
                            edges_dest{end+1} = ['.C: ' obj.coordinates{i}.identifier()];
                        end
                    end
                end
            end
            
            if includeGraphs
                for i = 1:numel(obj.localGroupDefinitions)
                    if ~isprop(obj.localGroupDefinitions{i}, 'Name')
                        continue;
                    end
                    nodeNames{K+1} = ['.LG: ' obj.localGroupDefinitions{i}.Name];
                    nodeObjects{K+1} = obj.localGroupDefinitions{i};
                    nodeTypes(K+1) = dspace_data.DataSummaryGraph.NODETYPE_LOCALGROUP;
                    K = K + 1;
                end
            end
            
            if includeLabels
            end
            
            missing_nodes = nodeNames(~ismember(nodeNames, edges_src) & ~ismember(nodeNames, edges_dest));
            
            edges_src(end+1:end+numel(missing_nodes)) = missing_nodes;
            edges_dest(end+1:end+numel(missing_nodes)) = missing_nodes;
            
            
            G = digraph(edges_src, edges_dest, 'omitselfloops');
            
            orderedNames = G.Nodes.Name';
            orderedTypes = nodeTypes(cellfun(@(x) find(strcmp(x, nodeNames)), orderedNames));
            orderedObjects = nodeObjects(cellfun(@(x) find(strcmp(x, nodeNames)), orderedNames));
            
            dsg = dspace_data.DataSummaryGraph(orderedNames, orderedTypes,...
                edges_src, edges_dest, orderedObjects);
            dsg.graph = G;
        end 
    end
    
    % Internal & legacy methods (public for legacy reasons)
    methods (Access=public, Hidden=true)
        
        function idx = addCoordinates(obj, coordinates, doReplace)
            if nargin < 3
                doReplace = false;
            end
            idx = addFeatures(obj, coordinates, doReplace);
        end
        
        function idx = addLocalGroup(obj, localGroupDef, doReplace)
            idx = addGraph(obj, localGroupDef, doReplace);
        end
        
        function lgNames = getLocalGroupNames(obj)
            lgNames = obj.getGraphNames();
        end
        
        function coordinateIdentifiers = getCoordinateIdentifiers(obj)
             coordinateIdentifiers = getFeatureNames(obj);
        end
       
        function [coordinates, coordId] = getCoordinatesByIdentifier(obj, identifier)
            ci = obj.getCoordinateIdentifiers();
            coordId = find(strcmp(identifier, ci), 1);
            if ~isempty(coordId)
                coordinates = obj.C{coordId};
            else
                coordinates = [];
            end
        end
        
        function [lg, lgId] = getLocalGroupDefByName(obj, name)
            names = obj.getLocalGroupNames();
            lgId = find(strcmp(name, names), 1);
            if ~isempty(lgId)
                lg = obj.LG{lgId};
            else
                lg = [];
            end
        end
        
    end
    
    % Internal & legacy methods (public for legacy reasons)
    methods (Access=public, Hidden=true)
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function ui = getUniqueIdentifier(obj)
            ui = obj.uniqueIdentifier;
        end
        
        function grabXprops(obj, Xprops)
            fn = fieldnames(Xprops);
            for fni = 1:numel(fn)
                obj.Xprops.(fn{fni}) = Xprops.(fn{fni});
            end
        end
        
        function propDefinition = getPropertyDefinition(obj, propertyName)
            if isfield(obj.XpropDefinitions, propertyName)
                propDefinition = obj.XpropDefinitions.(propertyName);
            else
                propDefinition = dspace_data.PropertyDefinition.getDefaultDefinition(propertyName);
            end
        end
        
        function setPropertyDefinition(obj, propertyName, propDefinition)
            obj.XpropDefinitions.(propertyName) = propDefinition;
        end
        
        function values = getPropertyValues(obj, propertyName)
            if isempty(propertyName)
                values = [];
            elseif any(strcmp(obj.Xprops.Properties.VariableNames, propertyName))
                values = obj.Xprops.(propertyName);
            else
                values = [];
            end
        end
        
        function setPropertyValues(obj, propertyName, propertyValues)
            obj.Xprops.(propertyName) = propertyValues;
        end
        
        function matrix = getDataMatrix(obj, ids, coordinateId)
            matrix = obj.coordinates{coordinateId}.getDataMatrix(obj, ids);
        end
        
        function matrix = getDataMatrixCutout(obj, ids, cutoutIds, coordinateId)
            matrix = obj.coordinates{coordinateId}.getDataMatrixCutout(obj, ids, cutoutIds);
        end
        
        function cellArray = getVariableLengthRepresentation(obj, coordinateId)
            assert(coordinateId == 1);
            cellArray = obj.Xv;
        end
        
        function [ids, distances] = getLocalGroup(obj, groupId, pointId, k)
            if ~isempty(obj.lastLGPointId) && ~isnan(obj.lastLGPointId)...
                    && obj.lastLGPointId == pointId && obj.lastLGGroupId == groupId
                ids = obj.lastLocalGroup_ids;
                distances = obj.lastLocalGroup_distances;
                return;
            end
            
            lg = obj.localGroupDefinitions{groupId};
            
            if ~lg.isInitialized()
                lg.initialize(obj);
            end
            
            if ~lg.isInitialized()
                lg.initialize(obj);
            end
            
            if nargin < 5
                [ids, distances] = lg.getLocalGroup(pointId);
            else
                [ids, distances] = lg.getLocalGroup(pointId, k);
            end
            
            obj.lastLocalGroup_ids = ids;
            obj.lastLocalGroup_distances = distances;
            obj.lastLGPointId = pointId;
            obj.lastLGGroupId = groupId;
        end
        
        function localGroupDefinitions = getLocalGroupDefinitions(obj)
            localGroupDefinitions = obj.localGroupDefinitions;
        end
        
        function reindexDatasource(obj, newIdsInOrder)
            obj.P = obj.P(newIdsInOrder, :);
            for cid = 1:numel(obj.C)
                obj.C{cid}.reindexDatasource(obj, newIdsInOrder);
            end
            for lgid = 1:numel(obj.LG)
                obj.LG{lgid}.reindexDatasource(obj, newIdsInOrder);
            end
        end
        
        function n = getNumberOfPoints(obj)
            n = size(obj.Xprops, 1);
        end
        
    end
    
    % Internal methods
    methods
        function varargout = subsref(obj,S)
            if numel(S) >= 2 && strcmp(S(1).type, '.') && ischar(S(1).subs)...
                    && any(strcmp(S(1).subs, {'C', 'F'})) && strcmp(S(2).type, '()')...
                    && numel(S(2).subs) == 1 && ischar(S(2).subs{1})
                % .C('Name')
                crdName = S(2).subs{1};
                crd = obj.getCoordinatesByIdentifier(crdName);
                if numel(S) > 2
                    [varargout{1:nargout}] = subsref(crd, S(3:end));
                else
                    varargout{1} = crd;
                end
            elseif numel(S) == 2 && strcmp(S(1).type, '.') && ischar(S(1).subs)...
                    && any(strcmp(S(1).subs, {'LG', 'G'})) && strcmp(S(2).type, '()')...
                    && numel(S(2).subs) == 1 && ischar(S(2).subs{1})
                % .LG('Name')
                lgName = S(2).subs{1};
                lg = obj.getLocalGroupDefByName(lgName);
                if numel(S) > 2
                    [varargout{1:nargout}] = subsref(lg, S(3:end));
                else
                    varargout{1} = lg;
                end
            else
                [varargout{1:nargout}] = builtin('subsref', obj, S);
            end
        end
        
        function forceDeletion(obj)
            % Use this function to delete all handles held by a TableDataSource.
            % This will make the datasource unusable.
            obj.Xprops = [];
            if ~isempty(obj.XpropDefinitions) && isstruct(obj.XpropDefinitions)
                f = fieldnames(obj.XpropDefinitions);
                for k = 1:numel(f)
                    delete(obj.XpropDefinitions.(f{k}));
                end
            end
            if ~isempty(obj.coordinates) && iscell(obj.coordinates)
                for k = 1:numel(obj.coordinates)
                    delete(obj.coordinates{k});
                end
            end
            if ~isempty(obj.localGroupDefinitions) && iscell(obj.localGroupDefinitions)
                for k = 1:numel(obj.localGroupDefinitions)
                    delete(obj.localGroupDefinitions{k});
                end
            end
            obj.parentCollection = [];
            obj.various = [];
            
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

