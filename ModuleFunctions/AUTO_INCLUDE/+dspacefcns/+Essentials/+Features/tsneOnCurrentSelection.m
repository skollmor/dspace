function [ titleStr, settings, results ] = tsneOnCurrentSelection( dataview, settings )
    % Embed points in current pointfilter using 
    % <a href="matlab:web('https://en.wikipedia.org/wiki/T-distributed_stochastic_neighbor_embedding', '-browser')">(Barnes-Hut-)t-SNE</a>. 
    %
    % PCA-dimensions can be 0 (no PCA) or >0 and <= feature dimension.
    % If PCA-dimension is larger than the feature dimension, no PCA is performed.
    % Note: You can perform pca preprocessing (or another dimensionality 
    % reduction step) with more control via the PCA module function.
    %
    % See also tsne, dspacefcns.Essentials.Features.pcaOnCurrentSelection, dspace_features.LinearDerivedFeatures
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

        
    possibleAlgorithms = {'barneshut'}; %, 'exact'};
    possibleDistances = {'euclidean', 'cityblock', 'minkowski', 'chebychev', 'seuclidean',...
        'mahalanobis', 'cosine', 'correlation', 'spearman', 'hamming', 'jaccard'};
    
    
    if nargin == 0
        titleStr = 'Essentials/Features/Embed Features using t-SNE';
        return;
    end
    
    [pf, ~, pfContainer] = dataview.getPointFilter();
    np = sum(pf);
    varNames = ['-', dataview.getPropertyNames()];
    dataSource = dataview.dataSource;
    ftNames = dataSource.getCoordinateIdentifiers();
    titleStr = sprintf('Embed current selection (%i points) using t-SNE.', np);
        
     if isempty(ftNames)
        fprintf('dspacefcns.Essentials.Features.pcaOnCurrentSelection: No Features defined for current datasource.\nCreate some features first.\n');
        assert(false);
    end
    
    if nargin < 2 || isempty(settings)
        settings = {'Description', titleStr,...
            'WindowWidth', 600, 'ControlWidth', 350,...
            {'Features', 'featureName'}, ftNames,...
            {'Distance Function', 'distance'}, possibleDistances,...
            {'Algorithm', 'algorithm'}, possibleAlgorithms,...
            {'PCA dimensions (0 for no pca)', 'pcaDimensions'}, 100,...
            'dimensions', 2,...
            'perplexity', 30,...
            'theta', 0.5,...
            'max_iter', 1000,...
            'exaggeration', 4,...
            'variableName', 'E_d100_p20',...
            {'Ignore Feature Cutout', 'useAllXf'}, false,...
            'separator', 'Initial Conditions',...
            {'Y0-1', 'y01'},  permuteStringOptions(varNames, '-'),...
            {'Y0-2', 'y02'},  permuteStringOptions(varNames, '-'),...
            {'Y0-3', 'y03'},  permuteStringOptions(varNames, '-'),...
            {'z-score', 'zScore'}, true};
        return;
    end
    
   switch settings.dimensions
        case 1
            if ~strcmp(settings.y01, '-')
                Y0 = dataview.getPropertyValues(settings.y01);
                Y0 = Y0(pf, :);
            else
                Y0 = [];
            end 
        case 2
            if ~strcmp(settings.y01, '-') && ~strcmp(settings.y02, '-')
                Y0 = [dataview.getPropertyValues(settings.y01), dataview.getPropertyValues(settings.y02)];
                Y0 = Y0(pf, :);
            else
                Y0 = [];
            end
        case 3
             if ~strcmp(settings.y01, '-') && ~strcmp(settings.y02, '-') && ~strcmp(settings.y03, '-')
                Y0 = [dataview.getPropertyValues(settings.y01), dataview.getPropertyValues(settings.y02), dataview.getPropertyValues(settings.y03)];
                Y0 = Y0(pf, :);
            else
                Y0 = [];
            end
        otherwise
            Y0 = [];
    end
    
    if ~isempty(Y0) && settings.zScore
        Y0 = zscore(Y0);
    end
    
    cid = find(strcmp(settings.featureName, ftNames));
    if settings.useAllXf
        Xf = dataview.getDataMatrix(find(pf), cid);   
    else
        Xf = dataview.getDataMatrixCutout(find(pf),...
            dataSource.coordinates{cid}.getLayout().cutoutIndices, cid);   
    end
    Xf = full(Xf);
    
    if size(Xf, 2) < settings.pcaDimensions
        % Not enough data-dimensions available. Do not perform PCA.
        settings.pcaDimensions = 0;
    end
    
    optopt = statset('MaxIter', settings.max_iter);
    if isempty(Y0)
        [Y, loss] = tsne(Xf, 'Algorithm', settings.algorithm, 'Distance', settings.distance,...
            'Exaggeration', settings.exaggeration, 'NumDimensions', settings.dimensions,...
            'NumPCAComponents', settings.pcaDimensions, 'Perplexity', settings.perplexity,...
            'Options', optopt, 'Theta', settings.theta, 'Verbose', 1);
    else
        [Y, loss] = tsne(Xf, 'Algorithm', settings.algorithm, 'Distance', settings.distance,...
            'Exaggeration', settings.exaggeration, 'NumDimensions', settings.dimensions,...
            'NumPCAComponents', settings.pcaDimensions, 'Perplexity', settings.perplexity,...
            'Options', optopt, 'Theta', settings.theta, 'Verbose', 1, 'InitialY', Y0);
    end
     
    
    tsneRt.settings = settings;
    tsneRt.loss = loss;
    tsneRt.pointFilter = pfContainer;
            
    for d = 1:size(Y, 2)
        dataSource.Xprops.(sprintf('%s%i', settings.variableName, d)) =  NaN(dataSource.getNumberOfPoints(), 1);
        dataSource.XpropDefinitions.(sprintf('%s%i', settings.variableName, d)) =...
            dspace_data.PropertyDefinition([], [], sprintf('%s%i', settings.variableName, d), '', tsneRt);
        dataSource.Xprops.(sprintf('%s%i', settings.variableName, d))(pf) = Y(:, d);
        varnames{d} = sprintf('%s%i', settings.variableName, d);
    end
     
    results.createdVariables = varnames;
