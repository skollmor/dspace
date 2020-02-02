function [ titlestr, settings, results ] = createNNGraphFromFeatures( dataview, settings )
    % Creates a nearest neighbour graph based on the given features and distance function.
    %
    % Use low dimensional features (dimension<250 required) or make derived low-dimensional 
    % features by running the principal component analysis module function.
    %
    % See also dspace_graphs.RealtimeFeatureNNGraph.
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


    possibleDistances = {'euclidean', 'cityblock', 'minkowski', 'chebychev', 'seuclidean',...
        'mahalanobis', 'cosine', 'correlation', 'spearman', 'hamming', 'jaccard'};
    
    titlestr = 'Essentials/Graphs/Create Nearest Neighbour Graph from Features';
    
    if nargin == 0
        return;
    end
    
    np = dataview.getNumberOfPoints();
    [pf, ~, pfContainer] = dataview.getPointFilter();
    dataSource = dataview.dataSource;
    
    ftNames = dataSource.getFeatureNames();
    
    if nargin < 2 || isempty(settings)
        
        settings = {'Description',...
            sprintf('Create Nearest Neighbour Graph from Features over Current Selection (%i/%i points in total).', sum(pf), np),...
            'WindowWidth', 700, 'ControlWidth', 350,...
            {'Features', 'featureName'}, ftNames,...
            {'New Graph Name', 'graphName'}, 'NewFeatureGraph',...
            {'Ignore Feature Cutout (only Precomputed-Searcher)', 'useAllXf'}, true,...
            {'Type', 'type'}, {'Precomputed-ExhaustiveSearcher', 'Realtime-ExhaustiveSearcher'},...
            {'Distance Function', 'distance'}, possibleDistances,...
            {'Number of Neighbours', 'nNeighbours'}, 100,...
            {'Reduce Dimensionality (only Precomputed-Searcher)', 'doPCA'}, true,...
            {'Underlying Dimensionality', 'maxDim'}, 100};
        return;
        
    end
    
    cid = find(strcmp(settings.featureName, ftNames));
    
    switch settings.type
        % Use coordinates with less than 250 dimensions
        case 'Realtime-ExhaustiveSearcher'
            assert(~settings.doPCA && settings.useAllXf, 'No cutouts or PCA allowed for realtime searcher.');
            newGraph = dspace_graphs.RealtimeFeatureNNGraph(...
                settings.featureName, settings.graphName, find(pf), np, settings.nNeighbours, settings.distance);
            dataSource.addGraph(newGraph, true); 
        case {'Precomputed-ExhaustiveSearcher'}
            if settings.useAllXf
                X = dataview.getDataMatrix(find(pf), cid);
            else
                X = dataview.getDataMatrixCutout(find(pf),...
                        dataSource.coordinates{cid}.getLayout().cutoutIndices, cid);
            end
            if settings.doPCA
                fprintf('Computing PCA (Dim: %i, nPts: %i)... ', size(X, 2), size(X, 1)); tic();
                X = double(full(X));
                X = bsxfun(@minus, X, mean(X, 1));
                dim = settings.maxDim;
                covX = X' * X;
                [M, lambda] = eig(covX);
                [~, ind] = sort(diag(lambda), 'descend');
                if dim > size(M, 2)
                    dim = size(M, 2);
                end
                M = M(:,ind(1:dim));
                X = X * M;
                clear covX M lambda
                toc();
            end
            
            %s = toc(); fprintf('%.2fs. neighbors... ', s); tic();
            %fprintf('Computing neighbors (%i Nbs, Dim: %i, nPts: %i)... ', settings.Size, size(X, 2), size(X, 1)); tic();
            switch settings.type
                case 'Precomputed-ExhaustiveSearcher'
                    fprintf('Computing neighbours (%i Nbs, Dim: %i, nPts: %i, exh.s. - %s distance)... ',...
                        settings.nNeighbours, size(X, 2), size(X, 1), settings.distance); tic();
                    ns = createns(X, 'distance', settings.distance);
                    [nnids, ~] = knnsearch(ns, X, 'k', settings.nNeighbours);
                otherwise
                    assert(false);
            end
            toc();
            %s = toc(); fprintf('%.2fs.\n', s);
            
            % in cases of several points having the same coordinates, the
            % querry element is not necessarily its own closest neighbour
            if all(nnids(:, 1) == (1:size(nnids, 1))') 
                % 1st nn is the querry element itself
                nnids = nnids(:, 2:end); % remove querry element
                assert(~any(nnids(:, 1) == (1:size(nnids, 1))')); % recheck
            else
                for ki = 1:size(nnids, 1)
                    bidx = find(nnids(ki, :) == ki);
                    if isempty(bidx)
                        % the last neighbour will be removed
                    elseif numel(bidx) == 1
                        % remove querry element
                        nnids(ki, 1:end-1) = nnids(ki, [1:bidx-1, bidx+1:end]); 
                    else
                        assert(false);
                    end
                end
                nnids = nnids(:, 1:end-1); 
            end
            
            
            
             % 1 - name: string
            % 2 - NNids: numeric (int, can be sparse), NQ X MaxOutdegree
            % 3 - querryDomain: numeric (int) NQ x 1
            % 4 - candidateDomain: numeric (int) NC x 1
            % 5 - Ntotal: numeric, total number of points in underlying
            %         datasource
            newGraph = dspace_graphs.PrecomputedGraph(settings.graphName, nnids, find(pf), [], numel(pf));
            newGraph.various = settings;
            dataSource.addGraph(newGraph, true);
            
    end
    
    results.newGraphName = settings.graphName; 
end
