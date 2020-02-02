function [ titleStr, settings, results ] = dspace_moduleFcn_template( dataview, settings )
    % Use this as a starting point for new module functions.
    %
    % Dataspace-Module functions are Matlan functions that can be called with 0, 1, or 2 arguments.
    % Depending on the number of input arguments the behavior of the Module Function differs.
    %
    % Call with 0 arguments: The Module-Function returns a string description as its first output (e.g. 
    % 'Essentials/Features/Principal Component Analysis').
    % 
    % Call with 1 argument: The Module-Function returns a string description as its first output and
    % returns a cell array specifying all its parameters and their default values as the second output 
    % (see below).
    %
    % Call with 2 arguments: The Module-Function executes on the given dataview using the settings provided. 
    % (see below).
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

   
    titleStr = 'Essentials/Features/Principal Component Analysis';
    if nargin == 0
        % This moduleFcn was called with 0 arguments --> return a name and label for this module
        % function.
        return;
    end
    
    % Fetch datasource from dataview
    source = dataview.dataSource;
    
    % Fetch current point filter
    pf = dataview.getPointFilter();
    
    if nargin < 2 || isempty(settings)
        % This moduleFcn was called with 1 argument --> return a settings structure for this module
        % function
        settings = {'Description',...
            sprintf('PCA on current selection (%i points).', np),...        % Description is just a one line string
            'WindowWidth', 600, 'ControlWidth', 350,...                     % Specifies the window size in dspace-GUI
            'separator', 'Input',...                                        % Create a section (dspace-GUI)
            {'k (e.g. 0.95 for var expl. or 100 for #pcs) ', 'k'}, 0.95,... % Define various parameters
            {'Method', 'method'}, {'default', 'svd or svds'}};              % Define various parameters 
        return;
    end
    
    %% ModuleFcn called with 2 arguments - perform computation
    
    someValue = source.N * double(settings.k);
    fprintf('source.N * settings.k = %.3f', someValue);
    
    %% Write results struct
    results.value = someValue;
    
end
