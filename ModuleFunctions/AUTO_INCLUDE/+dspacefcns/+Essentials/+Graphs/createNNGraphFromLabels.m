function [ titlestr, settings, results ] = createNNGraphFromLabels( dataview, settings )
    % Creates a nearest neighbour graph based on the given labels.
    %
    % This graph is computed using the Euclidean distance.
    %
    % See also dspace_graphs.RealtimeLabelBasedNNGraph.
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

    
    titlestr = 'Essentials/Graphs/Create Nearest Neighbour Graph from Labels';
    if nargin == 0
        return;
    end
    
    source = dataview.getDatasource();
    np = source.N;
    pf = dataview.getPointFilter();
    varNames = source.getPropertyNames(); 
    
    if nargin < 2 || isempty(settings)
        settings = {'Description',...
            sprintf('Create Nearest Neighbour Graph from Labels over Current Selection (%i/%i points).', sum(pf), np),...
            'WindowWidth', 700, 'ControlWidth', 350,...
            {'Input Labels', 'labelNames'}, dspace.app.StringList(varNames),...
            'separator', 'Parameters', ...
            {'Normalize Input Labels', 'labelNormalization'}, {'zTransform', 'none'},...
            {'New Graph Name', 'graphName'}, 'newLabelGraph',...
            {'Number of Neighbours', 'nNeighbours'}, 100};
        return;
    end
      
    newGraph = dspace_graphs.RealtimeLabelNNGraph(settings.labelNames.strings,...
            settings.graphName, settings.labelNormalization, find(pf), np, settings.nNeighbours);
            
    source.addGraph(newGraph, true);
    
    results.newGraphName = settings.graphName;
    
end