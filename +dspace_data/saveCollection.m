function saveCollection(collection, fullpath, collectionName, collectionRegistry,...
        omitHeavyFeatures, omitHeavyGraphs)
    % This function saves a data-collection. Always use this function to save data 
    % in the dspace-format. 
    %
    % Data-collections are explained here: <a href="matlab:doc('dspace_data.DataCollection')">dspace_data.DataCollection</a>.
    %
    %
    % Inputs:
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
    % collectionRegistry: struct, default: struct()
    %                     - this is for storing point-filters, presets, etc...
    %
    % omitHeavyFeatures: logical, default: false
    %
    % omitHeavyGraphs: logical, default: false
    %
    % 
    % Notes
    % -----
    % Saving a data-collection involves: 
    %
    % (a) saving a (small) file containing all collection information, such as
    % name, registry, number & type of datasources
    %
    % (b) saving each individual datasource in the .STORE subfolder of the
    % collection-save-folder.
    %
    %    - in this step graphs and features that require a lot of memory 
    %      are stored in separate files.
    %
    % See also: dspace_data.loadCollection.
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

    
    if nargin < 4 || isempty(collectionRegistry)
        collectionRegistry = struct();
    end
    assert(isstruct(collectionRegistry));
    
    if nargin < 5 || isempty(omitHeavyFeatures)
        omitHeavyFeatures = false;
    end
    
    if nargin < 6 || isempty(omitHeavyGraphs)
        omitHeavyGraphs = false;
    end
       
    t_all = tic();
    
    fprintf('#Saving collection %s...\n', collectionName); 
    name_of_main_collection_file = sprintf('%s/%s.dataCollection', fullpath, collectionName);
    path_to_collection_data_store = sprintf('%s/%s.dataCollection.STORE', fullpath, collectionName);
    [~, ~, ~] = mkdir(path_to_collection_data_store);
    
    if dspace.isAppActive()
        % display a progressbar only if the dspace app is active
        h = dspace.app.waitbar_dspace(0, sprintf('Saving Collection %s...', collectionName));
    else
        h = [];
    end
    
    sources_array = collection.getNestedCellArray();
    collectionLevelNames = collection.getLevelNames();
    srecord = cell(1, numel(sources_array));
    
    for k = 1:numel(sources_array)
        if iscell(sources_array{k})
            for j = 1:numel(sources_array{k})
                s = sources_array{k}{j};
                
                assert(isa(s, 'dspace_data.DataSource')...
                    || isa(s, 'dataSources.DataSource'));
                
                if isa(s, 'dspace_data.TableDataSource') ...
                || isa(s, 'dataSources.TableDataSource')
                
            
                    if ~isempty(h)
                        dspace.app.waitbar_dspace(j/numel(sources_array{k}), h,...
                            sprintf('Saving item %i.%i/%i: %s (%s)...', k, j,...
                            numel(sources_array{k}), strrep(s.getName(), '_', '-'), class(s)));
                        h.setAddReturns(false);
                    end
                    
                    fprintf('#Saving TableDataSource %s (%s)...\n', s.getName(), class(s)); 

                    % srecord contains a record identifying the stroed
                    % DataSource (without heavy components; those have been
                    % stored under the path cp)          
                    srecord{k}{j} = dspace_data.saveTableDatasource(path_to_collection_data_store,...
                        sprintf('source%i_%i', k, j), s, omitHeavyFeatures, omitHeavyGraphs, h,...
                        (j-1)/numel(sources_array{k}));
                    
                    if ~isempty(h), h.setAddReturns(true); end
                    
                else
                    
                    % This branch is never used
                    if ~isempty(h)
                        dspace.app.waitbar_dspace(j/numel(sources_array{k}), h,...
                            sprintf('Saving item %i.%i/%i...', k, j, numel(sources_array{k})));
                    end
                    
                    save(sprintf('UNUSUAL: %s/source%i_%i.mat', path_to_collection_data_store, k, j), 's', '-v7.3');
                    
                    srecord{k}{j} = sprintf('source%i_%i.mat', k, j);
                
                end
            end
        else
            assert(false, ' Input must be {{}} of valid DataSources.');
        end
    end
    
    % registry, srecord and levelNames should be much smaller than 2gb
    % --> use normal matlab save
    registry = collectionRegistry;
    save(name_of_main_collection_file, 'srecord', 'registry', 'collectionLevelNames');
    
    if ~isempty(h), close(h); end
    
    fprintf('Collection %s saved. ', collectionName); toc(t_all);
   
end
