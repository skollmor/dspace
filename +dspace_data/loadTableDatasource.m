function [ dataSource ] = loadTableDatasource( path, saveName, omitHeavyCoordinates, omitHeavyLGs, wbh, headpr )
    % Don't directly use this function. Use dspace_data.loadCollection instead.
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

    
    if nargin < 3 || isempty(omitHeavyCoordinates)
        omitHeavyCoordinates = false;
    end
    
    if nargin < 4 || isempty(omitHeavyLGs)
        omitHeavyLGs = false;
    end
    
    if nargin < 5 || isempty(wbh)
        wbh = [];
    else
    end
    if nargin < 6 || isempty(headpr)
        headpr = [];
    end
    if ~isempty(wbh)
        dspace.app.waitbar_dspace([headpr 0], wbh, '  core');
    end
    q = load(sprintf('%s/%s_core.mat', path, saveName), '-mat');
    % Note: At this point upgradeDataSources has already been executed
    
    dataSource = q.dataSource;
    
    if ~omitHeavyCoordinates
        if ~isempty(wbh)
            dspace.app.waitbar_dspace([headpr 0.1], wbh, '.C');
        end
        
        if q.record.XfSaved
            % EXTRMELY OUTDATED legacy data-format:
            %
            % standardCoordinates are saved as Xf before introduction of the Coordinate
            % class
            
            s = load(sprintf('%s/%s_Xf.mat', path, saveName), '-mat');
            %% Potentially XX.
            layout = dataSources.CoordinateLayout(dataSource.various.XfLayout.dimensions,...
                dataSource.various.XfLayout.range, dataSource.various.XfLayout.cutout.indices,...
                dataSource.various.XfLayout.cutout.dimensions);
            dataSource.coordinates = {dataSources.StandardCoordinates(s.Xf, 'Xf', layout)};
            
        elseif isfield(q.record, 'nCoordinatesSaved') && q.record.nCoordinatesSaved > 0
            for k = 1:q.record.nCoordinatesSaved
                if q.record.isStandardCoordinates(k)
                    % Coordinates have heavy data - dinstinguish dspace.
                    % and outdated legacy format
                    if isa(dataSource.coordinates{k}, 'dataSources.StandardCoordinates') ||...
                            isa(dataSource.coordinates{k}, 'dataSources.PartialStandardCoordinates')
                        % outdated legacy format
                        s = load(sprintf('%s/%s_Xf%i.mat', path, saveName, k), '-mat');
                        dataSource.coordinates{k}.Xf = s.Xf;
                    elseif isa(dataSource.coordinates{k}, 'dspace_features.AbstractHeavyFeatures') ...
                            || isa(dataSource.coordinates{k}, 'dspacelib_crd.HeavyCoordinates')
                        % dspace.format
                        s = load(sprintf('%s/%s_Xf%i.mat', path, saveName, k), '-mat');
                        dataSource.coordinates{k}.restoreHeavyData(s.Xf);
                    else
                        assert(false);
                    end
                end
            end
        end
    end
    
    if ~omitHeavyLGs
        if ~isempty(wbh)
            dspace.app.waitbar_dspace([headpr 0.2], wbh, '.LG');
        end
        
        if ~isfield(q.record, 'nLGsSaved')
            % EXTREMELY OUTDATED legacy format:
            %
            % LocalHighDGroup_precomputed are saved with NNids in the core
            % .mat file
        elseif q.record.nLGsSaved > 0
            for k = 1:q.record.nLGsSaved
                if q.record.isHighDprecomputedLG(k)
                    % LG contains heavy data, distinguish outdated legacy from dspace.format
                    if isa(dataSource.localGroupDefinitions{k}, 'dataSources.LocalHighDGroup_precomputed')
                        % outdated legacy format
                        s = load(sprintf('%s/%s_NNids%i.mat', path, saveName, k), '-mat');
                        dataSource.localGroupDefinitions{k}.NNids = s.NNids;
                    elseif isa(dataSource.localGroupDefinitions{k}, 'dspace_graphs.AbstractHeavyGraph') ...
                            || isa(dataSource.localGroupDefinitions{k}, 'dspacelib_lg.HeavyLocalGroup')
                        % new dspace.format
                        s = load(sprintf('%s/%s_NNids%i.mat', path, saveName, k), '-mat');
                        dataSource.localGroupDefinitions{k}.restoreHeavyData(s.NNids);
                    else
                        assert(false);
                    end
                end
            end
        end
        
    end
    
    % Outdated legacy information:
    if isfield(q.record, 'XvSaved') && q.record.XvSaved
        s = load(sprintf('%s/%s_Xv.mat', path, saveName), '-mat');
        dataSource.Xv = s.Xv;
    end
    
    % XpropDefinitions
    if isfield(q.record, 'XpropDefinitionsSaved') && q.record.XpropDefinitionsSaved
        if ~isempty(wbh)
            dspace.app.waitbar_dspace([headpr 0.4], wbh, '.Pdef');
        end
        
        file = load(sprintf('%s/%s_XpropDefinitions.mat', path, saveName), '-mat');
        dataSource.XpropDefinitions = file.XpropDefinitions;
    end
    
    % Xprops
    if isfield(q.record, 'XpropsSaved') && q.record.XpropsSaved
        if ~isempty(wbh)
            dspace.app.waitbar_dspace([headpr 0.6], wbh, '.P');
        end
        
        file = load(sprintf('%s/%s_Xprops.mat', path, saveName), '-mat');
        dataSource.Xprops = file.Xprops;
    end
    
    % various
    if isfield(q.record, 'variousSaved') && q.record.variousSaved
        if ~isempty(wbh)
            dspace.app.waitbar_dspace([headpr 0.8], wbh, '.various');
        end
        
        file = load(sprintf('%s/%s_various.mat', path, saveName), '-mat');
        dataSource.various = file.various;
    end
    
    for k = 1:numel(dataSource.C)
        crd = dataSource.C{k};
        try
            crd.initialize(dataSource);
        catch
        end
    end
    
    for k = 1:numel(dataSource.LG)
        lg = dataSource.LG{k};
        try
            lg.initialize(dataSource);
        catch
        end
    end
    
end

