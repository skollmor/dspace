function [ titleStr, settings, results ] = createFeaturesFromLabels( dataview, settings )
    % Creates coordinates from the selected labels.
    %
    % The current point-filter has no effect.
    %
    % Newly created features are stored as StandardFeatures, i.e. as a complete copy.
    %
    % See also dspace_features.StandardFeatures.
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

        
    if nargin == 0
        titleStr = 'Essentials/Features/Create Features from Labels';
        return;
    end
    
    dataSource = dataview.dataSource;
    np = dataSource.getNumberOfPoints();
    labelNames = dataSource.getPropertyNames();
        
    titleStr = sprintf('Create features from labels.');
    
    if nargin < 2 || isempty(settings)
        settings = {'Description', titleStr,...
            'WindowWidth', 600, 'ControlWidth', 350,...
            'separator', 'Input',...
            {'Labels', 'labels'}, dspace.app.StringList(labelNames),...
            {'Sort Alphabetically', 'sortVars'}, true,...
            {'New Feature Name', 'featureName'}, 'NewFeature',...
            {'z-Score each Label', 'zscore'}, true};
        return;
    end
    
    vnames = settings.labels.strings;
    
    if settings.sortVars
        vnames = sort(vnames);
    end
    
    X = NaN(np, numel(vnames));
    for k = 1:numel(vnames)
        if settings.zscore
            vids = ~isnan(dataSource.L.(vnames{k}));
            X(vids, k) = zscore(dataSource.L.(vnames{k})(vids));
        else
            X(:, k) = dataSource.L.(vnames{k});
        end
    end
    
    layout = dspace_features.FeatureLayout([numel(vnames), 1], [], 1:numel(vnames), [numel(vnames), 1]); 
    layout.componentMeanings = vnames;
    
    newFeatures = dspace_features.StandardFeatures(X, settings.featureName, layout);
    idx = dataSource.addFeatures(newFeatures, true);
    
    results.newFeatureIdx = idx; 
end