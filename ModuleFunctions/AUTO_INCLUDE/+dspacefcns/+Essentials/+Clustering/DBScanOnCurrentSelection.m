function [ titleStr, settings, results ] = DBScanOnCurrentSelection( dataview, settings )
    % Clustering of selected datapoints in the given feature space using
    % <a href="matlab:web('https://en.wikipedia.org/wiki/DBSCAN', '-browser')">DBScan</a>.
    %
    % Use for up to ~30k datapoints.
    %
    % The parameter Epsilon should be a scalar or a Matlab expression
    % that evaluates to a vector or scalar.
    %
    % If Epsilon evaluates to a vector, dbscan clustering is performed for 
    % each element of that vector (parallel processing, enable parpool 
    % for better performance). Clustering results are plotted against epsilon.
    % 
    % If the feature dimension exceeds nMaxDimensions, PCA is performed as 
    % the first step. Consider creating PCA-transformed derived coordinates
    % to have more control over this step and use more efficient algorithms.
    %
    % One return variable is created containing the cluster idx for each datapoint.
    % Clusters are numbered starting at 1 and noise points have value 0.
    % 
    % See also dbscan, dspacefcns.Features.pcaOnCurrentSelection.
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
        titleStr = 'Essentials/Features/DBScan-Clustering';
        return;
    end
    
    pf = dataview.getPointFilter();
    dataSource = dataview.dataSource;
    np = sum(pf);
    
    featureNames = dataSource.getCoordinateIdentifiers();
    
    titleStr = sprintf('DBScan-clustering on current selection (%i points).', np);
    
    if nargin < 2 || isempty(settings)
        settings = {'Description', titleStr,...
            'WindowWidth', 700, 'ControlWidth', 350,...
            'separator', 'Input',...
            {'Features', 'features'}, featureNames,...
            {'Ignore Feature Cutout', 'ignoreCutout'}, false,...
            'separator', 'DBScan Parameters',...
            {'Epsilon', 'epsilon'}, '2',...
            {'Neighbourhood Size', 'neighborhoodSize_K'}, 25,...
            {'Maximum Dimension', 'nMaxDimensions'}, 20,...
            {'Return Variable Stem', 'returnVariable'}, 'C_dbscan_clusterIdx'};
        return;
    end
   
    feature = dataSource.F(settings.features);
    pfIds = find(pf);
    
    if settings.ignoreCutout
        X = feature.getMatrix(pfIds);
    else
        X = feature.getMatrixCutout(pfIds, feature.getLayout().cutoutIndices);
    end
    
    X = single(full(X));
    dataDim = size(X, 2);
    maxDim = settings.nMaxDimensions;
    if maxDim < dataDim
        % Perform PCA
        X = bsxfun(@minus, X, mean(X, 1));
        covX = X' * X;
        [M, lambda] = eig(covX);
        [~, ind] = sort(diag(lambda), 'descend');
        if maxDim > size(M, 2)
            maxDim = size(M, 2);
        end
        M = M(:,ind(1:maxDim));
        X = X * M;
        clear covX M lambda
    end
    
    if isnumeric(settings.epsilon)
        eps = settings.epsilon;
    elseif ischar(settings.epsilon)
        eps = eval(settings.epsilon);
    end
    
    clustLabel = NaN(size(X, 1), numel(eps));
    varType = NaN(size(X, 1), numel(eps));
    nclust = NaN(1, numel(eps));
    settings_K = settings.neighborhoodSize_K;
    
    if numel(eps) > 1
        fprintf('  Running DBScan for %i values for epsilon...', numel(eps)); 
        tic();
        parfor k = 1:numel(eps)
            [cL, varType(:, k)] = dbscan(X, settings_K, eps(k));
            clustLabel(:, k) = cL;
            nclust(k) = numel(unique(cL(cL ~= 0))); 
        end
        toc();
       
        % Plot clustering results vs. epsilon
        paf = bda_figure(sprintf('DBScan on %s', dataSource.getName()), [1, 2], 1);
        paf(1, 1, '');
        plot(eps, sum(varType == -1, 1)/size(varType, 1), '-k');
        %hold all, plot(eps([1, end]), [1,1]*0.01, ':b');
        ylabel('Fraction of Noise Pts.');
        xlabel('\epsilon');
        set(gca, 'yscale', 'log');
        xlim(eps([1 end]));
        title(sprintf('%s; K: %i; dim: %i/%i', feature.Name, settings.neighborhoodSize_K,...
            size(X, 2), dataDim), 'interpreter', 'none');
        %set(gca, 'yscale', 'log');
        paf(1, 2, 'b');
        plot(eps, nclust, '-k');
        ylabel('#Clusters');
        xlabel('\epsilon');
        ylim([0, 12]);
        xlim(eps([1 end]));
        %set(gca, 'yscale', 'log');
        bda_formatFigure(gcf, 1);
        
        clustLabel = clustLabel(:, 1);
        varType = varType(:, 1);
        
    else
        [clustLabel(:, 1), varType(:, 1)] = dbscan(X, settings_K, eps);
    end
    
    Xvals_idx = NaN(numel(pf), 1);
    
    %Xvals_valid = NaN(numel(pf), 1);
    
    Xvals_idx(pf) = double(clustLabel);
    
    %Xvals_valid(pf) = double(varType);
    
    info.settings = settings;
    
    dataSource.L.(settings.returnVariable) = Xvals_idx;
    dataSource.Ldef.(settings.returnVariable) = dspace_data.PropertyDefinition(...
        [], [], '', '', info);
    
    results = [];
    
end
