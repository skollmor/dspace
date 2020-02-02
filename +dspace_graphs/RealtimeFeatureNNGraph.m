classdef RealtimeFeatureNNGraph < dspace_graphs.AbstractGraph
    % k-NN-Graph based on a feature defined in the underlying datasource.
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
         possibleDistances = {'euclidean', 'cityblock', 'minkowski', 'chebychev', 'seuclidean',...
            'mahalanobis', 'cosine', 'correlation', 'spearman', 'hamming', 'jaccard'};
    end
    
    properties
        % Name of the features defining the k-NN search space.
        coordinateName
        
        distanceFcn
        
        % k - Number of neighbors
        localGroupSize 
    end
    
    properties (Transient=true)
         % for low-d nn search
        coordinates
        exhaustiveSearcher
    end
     
    methods
        
        % for deleting and reordering datapoints
        function reindexDatasource(obj, datasource, newIdsInOrder)
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
        
        % adds n new datapoints to the end (only changes this
        % LG instance)
        function addPtsToDatasource(obj, datasource, n)
            assert(false);
            obj.domainMap(end+1:end+n) = 0;
            obj.initialize(datasource);
        end
         
        
        function obj = RealtimeFeatureNNGraph(coordinateName, name,...
                pointIds, totalNumberOfPoints, localGroupSize, distance)
            % sets up this local low d group definition using the given
            % coordinates (coordinateName: string)
            obj.coordinateName = coordinateName;
            obj.name = name;
         
            obj.mappedIds = zeros(totalNumberOfPoints, 1);
            obj.mappedIds(pointIds, :) = 1:numel(pointIds);
            obj.localGroupSize = localGroupSize;
            obj.distanceFcn = distance;
            obj.candidateIds = obj.originalIds;
        end
        
        function initialize(obj, dataSource)
            obj.dataSource = dataSource;
            cidents = arrayfun(@(i) dataSource.coordinates{i}.getIdentifier(),...
                1:numel(dataSource.C), 'uni', false);
            cid = find(strcmp(obj.coordinateName, cidents));
            obj.coordinates = obj.dataSource.coordinates{cid};
%             dspace_features.AbstractFeatures.getByDescriptor(obj.coordinateDescriptor,...
%                 dataSource.coordinates);
            assert(~isempty(obj.coordinates));
            
            fprintf('dspace_graphs.RealtimeFeatureNNGraph: Fetching features to construct search tree...\n');
            X = obj.coordinates.getDataMatrix(dataSource, obj.originalIds);
            if size(X, 2) > 500
                assert(false, ['dspace_graphs.RealtimeFeatureNNGraph: Dimensionailty is larger than 500. \n' ...
                    'Please reduce dimensionality before creating the LG.']);
            end
            obj.exhaustiveSearcher = createns(X, 'distance', obj.distanceFcn);
        end
        
        function rt = isInitialized(obj)
            rt = ~isempty(obj.dataSource) & ~isempty(obj.exhaustiveSearcher);
        end
              
        function [ids, distances] = getConnectedNodes(obj, pointIds, k)
            assert(~isempty(obj.exhaustiveSearcher));
            
            if nargin < 3
                k = obj.localGroupSize;
            end
            
            X = obj.exhaustiveSearcher.X;
            
            % apply injection map and search neighbours
            [ids] = knnsearch(obj.exhaustiveSearcher, X(obj.mappedQuerryIds(pointIds), :), 'k', k+1);
            
            distances = [];
            
            % apply extraction map
            ids = obj.candidateIds(ids);
            
            ids = ids(:, 2:end);
            
            assert(~any(arrayfun(@(i) ismember(pointIds(i), ids(i, :)), 1:numel(pointIds))));
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

