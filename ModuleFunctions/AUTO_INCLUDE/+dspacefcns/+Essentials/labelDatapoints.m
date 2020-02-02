function [ titleStr, settings, results ] = labelDatapoints( dataview, settings )
    % Allows to manually label datapoints. A labeling variable is created that contains 
    % labels per datapoint. Three labelling modes are available.
    %
    % This function can be particularly useful for continual labeling if it 
    % is docked or pinned and a hotkey is assigned to it (right click the 
    % launch button).
    % 
    % <h3>Labeling Modes</h3>
    % <h4>'Current point'</h4>
    % The current point is assigned the given label (settings.label) with the 
    % given probability (settings.label_prob).
    % <h4>'Current graph'</h4>
    % All points in the current local graph are assigned the given label 
    % (settings.label) with the given probability (settings.label_prob). 
    % This may include points outside the current filter.
    % <h4>'Current filter'</h4>
    % All points in the current filter are assigned the given label 
    % (settings.label) with the given probability (settings.label_prob). 
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


    titleStr = 'Essentials/Select Datapoints/Select Manually';
    
    if nargin == 0
        return;
    end
    
    varNames = dataview.getPropertyNames();
    
    if nargin < 2 || isempty(settings)
        settings = {'Description' , 'Manually label datapoints.',...
            'WindowWidth', 450, 'ControlWidth', 250,...
            {'Datapoints to label', 'toLabel'}, {'Current point', 'Current graph', 'Current filter'},...
            {'Label (needs to be double)', 'label'}, 1,...
            {'Label probability', 'label_prob'}, 1,...
            {'Reinitialize labeling variable', 'reinitializeVar'}, false,...
            {'Initialization value', 'initValue'}, NaN,... 
            {'Label variable name', 'lvar'}, varNames};
        return;
    end
    
    dsource = dataview.dataSource;
    if ~ismember(settings.lvar, dsource.P.Properties.VariableNames)
        dsource.P.(settings.lvar) = ones(dsource.N, 1)*settings.initValue;
    else
        if settings.reinitializeVar
            dsource.P.(settings.lvar) = ones(dsource.N, 1)*settings.initValue;
        end
    end
    
    switch settings.toLabel
        case 'Current point'
            id = dataview.FocussedId;
            if rand() <= settings.label_prob
                dsource.P.(settings.lvar)(id) = settings.label;
            end
        case 'Current graph'
            lg = dataview.LocalGroupDefinition;
            id = dataview.FocussedId;
            lg_ids = lg.getLocalGroup(id);
            lg_ids = lg_ids(rand(size(lg_ids)) <= settings.label_prob);
            dsource.P.(settings.lvar)(lg_ids) = settings.label;
        case 'Current filter'
            sel = dataview.Filter;
            sel = sel(rand(size(sel)) <= settings.label_prob);
            dsource.P.(settings.lvar)(sel) = settings.label;
    end
    
    results = [];
end
