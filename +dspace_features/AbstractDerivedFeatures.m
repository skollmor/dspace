classdef AbstractDerivedFeatures < dspace_features.AbstractFeatures
    % Derived features are computed for each datapoint as some transformation
    % of some other coordinates (the parent-coordinates).
    %
    % Any coordinates should be subclasses of either dspace_features.AbstractFeatures
    % or dspace_features.AbstractDerivedFeatures.
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
        parentCoordinateDescriptor
        parentCutoutIds
    end
    
    properties (Transient=true, Hidden=true)
        parentCoordinates
    end
    
    properties (Access=public, Dependent)
        % Parent coordinate object.
        ParentCoordinates
        % Name of parent coordinates.
        ParentCoordinateName
        % Cutout from parent coordinates.
        ParentCoordinateCutout
    end
    
    % Getters and Setters
    methods
        function value = get.ParentCoordinates(obj)
            if ~obj.isInitialized()
                assert(false, 'Link the coordinates to a datasource first by calling .initialize(datasource).');
            end
            value = obj.parentCoordinates;
        end
    end
    
    methods (Access=public)
        function initialize(obj, datasource)
            obj.dataSource = datasource;
            obj.parentCoordinates = dspace_features.AbstractFeatures.getByDescriptor(...
                obj.parentCoordinateDescriptor, datasource.coordinates);
            if isempty(obj.parentCoordinates)
                warning('Coordinates %s: parent coordinates %s could not be found.',...
                    obj.identifier, obj.parentCoordinateDescriptor);
            end
            %assert(~isempty(obj.parentCoordinates));
        end
        
        function rt = isInitialized(obj)
            rt = ~isempty(obj.parentCoordinates) && ~isempty(obj.dataSource);
        end
        
        function updateParentDescriptor(obj)
            if ~isempty(obj.parentCoordinates)
                obj.parentCoordinateDescriptor = obj.parentCoordinates.getDescriptor();
            else
                assert(false);
            end
        end
        
        function ids = getSupportDomain(obj) 
            ids = obj.parentCoordinates.getSupportDomain();
        end
    end
    
end

