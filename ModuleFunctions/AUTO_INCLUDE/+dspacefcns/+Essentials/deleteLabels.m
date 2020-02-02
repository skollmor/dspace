function [ titleStr, settings, results ] = deleteLabels( dataview, settings )
    % This function removes one or more variables from the datasource.
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

    
    titleStr = 'Essentials/Organize Datasource/Delete Labels';
    
    if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        varNames = dataview.getPropertyNames();
        settings = {'Description' , 'Delete labels from datasource.',...
            'WindowWidth', 500, 'ControlWidth', 350,...
            {'Labels to delete', 'varsToDelete'}, dspace.app.StringList(varNames)};
        return;
    end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    
    source = dataview.dataSource;
    varNames = settings.varsToDelete.strings;
    for vid = 1:numel(varNames)
        if ismember(varNames{vid}, source.L.Properties.VariableNames)
            source.L.(varNames{vid}) = [];
            if isfield(varNames{vid}, source.Ldef)
                source.Ldef = rmfield(source.Ldef, varNames{vid});
            end
        else
            fprintf('Variable %s not found in source %s...\n', varNames{vid}, source.getName());
        end
    end
   
    results.deletedVars = varNames;
end
