function [ titlestr, settings, results ] = normalizeFeatures( dataview, settings )
    % Create coordinates that are normalized per datapoint.
    %
    % See also dspace_features.NormalizedDerivedFeatures
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


    titlestr = 'Essentials/Features/Create Normalized Features';
    
    if nargin == 0, return; end
    
    np = dataview.getNumberOfPoints();
    source = dataview.dataSource;
    pf = dataview.getPointFilter();
    cnames = source.getFeatureNames();
        
    if nargin < 2 || isempty(settings)
        settings = {'Description', sprintf('Normalize features (%i points).', np),...
            'WindowWidth', 500,...
            'ControlWidth', 350,...
            {'Features', 'featureName'}, cnames,...
            {'Use Parent Cutout', 'parentCutout'}, false,...
            'Normalization', dspace_features.NormalizedDerivedFeatures.ALL_NAMES,...
            {'New Feature Name', 'newname'}, 'NORM'}; 
        return;
    end
    
    cid = find(strcmp(settings.featureName, cnames), 1);
    cutoutIds = source.coordinates{cid}.getLayout().cutoutIndices;  
    pLayout = source.coordinates{cid}.getLayout();
    
    if ~settings.parentCutout
        nlayout = dspace_features.FeatureLayout(pLayout.dimensions,...
            [], pLayout.cutoutIndices,...
            pLayout.cutoutDimension);
    else
        nlayout = dspace_features.FeatureLayout(pLayout.cutoutDimension,...
            [], 1:numel(pLayout.cutoutIndices),...
            pLayout.cutoutDimension);
    end
    
    normType = dspace_features.NormalizedDerivedFeatures.ALL_TYPES(strcmp(...
        dspace_features.NormalizedDerivedFeatures.ALL_NAMES, settings.Normalization));
    
    ncoordinates = dspace_features.NormalizedDerivedFeatures(source.coordinates{cid},...
        cutoutIds,  normType, settings.newname, nlayout);
    
    if normType == dspace_features.NormalizedDerivedFeatures.TYPE_GLOBAL_ZSCORE
        fprintf('Obtaining coordinates for %i points inside current point filter...\n', sum(pf));
        X = source.coordinates{cid}.getDataMatrix(source, find(pf));
        fprintf('Computing global z-scoring for %i points inside current point filter...\n', sum(pf));
        means = nanmean(X, 1);
        stddevs = nanstd(X, [], 1);
        ncoordinates.setGlobalScalingParameters(1./stddevs, means);
    elseif normType == dspace_features.NormalizedDerivedFeatures.TYPE_GLOBAL_MEAN_ABS_DEVIATION
        fprintf('Obtaining coordinates for %i points inside current point filter...\n', sum(pf));
        X = source.coordinates{cid}.getDataMatrix(source, find(pf));
        fprintf('Computing global mean-abs-dev for %i points inside current point filter...\n', sum(pf));
        means = nanmean(X, 1);
        mabsdev = nanmean(abs(X - means), 1);
        ncoordinates.setGlobalScalingParameters(1./mabsdev, means);
    elseif normType == dspace_features.NormalizedDerivedFeatures.TYPE_GLOBAL_MEAN_ABS_DEVIATION_BUFFERED
        fprintf('Obtaining coordinates for %i points inside current point filter...\n', sum(pf));
        X = source.coordinates{cid}.getDataMatrix(source, find(pf));
        layout = source.coordinates{cid}.getLayout();
        X = reshape(X, size(X, 1), layout.dimensions(1), layout.dimensions(2)); 
        fprintf('Computing global mean-abs-dev for %i points inside current point filter...\n', sum(pf));
        means = nanmean(nanmean(X, 1), 3);
        
        % mean abs deviation per feature
        mabsdev = nanmean(nanmean(abs(X - means), 1), 3);
        mabsdev = repmat(mabsdev', 1, layout.dimensions(2));
        means = repmat(means', 1, layout.dimensions(2));
        
        ncoordinates.setGlobalScalingParameters(1./reshape(mabsdev, 1, []), reshape(means, 1, []));
    end
    
    fprintf('Initializing new coordinates %s...\n', ncoordinates.getIdentifier());
    
    ncoordinates.initialize(source);
   
    % overwrite coordinates if they exist already
    results.coordinateIdx = source.addFeatures(ncoordinates, true);
    
    %results.coordinateIdx = numel(source.coordinates);
    
end



function stringCell = permuteStringOptions(options, primary)
    if isempty(primary)
        stringCell = options;
        return
    end
    idx = find(strcmp(options, primary), 1);
    stringCell = [options(idx), options([1:idx-1 idx+1:end])];
end