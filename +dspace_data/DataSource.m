classdef DataSource < handle
    % DATASOURCE is the abstract base-class for data-containers in Dataspace. 
    % The main subclass is dspace_data.TableDatasource.
    %
    % See also dspace_data.TableDatasource.
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

    
    methods (Abstract)
        
        name = getName(obj);
        n = getNumberOfPoints(obj);
        
        propertyNames = getPropertyNames(obj);
        values = getPropertyValues(obj, propertyName);
        setPropertyValues(obj, propertyName, propertyValues);
        
        propertyDefinition = getPropertyDefinition(obj, propertyName);
        setPropertyDefinition(obj, propertyName, propDefinition);

        coordinateIdentifiers = getCoordinateIdentifiers(obj);
        matrix = getDataMatrix(obj, ids, coordinateId);
        matrix = getDataMatrixCutout(obj, ids, cutoutIds, coordinateId);
        
        % not implement
        cellArray = getVariableLengthRepresentation(obj, coordinateId);
        
        mbytes = getMegabytes(obj);
        
        ui = getUniqueIdentifier(obj);
        
        localGroupNames = getLocalGroupNames(obj);
        
        % return k nearest neighbours around datapoint with id pointId
        % k can be omitted. In that case the source chooses an appropriate
        % group size (i.e. proportional to elements/day for birdsong)
        ids = getLocalGroup(obj, groupId, pointId, k);
        
        % returns a cell array of LocalGroupDefinitions
        % every data source must declare one local group at least
        localGroupDefinitions = getLocalGroupDefinitions(obj);
        
    end
     
end











