classdef StandardFeatures < dspace_features.AbstractFeatures & dspace_features.AbstractHeavyFeatures
    % Coordinates backed by cell array or numeric matrix. numeric types float, 
    % double and sparse are supported.
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
        % np x 1, np - total number of points in datasource 
        % mappedIds(j) = 0, if no coordinates are defined
        % mappedIds(j) = k, with Xf(k, :) = coordinates
        mappedIds
        
        % n x 1, n - number of unique coordinate vectors in this definition 
        % (size(Xf, 1) == n); originalIds(j) - idx in datasource
        % 
        various
     
        % 
        hasFixedDimension
        
        % Note: dspace_features.AbstractHeavyFeatures takes care of Xf serialization 
        % and Xf stored inside dspace_data.saveDatasource()
        Xf % #points x dimensions
        
        % identifier
        
        layout
        
    end
    
    methods
        
        function obj = StandardFeatures(varargin)
            % Constructor, can be used in three ways:
            %
            % (a) Call with 4 arguments: Xf, mappedIds, identifier, layout
            % Xf            numeric matrix, #points x feature dimensions (fixed dimension), 
            %               or cell array #points x 1 containing numeric arrays
            % mappedIds     np x 1, integers, where np is the total number of 
            %               points in datasource. 
            %               mappedIds(j) = 0, if no coordinates are defined
            %               mappedIds(j) = k, with Xf(k, :) = coordinates otherwise
            % identifier    string, identifier/name
            % layout        FeatureLayout object
            %
            % (b) Call with 5 arguments: Xf, pointIds, totalNumberOfPoints, identifier, layout
            % Xf, identifier layout defined as in (a)
            % pointIds      n x 1, where n is the number of points covered by 
            %               this feature definition
            %               (size(Xf, 1) == n); pointIds(j) - idx in datasource, 
            %               associated to Xf(j, :)
            %
            % (c) Call with 3 arguments: Xf, identifier, layout
            % The number of rows in Xf is assumed to equal the number of datapoints
            %
            % 
            if nargin == 3
                obj.Xf = varargin{1};    
                obj.mappedIds = (1:size(obj.Xf, 1))';
                obj.identifier = varargin{2};
                obj.layout = varargin{3};
            elseif nargin == 4
                obj.Xf = varargin{1};    
                obj.mappedIds = varargin{2};
                obj.identifier = varargin{3};
                obj.layout = varargin{4};
            elseif nargin == 5
                obj.Xf = varargin{1};    
                pointIds = varargin{2};
                totalNumberOfPoints = varargin{3};
                obj.identifier = varargin{4};
                obj.layout = varargin{5};
                obj.mappedIds = zeros(totalNumberOfPoints, 1);
                obj.mappedIds(pointIds, :) = 1:numel(pointIds);
            end
            if obj.layout.isFixedDimension
                obj.hasFixedDimension = true;
            else
                assert(iscell(obj.Xf));
                obj.hasFixedDimension = false;
            end
        end
        
        function [matrix, layout] = getDataMatrix(obj, datasource, ids)
            assert(obj.hasFixedDimension);
            mIds = obj.mappedIds(ids);
            zz = mIds == 0;
            if any(zz)
                matrix = NaN(numel(mIds), size(obj.Xf, 2));
                matrix(~zz, :) = obj.Xf(mIds(~zz), :);
            else
                matrix = obj.Xf(mIds, :);
            end
            layout = obj.layout;
        end
        
        function [matrix, layout] = getDataMatrixCutout(obj, datasource, ids, cutoutIds)
            assert(obj.hasFixedDimension);
            mIds = obj.mappedIds(ids);
            zz = mIds == 0;
            if any(zz)
                matrix = NaN(numel(mIds), numel(cutoutIds));
                matrix(~zz, :) = obj.Xf(mIds(~zz), cutoutIds);
            else
                matrix = obj.Xf(mIds, cutoutIds);
            end
            layout = obj.layout;
        end
        
        function mb = getMegabytes(obj)
            Xf_ = obj.Xf;
            q = whos('Xf_');
            mb = q.bytes / 1024^2;
        end
        
        function layout = getLayout(obj)
            layout = obj.layout;
        end
        
        function rt = getIsFixedDimensionality(obj)
            rt = obj.hasFixedDimension;
        end
        
        function ids = getSupportDomain(obj)
            ids = obj.domain;
        end
        
        function [cellArray, layouts] = getCell(obj, ids)
            assert(~obj.hasFixedDimension);
            mIds = obj.mappedIds(ids);
            cellArray = cell(numel(ids), 1);
            cellArray(:) = {[]};
            zz = mIds == 0;
            cellArray(~zz) = obj.Xf(mIds(~zz));
            layouts = obj.layout;
        end
        
        % Deprecated:
        % for deleting and reordering datapoints
        % --Seems to complicated
        function reindexDatasource(obj, newIdsInOrder)
            assert(false);
            old_Np = numel(obj.domainMap);
            newIdsInOrder_inv = zeros(old_Np, 1);
            newIdsInOrder_inv(newIdsInOrder) = 1:numel(newIdsInOrder);
            inLG = obj.domainMap(newIdsInOrder) ~= 0;
            newDomain = newIdsInOrder_inv(obj.domain(obj.domainMap(newIdsInOrder(inLG))));
            
            if any(newDomain == 0) || numel(newDomain) ~= numel(obj.domain)
                assert(false, 'CloningStandardCoordinates: Reindexing would change the coordinate domain.');
            end
            
            newDomainMap = zeros(numel(newIdsInOrder), 1);
            newDomainMap(newDomain) = 1:numel(newDomain);
            
            newXf = obj.Xf(obj.domainMap(newIdsInOrder(inLG)), :);
            
            obj.domain = newDomain;
            obj.domainMap = newDomainMap;
            obj.Xf = newXf;
        end
        
        % Deprecated:
        % adds n new datapoints to the end (only changes this
        % LG instance)
        function addPtsToDatasource(obj, n)
            assert(false);
            obj.domainMap(end+1:end+n) = 0;
        end
        
    end
    
    % Deprecated:
    properties (Dependent, Access=public, Hidden=true)
        domain
        domainMap
    end
    
    % Deprecated:
    methods
        function rt = get.domain(obj)
            rt = find(obj.mappedIds ~= 0);
        end
        function rt = get.domainMap(obj)
            rt = obj.mappedIds;
        end
        function set.domain(obj, value)
            assert(false);
            obj.originalIds = value;
        end
        function set.domainMap(obj, value)
            assert(false);
            obj.mappedIds = value;
        end
    end
    
end

