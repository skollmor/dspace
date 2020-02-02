function addPaths(root) 
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

    
    %% Root Path
    % this path contains +dspace, +dspace_graphs, +dspace_data, +dspace_features
    % PART A
    addpath(root);
     
    %% Third Party Components
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'cm_and_cb_utilities'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'cubehelix'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'dbscan'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'findjobj'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'genstructcode'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'guiLayoutToolbox2_3_3', 'layout'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'horizontalErrorbars'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'saveFast'));
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'subaxis')); 
    addpath(fullfile(root, 'Extras', 'ThirdPartyComponents', 'export_fig')); 
    
    if exist(fullfile(root, 'Extras', 'RepertoireDating'), 'dir')
        addpath(fullfile(root, 'Extras', 'RepertoireDating')); 
    end
    
    %% Module Functions
    % this path contains the package +dspacefcns
    % PART A
    addpath(fullfile(root, 'ModuleFunctions'));
    addpath(fullfile(root, 'ModuleFunctions', 'AUTO_INCLUDE'));
    
    %% Application GUI Elements
    % this path contains +dspace.mex, +dspace.app
    % PART B
    addpath(fullfile(root, 'App'));
    % this path contains all internal documentation in +dspace
    % PART B
    addpath(fullfile(root, 'App', 'Docs'));
    % this path contains the modules, code to display the GUI, etc.
    % PART B, .p-files
    addpath(fullfile(root, 'App', 'bin'));
    
    % this path contains some additional GUI code
    % PART B, .p-files
    addpath(fullfile(root, 'App', 'bin', 'Various'));
    
    
    %% Additional Dataspace Components
    % PART B
    addpath(fullfile(root, 'Extras', 'ExtremeLogger'));
    
    %% Tutorials
    % PART A
    addpath(fullfile(root, 'Tutorials', 'Scripts'));
    
    try
        % This code is not necessary for dspace-core:
        if dspace.hasLegacySupport()
            addpath(fullfile(root, 'Internal'));
            dspace.addInternalPaths(root);
        end
    catch
    end
    
end