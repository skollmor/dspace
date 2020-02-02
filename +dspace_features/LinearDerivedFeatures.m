classdef LinearDerivedFeatures < dspace_features.AbstractDerivedFeatures & dspace_features.AbstractHeavyFeatures
    % These coordinates are computed from the parent coordinates as 
    % X_new = (X_old - Xmean_pre) * TM + Xmean_post
    %
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
        
%         identifier
%         
%         parentCoordinateDescriptor
%         parentCutoutIds
        
        Xmean_pre   % <x_old>, 1 x numel(parentCutoutIds)
        Xmean_post
        TM % d x d_parent
       
        various
        
        layout
        
    end
    
%     properties (Transient=true, SetAccess=private)
%         
%         parentCoordinates
%         
%     end
    
    % HeavyCoordinates
    methods
    
        function HD = getHeavyData(obj)
            HD = obj.TM;
        end
        
        function restoreHeavyData(obj, HD)
            obj.TM = HD;
        end
        
        function clearHeavyData(obj)
            obj.TM = []; 
        end
        
    end
    
    methods
        
        % for deleting and reordering datapoints
        function reindexDatasource(obj, newIdsInOrder)
        end
        
        % adds n new datapoints to the end (only changes this
        % coordinates instance)
        function addPtsToDatasource(obj, n)
        end
        
        function obj = LinearDerivedFeatures(parentCoordinates, parentCutoutIds, TM, Xmean_pre, Xmean_post, identifier, layout)
            obj.parentCoordinates = parentCoordinates;
            obj.parentCutoutIds = parentCutoutIds;
            obj.TM = TM;
            obj.Xmean_pre = Xmean_pre;
            obj.Xmean_post = Xmean_post;
            obj.identifier = identifier;
            if ~isempty(parentCoordinates)
                obj.parentCoordinateDescriptor = parentCoordinates.getDescriptor();
            end
            obj.layout = layout;
        end
        
%         function str = getDescriptor(obj)
%             str = sprintf('%s - %s', obj.identifier, obj.layout.getIdentifier());
%         end
%         
%         function str = getIdentifier(obj)
%             str = obj.identifier;
%         end
        
%         function initialize(obj, datasource)
%             obj.dataSource = datasource;
%             obj.parentCoordinates = dspace_features.AbstractFeatures.getByDescriptor(...
%                 obj.parentCoordinateDescriptor, datasource.coordinates);
%             assert(~isempty(obj.parentCoordinates));
%         end
         
         function [matrix, layout] = getLowDRepresentation(obj, datasource, ids)
            assert(false); % Should't use but rather create explicit low-d coordinates
            if isempty(obj.parentCoordinates)
                obj.initialize(datasource)
            end
            if isempty(obj.parentCutoutIds)
                matrix = bsxfun(@minus, obj.parentCoordinates.getDataMatrix(datasource, ids), obj.Xmean_pre) * obj.M;
            else
                matrix = bsxfun(@minus, obj.parentCoordinates.getDataMatrixCutout(datasource, ids, obj.parentCutoutIds),...
                    obj.Xmean_pre) * obj.M;
            end
            layout = obj.layout;
        end
        
        function [matrix, layout] = getDataMatrix(obj, datasource, ids)
            if isempty(obj.parentCoordinates)
                obj.initialize(datasource)
            end
            if isempty(obj.parentCutoutIds)
                matrix = bsxfun(@minus, single(obj.parentCoordinates.getDataMatrix(datasource, ids)), obj.Xmean_pre)...
                    * obj.TM;
                if ~isempty(obj.Xmean_post)
                    matrix = bsxfun(@plus, matrix, obj.Xmean_post);
                end
            else
                matrix = bsxfun(@minus, single(full(obj.parentCoordinates.getDataMatrixCutout(...
                    datasource, ids, obj.parentCutoutIds))),...
                    obj.Xmean_pre) * obj.TM;
                if ~isempty(obj.Xmean_post)
                    matrix =  bsxfun(@plus, matrix, obj.Xmean_post);
                end
            end
            layout = obj.layout;
        end
        
        function [matrix, layout] = getDataMatrixCutout(obj, datasource, ids, cutoutIds)
            if isempty(obj.parentCoordinates)
                obj.initialize(datasource)
            end
            if isempty(obj.parentCutoutIds)
                matrix = bsxfun(@minus, single(full(obj.parentCoordinates.getDataMatrix(datasource, ids))), obj.Xmean_pre)...
                    * obj.TM(:, cutoutIds);
                if ~isempty(obj.Xmean_post)
                    matrix =  bsxfun(@plus, matrix, obj.Xmean_post(1, cutoutIds));
                end
            else
                matrix = bsxfun(@minus, single(full(obj.parentCoordinates.getDataMatrixCutout(datasource, ids,...
                    obj.parentCutoutIds))), obj.Xmean_pre) * obj.TM(:, cutoutIds);
                if ~isempty(obj.Xmean_post)
                    matrix =  bsxfun(@plus, matrix, obj.Xmean_post(1, cutoutIds));
                end
            end
            layout = obj.layout;
        end
        
        function mb = getMegabytes(obj)
            TM_ = obj.TM;
            q = whos('TM_');
            mb = q.bytes / 1024^2;
            tmp_ = obj.Xmean_pre;
            q = whos('tmp_');
            mb = mb + q.bytes / 1024^2;
            tmp_ = obj.Xmean_post;
            q = whos('tmp_');
            mb = mb + q.bytes / 1024^2;
            tmp_ = obj.various;
            q = whos('tmp_');
            mb = mb + q.bytes / 1024^2; 
        end
        
        function layout = getLayout(obj)
            layout = obj.layout;
        end
        
        function rt = getIsFixedDimensionality(obj)
            rt = true;
        end
        
        function [cellArray, layouts] = getCell(obj, ids)
           assert(false); 
        end
        
    end
    
end

