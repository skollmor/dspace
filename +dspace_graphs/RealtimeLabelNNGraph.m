classdef RealtimeLabelNNGraph < dspace_graphs.AbstractGraph
    % k-NN-Graph based on one or more labels defined in the underlying datasource.
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

    
    properties
        % Names of the labels defining the k-NN search space.
        coordinateProperties
        localGroupSize
        normalization   
    end
    
    properties (Transient=true)
        % for low-d nn search
        treeSearcher
    end
      
    methods    
        
        function reindexDatasource(obj, datasource, newIdsInOrder)
            % for deleting and reordering datapoints
            assert(false);
            old_Np = numel(obj.domainMap);
            newIdsInOrder_inv = zeros(old_Np, 1);
            newIdsInOrder_inv(newIdsInOrder) = 1:numel(newIdsInOrder);
            inLG = obj.domainMap(newIdsInOrder) ~= 0;
            newDomain = newIdsInOrder_inv(obj.domain(obj.domainMap(newIdsInOrder(inLG))));
            
            if any(newDomain == 0) || numel(newDomain) ~= numel(obj.domain)
                assert(false, 'ConditionLocalLowDGroup: Reindexing would change the group domain.');
            end
            
            newDomainMap = zeros(numel(newIdsInOrder), 1);
            newDomainMap(newDomain) = 1:numel(newDomain);
            
            obj.domain = newDomain;
            obj.domainMap = newDomainMap;
            obj.initialize(datasource);
        end
        
       
        function addPtsToDatasource(obj, datasource, n)
            % adds n new datapoints to the end (only changes this
            % LG instance)
            assert(false);
            obj.domainMap(end+1:end+n) = 0;
            obj.initialize(datasource);
        end
        
        
        function obj = RealtimeLabelNNGraph(coordinateProperties, name,...
                normalization, pointIds, totalNumberOfPoints, localGroupSize)
            % Sets up this graph using the given label properties (cell array of strings).
            %
            obj.coordinateProperties = coordinateProperties;
            obj.name = name;
            if nargin < 4 || isempty(normalization)
                obj.normalization = 'none';
            else
                obj.normalization = normalization;
            end
            obj.mappedIds = zeros(totalNumberOfPoints, 1);
            obj.mappedIds(pointIds, :) = 1:numel(pointIds);
            obj.localGroupSize = localGroupSize;
            obj.candidateIds = obj.originalIds;
        end
          
        function initialize(obj, dataSource)
            obj.dataSource = dataSource;
            X = NaN(numel(obj.originalIds), numel(obj.coordinateProperties));
            for c = 1:numel(obj.coordinateProperties)
                h = dataSource.getPropertyValues(obj.coordinateProperties{c});
                if isempty(h)
                    fprintf(['dspace_graphs.RealtimeLabelNNGraph: Could not initialize graph.\nThe '...
                        'required label %s is missing in the underlying datasource.\n'], obj.coordinateProperties{c});
                    assert(false);
                end
                X(:, c) = h(obj.originalIds);
                switch obj.normalization
                    case 'zTransform'
                        X(:, c) = (X(:, c) - mean(X(:, c)))./std(X(:, c));
                    case 'none'
                end
            end
            obj.treeSearcher = KDTreeSearcher(X);
        end
        
        function rt = isInitialized(obj)
            rt = ~isempty(obj.dataSource) & ~isempty(obj.treeSearcher);
        end
           
        function [ids, distances] = getConnectedNodes(obj, pointIds, k)
            assert(~isempty(obj.treeSearcher));
            
            if nargin < 3
                k = obj.localGroupSize;
            end
            
            X = obj.treeSearcher.X;
            
            % apply injection map and search neighbours
            [ids, distances] = obj.treeSearcher.knnsearch(X(obj.mappedIds(pointIds), :), 'K', k+1);
            
            % apply extraction map
            ids = obj.candidateIds(ids);
            
            ids = ids(:, 2:end);
            distances = distances(:, 2:end);
            %assert(~any(arrayfun(@(i) ismember(pointIds(i), ids(i, :)), 1:numel(pointIds))));
        end
        
        function mbytes = getMegabytes(obj)
            ids_ = obj.mappedIds;
            q = whos('ids_');
            mbytes = q.bytes / 1024^2;
            ids_ = obj.originalIds;
            q = whos('ids_');
            mbytes = mbytes + q.bytes / 1024^2;
        end
        
    end
    
end

