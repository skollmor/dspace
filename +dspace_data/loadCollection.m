function [collection, registry] = loadCollection(fullpath, name, omitHeavyFeatures,...
        omitHeavyGraphs)
    % This function loads a data-collection. Always use this function to load data 
    % in the dspace-format. 
    %
    % Data-collections are explained here: <a href="matlab:doc('dspace_data.DataCollection')">dspace_data.DataCollection</a>.
    %
    %
    % Inputs
    % ------
    % collection: dspace_data.DataCollection
    %
    % fullpath: full path to the folder containing the main collection file 
    %           and .STORE folder  
    %
    % collectionName: name for the collection (filename of the main collection file)
    %
    %
    % Optional Inputs
    % ---------------
    % omitHeavyFeatures: logical, default: false
    %
    % omitHeavyGraphs: logical, default: false
    %
    %
    % Outputs
    % -------
    % collectionRegistry: struct
    %
    % collection: dspace_data.DataCollection
    %
    %
    % Notes
    % -----
    % Loading a data-collection involves: 
    %
    % (a) loading a (small) file containing all collection information, such as
    % name, registry, number & type of datasources
    %
    % (b) loading each individual datasource from the .STORE subfolder of the
    % collection-save-folder.
    %
    %    - in this step, a stripped down datasource is loaded and graphs and 
    %      features that require a lot of memory are loaded from separate files
    %      and integrated afterwards.
    %
    % See also: dspace_data.saveCollection.
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

    
    if nargin < 3 || isempty(omitHeavyFeatures)
        omitHeavyFeatures = false;
    end
    
    if nargin < 4 || isempty(omitHeavyGraphs)
        omitHeavyGraphs = false;
    end
    
    tic();
    
    fn = sprintf('%s/%s.dataCollection', fullpath, name);
    cp = sprintf('%s/%s.dataCollection.STORE', fullpath, name);
    q=load(fn, '-mat');
    
    srecord = q.srecord;
    
    if isfield(q, 'registry')
        registry = q.registry;
    else
        registry = struct();
    end
    
    if isfield(q, 'collectionLevelNames')
        levelNames = q.collectionLevelNames;
    else
        levelNames = {};
    end
    
    if dspace.isAppActive()
        % display a progressbar whenever if the dspace app is active
        h = dspace.app.waitbar_dspace(0, sprintf('Loading collection %s', name));
    else
        h = [];
    end
    
    %% Load individual sources
    sources = {};
    for k = 1:numel(srecord)
        for j = 1:numel(srecord{k})
            
            if isa(srecord{k}{j}, 'struct') && isfield(srecord{k}{j}, 'sourceType')...
                    && (strcmp(srecord{k}{j}.sourceType, 'dspace_data.TableDataSource')...
                        || strcmp(srecord{k}{j}.sourceType, 'dspacelib_data.TableDataSource')...
                        || strcmp(srecord{k}{j}.sourceType, 'dataSources.TableDataSource'))
                
                if ~isempty(h)
                    dspace.app.waitbar_dspace(j/numel(srecord{k}), h, sprintf('Loading %i.%i: %s (%s)...',...
                        k, j, strrep(srecord{k}{j}.sourceName, '_', '-'), srecord{k}{j}.sourceType));
                    h.setAddReturns(false);
                end
               
                % this function handles both outdated legacy and new dspace.sources
                sources{k}{j} = dspace_data.loadTableDatasource(cp, srecord{k}{j}.saveName,...
                    omitHeavyFeatures, omitHeavyGraphs, h, (j-1)/numel(srecord{k}));
                 
                if ~isempty(h), h.setAddReturns(true); end
                
            elseif isa(srecord{k}{j}, 'char')
                
                % Not a TableDataSource - this branch is never used
                if ~isempty(h)
                    dspace.app.waitbar_dspace(j/numel(srecord{k}), h, sprintf('Loading %i.%i...', k, j));
                end
                
                q=load(sprintf('%s/%s', cp, srecord{k}{j}));
                sources{k}{j} = q.s;
            
            end
        end
    end
    
    if ~isempty(h), close(h); end
    
    %% Upgrade datasources if necessary
    try
        % the following line is not required for dspace-core:
        hasLS = dspace.hasLegacySupport();
    catch 
        hasLS = false;
    end
    if hasLS
        % the following loop is not required for dspace-core:
        % its purpose is backward compatibility previous unpublished versions
        for k = 1:numel(srecord)
            for j = 1:numel(srecord{k})
                sources{k}{j} = dspace_data.upgradeLegacyDatasource(sources{k}{j});
            end
        end
    end
    
    
    %% Create new collection with the loaded sources and levelNames
    collection = dspace_data.DataCollection(sources, levelNames, name);
    
    %% Link datasources with parent-collection
    for k = 1:numel(srecord)
        for j = 1:numel(srecord{k})      
            sources{k}{j}.parentCollection = collection;
        end
    end
    fprintf('Collection %s loaded. ', name); toc();
    
end
