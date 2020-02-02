function [ record ] = saveTableDatasource( path, saveName, dataSource, omitHeavyCoordinates,...
        omitHeavyLGs, waitbarhandle, headpr)
    % Don't directly use this function. Use dspace_data.saveCollection instead.
    %
    %
    % Note: In many Matlab version file sizes are limited to 2gb or saving
    % is extremely slow, but for simple data types the savefast function is
    % a work-around.
    % 
    % Each datasource is split up into 
    %
    % _core : dataSource Object 
    %
    % _NNids%i : heavy graphs (.G)
    %
    % _Xf%i: heavy coordinates (.F)
    %
    % _XpropDefinitions: all XpropDefinitions (.Ldef)
    % 
    % _various: various field 
    % 
    % _Xprops: all labels (.L)
    %
    % As the last step of the saving process the datasource is cleared of heavy data,
    % saved as stripped down version and then reconstituted.
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

    
    matlabOlderThan2017a = verLessThan('matlab', '9.2');
    
    if nargin < 4 || isempty(omitHeavyCoordinates)
        omitHeavyCoordinates = false;
    end
    if nargin < 5 || isempty(omitHeavyLGs)
        omitHeavyLGs = false;
    end
    if nargin < 6 || isempty(waitbarhandle)
        waitbarhandle = [];
    else
        
    end
    
    if nargin < 7 || isempty(headpr)
        headpr = [];
    end
    
    record = [];
    record.path = path;
    record.saveName = saveName;
    record.sourceName = dataSource.getName();
    record.sourceType = class(dataSource);      %e.g. 'dspace_data.TableDataSource';
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0], waitbarhandle, '.C');
    end
    
    [record, data_crdHeavy] = fetchHeavyCoordinateData(dataSource, record);
    if ~omitHeavyCoordinates
        try 
            saveHeavyCoordinateData(dataSource, record, path, saveName, matlabOlderThan2017a);
        catch ex
            fprintf(['dspace_data.saveTableDatasource (Error): Could not save heavy data for coordinates.'...
                '\nThe datasource has not been saved! The target files might now be corrupt!']);
            throw(ex);
        end
    end
    
    %% CURRENT STATE: Heavy coordinate data saved. Datasource unchanged.
    % outdated legacy information:
    record.XfSaved = false;
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0.2], waitbarhandle, '.LG');
    end
    
    [record, data_lgHeavy] = fetchHeavyLocalGroupData(dataSource, record);
    if ~omitHeavyLGs
        try 
            saveHeavyLocalGroupData(dataSource, record, path, saveName);
        catch ex
            fprintf(['dspace_data.saveTableDatasource (Error): Could not save heavy data for graphs.'...
                '\nThe datasource has not been saved properly! The target files might now be corrupt!\n'...
                'The datasource in memory has not been changed and should be intact.\n']);
            throw(ex);
        end
    end
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0.4], waitbarhandle, '.Pdef');
    end
    
    tic();
    XpropDefinitions = dataSource.XpropDefinitions;
    try
        if matlabOlderThan2017a
            save(sprintf('%s/%s_XpropDefinitions.mat', path, saveName), 'XpropDefinitions', '-v7.3');
        else
            save(sprintf('%s/%s_XpropDefinitions.mat', path, saveName), 'XpropDefinitions', '-v7.3', '-nocompression');
        end
        %save(sprintf('%s/%s_XpropDefinitions.mat', path, saveName), 'XpropDefinitions', '-v6');
    catch ex
        fprintf(['dspace_data.saveTableDatasource (Error): Could not save XpropDefintions'...
            '\nThe datasource has not been saved properly! The target files might now be corrupt!']);
        throw(ex);
    end
    record.XpropDefinitionsSaved = true; 
    fprintf('Pdef: '); toc();
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0.6], waitbarhandle, '.P');
    end
    
    tic();
    Xprops = dataSource.Xprops;
    try
        if matlabOlderThan2017a
            save(sprintf('%s/%s_Xprops.mat', path, saveName), 'Xprops', '-v7.3');
        else
            rr = whos('Xprops');
            if rr.bytes/1024^2 < 1500
                save(sprintf('%s/%s_Xprops.mat', path, saveName), 'Xprops', '-v6');
            else
                save(sprintf('%s/%s_Xprops.mat', path, saveName), 'Xprops', '-v7.3', '-nocompression');
            end
            %savefast(sprintf('%s/%s_Xprops.mat', path, saveName), 'Xprops');
            %save(sprintf('%s/%s_Xprops.mat', path, saveName), 'Xprops', '-v6');
        end
    catch ex
        fprintf(['dspace_data.saveTableDatasource (Error): Could not save Xprops'...
            '\nThe datasource has not been saved properly! The target files might now be corrupt!']);
        throw(ex);
    end
    record.XpropsSaved = true;
    fprintf('Xprops: '); toc();
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0.8], waitbarhandle, '.various');
    end
    
    tic();
    various = dataSource.various;
    try
        %savefast(sprintf('%s/%s_various.mat', path, saveName), 'various');
        save(sprintf('%s/%s_various.mat', path, saveName), 'various', '-v6');
        %save(sprintf('%s/%s_various.mat', path, saveName), 'various', '-v7.3', '-nocompression');
    catch ex
        fprintf(['dspace_data.saveTableDatasource (Error): Could not save .various'...
            '\nThe datasource has not been saved properly! The target files might now be corrupt!']);
        throw(ex);
    end
    record.variousSaved = true;
    fprintf('.various: '); toc();   
    
    % CURRENT STATE: Heavy coordinate data saved. 
    % Heavy LG data saved. XpropDefinitions saved,
    % Xprops saved, various saved. The datasource is unchanged.
    
    if ~isempty(waitbarhandle)
        dspace.app.waitbar_dspace([headpr 0.9], waitbarhandle, '-CORE');
    end
    
    tic();
    
    try
        %% CLEARING HEAVY DATA    
        % clear out heavy data
        dataSource.various = [];
        dataSource.XpropDefinitions = [];
        dataSource.Xprops = [];
        clearHeavyLocalGroupData(dataSource, record);
        clearHeavyCoordinateData(dataSource, record);
        
        % CURRENT STATE: Datasource is cleared of heavy data. Needs to be restored!
        
        %savefast(sprintf('%s/%s_core.mat', path, saveName), 'dataSource', 'record');
        
        % save the core, this includes the action-log.
        save(sprintf('%s/%s_core.mat', path, saveName), 'dataSource', 'record', '-v6');
        %save(sprintf('%s/%s_core.mat', path, saveName), 'dataSource', 'record', '-v7.3', '-nocompression');
        
    catch ex
        %% RESTORING HEAVY DATA in case of exception
        dataSource.various = various;
        dataSource.XpropDefinitions = XpropDefinitions;
        dataSource.Xprops = Xprops;
        restoreHeavyLocalGroupData(dataSource, record, data_lgHeavy);
        restoreHeavyCoordinateData(dataSource, record, data_crdHeavy);
        
        % CURRENT STATE: Datasource is restored.
        
        fprintf(sprintf(['dspace_data.saveTableDatasource: Could not save core'...
            '\nThe datasource has not been saved properly! Attention: The target files might now be corrupt!'...
            '\nThe datasource in memory is intact. You will have to resave.'... 
            '\nTo fix this problem, try removing your data-custody-chains: dsource.dataCustodyChains = {}.'...
            '\nYou can also try removing the action-log: dsource.clearActionLog()'...
            '\nYou may need to do this for all datasources in the collection.'...
            '\n(use the <run matlab command> module fcn in batch mode with the command above.\n']));
        throw(ex);
    end
    
    %% RESTORING HEAVY DATA
    dataSource.various = various;
    dataSource.XpropDefinitions = XpropDefinitions;
    dataSource.Xprops = Xprops;
    restoreHeavyLocalGroupData(dataSource, record, data_lgHeavy);
    restoreHeavyCoordinateData(dataSource, record, data_crdHeavy);
    
    % CURRENT STATE: Datasource is saved and restored.
    
    fprintf('core: '); toc();
    
    fprintf('Datasource %s saved successfully.\n', dataSource.getName());
      
