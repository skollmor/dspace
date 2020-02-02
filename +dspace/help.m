function help(topic, varargin)
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

    
    % Display help for a Dataspace component.
    %
    % Usage:
    %
    % >> dspace.app.help(topic);
    %
    % Examples:
    %
    % >> dspace.app.help('start');
    % 
    % Or:
    % 
    % >> dspace.app.help('dspacefcns.Features.pcaOnCurrentSelection')
    %
    % This is either a html help defined in dataspace-root/docs/html or a
    % automatically generated help, generated from the specified .m file.
    %
    % For many topics you can also use MATLABs doc function.
    %
    % Example:
    %
    % >> doc dspace.start        
    % 
    %
    %
    % See also dspace.resources.docs.Essential_Functions
    %
    % (c) 2015-2017, Sepp Kollmorgen, All Rights Reserved.
    
    % make sure the dataspace paths are added
    dspace.start('-nogui');
    
    dspace.app.help(topic, varargin{:});
    
end

