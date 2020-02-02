function dspaceApp = start(varargin)
    % START Starts an instance of the Dataspace GUI. Use this to start 
    % Dataspace. Can also be used to add all paths required to the MATLAB search 
    % path.
    %
    % It is recommended to use the function dspace() instead. It allows for 
    % more flexible data import.
    % Reference page for  <a href="matlab:dspace.help('dspace')">dspace().</a>
    %
    % Usage:
    %
    % <h4>Start with dspace_data.TableDataSource:</h4>
    % >> dspace.start(source);
    %
    % <h4>Start with dspace_data.DataCollection:</h4>
    % >> dspace.start(collection);
    %
    % <h4>Add required paths to the MATLAB path but do not start Dataspace:</h4>
    % >> dspace.start('-nogui');
    %
    % <h4>Start with table:</h4>
    % >> dspace.start(table); 
    %
    % Example (1000 datapoints, 2 variables):
    %
    % >> T = table(); 
    % >> T.index = (1:1000)'; 
    % >> T.value = randn(1000, 1);
    % >> dspace.start(T);
    % 
    % See also dspace.resources.docs.Essential_Functions.
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

    
    %% Add Dataspace Paths to Matlab Path
    
    p = mfilename('fullpath');
    % this function is located in dataspaceMainFolder\+dspace\start
    dspace_main_folder = p(1:end-14);
    
    % check whether dspace-paths have already been added to the matlab path
    ch = path();
    if contains(ch, [dspace_main_folder filesep 'ModuleFunctions;'])
        %%fprintf('Not adding paths...\n');
    else
        % Add dspace paths
        dspace.addPaths(dspace_main_folder);
    end
    
    if nargin == 1 && ischar(varargin{1}) && strcmpi(varargin{1}, '-nogui')
        dspaceApp = [];
        return
    end
    
    %% We are about to start the App
    
    %%warning off MATLAB:ui:javacomponent:FunctionToBeRemoved
    
    if nargin == 0
        dspaceApp = dspace.app.Dataspace();
        return
    end
    
    %% Parse input table, datasource(s) or data-collections.
    
    if nargin == 1 && dspace.isDataCollection(varargin{1})
        dspaceApp = dspace.app.Dataspace(varargin{:});
    elseif nargin == 1 && dspace.isDatasource(varargin{1})
        dspaceApp = dspace.app.Dataspace(varargin{:});
    elseif nargin == 1 && iscell(varargin{1}) && iscell(varargin{1}{1})
        dspaceApp = dspace.app.Dataspace(varargin{:});
    elseif  nargin == 1 && istable(varargin{1})
        dspaceApp = dspace.app.Dataspace(varargin{:});
    else
        assert(false, 'dspace.start: Arguments not supported.\nUse the function dspace() to import data. (type matlab command "doc dspace" for help).');
    end
    
    %%warning on MATLAB:ui:javacomponent:FunctionToBeRemoved
    
    
          
end