end

%% Coordinates
function [record, data_crdHeavy] = fetchHeavyCoordinateData(dataSource, record)
   
    coordinates = dataSource.coordinates;
    record.nCoordinatesSaved = numel(coordinates);
    % We use this to indicate heavy coordinates (StandardCoordinates in old data-format)
    record.isStandardCoordinates = false(1, record.nCoordinatesSaved);
    data_crdHeavy = cell(1, record.nCoordinatesSaved);
    
    for k = 1:record.nCoordinatesSaved
        if isa(coordinates{k}, 'dataSources.StandardCoordinates') ||...
                isa(coordinates{k}, 'dataSources.PartialStandardCoordinates')
            % Outdated Legacy Coordinates
            
            record.isStandardCoordinates(k) = true;
            
            % Xf is defined as transient, so we do not need to set to []
            % and do not need to restore it
            % Xf = coordinates{k}.Xf;
            
        elseif isa(coordinates{k}, 'dspace_features.AbstractHeavyFeatures')
            % New Data-Format
            
            record.isStandardCoordinates(k) = true;
            
            % 'Xf', is now heavyProperties ... NOT defined as transient, so we DO need to set to []
            HD = coordinates{k}.getHeavyData();
            if isnumeric(HD)
                Xf = HD;
            elseif iscell(HD) && numel(HD) == 1 && isnumeric(HD{1})
                Xf = HD{1};
            else
                assert(false);
            end
               
            % save for recovery after dataspace-core has been saved
            data_crdHeavy{k} = Xf;
                  
        else
            % Since there is no heavy data in these coordinates, no special
            % actions are required upon saving (or loading)
            record.isStandardCoordinates(k) = false;
        end
    end
