function [ titleStr, settings, results ] = pcaOnCurrentSelection( dataview, settings )
    % Principal component analysis (<a href="matlab:web('https://en.wikipedia.org/wiki/Principal_component_analysis', '-browser')">PCA</a>).
    % 
    % Newly created features are stored as (affine) linear transformations 
    % only and computed on demand. Data will be mean-subtracted. The current 
    % point-filter is respected when computing the mean and the PCs. This function 
    % can create up to 3 new features:
    %
    % a) pca_reconstruction (the original data reconstructed via the PCs)
    %
    % b) pca_lowD (the low dimensional representation of the data)
    % 
    % c) pca_lowD_FRZ (the low dimensional representation of the data)
    %
    % (c) is not stored as a linear-transformation but as transformed data using 
    % StandardFeatures. You can also create StandardFeatures later on by using the
    % 'Freeze to Standard Features' module function.
    %
    % It can also create label-variables storing projections onto individual PCs. For 
    % very high dimensional data (e.g. dim > 5000) use method 'svd or svds'.
    %
    % See also dspacefcns.Essentials.Features.freezeFeatures, dspace_features.LinearDerivedFeatures, pca.
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
        % This moduleFcn was called with 0 arguments. Title-String is assigned. Nothing else to do.
        return;
    end
    
    pf = dataview.getPointFilter();
    source = dataview.dataSource;
    np = sum(pf);
    ftIdentifiers = source.getCoordinateIdentifiers();
    
    if isempty(ftIdentifiers)
        fprintf('dspacefcns.Essentials.Features.pcaOnCurrentSelection: No Features defined for current datasource.\nCreate some features first.\n');
        assert(false);
    end
    
    if nargin < 2 || isempty(settings)
        % This moduleFcn was called with 1 argument or settings=[] --> return 
        % a settings structure for this module function
        settings = {'Description', sprintf('PCA on current selection (%i points).', np),...
            'WindowWidth', 600, 'ControlWidth', 350,...
            'separator', 'Input',...
            {'Features', 'featureName'}, ftIdentifiers,...
            {'Ignore Feature Cutout', 'ignoreCutout'}, false,...
            'separator', 'Dimensionality&Method',...
            'Criterion', {'fraction variance explained', 'fixed number of pcs'},...
            {'k (e.g. 0.95 for var expl. or 100 for #pcs) ', 'k'}, 0.95,...
            {'Method', 'method'}, {'default', 'svd or svds'},...
            'separator', 'New Features',...
            {'Create Reconstruction', 'createReconstruction'}, true,...
            {'Create subspace representation', 'createLowD'}, true,...
            {'Create frozen subspace representation', 'freezeLowD'}, false,...
            {'Exclude coeff. (e.g. 1 2 3)', 'excludeCoefficients'}, '',...
            'separator', 'New Variables',...
            {'Store Coeff. (i.e 1 2 3)', 'coefficientsToStore'}, '',...
            {'Variable Stem', 'variableStem'}, 'pca_',...
            {'Plot #PCs vs. %Variance Explained', 'plotVarExpl'}, true};
        return;
    end
    
    %% ModuleFcn called with 2 arguments - perform computations
    
    newName = settings.variableStem;
    newName = [newName settings.featureName];
    crdId = find(strcmp(settings.featureName, ftIdentifiers));
    parentCoordinates = source.coordinates{crdId};
    if settings.ignoreCutout
        X = dataview.getDataMatrix(find(pf), crdId);
    else
        X = dataview.getDataMatrixCutout(find(pf),...
            parentCoordinates.getLayout().cutoutIndices, crdId);
    end
    
    if any(isnan(X(:)))
        error('pcaOnCurrentSelection::Feature contains NaNs');
    end
    
    if isnumeric(settings.excludeCoefficients)
        coeffsToExclude = settings.excludeCoefficients;
    else
        coeffsToExclude = uint32(str2num(settings.excludeCoefficients));
    end
    
    X = single(full(X));
    %X = full(double(X));
    Xm = mean(X, 1);
    X = bsxfun(@minus, X, Xm);
    
    switch settings.method
        case 'default'
            if size(X, 2) > 1000 && strcmp(settings.Criterion, 'fixed number of pcs')
                fprintf('  pca() to extract %i pcs from %i x %i data... ', settings.k, size(X, 1), size(X, 2)); tic();
                [coeff, ~, ~, ~, lambda] = pca(X, 'NumComponents',  settings.k);
                M = coeff;
                toc();
            else
                fprintf('  eig() to extract pcs on %i x %i data... ', size(X, 1), size(X, 2)); tic();
                covX = X' * X;
                [M, lambda] = eig(covX);
                [lambda, ind] = sort(diag(lambda), 'descend');
                M = M(:, ind);
                toc();
                %M = M(:, ind(1:settings.Dimensions));
            end
        case 'svd or svds' 
            % Perform Singular Value Decomposition
            if strcmp('fixed number of pcs', settings.Criterion)
                fprintf('  svds() to extract %i pcs from %i x %i data... ', settings.k, size(X, 1), size(X, 2)); tic();
                % iterative method (requires double matrix)
                X = double(X);
                [u, d, ~] = svds(X', settings.k);
                u = single(u);
                toc();
            else
                fprintf('  svd() on %i x %i data... ', size(X, 1), size(X, 2)); tic();
                [u,d,~] = svd(X', 0);
                toc();
            end
            % Pull out eigen values and vectors
            lambda = diag(d);
            M = u;
            %eigenVecs = u(:, 1:percentMark);
            %M = M(:, ind);
            %M = M(:, ind(1:settings.Dimensions));
    end
    
    switch settings.Criterion
        case 'fraction variance explained'
            dim = find(cumsum(lambda)/sum(lambda) > settings.k, 1);
            if isempty(dim)
                settings.Dimensions = size(M, 2);
            else
                settings.Dimensions = dim;
            end
        case 'fixed number of pcs'
            settings.Dimensions = settings.k;
        otherwise
            assert(false);
    end
    
    if settings.plotVarExpl
        panelfun = bda_figure(sprintf('PCA of %s:%s', source.getName(), settings.featureName), [1, 1], 1/2);
        panelfun(1, 1, 'a');
        plot(cumsum(lambda)/sum(lambda));
        if strcmp(settings.Criterion, 'fraction variance explained')
            hold all; plot([1, numel(lambda)], settings.k * [1, 1], ':r');
        else
            hold all; plot(settings.k * [1, 1], [0, 1], ':r');
        end
        xlabel('#PCs');
        ylabel('Fraction Variance Explained');
        title(sprintf('Dimension = %i/%i (%.3f%%)', settings.Dimensions, numel(lambda),...
            settings.Dimensions/numel(lambda)*100));
        bda_formatFigure(gcf, 1, 8);
        drawnow;
    end
    
    if settings.createReconstruction
        M_ = M(:, setdiff(1:settings.Dimensions, coeffsToExclude));
        TM = M_ * M_';
        pLayout = parentCoordinates.getLayout();
        if settings.ignoreCutout
            layout = dspace_features.FeatureLayout(pLayout.dimensions,...
                pLayout.range, pLayout.cutoutIndices,...
                pLayout.cutoutDimension);
            source.coordinates{end+1} = dspace_features.LinearDerivedFeatures(...
                parentCoordinates, 1:prod(pLayout.dimensions), TM, Xm, Xm,...
                adaptName([newName '_reconstruction'], ftIdentifiers), layout);
        else
            layout = dspace_features.FeatureLayout(pLayout.cutoutDimension,...
                pLayout.range, 1:numel(pLayout.cutoutIndices),...
                pLayout.cutoutDimension);
            source.coordinates{end+1} = dspace_features.LinearDerivedFeatures(...
                parentCoordinates, pLayout.cutoutIndices, TM, Xm, Xm,...
                adaptName([newName '_reconstruction'], ftIdentifiers), layout);
        end
        
        source.coordinates{end}.various.lambdas = lambda;
        source.coordinates{end}.various.settings = settings;
        coordinateIdx_reconstruction = numel(source.coordinates);
    else
        coordinateIdx_reconstruction = NaN;
    end
    
    if settings.createLowD
        M = M(:, setdiff(1:settings.Dimensions, coeffsToExclude));
        TM = M;
        pLayout = parentCoordinates.getLayout();
        if round(sqrt(settings.Dimensions)) == sqrt(settings.Dimensions)
            layout = dspace_features.FeatureLayout(sqrt(settings.Dimensions)*[1,1],...
                pLayout.range, 1:settings.Dimensions,...
                sqrt(settings.Dimensions)*[1,1]);
        else
            layout = dspace_features.FeatureLayout([settings.Dimensions, 1],...
                pLayout.range, 1:settings.Dimensions,...
                [settings.Dimensions, 1]);
        end
        
        if settings.ignoreCutout
            source.coordinates{end+1} = dspace_features.LinearDerivedFeatures(...
                parentCoordinates, 1:prod(pLayout.dimensions), TM, Xm, [],...
                adaptName([newName '_lowD'], ftIdentifiers), layout);
        else
            source.coordinates{end+1} = dspace_features.LinearDerivedFeatures(...
                parentCoordinates, pLayout.cutoutIndices, TM, Xm, [],...
                adaptName([newName '_lowD'], ftIdentifiers), layout);
        end
        
        source.coordinates{end}.various.lambdas = lambda;
        source.coordinates{end}.various.settings = settings;
        coordinateIdx_lowD = numel(source.coordinates);
        if settings.freezeLowD
            source.coordinates{end+1} = dspace_features.StandardFeatures(X * TM, find(pf), numel(pf),...
                [source.coordinates{end}.getIdentifier() '_FRZ'], layout);
        end
    else
        coordinateIdx_lowD = NaN;
    end
    
    cts = uint32(str2num(settings.coefficientsToStore));
    
    if numel(cts) > 0
        X = X * M;
        if max(cts) > size(X, 2)
            cts(cts > size(X, 2)) = [];
        end
        for k = 1:numel(cts)
            Xvals = NaN(source.getNumberOfPoints(), 1);
            Xvals(pf) = X(:, cts(k));
            dataview.putProperty(matlab.lang.makeValidName(sprintf('%s_c%i', newName, cts(k))), Xvals,...
                dspace_data.PropertyDefinition([], [], sprintf('%s_c%i', newName, cts(k)), '', settings));
        end
    end
    
    %% Write results struct
    results.settings = settings;
    results.lambdas = lambda;
    results.newCoordinateIdx_reconstruction = coordinateIdx_reconstruction;
    results.newCoordinateIdx_lowD = coordinateIdx_lowD;
    
end

function str = adaptName(str, cnames)
    while 1
        if ismember(str, cnames)
            str = [str ''''];
        else
            return;
        end
    end
end



