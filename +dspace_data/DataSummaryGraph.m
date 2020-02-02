classdef DataSummaryGraph < handle
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

   properties (Constant)
       
        NODETYPE_VARIABLE = 1;
        NODETYPE_LOCALGROUP = 2;
        NODETYPE_COORDINATES = 3;
        NODETYPE_POINTFILTER = 4;
        NODETYPE_MODULEFCN = 5;
        NODETYPE_COLLECTION = 6;
        
        NODETYPES = 1:6;
        NODEMARKERS = {'o', 'h', 's', 'x', 'v', 'd'};
        NODEMARKERSIZES = [42, 42, 42, 32, 54, 64]/2;
        
    end
    
    
    properties
    
        nodeNames
        nodeTypes
        
        edges_s
        edges_t
        
        graph
        
        chain_objects
     
    end
    
    methods
       
        function obj = DataSummaryGraph(nodeNames, nodeTypes, edges_s, edges_t, chain_objects)
            obj.nodeNames = nodeNames;
            obj.nodeTypes = nodeTypes;
            obj.edges_s = edges_s;
            obj.edges_t = edges_t;
            obj.chain_objects = chain_objects;
        end
        
        function v = getNodeMarkers(obj)
            v = obj.NODEMARKERS(obj.nodeTypes);
        end
        function v = getNodeColors(obj)
            v = dspace.app.DataspaceLook.custodyChain_MARKERCOLORS(obj.nodeTypes', :);
        end
        function v = getNodeSizes(obj)
            v = obj.NODEMARKERSIZES(obj.nodeTypes);
        end
       
    end
end

