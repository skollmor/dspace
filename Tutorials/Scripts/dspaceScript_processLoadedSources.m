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



%% Accessing variables
% The datasource currently selected in the GUI can be accessed and modified
% through dsource, e.g.:
dsource.getName()
dsource.L(1:5, :)

% get the names of all labels 
labelNames = dsource.getPropertyNames();

if numel(labelNames) == 0
    fprintf('Source has no labels defined.\n');
    return;
end

% Draw a histogram for the first label in the current datasource:
figure; histogram(dsource.L.(labelNames{1})); 
xlabel(labelNames{1}); ylabel('Count'); title(dsource.getName());

% The current point filter can be accessed through dview:
[pf, ~, pfc] = dview.getPointFilter();
fprintf('Currently selected: %i/%i points (%s).\n', sum(pf), numel(pf), pfc.getLongDescriptor()); 

featureNames = dsource.getFeatureNames();

if numel(featureNames) == 0
    fprintf('Source has no features defined.\n');
    return;
else
    fprintf('Source has %i features defined.\n', numel(featureNames));
end

%% Calling module functions
% Calling a module-function on a loaded datasource:
% Run Essentials/Features/Principal Component Analysis on the first features 
% defined. 
settings = [];
settings.empty = [];
settings.featureName = featureNames{1};
settings.ignoreCutout = false;
settings.Criterion = 'fraction variance explained';
settings.k = 0.9;
settings.method = 'default';
settings.createReconstruction = true;
settings.createLowD = true;
settings.freezeLowD = false;
settings.excludeCoefficients = '';
settings.coefficientsToStore = '1 2 3';
settings.variableStem = 'pca_';
settings.plotVarExpl = true;
settings.runAll = false;
settings.Dimensions = 100;
view = Dataview.getConfiguredDefaultView(dsource);
[~, ~, results] = dspacefcns.Essentials.Features.pcaOnCurrentSelection(view, settings);

% two new features were added by the pca module function
featureNames = dsource.getFeatureNames();
fprintf('Source has %i features defined.\n', numel(featureNames));


%% Process all loaded sources
% If dspace is active, global variables dspaceApp, dview and dsource are defined,
% and code like this can be used to access, process and change all loaded dataSources: 
for le1 = 1:numel(dspaceApp.dataSources)
    for le2 = 1:numel(dspaceApp.dataSources{le1})
        fprintf('Level %i, Source No. %i:\n', le1, le2);
        dsource.parentCollection{le1}{le2}.getMegabytes(true);
    end
end




