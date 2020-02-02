classdef PrecomputedGraph < dspace_graphs.AbstractGraph & dspace_graphs.AbstractHeavyGraph
    % This class defines a bidirectional unweighted graph. Connections are stored as a
    % (possibly sparse)matrix containing the ids of all connected (target) nodes for each
    % (source) node. This representation is well suited for graphs with fixed out-degree such as k-NN graphs.
    % The graph definition can be partial. In that case outgoing connections
    % are only defined on a subset of all datapoints in the underlying dataset (the querry-domain)
    % and incoming connections are only defined for a subset of all datapoints (the candidate-domain).
    %
    % querry-domain is specified via the property
    % mappedQuerryIds: int, NP x 1, where np is total number of points in the datasource
    % mappedQuerryIds(j) = 0: point j not in querry domain
    % mappedQuerryIds(j) = k, point j is in querry domain and NNids(k, :) are the ids
    %                                                         of connected nodes
    % the candidate domain is specified via the property
    % candidateIds: int, NC x 1, where NC is the size of the candidate domain
    %
    % The outgoing connections for each node j are stored in the matrix of indices
    % NNids as NNids(j, :). Each element of NNids(j, :) is either zero or
    % an element of the candidate domain.
    %
    % The querry-domain implies an injection map injectionMap(id) = mappedQuerryIds(id).
    % The candidate domain implies an extraction map extractionMap(id) = candidateIds(id).
    %
    % In most cases the querry-domain equals the candidate-domain and injectionMap 
    % and extractionMap are inversely related. In that case the property IsSimpleDomainGraph is true.
    %
    % In some cases querry-domain and candidate-domain are not equal and injectionMap 
    % and extractionMap are not inversely related. In that case the property IsSimpleDomainGraph is false.
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

    
    properties (Access=public, Hidden=true)
        
        % n x 1, n - number of points covered by this definition
        % sum(NNids(j, :) ~= 0) == outDegrees(j)
        outDegrees
        
        % ids of neighbours for the querry points covered by this group definition
        % indices refer to (1:n_source), where n_source is the number of points covered by the underlying datasource.
        % the set of all ids occuring in NNids is a subset of candidateIds (candidate domain).
        NNids
        
    end
    
    methods
        
        function reindexDatasource(obj, datasource, newIdsInOrder)
            % for deleting and reordering datapoints
            assert(false);
        end
        
        function addPtsToDatasource(obj, datasource, n)
            % adds n new datapoints to the end (only changes this
            % LG instance)
            assert(false);
        end
        
        function obj = PrecomputedGraph(varargin)
            % This constructor can be used in two ways
            % (a) Call with 5 arguments:
            % 1 - name: string
            % 2 - NNids: numeric (int, can be sparse), NQ X MaxOutdegree
            % 3 - querryDomain: numeric (int) NQ x 1
            % 4 - candidateDomain: numeric (int) NC x 1, can be empty (implies IsSimpleDomainGraph == true)
            % 5 - Ntotal: numeric, total number of points in underlying
            %         datasource
            %
            % where NQ: size of the querry domain (outgoing links are defined for those nodes)
            %       NC: size of the candidate domain (all nodes that have incoming connections
            %           from nodes in the querry domain)
            %
            % (b) Call with 2 arguments, assumes NQ == NC == Ntotal == size(NNids, 1)
            % name: string
            % NNids: numeric (int, can be sparse), NQ X MaxOutdegree
            %
            % NNids, querryDomain, candidateDomain all contain ids that identify
            % datapoints in the underlying datasource.
            if nargin == 5
                name = varargin{1};
                NNids = varargin{2};
                querryDomain = reshape(varargin{3}, [], 1);
                candidateDomain = reshape(varargin{4}, [], 1);
                nTotal = varargin{5};
            elseif nargin == 2
                name = varargin{1};
                NNids = varargin{2};
                querryDomain = (1:size(NNids, 1))';
                candidateDomain = (1:size(NNids, 1))';
                nTotal = size(NNids, 1);
            else
                assert(false);
            end
            obj.name = name;
            obj.NNids = NNids;
            if isempty(querryDomain)
                querryDomain = (1:nTotal)';
            end
            
            obj.mappedQuerryIds = zeros(nTotal, 1);
            obj.mappedQuerryIds(querryDomain) = 1:numel(querryDomain);
            
            if isempty(candidateDomain)
                % Assume that IsSimpleDomainGraph == true
                candidateDomain = obj.originalIds; %(1:nTotal)';
            end
            
            obj.candidateIds = candidateDomain;
            
            %assert(all(ismember(unique(NNids(:)), obj.candidateIds)));
            obj.outDegrees = ones(size(NNids, 1), 1)*size(NNids, 2);
        end
        
        function initialize(obj, dataSource)
            obj.dataSource = dataSource;
            assert(dataSource.getNumberOfPoints() == numel(obj.mappedQuerryIds));
        end
        
        function rt = isInitialized(obj)
            rt = ~isempty(obj.dataSource);
        end
        
        function [degrees] = getOutDegrees(obj, pointIds)
            mpids = obj.mappedQuerryIds(pointIds);
            degrees = obj.outDegrees(mpids);
        end
        
        function [ids, weights] = getConnectedNodes(obj, pointIds, k) 
            mpids = obj.mappedQuerryIds(pointIds);
            
            if nargin < 3
                k = obj.outDegrees(mpids);
                k = unique(k);
                assert(numel(k) == 1);
            else
                assert(k <= size(obj.NNids, 2));
            end
            
            weights = [];
            
            % apply injection map and lookup neighbours
            ids = obj.NNids(mpids, 1:k);
            
            % apply extraction map
            ids = obj.candidateIds(ids);
            
        end
        
        function mbytes = getMegabytes(obj)
            NNids_ = obj.NNids;
            q = whos('NNids_');
            mbytes = q.bytes / 1024^2;
            
            NNids_ = obj.various;
            q = whos('NNids_');
            mbytes = mbytes + q.bytes / 1024^2;
        end
        
    end
    
end

