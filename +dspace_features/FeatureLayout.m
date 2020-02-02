classdef FeatureLayout < matlab.mixin.Copyable
    % Instances of this class determine how coordinates are plotted and
    % describe and annotate various components or dimenions.
    %
    % Features with fixed dimensions are viewed as matrices or (sometimes)
    % higher order tensors (i.e. n-d arrays with n>=3). For two dimensions,
    % the order of dimensions is y, x (matrix-columns are plotted vertically).
    % Each datapoint is represented as a row vector (returned by .getMatrix()
    % or .getMatrixCutout() and reshaped by Dataspace to .dimensions before
    % plotting: reshape(Cvector, dimensions(1), dimensions(2)).
    %
    % Features with variable dimensions have .dimenions(n) == NaN if
    % the size along this dimension is varying.
    %
    % See also dspace_features.AbstractFeatures.
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
       
        dimensions              % Rows x columns, e.g. [100, 10]
        range                   % Minimum and maximum value, e.g. [-1, 1], can be empty
        
        % these are linear indices
        cutoutIndices           % e.g. 1:100
        
        % y, x
        cutoutDimension         % e.g. [10,10]
        
        % These following properties give meaning to the dimensions of the 
        % reshaped coordinate vector. They are for advanced layout-purposes.
        
        % Cell array of length numel(dimensions), gives meaning to each value for each dimension
        % of the reshaped coordinate vector
        % For example, if dimensions = 100 x 10, the resulting matrix has 100 rows and 10 columns
        % the rows have the meanings dimensionMeanings{1} and the columns dimensionMeanings{2}.
        % dimensionMeanings{1} must be a 100-element numeric vector and dimensionMeanings{2} 
        % must be 10-element numeric vector.
        %
        % Each dimensionMeanings-element can also be empty.
        dimensionMeanings = {[], []}; 
        % Cell array of length numel(dimensions) of cell arrays of strings.
        % This corresponds one-to-one to dimensionMeanings. 
        % Can be empty
        dimensionMeaningNames = {{}, {}};
        
        dimensionNames = {'', ''};      % a name for each dimension, e.g. {'Freq', 'Time'}, can contain 2 empty elements
        dimensionLimits = {[], []};     % limits for each dimension, e.g. {[0, 10], [20, 100]}, can contain 2 empty elements
        
        % For layouts with width or height greater 1, a meaning can be
        % assigned to each component
        componentMeanings = {}; % e.g. {'PC1','PC2',...,'PCn'}, where n = prod(dimensions)
        
        % For layouts with variable dimensions an increment can be provided 
        % to dimensionMeanings 
        dimensionIncrements = [NaN, NaN];
        
        % Setting these properties will trigger an integrity check
        integrityDefiningProperties = {'dimensions', 'range', 'cutoutIndices', 'cutoutDimension', 'dimensionMeanings', ...
            'dimensionMeaningNames', 'dimensionNames', 'dimensionLimits', 'componentMeanings', ...
            'dimensionIncrements'};
        
        various
        
    end
    
    properties (Access=public, Dependent)
        % total number of components; product of sizes across all dimensions
        nTotal
        
        % total number of components for the cutout; product of sizes across all dimensions
        nCutout
        
        dim1Meanings
        dim1Meanings_cutout
        
        dim2Meanings
        dim2Meanings_cutout
        
        dim1Name
        dim2Name
        
        isFixedDimension
        
        identifier
    end
    
    properties (Hidden=true)
        % You need to set this to false after the object has been 
        % constructed or loaded in order to not perform integrity checks
        % 
        % The object constructor and loadObj method will automatically set performIntegrityChecks to true.
        %
        % Do not change the default-value. The next line must be 'performIntegrityChecks = false'
        % even if checks are to be performed.
        performIntegrityChecks = false;
    end
    
    methods (Access=public)
        
        function conditional_assert(obj, condition, str)
            if ~condition
                warning(str);
            end
        end
            
        
        function rt = integrityCheck(obj, varargin)
            return;
            if ~obj.performIntegrityChecks
                rt = true;
                return
            end
            
            obj.conditional_assert(numel(obj.dimensions) == 2, 'dspace_features.FeatureLayout: .dimensions should have 2 elements.');
            
            obj.conditional_assert(isempty(obj.range) || numel(obj.range) == 2, 'dspace_features.FeatureLayout: .range should have 2 elements or be empty.'); 
            
            obj.conditional_assert(numel(obj.cutoutDimension) == 2, 'dspace_features.FeatureLayout: .cutoutDimension should have 2 elements.'); 
            obj.conditional_assert(all(obj.dimensions >= obj.cutoutDimension), 'dspace_features.FeatureLayout: .cutoutDimension can not exceed .dimensions.'); 
            linearDim = prod(obj.dimensions);
            obj.conditional_assert(ismember(obj.cutoutIndices, 1:linearDim), 'dspace_features.FeatureLayout: .cutoutIndices need to be linear indices.');
            
            obj.conditional_assert(numel(obj.dimensionMeanings) == 2, 'dspace_features.FeatureLayout: .dimensionMeanings needs to have 2 arrays as elements.');
            obj.conditional_assert(numel(obj.dimensionMeaningNames) == 2, 'dspace_features.FeatureLayout: .dimensionMeaningNames needs to have 2 cell arrays as elements.');
            
            obj.conditional_assert(numel(obj.dimensionNames) == 2, 'dspace_features.FeatureLayout: .dimensionNames needs to have 2 strings elements.');
            obj.conditional_assert(numel(obj.dimensionLimits) == 2, 'dspace_features.FeatureLayout: .dimensionLimits needs to have 2 array elements, each of size 2.');
            
            for j = 1:2
                obj.conditional_assert(isempty(obj.dimensionMeanings{j}) || numel(obj.dimensionMeanings{j}) == obj.dimensions(j),...
                    sprintf(['dspace_features.FeatureLayout: %ith component of .dimensionMeanings is not proper.'...
                                '\nIt needs to be either empty or correctly sized.'], j));
                obj.conditional_assert(isempty(obj.dimensionMeaningNames{j}) || numel(obj.dimensionMeaningNames{j}) == obj.dimensions(j),...
                    sprintf(['dspace_features.FeatureLayout: %ith component of .dimensionMeaningNames is not proper.'...
                                '\nIt needs to be either empty or correctly sized.'], j));
%                 obj.conditional_assert(isempty(obj.dimensionNames{j}) || isstring(obj.dimensionNames{j}),...
%                     sprintf(['dspace_features.FeatureLayout: %ith component of .dimensionNames is not proper.'...
%                                 '\nIt needs to be either empty or a string.'], j));
                obj.conditional_assert(isempty(obj.dimensionLimits{j})...
                    || (isnumeric(obj.dimensionLimits{j}) && numel(obj.dimensionLimits{j}) == 2),...
                    sprintf(['dspace_features.FeatureLayout: %ith component of .dimensionLimits is not proper.'...
                                '\nIt needs to be either empty or a numeric array with 2 elements.'], j));
            end
            
            obj.conditional_assert(isempty(obj.componentMeanings) || numel(obj.componentMeanings) == linearDim,...
                'dspace_features.FeatureLayout: .componentMeanings needs to be either empty or have .dimensions(1) * .dimensions(2) elements.');
            obj.conditional_assert(isempty(obj.dimensionIncrements) || numel(obj.dimensionIncrements) == 2,...
                'dspace_features.FeatureLayout: .dimensionIncrements needs to be either empty or have 2 elements.');
            
            rt = true;
            
        end
    end
    
    % Getters and Setters
    methods
        % Setters for non-dependent properties to allow integrity checks
        function set.dimensions(obj, val)
            obj.dimensions = val;
            obj.integrityCheck();
        end 
        function set.range(obj, val)
            obj.range = val;
            obj.integrityCheck();
        end
        function set.cutoutIndices(obj, val)
            obj.cutoutIndices = val;
            obj.integrityCheck();
        end
        function set.cutoutDimension(obj, val)
            obj.cutoutDimension = val;
            obj.integrityCheck();
        end
        function set.dimensionMeanings(obj, val)
            obj.dimensionMeanings = val;
            obj.integrityCheck();
        end
        function set.dimensionMeaningNames(obj, val)
            obj.dimensionMeaningNames = val;
            obj.integrityCheck();
        end
        function set.dimensionNames(obj, val)
            obj.dimensionNames = val;
            obj.integrityCheck();
        end
        function set.dimensionLimits(obj, val)
            obj.dimensionLimits = val;
            obj.integrityCheck();
        end
        function set.componentMeanings(obj, val)
            obj.componentMeanings = val;
            obj.integrityCheck();
        end
        function set.dimensionIncrements(obj, val)
            obj.dimensionIncrements = val;
            obj.integrityCheck();
        end
          
        % Getters for dependent properties
        function rt = get.isFixedDimension(obj)
            rt = ~any(isnan(obj.dimensions));
        end
        function rt = get.nTotal(obj)
            rt = prod(obj.dimensions);
        end
        function rt = get.nCutout(obj)
            rt = numel(obj.cutoutIndices);
        end
        function rt = get.dim1Meanings(obj)
            rt = obj.dimensionMeanings{1};
            if isempty(rt)
                rt = 1:obj.dimensions(1);
            end
        end
        function rt = get.dim1Meanings_cutout(obj)
            assert(false);
            rt = obj.dimensionMeanings{1};
            if isempty(rt)
                rt = 1:obj.dimensions(1);
            end
            ii = repmat((1:obj.dimensions(1))', 1, obj.dimensions(2));
            ii = ii(obj.cutoutIndices);
            ii = unique(ii(:));
            rt = rt(ii);
        end
        function rt = get.dim2Meanings(obj)
            rt = obj.dimensionMeanings{2};
            if isempty(rt)
                rt = 1:obj.dimensions(2);
            end
        end
        function rt = get.dim2Meanings_cutout(obj)
            assert(false);
            rt = obj.dimensionMeanings{2};
            if isempty(rt)
                rt = 1:obj.dimensions(2);
            end
            rt = rt(obj.cutoutIndices);
        end
        
        function rt = get.dim1Name(obj)
            rt = obj.dimensionNames{1};
        end
        function rt = get.dim2Name(obj)
            rt = obj.dimensionNames{2};
        end
        function rt = get.identifier(obj)
            rt = obj.getIdentifier();
        end
    end
    
    % Methods
    methods (Access=public)
        
        function obj = FeatureLayout(dimensions, range, cutoutIndices, cutoutDimension)
            %obj.performIntegrityChecks = false; % this is the default
            
            obj.dimensions = dimensions;
            obj.range = range;
            obj.cutoutIndices = cutoutIndices;
            obj.cutoutDimension = cutoutDimension;
            
            obj.performIntegrityChecks = true;
        end
        
        function setCutoutToAll(obj)
            obj.performIntegrityChecks = false;
            obj.cutoutIndices = 1:obj.nTotal;
            obj.cutoutDimension = obj.dimensions;
            obj.performIntegrityChecks = true;
            obj.integrityCheck();
        end
        
        function setLabeling(obj, yAxisValues, yAxisName, xAxisValues, xAxisName)
            obj.performIntegrityChecks = false;
            obj.dimensionNames = {yAxisName, xAxisName};
            obj.dimensionMeanings = {yAxisValues, xAxisValues};
            obj.performIntegrityChecks = true;
            obj.integrityCheck();
        end
        
        function setDimensionIncrements(obj, yAxisIncrement, xAxisIncrement)
            obj.dimensionIncrements = {xAxisIncrement, yAxisIncrement};
        end
        
        function str = getIdentifier(obj)
            if isempty(obj.cutoutDimension)
                str = sprintf('%i x %i (%i) [%i x %i (%i)]', obj.dimensions(1), obj.dimensions(2), prod(obj.dimensions),...
                    obj.dimensions(1), obj.dimensions(2), numel(obj.cutoutIndices));
            else
                str = sprintf('%i x %i (%i) [%i x %i (%i)]', obj.dimensions(1), obj.dimensions(2), prod(obj.dimensions),...
                    obj.cutoutDimension(1), obj.cutoutDimension(2), numel(obj.cutoutIndices));
            end
        end
        
        function transposeLayout(e)
            % This method is incomplete (TODO)
            obj.performIntegrityChecks = false;
            e.dimensions = e.dimensions(end:-1:1);
            e.cutoutDimension = e.cutoutDimension(end:-1:1);
            %             tmp1 = e.dim1Meanings;
            %             e.dim1Meanings = e.dim2Meanings;
            %             e.dim2Meanings = tmp1;
            %             tmp1 = e.dim1Name;
            %             e.dim1Name = e.dim2Name;
            %             e.dim2Name = tmp1;
            e.dimensionMeanings = e.dimensionMeanings(end:-1:1);
            e.dimensionNames = e.dimensionNames(end:-1:1);
            e.dimensionLimits = e.dimensionLimits(end:-1:1);
            obj.performIntegrityChecks = true;
        end
        
    end
    
    methods (Static)
        function obj = loadobj(s)
            s.performIntegrityChecks = true;
            obj = s;
        end
    end
end