end

function clearHeavyCoordinateData(dataSource, record)
    coordinates = dataSource.coordinates;  
    for k = 1:record.nCoordinatesSaved
        if isa(coordinates{k}, 'dataSources.StandardCoordinates') ||...
                isa(coordinates{k}, 'dataSources.PartialStandardCoordinates')
            % Outdated Legacy Coordinates
            
            % Xf is defined as transient, so we do not need to set to []
            % and do not need to restore it
           
        elseif isa(coordinates{k}, 'dspace_features.AbstractHeavyFeatures')
            % New Data-Format
            
            % clear heavy data (recovered below)
            coordinates{k}.clearHeavyData();
            
        else
            % Since there is no heavy data in these coordinates, no special
            % actions are required upon saving (or loading)
        end
    end
end

function restoreHeavyCoordinateData(dataSource, record, data_crdHeavy)
     for k = 1:record.nCoordinatesSaved
        if isa(dataSource.coordinates{k}, 'dataSources.StandardCoordinates') ||...
                isa(dataSource.coordinates{k}, 'dataSources.PartialStandardCoordinates')
            % No special action required for outdated legacy coordinates
        elseif isa(dataSource.coordinates{k}, 'dspace_features.AbstractHeavyFeatures')
            dataSource.coordinates{k}.restoreHeavyData(data_crdHeavy{k});
        end
        % Other coordinates require no special operations
     end
end

