function [ titleStr, settings, results ] = deleteGraphs( dataview, settings )
    % This function removes one or more graphs from the datasource.
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

    
    titleStr = 'Essentials/Organize Datasource/Delete Graphs';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        source = dataview.getDatasource();
        graphNames = source.getLocalGroupNames();
        settings = {'Description' , 'Delete graphs from datasource.',...
            'WindowWidth', 500, 'ControlWidth', 350,...
            {'Graphs to Delete', 'graphsToDelete'}, dspace.app.StringList(graphNames)};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.dataSource;
    graphNames = settings.graphsToDelete.strings;
    for gid = 1:numel(graphNames)
        [~, idx] = source.getLocalGroupDefByName(graphNames{gid});
        if ~isempty(idx)
            source.G(idx) = [];
        else
            fprintf('Graph %s not found in source %s...\n', graphNames{gid}, source.getName());
        end
    end
   
    results.deletedGraphs = graphNames;
end
