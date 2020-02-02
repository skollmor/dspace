    % This script shows how to process and manipulate loaded datasources and
    % how to call dataspace module-functions on them.
    %
    % The same exact procedures apply to programatically loaded datasources (not involving the GUI).
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



path_to_mnist = [dspace.getDspaceRootFolder filesep 'Tutorials' filesep 'MNIST_Datasource'];
%% Load data-collection
col = dspace_data.loadCollection(path_to_mnist, 'mnist10k');

% Fetch a source
source = col.sources.main{1};
%source = col{1}{1};                    possible alternative

%% Do some processing
% Run Essentials/Features/Principal Component Analysis
settings = [];
settings.empty = [];
settings.featureName = 'Raw MNIST Images';
settings.ignoreCutout = false;
settings.Criterion = 'fraction variance explained';
settings.k = 0.9;
settings.method = 'default';
settings.createReconstruction = true;
settings.createLowD = false;
settings.freezeLowD = false;
settings.excludeCoefficients = '';
settings.coefficientsToStore = '1 2 3';
settings.variableStem = 'pca_';
settings.plotVarExpl = true;
settings.runAll = false;
settings.Dimensions = 100;
view = Dataview.getConfiguredDefaultView(source);
[~, ~, results] = dspacefcns.Essentials.Features.pcaOnCurrentSelection(view, settings);

% save modified collection (under a different name to keep the example intact)
dspace_data.saveCollection(col, path_to_mnist, 'mnist10k_v2');


