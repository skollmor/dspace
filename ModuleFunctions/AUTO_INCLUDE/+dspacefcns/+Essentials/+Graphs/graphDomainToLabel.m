function [ titleStr, settings, results ] = graphDomainToLabel( dataview, settings )
    % Creates an indicator variable that is 1 only for points inside the
    % domain of the given graph.
    %
    % The current pointfilter has no effect.
    %
    % If no variable name is provided, domain will be named domain_<LG name>.
    %
    % See also dspace_graphs.AbstractGraph.getQuerryDomain.
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


    
    if nargin == 0
        titleStr = 'Essentials/Graphs/Graph Domain to Variable';
        return;
    end
    
    source = dataview.dataSource;
    lgDefs = dataview.getLocalGroupDefinitions();
    
    groupNames = cell(1, numel(lgDefs));
    for j = 1:numel(lgDefs)
        if ~isempty(lgDefs{j})
            groupNames{j} = lgDefs{j}.getName();
        else
            groupNames{j} = '';
        end
    end
    graphNames = groupNames; %cellfun(@(lg) lg.getName(), lgDefs, 'uni', false);
    titleStr = sprintf('Graph Domain to Variable');
       
    if nargin < 2 || isempty(settings)
        settings = {'Description', titleStr,...
            'WindowWidth', 600, 'ControlWidth', 200,...
            {'Graph', 'graphName'}, graphNames,...
            {'New Variable Name (can be empty for auto-naming)', 'newVariableName'}, ''};
        return;
    end
    graph = source.G(settings.graphName);
    
    % Obtain LGs
    if ~graph.isInitialized()
        graph.initialize(dataview.dataSource);
    end
    
    ids = graph.getQuerryDomain();
    
    if isempty(settings.newVariableName)
        name = genvarname(['domain_' settings.graphName]);
    else
        name = settings.newVariableName;
    end
    
    newvar = zeros(source.getNumberOfPoints(), 1);
    newvar(ids) = 1;
    dataview.putProperty(name, newvar, dspace_data.PropertyDefinition([], [], name, '', settings));
    results.domain = newvar;
end