classdef AbstractHeavyFeatures < handle
    % HeavyCoordinates are coordinates that can contain data > 2GB. To store this
    % 'heavy-data' data fast, special arrangements are needed. Storing of
    % the data is done by the saveTableDataSource_v3 function.
    %
    % Default methods work if a property named 'Xf' is the only heavy data.
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

        
    methods
        
        function HD = getHeavyData(obj)
            HD = obj.Xf; %#ok<MCNPN>
        end
        
        function restoreHeavyData(obj, HD)
            obj.Xf = HD;
        end
        
        function clearHeavyData(obj)
            obj.Xf = []; %#ok<MCNPR>
        end
        
    end
end

