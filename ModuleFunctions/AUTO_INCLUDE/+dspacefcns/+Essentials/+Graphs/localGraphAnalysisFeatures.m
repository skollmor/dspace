function [ titleStr, settings, results ] = localGraphAnalysisFeatures( dataview, settings )
    % This function can compute graph based density estimates. 
    %
    % This function is meant for k-NN graphs.
    %
    % The parameter k determines which neighbor to consider.
    %
    % Depending on the dimensionality of the selected features, this function might
    % take a long time to complete. 
    %
    % Consider preprocessing through the prinicpal component analysis module function.
    %
    % See also dspacefcns.Essentials.Graphs.localGraphAnalysisLabels, dspacefcns.Essentials.Features.pcaOnCurrentSelection.
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


    titleStr = 'Essentials/Graphs/Local Graph Analysis - Feature Based Density';
    
    if nargin == 0
        return;
    end
    
    pf = dataview.getPointFilter();
    np = numel(pf);
    dsource = dataview.dataSource;
    graphNames = dsource.getGraphNames(); %cellfun(@(lg) lg.getName(), lgDefs, 'uni', false);
    featureNames = dsource.getFeatureNames();
     
    if nargin < 2 || isempty(settings)
        settings = {'Description', sprintf('Local Graph Analysis. Datapoints: %i/%i', sum(pf), np),...
            'WindowWidth', 500, 'ControlWidth', 250,...
            {'Graph', 'graphName'}, graphNames,...
            {'k (0 corresponds to k_max)', 'k'}, 0,...
            {'Features', 'featureName'}, featureNames,...
            {'Ignore Feature cutout', 'useAllXf'}, false,...
            {'Compute 1/D(NN_k(x), x)', 'kDensity'}, false,...
            {'Compute D(NN_k(x), x)', 'kWidth'}, false,...
            {'Output Stem', 'outputStem'}, 'LGA'};
        return;
    end
    
    h = waitbar(0, titleStr);
    
    gIdx = find(strcmp(graphNames, settings.graphName));
    graph = dsource.G{gIdx};
    pfIds = find(pf);
    
    if ~graph.isInitialized()
        graph.initialize(dataview.dataSource);
    end
    
    [connectedNodes] = graph.getLocalGroups(pfIds);
    cid = find(strcmp(settings.featureName, featureNames));
    
    if settings.useAllXf
        % need to fetch all since lg elements can fall outside the selection
        X = dataview.getDataMatrix(1:np, cid);
    else
        cutoutIndices = dataview.dataSource.coordinates{cid}.layout.cutoutIndices;
        X = dataview.getDataMatrixCutout(1:np, cutoutIndices, cid);
    end
    if settings.k == 0
        k = size(connectedNodes, 2);
    else
        k = settings.k;
    end
    
    outputStem = [settings.outputStem '_' settings.graphName '_' settings.featureName];
    
    if settings.kWidth || settings.kDensity   
        Xc = X(pfIds, :);
        distances = sqrt(sum((X(connectedNodes(:, k), :)-Xc).^2, 2));
        lgd = NaN(np, 1);
        if settings.kWidth
            lgd(pfIds) = distances;
            name = genvarname([outputStem '_kWidth']);
            dataview.putProperty(name,...
                lgd, dspace_data.PropertyDefinition([], [], name, '', settings));
        end
        if settings.kDensity
            lgd(pfIds) = 1./distances;
            name = genvarname([outputStem '_kDensity']);
            dataview.putProperty(name,...
                lgd, dspace_data.PropertyDefinition([], [], name, '', settings));
        end
    end
    
    results = [];
    
    close(h);
    
end