function [ titleStr, settings, results ] = localGraphAnalysisLabels( dataview, settings )
    % This function function can summarize the connected nodes for each datapoint 
    % in the current filter in several ways.
    %
    % If the graph is a nearest-neighbour graph, this module function computes 
    % statistics over the neighborhood of each datapoint.
    %
    % Results of this computation are stored in variables that are named:
    % [CUSTOM STEM]_[GRAPH NAME]_[TARGET_LABEL]_[TYPE].
    %
    %
    %
    % c: datapoint id; e_i: indices of connected nodes; Tar: target variable
    %
    % Relative Mean (RM) = Avg(Tar(e_i)) - Tar(c)
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


    titleStr = 'Essentials/Graphs/Local Graph Analysis - Labels';
    
    if nargin == 0
        
        return;
    end
    
    source = dataview.getDatasource();
    varNames = source.getPropertyNames();
    pf = dataview.getPointFilter();
    np = source.N;
    lgNames = source.getLocalGroupNames();  
    defaultSettings = {'Description' , sprintf('Local Graph Analysis. %i/%i datapoints in current filter.', sum(pf), np),...
            'WindowWidth', 700, 'ControlWidth', 400,...
            'separator', 'Graph & Labels',...
            {'Graph', 'graphName'}, lgNames,...
            {'Target Label', 'targetVariable'}, varNames,...
            {'Results Stem', 'resultVariableStem'}, 'LGA',...           
            'separator', 'Simple functions of the target label f({e_i})',...
            {'Mean (LGm)', 'doMean'}, false,...
            {'Median (LGmed)', 'doMedian'}, false,...
            {'Min (LGmin)', 'doMin'}, false,...
            {'Max (LGmax)', 'doMax'}, false,...
            {'Std. dev. (LGstd)', 'doStd'}, false,...
            {'Relative mean (LGrm)', 'doRelativeMean'}, false,...
            {'Relative median (LGrmed)', 'doRelativeMedian'}, false};
    
    if nargin < 2 || isempty(settings)
        settings = defaultSettings;
        return;
    elseif nargin == 2
        % overwrite defaults with provided settings (can be incomplete)
        % this makes running this modulefcn on the commandline easier
        % because not all fields of the settings structure have to be provided
        settingsNew = dspace.resources.makeSettingsStruct(defaultSettings{:});
        fn = fieldnames(settings);
        for fni = 1:numel(fn)
            settingsNew.(fn{fni}) = settings.(fn{fni});
        end
        settings = settingsNew;
        clear settingsNew;
    end
    
    %% Compute
    varsCreated = {};
    
    h = dspace.app.waitbar_dspace(0, titleStr);
    graph = source.getLocalGroupDefByName(settings.graphName);
    selection = find(pf);
    
    if ~graph.isInitialized()
        fprintf('Initializing Graph...\n');
        graph.initialize(source);
    end
    
    % The element itself is not part of the LG
    fprintf('Querrying graph...\n');
    connectedIds = graph.getConnectedNodes(selection);
    
    targetVar = source.L.(settings.targetVariable);
    
    outputStem = [settings.resultVariableStem '_' settings.graphName '_' settings.targetVariable];
    
    
    %% Simple Functions
    
    nansPerCenter = sum(isnan(connectedIds), 2);
    if any(nansPerCenter) > 0
        fprintf('%i Datapoints have partially undefined connected nodes (avg #NaNs: %.2f).\n',...
            sum(nansPerCenter>0), mean(nansPerCenter(nansPerCenter>0)));
    end
    targetVar(end+1) = NaN;
    connectedIds(isnan(connectedIds)) = numel(targetVar);
    T = targetVar(connectedIds);
    targetVar(end) = [];
    %T(~valid_connected_elements) = NaN;
    
    fprintf('Computing Analyses...\n');
    if settings.doStd
        values = NaN(np, 1);    
        values(pf) = nanstd(T, [], 2);
        name = genvarname(sprintf('%s_%s', outputStem, 'std'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    if settings.doMean
        values = NaN(np, 1);
        values(pf) = nanmean(T, 2);
        name = genvarname(sprintf('%s_%s', outputStem, 'm'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    if settings.doMedian
        values = NaN(np, 1);
        values(pf) = nanmedian(T, 2);
        name = genvarname(sprintf('%s_%s', outputStem, 'med'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    if settings.doMin
        values = NaN(np, 1);
        values(pf) = nanmin(T, [], 2);
        name = genvarname(sprintf('%s_%s', outputStem, 'min'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    if settings.doMax
        values = NaN(np, 1);
        values(pf) =  nanmax(T, [], 2);
        name = genvarname(sprintf('%s_%s', outputStem, 'max'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    
    %% f({e_i}, c)
    dspace.app.waitbar_dspace(0.5, h);
    
    if settings.doRelativeMedian
        values = NaN(np, 1);
        values(pf) = nanmedian(T, 2) - targetVar(selection);
       name = genvarname(sprintf('%s_%s', outputStem, 'rmed'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
    
    if settings.doRelativeMean
        values = NaN(np, 1);
        values(pf) = nanmean(T, 2) - targetVar(selection);
        name = genvarname(sprintf('%s_%s', outputStem, 'rm'));
        dataview.putProperty(name, values, dspace_data.PropertyDefinition([], [], name, '', settings));
        varsCreated{end+1} = name;
    end
  
    close(h);
    
    results = [];
    results.variablesCreated = varsCreated;  
end