end
    
%     dataSource = dataview.dataSource;
%     displayId = cid;
%     timerObj = timer('ExecutionMode', 'fixedSpacing', 'TimerFcn', @timerfcn,...
%         'StartDelay', 10, 'period', 10, 'Name', 'DSPACE');
%     start(timerObj);
%     %advertiseCompletion = nargout == 2;
%     
%     
%     
%     function timerfcn(varargin)    
%         tsneResults = bhtsne_get(tsneHandle);
%         if isempty(tsneResults)
%             return;
%         end
%         perpRt = bhtsne_get_perplexityFile(tsneHandle, np, tsneOpt.perplexity*3);
%         varnames = cell(1, size(tsneResults.X, 2));
%         tsneOpt.various.results = tsneResults;
%         tsneOpt.various.coordinateDescriptor = dataSource.coordinates{displayId}.getDescriptor();
%         tsneOpt.various.pointFilter = pfContainer;
%             
%         for d = 1:size(tsneResults.X, 2)
%             dataSource.Xprops.(sprintf('%s%i', variableName, d)) =  NaN(dataSource.getNumberOfPoints(), 1);    
%             dataSource.XpropDefinitions.(sprintf('%s%i', variableName, d)) =...
%                     dspace_data.PropertyDefinition([], [], sprintf('%s%i', variableName, d), '', tsneOpt);
%             dataSource.Xprops.(sprintf('%s%i', variableName, d))(pf) = tsneResults.X(:, d);
%             varnames{d} = sprintf('%s%i', variableName, d);
%         end
%         if ~isempty(perpRt) && ~isempty(highDIdx) && highDIdx > 0
%             dataSource.localGroupDefinitions{highDIdx} =...
%                 dspace_graphs.LocalHighDGroup_precomputed(sprintf('%s_bhLocals', variableName), perpRt.NNids, find(pf), numel(pf));
%         end
%         if ~isempty(lowDIdx) && lowDIdx > 0
%             dataSource.localGroupDefinitions{lowDIdx} = dspace_graphs.LocalLowDGroup(...
%                 varnames, sprintf('%s_tsne%idLocals', variableName, size(tsneResults.X, 2)));
%             %dataSource.various.(['bhtsne_' variableName]) = tsneResults;
%         end
%         msgbox(sprintf('Results of embedding %s are available for data source %s.', variableName, dataSource.getName()));
%         stop(timerObj);
%     end
%     
%end

function stringCell = permuteStringOptions(options, primary)
    if isempty(primary)
        stringCell = options;
        return
    end
    idx = find(strcmp(options, primary), 1);
    stringCell = [options(idx), options([1:idx-1 idx+1:end])];
end



