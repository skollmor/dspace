classdef NormalizedDerivedFeatures < dspace_features.AbstractDerivedFeatures
    % These coordinates are computed from the parent coordinates by element-wise 
    % normalization.
    %
    % Depending on the parent-coordinates dimension can be fixed or variable.
    %
    % Normalization Modes
    % -------------------
    %
    % 1) No influence between datapoints:
    % -----------------------------------
    %
    % X_new(i, :) = 1/norm * X_old(i, :)
    %
    % where norm is defined as follows:
    %
    % TYPE_DIVIDE_BY_MEAN_OF_5_LARGEST_COMPONENTS (fixed/variable dim.):
    % srt = sort(matrix(k, :));
    % norm = mean(srt(end-4:end));
    %
    % TYPE_DIVIDE_BY_MEAN_OF_10_LARGEST_COMPONENTS (fixed/variable dim.):
    % srt = sort(matrix(k, :));
    % norm = mean(srt(end-9:end));
    %
    % TYPE_DIVIDE_BY_SUM (fixed dim. only):
    % norm = sum(matrix, 2);
    %
    % TYPE_DIVIDE_BY_NORM (fixed dim. only):
    % norm = sqrt(sum(matrix.^2, 2));
    %
    % 2) Global component-wise normalization (only fixed dim.):
    % ---------------------------------------------------------
    %
    % X_new(i, k) = X_scale(k) * (X_old(i, k) - X_sub(k))
    % X_old(i,k) denotes the k-th coordinate component for datapoint i.
    % 
    % TYPE_GLOBAL_ZSCORE
    % X_sub is the mean and X_scale is 1/std-dev
    %
    % TYPE_GLOBAL_MEAN_ABS_DEVIATION
    % X_sub is the mean and X_scale is 1/ (sum( |X_i - X_sub| )/N)
    %
    % TYPE_GLOBAL_MEAN_ABS_DEVIATION_BUFFERED
    % X_sub is the mean and X_scale is 1/ (sum( |X_i - X_sub| )/N)
    % This mode assumes that each coordinate vector captures multiple time
    % points, normalization is constant across time and only varies across
    % features
    %
    %
    % See also dspacefcns.Features.normalizeFeatures.
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
        TYPE_DIVIDE_BY_MEAN_OF_5_LARGEST_COMPONENTS = 1; %'divide by mean of 5 largest components';
        TYPE_DIVIDE_BY_MEAN_OF_10_LARGEST_COMPONENTS = 2; %'divide by mean of 5 largest components';
        TYPE_DIVIDE_BY_SUM = 3; %'divide by sum';
        
        TYPE_DIVIDE_BY_NORM = 4; %'divide by norm';
        
        TYPE_CENTER = 5; %'subtract mean across components (center)' per datapoint
        
        TYPE_GLOBAL_ZSCORE = 6; % NaNs in normalized coordinate vectors are set to 0
        
        TYPE_GLOBAL_MEAN_ABS_DEVIATION = 7; % NaNs in normalized coordinate vectors are set to 0
        
        TYPE_GLOBAL_MEAN_ABS_DEVIATION_BUFFERED = 8; % NaNs in normalized coordinate vectors are set to 0
        
        ALL_TYPES = 1:8;
        ALL_NAMES = {'divide by mean of 5 largest components',...
            'divide by mean of 10 largest components',...
            'divide by sum',...
            'divide by norm',...
            'center (subtract mean across dimensions per datapoint)',...
            'global (z-score)',...
            'global (avg abs deviation from mean)',...
            'global (avg abs deviation from mean, buffered)'};
        
        VALID_TYPES_VARIABLE_DIMENSION = [1, 2, 5];
    end
    
    properties
            
        type = [];
        
        various
        
        layout
        
        % 1 x dim
        global_multiplications
        
        % 1 x dim
        global_subtractions
        
    end
    
    methods
        function reindexDatasource(obj, newIdsInOrder)
            if ~isempty(obj.global_multiplications)
                obj.global_multiplications = obj.global_multiplications(newIdsInOrder);
            end
            if ~isempty(obj.global_multiplications)
                obj.global_subtractions = obj.global_subtractions(newIdsInOrder);
            end
        end
        
        function addPtsToDatasource(obj, n)
            if ~isempty(obj.global_multiplications)
                obj.global_multiplications(end+1:end+n) = NaN;
            end
            if ~isempty(obj.global_multiplications)
                obj.global_subtractions(end+1:end+n) = NaN;
            end
        end
        
        function obj = NormalizedDerivedFeatures(parentCoordinates, parentCutoutIds, type, identifier, layout)
            obj.parentCoordinates = parentCoordinates;
            obj.parentCutoutIds = parentCutoutIds;
            obj.type = type;
            obj.identifier = identifier;
            if ~isempty(parentCoordinates)
                obj.parentCoordinateDescriptor = parentCoordinates.getDescriptor();
            end
            obj.layout = layout;
        end
        
        function setGlobalScalingParameters(obj, mul, sub)
            obj.global_multiplications = mul;
            obj.global_subtractions = sub;
        end
        
        function normTerms = computeNormalizerTerms(obj, matrix)         
            normTerms = NaN(size(matrix, 1), 1);
            
            switch obj.type
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_MEAN_OF_5_LARGEST_COMPONENTS
                    parfor k = 1:size(matrix, 1)
                        srt = sort(matrix(k, :));
                        normTerms(k) = mean(srt(end-4:end));
                    end
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_MEAN_OF_10_LARGEST_COMPONENTS
                    parfor k = 1:size(matrix, 1)
                        srt = sort(matrix(k, :));
                        normTerms(k) = mean(srt(end-9:end));
                    end
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_SUM
                    normTerms = sum(matrix, 2);
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_NORM
                    normTerms = sqrt(sum(matrix.^2, 2));
                case dspace_features.NormalizedDerivedFeatures.TYPE_CENTER
                    normTerms = [];
                otherwise
                    assert(false);
            end
            normTerms = 1./normTerms;
        end
        
        function cellArray = computeNormalization_cell(obj, cellArray)         
            switch obj.type
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_MEAN_OF_5_LARGEST_COMPONENTS
                    parfor k = 1:numel(cellArray)
                        srt = sort(cellArray{k}(:));
                        cellArray{k} = cellArray{k}/mean(srt(end-4:end));
                    end
                case dspace_features.NormalizedDerivedFeatures.TYPE_DIVIDE_BY_MEAN_OF_10_LARGEST_COMPONENTS
                    parfor k = 1:numel(cellArray)
                        srt = sort(cellArray{k}(:));
                        cellArray{k} = cellArray{k}/mean(srt(end-9:end));
                    end
                otherwise
                    assert(false);
            end
        end
        
        function [matrix, layout] = getDataMatrix(obj, datasource, ids)
            assert(obj.getIsFixedDimensionality());
            
            if ~obj.isInitialized()
                obj.initialize(datasource)
            end
            if isempty(obj.parentCutoutIds)
                matrix = obj.parentCoordinates.getDataMatrix(datasource, ids);
            else
                matrix = obj.parentCoordinates.getDataMatrixCutout(datasource, ids, obj.parentCutoutIds);
            end
            
            switch obj.type
                case {obj.TYPE_GLOBAL_ZSCORE, obj.TYPE_GLOBAL_MEAN_ABS_DEVIATION,...
                        obj.TYPE_GLOBAL_MEAN_ABS_DEVIATION_BUFFERED}
                    matrix = bsxfun(@times,...
                        bsxfun(@minus, matrix, obj.global_subtractions),...
                        obj.global_multiplications);
                    
                    matrix(isnan(matrix)) = 0;
                    
                case obj.TYPE_CENTER
                    matrix = matrix - nanmean(matrix, 2);
                otherwise
                    normTerms = obj.computeNormalizerTerms(matrix);
                    matrix = bsxfun(@times, matrix, normTerms);
            end
            layout = obj.layout;
        end
        
        function [matrix, layout] = getDataMatrixCutout(obj, datasource, ids, cutoutIds)
            assert(obj.getIsFixedDimensionality());
            
            if ~obj.isInitialized()
                obj.initialize(datasource)
            end
            if isempty(obj.parentCutoutIds)
                matrix = obj.parentCoordinates.getDataMatrix(datasource, ids);
            else
                matrix = obj.parentCoordinates.getDataMatrixCutout(datasource, ids, obj.parentCutoutIds);
            end
            
            matrix = matrix(:, cutoutIds);
            
            switch obj.type
                case {obj.TYPE_GLOBAL_ZSCORE, obj.TYPE_GLOBAL_MEAN_ABS_DEVIATION,...
                        obj.TYPE_GLOBAL_MEAN_ABS_DEVIATION_BUFFERED}
                    matrix = bsxfun(@times,...
                        bsxfun(@minus, matrix, obj.global_subtractions),...
                        obj.global_multiplications);
                    
                    matrix(isnan(matrix)) = 0;
                    
                case obj.TYPE_CENTER
                    matrix = matrix - nanmean(matrix, 2);
                otherwise
                    normTerms = obj.computeNormalizerTerms(matrix);
                    matrix = bsxfun(@times, matrix, normTerms);
            end
            
            layout = obj.layout;
        end
        
        function mb = getMegabytes(obj)
            nt = obj.global_subtractions;
            q = whos('nt');
            mb = q.bytes / 1024^2;
            nt = obj.global_multiplications;
            q = whos('nt');
            mb = mb + q.bytes / 1024^2;
        end
        
        function layout = getLayout(obj)
            layout = obj.layout;
        end
        
        function rt = getIsFixedDimensionality(obj)
            rt = obj.parentCoordinates.getIsFixedDimensionality();
        end
        
        function [cellArray, layouts] = getCell(obj, ids)
            assert(obj.isInitialized());
            assert(~obj.getIsFixedDimensionality());
            
            [cellArray, layouts] = obj.parentCoordinates.getCell(ids);
            
            switch obj.type
                case obj.TYPE_CENTER
                    parfor k = 1:numel(cellArray)
                        cellArray{k} = cellArray{k} - nanmean(cellArray{k});
                    end
                case {obj.TYPE_DIVIDE_BY_MEAN_OF_10_LARGEST_COMPONENTS,...
                        obj.TYPE_DIVIDE_BY_MEAN_OF_5_LARGEST_COMPONENTS,...
                        obj.TYPE_DIVIDE_BY_NORM,...
                        obj.TYPE_DIVIDE_BY_SUM}    
                    cellArray = obj.computeNormalization_cell(cellArray);
                otherwise
                    assert(false);
            end
        end
        
    end
end

