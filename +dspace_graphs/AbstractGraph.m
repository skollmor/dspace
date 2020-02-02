classdef AbstractGraph < handle
    % This class defines a bidirectional graph. The graph definition can be partial. 
    % Outgoing connections are only defined for a subset of all datapoints in the 
    % underlying dataset. This subset is called the the querry-domain. 
    % Incoming connections are similarly only defined for a subset of all datapoints 
    % (the candidate-domain). Querry- and candidate-domain specify a set of possible graphs
    % of which this graph is an element.
    %
    % The querry-domain is specified via the property
    % mappedQuerryIds: int, Ntotal x 1, where Ntotal is total number of points in the datasource 
    % mappedQuerryIds(j) = 0: point j not in querry domain
    % mappedQuerryIds(j) = k, point j is in querry domain and getConnectedNodes(k) are the ids 
    %                                                         of connected nodes 
    % The candidate domain is specified via the property 
    % candidateIds: int, Ncandidate x 1, where Ncandidate is the size of the candidate domain
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

        
    properties (Access=public)
        % 1 x np, np - total number of points in datasource 
        % mappedIds(j) = 0, if no local group is defined (point not in
        % querry domain)
        % mappedIds(j) = k, with NNids(k, :) = local group, if defined
        mappedQuerryIds
        
        % 1 x NC, where NC is the size of the candidate domain
        candidateIds
        
        various
    end
    
    properties (Access=public, Hidden=true)
        name
        
        % deprecated
        displayId = 1;
    end
    
    properties (Access=public, Hidden=true, Transient=true) 
        dataSource
    end
    
    properties(GetAccess=public, SetAccess=private, Dependent)
        % True if this LG is linked to a datasource.
        LinkedDatasource
    end
    
    properties (Dependent, Access=public)
        Name
        
        Megabytes
        
        % Total points in underlying dataset
        Ntotal
        
        % Size of the querry domain
        Nquerry
        
        % Size of the candidate domain
        Ncandidate
        
        % true iff candidate-domain == querry-domain
        IsSimpleDomainGraph
        
        % 1 x n, n - number of points covered by this definition 
        % (size(NNids, 1) == n); originalIds(j) - idx in datasource
        % querryIds is the inverse of mappedQuerryIds
        querryIds
        
    end
    
    % Legacy properties. Deprecated.
    properties (Dependent, Hidden=true)
        % 1 x n, n - number of points covered by this definition 
        % (size(NNids, 1) == n); originalIds(j) - idx in datasource
        % originalIds is the inverse of mappedQuerryIds
        % legacy
        originalIds
        
        % 1 x np, np - total number of points in datasource 
        % mappedIds(j) = 0, if no point not in querry-domain
        % mappedIds(j) = k, with getConnectedNodes(k) being the connected nodes
        % legacy
        mappedIds
        
        % same as originalIds, legacy
        domain
        
        % same as mappedQuerryIds, legacy
        domainMap
    end
    
    % Getters and Setters
    methods
        function value = get.Name(obj)
            value = obj.name;
        end
        function value = get.Megabytes(obj)
            value = obj.getMegabytes();
        end
        function value = get.LinkedDatasource(obj)
            value = obj.dataSource;
        end
        function set.Name(obj, value)
            obj.name = value;
        end
        function set.LinkedDatasource(obj, value)
            obj.dataSource = value;
        end
        function value = get.originalIds(obj)
            valid = obj.mappedQuerryIds ~= 0;
            value = NaN(1, sum(valid));
            value(obj.mappedQuerryIds(valid)) = find(valid);
        end
        function value = get.querryIds(obj)
            valid = obj.mappedQuerryIds ~= 0;
            value = NaN(1, sum(valid));
            value(obj.mappedQuerryIds(valid)) = find(valid);
        end
        function value = get.mappedIds(obj)
            value = obj.mappedQuerryIds;
        end
        function value = get.Ntotal(obj)
            value = numel(obj.mappedQuerryIds);
        end
        function value = get.Nquerry(obj)
            value = sum(obj.mappedQuerryIds ~= 0);
        end
        function value = get.Ncandidate(obj)
            value = numel(obj.candidateIds);
        end
        function value = get.IsSimpleDomainGraph(obj)
            value = all(obj.getQuerryDomain() == obj.getCandidateDomain());
        end
        % Legacy
        function rt = get.domain(obj)
            rt = obj.originalIds;
        end
        % Legacy
        function rt = get.domainMap(obj)
            rt = obj.mappedIds;
        end
        function set.mappedIds(obj, value)
            obj.mappedQuerryIds = value;
        end
        % Legacy
        function set.domain(obj, value)
            assert(false);
            obj.originalIds = value;
        end
        % Legacy
        function set.domainMap(obj, value)
            assert(false);
            obj.mappedIds = value;
        end
    end
    
    methods (Abstract)
        % Establishes the link to the underlying datasource
        initialize(obj, dataSource);
        
        rt = isInitialized(obj);
          
        % Returns list of connected nodes (local group) of size k. k can be 
        % omitted to autodetermine group size.
        % The returned matrix ids can be partially zeros and sparse if different 
        % datapoints have different outdegrees. Convention in Dataspace is that 
        % zeros are ignored in that case but this behavior might not yet be 
        % implemented everywhere.
        %
        % weights can be []
        %
        % Throws an exception if pointIds are not in the querry-domain.
        [ids, weights] = getConnectedNodes(obj, pointIds, k);
         
        % for deleting and reordering datapoints
        reindexDatasource(obj, datasource, newIdsInOrder);
        
        % adds n new datapoints to the end (only changes this
        % coordinates instance)
        addPtsToDatasource(obj, datasource, n);
    end
    
    % Legacy methods & Hidden abstract methods
    methods (Abstract, Hidden=true)
        mbytes = getMegabytes(obj);
    end
    
    methods (Hidden=true)
        function name = getName(obj)
            name = obj.name;
        end
        function source = getDatasource(obj)
            source = obj.dataSource;
        end
        % Returns local group of size k. k can be omitted to autodetermine group size. 
        % The element itself is not part of the LG.
        % This function returns a set of NaNs if pointIf is not in the querry-domain.
        % Note that .getConnectedNodes and .getLocalGroups throw exceptions in that case.
        function [ids, weights] = getLocalGroup(obj, pointId, k)
            assert(numel(pointId) == 1);
            if nargin == 2
                [ids, weights] = getConnectedNodes(obj, pointId);
            else
                [ids, weights] = getConnectedNodes(obj, pointId, k);
            end
        end
        % Legacy method
        function [ids, weights] = getLocalGroups(obj, pointIds, k)
            if nargin == 2
                [ids, weights] = obj.getConnectedNodes(pointIds);
            else
                [ids, weights] = obj.getConnectedNodes(pointIds, k);
            end
        end
        % Points in the querry domain can be querried for connections
        function ids = getQuerryDomain(obj)
            ids = find(obj.mappedQuerryIds ~= 0);
        end
        function ids = getCandidateDomain(obj)
            ids = obj.candidateIds;
        end
        % Returns the union of all candidate sets (those that fulfill the condition) 
        % for the points specified by pointIds and in how many candidate
        % sets each element appears
        function [ids, weights] = getWeightedJointDomain(obj, pointIds)
            assert(all(ismember(pointIds, obj.getQuerryDomain())));
            ids = obj.candidateIds;
            weights = ones(size(ids))*numel(pointIds);
        end
        % Applies processFcn to the candidate set (those that fulfill the condition) 
        % of each point specified in pointIds; returns a vector of results (one per pointId)
        % processFcn(domainIds, pointIdsWithDomain): pointIdsWithDomain is
        % a subset of pointIds and domainIds specifies the candidate set;
        % returns a vector of results (one per element of pointIdsWithDomain)
        function [processedDomains] = processDomains(obj, pointIds, processFcn)   
            assert(all(ismember(pointIds, obj.getQuerryDomain())));
            processedDomains = processFcn(obj.candidateIds, pointIds);
        end
    end
    
    % Hide handle class methods
    methods (Hidden=true)
        function lh = addlistener(varargin)
            lh = addlistener@handle(varargin{:});
        end
        function notify(varargin)
            notify@handle(varargin{:});
        end
        function delete(varargin)
            delete@handle(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@handle(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@handle(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
    end
end

