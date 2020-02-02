function rt = isParsableDspaceArg(arg)
    % This function returns true if the function dspace() could parse the argument as part of 
    % a Dataspace datasource.
    % Internal function used by dspace().
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

    
    if istable(arg)
    
        rt = true;
    
    elseif isnumeric(arg)
    
        rt = true;
    
    elseif iscell(arg)
        
        if all(cellfun(@(e) isnumeric(e), arg(:)))
        
            unl = unique(cellfun(@(e) numel(e), arg(:)));
            udims = unique(cellfun(@(e) numel(size(e)), arg(:)));
            
            if numel(unl) ~= 1 || numel(udims) ~= 1 || ~ismember(udims, [1, 2])
        
                rt = false;
            
            else
                
                rt = true;
            end
            
        elseif all(cellfun(@(e) isstring(e) || ischar(e) || iscategorical(e), arg(:)))
        
            rt = true;
        
        else
            
            rt = false;
        
        end
        
    else
        
        rt = false;
        
    end
    
end

