classdef AbstractFeatures < matlab.mixin.Copyable
    % Baseclass for Features in Dataspace.
    % Features are explained in broad terms here:
    % <a href="matlab:dspace.help('dspace.resources.docs.Introduction_to_Dataspace')">Introduction to Dataspace (Dataspace Help)</a>.
    %
    % Features can have fixed dimensions (default). In that case the 
    % representations for all datapoints have the same number of components 
    % and the same dimensions and layout. The functions getMatrix() and getMatrixCutout()
    % are used to access coordinates data.
    % getIsFixedDimensionality()==true is the default. 
    %
    % Features that have varying dimension across datapoints override the
    % method getIsFixedDimensionality() (so it returns false)
    % as well as the function getDataCell() which is used to access coordinate
    % data if getIsFixedDimensionality()==false.
    %
    % Per default all datapoints in the associated datasource are covered
    % by these coordinates (SupportDomain==[NaN]). For partial coverage,
    % override the method getSupportDomain().
    %
    % Any coordinates should be subclasses of either dspace_features.AbstractFeatures
    % or dspace_features.AbstractDerivedFeatures.
    %
    % Additionally they can inherit from one or several of the following classes: 
    % - dspace_features.AbstractAdjustableFeatures
    % - dspace_features.AbstractHeavyFeatures
    % - dspace_features.StreamEmbeddedFeatures
    %
    % See also dspace_features.AbstractDerivedFeatures, dspace_features.AbstractAdjustableFeatures, 
    % dspace_features.AbstractHeavyFeatures, dspace_features.StreamEmbeddedFeatures, 
    % dspace_data.TableDataSource.
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

    
    properties (Access=public, Dependent)
        % The name of these Features (identical to the identifier).
        Name
        
        % The layout of these Features (see <a href="matlab:doc('dspace_features.FeatureLayout')">dspace_features.FeatureLayout</a>).
        Layout
        
        % Size of these coordinates in mb.
        Megabytes
        
        % True if the representations of all datapoints have the same dimension.
        % If dimensionality is fixed, use getMatrix or getDataMatrix to obtain coordinates for
        % datapoints. Otherwise use getCell or getDataCell.
        IsFixedDimensionality
        
        % List of all datapoint-ids for which coordinates are provided.
        % Per convention, .SupportDomain==[NaN] implies that all datapoints
        % are covered.
        SupportDomain
    end
    
    properties(GetAccess=public, SetAccess=private, Dependent)
        % The datasource these coordinates are linked to. Note: not all
        % coordinates require a link to a datasource.
        LinkedDatasource
    end
     
    properties (Access=public, Hidden=true)
        identifier
    end
    
    properties (Access=public, Hidden=true, Transient=true)
        dataSource
    end
    
    % Getters and Setters for Properties
    methods
        function value = get.Name(obj)
            value = obj.identifier;
        end
        function value = get.Layout(obj)
            value = obj.getLayout();
        end
        function value = get.Megabytes(obj)
            value = obj.getMegabytes();
        end
        function value = get.LinkedDatasource(obj)
            value = obj.dataSource;
        end
        function value = get.IsFixedDimensionality(obj)
            value = obj.getIsFixedDimensionality();
        end
        function value = get.SupportDomain(obj)
            value = obj.getSupportDomain();
        end
        function set.LinkedDatasource(obj, value)
            obj.dataSource = value;
        end
    end
    
    methods (Access=public)
        
        function initialize(obj, datasource)
            % Link coordinates to their datasource. Overwrite this method if special initialization is needed.
            % The datasource link is not required for all coordinates.
            obj.dataSource = datasource;
        end
        
        
        function rt = isInitialized(obj)
            % Returns true if coordinates are linked to a datasource. Overwrite this method if special initialization is needed.
            rt = ~isempty(obj.dataSource);
        end
    end
    
    methods (Access=public)
        
        function [matrix, layout] = getMatrix(obj, ids)
            % Return the coordinate vectors for the given datapoints.
            % For legacy reasons, you should override the hidden methods getDataMatrix
            % and getDataMatrixCutout.
            assert(obj.IsFixedDimensionality);
            [matrix, layout] = obj.getDataMatrix(obj.dataSource, ids);
        end
        
        function [matrix, layout] = getMatrixCutout(obj, ids, cutoutIds)
            % Return coordinate vector cutouts for the given datapoints.
            % For legacy reasons, you should override the hidden methods getDataMatrix
            % and getDataMatrixCutout.
            assert(obj.IsFixedDimensionality);
            if nargin < 3
                cutoutIds = obj.Layout.cutoutIndices;
                [matrix, layout] = obj.getDataMatrixCutout(obj.dataSource, ids, cutoutIds);
            else
                [matrix, layout] = obj.getDataMatrixCutout(obj.dataSource, ids, cutoutIds);
            end
        end
        
        function updateAllDerivedCoordinates(obj)
            % Update derrived coordinates
            if ~obj.isInitialized()
                assert(false, sprintf('Coordinates.updateAllDerivedCoordinates: Coordinates %s are not initialized.\n', obj.Name));
            else
                for cid = 1:numel(obj.dataSource.C)
                    if isa(obj.dataSource.C{cid}, 'dspace_features.AbstractDerivedFeatures')...
                        || isa(obj.dataSource.C{cid}, 'dataSources.AcousticFeatureDerrivedCoordinates') % legacy class       
                        
                        if ~obj.dataSource.C{cid}.isInitialized()
                            obj.dataSource.C{cid}.initialize(obj.dataSource);
                        end
                        
                        %if isprop(obj.dataSource.C{cid}, 'ParentCoordinates')
                        %    if obj.dataSource.C{cid}.ParentCoordinates == obj
                        
                        if ismethod(obj.dataSource.C{cid}, 'recomputeLayout')
                            obj.dataSource.C{cid}.recomputeLayout();
                        end
                        
                        %    end
                        %end
                        
                    end
                end
            end
        end
            
    end
    
    methods (Abstract)
        % for deleting and reordering datapoints
        reindexDatasource(obj, newIdsInOrder);
        
        % adds n new datapoints to the end (only changes this
        % coordinates instance)
        addPtsToDatasource(obj, n);
        
        megabytes = getMegabytes(obj);
        
        % Returns CoordinateLayout instance.
        layout = getLayout(obj);
        
        % True if the representations of all datapoints have the same dimension.
        % If dimensionality is fixed, use getMatrix or getDataMatrix to obtain coordinates for
        % datapoints. Otherwise use getCell or getDataCell.
        rt = getIsFixedDimensionality(obj);
        
        % List of all datapoint-ids for which coordinates are provided.
        % The inverse of this provides the global datapoint id for each
        % datapoint covered by these coordinates. It is seldomly used.
        % Per convention, SupportDomain==[NaN] implies that all datapoints
        % are covered.
        ids = getSupportDomain(obj);
        
        [cellArray, layouts] = getCell(obj, ids)
    end
    
    methods (Abstract, Hidden=true)
        % Returns the coordinate vectors for the given datapoints.
        % The datasource argument is for legacy reasons and is always obj.dataSource.
        [matrix, layout] = getDataMatrix(obj, datasource, ids)
        
        % Returns the coordinate vectors for the given datapoints.
        % The datasource argument is for legacy reasons and is always obj.dataSource
        [matrix, layout] = getDataMatrixCutout(obj, datasource, ids, cutoutIds);
    end
    
    methods (Access=public, Hidden=true)
        function str = getDescriptor(obj)
            layout = obj.getLayout();
            if ~isempty(layout)
                str = sprintf('%s - %s', obj.identifier, obj.getLayout().getIdentifier());
            else
                str = sprintf('%s - %s', obj.identifier, '[Undef. Layout]');
            end
        end
        
        function str = getIdentifier(obj)
            str = obj.identifier;
        end
    end
    
    % Legacy properties
    properties (Access=public, Hidden=true)
        displayId = 1;
    end
    
    % Hide handle class methods
    methods (Hidden=true)
        function lh = listener(varargin)
            lh = listener@handle(varargin{:});
        end
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
    
    methods (Static, Hidden=true)
       
        function rt = compareDescriptors(a, b)
            % Compares coordinate descriptors excluding layout information
            % and dimensions. This is the same as getByIdentifier
            % (starting from '(')
            %             aspl = strsplit(a, '[');
            %             a = aspl{1};
            %             bspl = strsplit(b, '[');
            %             b = bspl{1};
            %             rt = strcmp(a, b);
            
            aspl = strsplit(a, '-');
            a = aspl{1};
            bspl = strsplit(b, '-');
            b = bspl{1};
            rt = strcmp(a, b);
        end
        
        function coordinates = getByDescriptor(descriptor, coordinateCell)
            coordinates = [];
            for k = 1:numel(coordinateCell)
                if dspace_features.AbstractFeatures.compareDescriptors(descriptor,...
                        coordinateCell{k}.getDescriptor())
                    coordinates = coordinateCell{k};
                end
            end
        end
        
        function coordinates = getByIdentifier(identifier, coordinatesCell)
            cidents = arrayfun(@(i) coordinatesCell{i}.getIdentifier(),...
                1:numel(coordinatesCell), 'uni', false);
            cordId = find(strcmp(identifier, cidents), 1);
            coordinates = coordinatesCell{cordId};
        end
        
    end
end

