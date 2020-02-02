classdef TrivialGraph < dspace_graphs.AbstractGraph
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

    
    methods
        
        function obj =  TrivialGraph()
            obj.name = 'identity';
        end
        
        % for deleting and reordering datapoints
        function reindexDatasource(obj, datasource, newIdsInOrder)
        end
        
        % adds n new datapoints to the end (only changes this
        % LG instance)
        function addPtsToDatasource(obj, datasource, n)
        end
        
        function initialize(obj, dataSource)
            obj.dataSource = dataSource;
        end
        
        function rt = isInitialized(obj)
            rt = ~isempty(obj.dataSource);
        end
        
        
        function [ids, distances] = getConnectedNodes(obj, pointIds, k)
            ids = pointIds;
            distances = zeros(size(pointIds));
        end
        
        function mbytes = getMegabytes(obj)
             mbytes = 0;
         end
        
    end
    
end

