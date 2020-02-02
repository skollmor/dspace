function [rt] = isDatasource(src)
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

   
    rt = isa(src, 'dspace_data.DataSource') | ...
         isa(src, 'dspace_data.DataSource') | ...
         isa(src, 'dataSources.DataSource');
     
%     rt = isa(inputData, 'dspace_data.TableDataSource') | ...
%          isa(inputData, 'dspace_data.TableDataSource') | ...
%          isa(inputData, 'dataSources.TableDataSource');
    
     
end