function saveHeavyCoordinateData(dataSource, record, path, saveName, matlabOlderThan2017a)
    coordinates = dataSource.coordinates;
    for k = 1:record.nCoordinatesSaved
        if isa(coordinates{k}, 'dataSources.StandardCoordinates') ||...
                isa(coordinates{k}, 'dataSources.PartialStandardCoordinates')
            % Outdated Legacy Coordinates
            
            % Xf is defined as transient, so we do not need to set to []
            % and do not need to restore it
            Xf = coordinates{k}.Xf;
            if ~isempty(Xf) && ~issparse(Xf)
                savefast(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf');
            else
                if matlabOlderThan2017a
                    save(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf', '-v7.3');
                else
                    save(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf', '-v7.3', '-nocompression');
                end
            end
            
        elseif isa(coordinates{k}, 'dspace_features.AbstractHeavyFeatures')
            % New Data-Format
            
            % 'Xf', is now heavyProperties ... NOT defined as transient, so we DO need to set to []
            HD = coordinates{k}.getHeavyData();
            if isnumeric(HD)
                Xf = HD;
            elseif iscell(HD) && numel(HD) == 1 && isnumeric(HD{1})
                Xf = HD{1};
            else
                assert(false);
            end
            
            % store the data matrix
            if ~isempty(Xf) && ~issparse(Xf)
                savefast(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf');
            else
                if matlabOlderThan2017a
                    save(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf', '-v7.3');
                else
                    save(sprintf('%s/%s_Xf%i.mat', path, saveName, k), 'Xf', '-v7.3', '-nocompression');
                end
            end
            
        else
            % Since there is no heavy data in these coordinates, no special
            % actions are required upon saving (or loading)         
        end
    end
end


%% Local Groups

function [record, data_lgHeavy] = fetchHeavyLocalGroupData(dataSource, record)
    LGs = dataSource.localGroupDefinitions;
    record.nLGsSaved = numel(LGs);
    data_lgHeavy = cell(1, record.nLGsSaved);
    
    % We use this to indicate whether this LG has heavy data (only
    % LocalHighDGroup_precomputed in legacy format)
    record.isHighDprecomputedLG = false(1, record.nLGsSaved);
    
    for k = 1:record.nLGsSaved
        if isa(LGs{k}, 'dataSources.LocalHighDGroup_precomputed')
            % Outdated Legacy LG
            record.isHighDprecomputedLG(k) = true;
            
            NNids = LGs{k}.NNids;
            data_lgHeavy{k} = NNids;
            
        elseif isa(LGs{k}, 'dspace_graphs.AbstractHeavyGraph')
            % New Data Format
            record.isHighDprecomputedLG(k) = true;
            
            NNids = LGs{k}.getHeavyData();
            data_lgHeavy{k} = NNids;
            
        else
            % Since there is no heavy data in this local group, no special
            % actions are required upon saving (or loading)
            record.isHighDprecomputedLG(k) = false;
        end
    end
    
end

function clearHeavyLocalGroupData(dataSource, record)
    LGs = dataSource.localGroupDefinitions;
    
    for k = 1:record.nLGsSaved
        if isa(LGs{k}, 'dataSources.LocalHighDGroup_precomputed')
            % Outdated Legacy LG
            LGs{k}.NNids = [];
        elseif isa(LGs{k}, 'dspace_graphs.AbstractHeavyGraph')
            % New Data Format
            % Clear heavy data (restored) below)
            LGs{k}.clearHeavyData();
        else
            % Since there is no heavy data in this local group, no special
            % actions are required upon saving (or loading)
        end
    end 
end

function restoreHeavyLocalGroupData(dataSource, record, data_lgHeavy)
    for k = 1:record.nLGsSaved
        if isa(dataSource.LG{k}, 'dataSources.LocalHighDGroup_precomputed')
            % Outdata Legacy Local Group
            dataSource.LG{k}.NNids = data_lgHeavy{k};
        elseif isa(dataSource.LG{k}, 'dspace_graphs.AbstractHeavyGraph')
            dataSource.LG{k}.restoreHeavyData(data_lgHeavy{k});
        end
        % Other LGs require no special operations
    end
end

function saveHeavyLocalGroupData(dataSource, record, path, saveName)
    LGs = dataSource.localGroupDefinitions;
    
    for k = 1:record.nLGsSaved
        if isa(LGs{k}, 'dataSources.LocalHighDGroup_precomputed')
            
            NNids = LGs{k}.NNids;
            savefast(sprintf('%s/%s_NNids%i.mat', path, saveName, k), 'NNids');
            
        elseif isa(LGs{k}, 'dspace_graphs.AbstractHeavyGraph')
            
            NNids = LGs{k}.getHeavyData();
            savefast(sprintf('%s/%s_NNids%i.mat', path, saveName, k), 'NNids');
           
        else
            % Since there is no heavy data in this local group, no special
            % actions are required upon saving (or loading)
        end
    end
    
end


