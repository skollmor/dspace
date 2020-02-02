function [ titlestr, settings, results ] = linearRegression( dataview, settings )
    % Regresses Coordinates onto Variable using leave-1-out CV or k-fold
    % CV.
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
        titlestr = 'Essentials/Features/Linear Regression: Features->Variable';
        return;
    end
    
    np = dataview.getNumberOfPoints();
    source = dataview.dataSource;
    ftnames = source.getCoordinateIdentifiers();
    varNames = dataview.getPropertyNames();
    [pf, ~, ~] = dataview.getPointFilter();
    titlestr = sprintf('Linear Regression based on Features (%i points).', sum(pf));
   
    if nargin < 2 || isempty(settings)
        settings = {'Description', titlestr,...
            'WindowWidth', 500,...
            'ControlWidth', 250,...
            {'Source Features', 'predictorFeatures'}, ftnames,...
            {'Target Variable', 'targetvar'}, varNames,...
            {'Lambdas (Regularizer)', 'lambdas'}, '10.^(-16:3)',...
            {'Cross Validation Type', 'cvType'}, {'Leave-One-Out', 'k-Fold'},...
            {'k (if k-fold)', 'cv_k'}, 10,...
            {'Prediction Variable Name', 'predictionVarName'}, 'pred',...
            {'Plot Result', 'doPlot'}, true};
        return;
    end
    
    cid = find(strcmp(settings.predictorFeatures, ftnames), 1);
    
    pfIds = find(pf);
    X = full(source.coordinates{cid}.getDataMatrix(source, pfIds));
    Y = source.P.(settings.targetvar)(pfIds);
    lambdas = eval(settings.lambdas);
    
    Xmean = mean(X, 1);
    Ymean = mean(Y, 1);
    X = X - Xmean;
    Y = Y - Ymean;
    
    switch settings.cvType
        case 'Leave-One-Out'
            % this function expects datapoints as columns
            [ cv_e, Yhat, lambdaId, msePerLambda ] = looRegression( X',  Y', lambdas);
        case 'k-Fold'
            % this function expects datapoints as columns
            [ cv_e, Yhat, msePerLambda, lambdaId, parts, bestBeta] = nfoldRegression( X',  Y',...
                lambdas, settings.cv_k, false);
    end
    % msePerLambda is the sum of squared residuals
    
    % compute variance explained
    Y2 = bsxfun(@minus, Y, mean(Y, 1)).^2;
    varY = sum(Y2(:));
    varExpl = 1 - sum(cv_e(:).^2) / varY;
    varExpl_per_lambda = 1 - msePerLambda/varY;
    
    % compute coefficients
    lambda = lambdas(lambdaId);
    %beta = bestBeta;
    
    beta = inv(X'*X/size(X, 1) + lambda*eye(size(X, 2))) * ((Y'*X)'/size(X, 1)); % + randn(size(X, 2), 1);
    beta10 = inv(X'*X/size(X, 1) + 10*lambda*eye(size(X, 2))) * ((Y'*X)'/size(X, 1));
    beta100 = inv(X'*X/size(X, 1) + 100*lambda*eye(size(X, 2))) * ((Y'*X)'/size(X, 1));
    beta1000 = inv(X'*X/size(X, 1) + 1000*lambda*eye(size(X, 2))) * ((Y'*X)'/size(X, 1));
    
    %beta = (X'*X + lambda*eye(size(X, 2)))\(Y'*X)';
    
     % Store predictions
    Yhat_all = NaN(np, 1);
    Yhat_all(pf) = Yhat;
    dataview.putProperty(sprintf('%s_cv', settings.predictionVarName), Yhat_all, dspace_data.PropertyDefinition(...
        [], [], sprintf('%s_cv', settings.predictionVarName), '', settings));
    
    % Store projection
    settings.Xmean = Xmean;
    settings.Ymean = Ymean;
    settings.beta = beta;
    Yhat_all = NaN(np, 1);
    Yhat_all(pf) = X * beta + Ymean;
    dataview.putProperty(sprintf('%s_prj', settings.predictionVarName), Yhat_all, dspace_data.PropertyDefinition(...
        [], [], sprintf('%s_prj', settings.predictionVarName), '', settings));
    
    % Store squared residuals
    Looe_all = NaN(np, 1);
    Looe_all(pf) = cv_e.^2;
    dataview.putProperty([settings.predictionVarName '_resid_squared'], Looe_all, dspace_data.PropertyDefinition(...
        [], [], settings.predictionVarName, '', settings));
    
    results = [];
    
    %% Plot
    varExpl_per_lambda = max(-eps, varExpl_per_lambda);
    if settings.doPlot
        pfcn = bda_figure(sprintf('%s:%s-->%s', source.name, source.coordinates{cid}.getIdentifier(), settings.predictionVarName), [5, 5], 1);
        pfcn(1, 1, '', 2, 1);
        plot(lambdas, varExpl_per_lambda, '-k'); xlabel('\lambda');
        set(gca, 'xscale', 'log', 'yscale', 'linear');
        hold all, plot([1, 1] * lambdas(lambdaId), [min(varExpl_per_lambda), max(varExpl_per_lambda)], ':k', 'lineWidth', 2);
        plot([1, 1] * 10* lambdas(lambdaId), [min(varExpl_per_lambda), max(varExpl_per_lambda)], ':g', 'lineWidth', 2);
        plot([1, 1] * 100* lambdas(lambdaId), [min(varExpl_per_lambda), max(varExpl_per_lambda)], ':g', 'lineWidth', 2);
        plot([1, 1] * 1000* lambdas(lambdaId), [min(varExpl_per_lambda), max(varExpl_per_lambda)], ':g', 'lineWidth', 2);
        ylabel('Fr.Var.Ex.');
        title(sprintf('Fr.Var.Ex.=%.4f', varExpl));
        
        pfcn(3, 1, 'XM', 2, 2);
        ly = source.coordinates{cid}.getLayout();
        imagesc([1, ly.dimensions(2)], [1, ly.dimensions(1)], reshape(Xmean, ly.dimensions(1), ly.dimensions(2)));
        makeClim_symmetric();
        axis tight;
        colorbar('Position', [0.81, 0.8, 0.025, 0.1]);
        pfcn(1, 3, 'Y_0X_0', 2, 2);
        ly = source.coordinates{cid}.getLayout();
        imagesc([1, ly.dimensions(2)], [1, ly.dimensions(1)], reshape((Y'*X), ly.dimensions(1), ly.dimensions(2)));
        makeClim_symmetric();
        axis tight;
        pfcn(3, 3, '\beta', 2, 2);
        ly = source.coordinates{cid}.getLayout();
        beta_r = reshape(beta', ly.dimensions(1), ly.dimensions(2));
        imagesc([1, ly.dimensions(2)], [1, ly.dimensions(1)], beta_r);
        makeClim_symmetric();
        axis tight;
        colorbar('Position', [0.81, 0.1, 0.025, 0.1]);
        pfcn(5, 3, '\Sigma \beta', 1, 2);
        plot(mean(beta_r, 2), 1:size(beta_r, 1));
        hold all
        plot(mean(abs(beta_r), 2), 1:size(beta_r, 1), ':');
        axis tight;
        pfcn(3, 5, '\Sigma \beta', 2, 1);
        plot(1:size(beta_r, 2), mean(beta_r, 1));
        hold all;
        plot(1:size(beta_r, 2), mean(abs(beta_r), 1), ':');
        axis tight;
        pfcn(1, 2, '', 2, 1);
        plot(Y+Ymean, X * beta + Ymean, '.');
        %plot(X * beta + Ymean, '.');
        
        xlabel('Y');
        ylabel('Best Projection');
        pfcn(1, 5, '', 2, 1);
        beta10_r = reshape(beta10', ly.dimensions(1), ly.dimensions(2));
        beta100_r = reshape(beta100', ly.dimensions(1), ly.dimensions(2));
        beta1000_r = reshape(beta1000', ly.dimensions(1), ly.dimensions(2));
        imagesc([beta10_r/norm(beta10_r(:)) NaN(size(beta10_r, 1), 1)...
            beta100_r/norm(beta100_r(:)) NaN(size(beta10_r, 1), 1) beta1000_r/norm(beta1000_r(:))]);
        makeClim_symmetric();
        title('\lambda*10 | *100 | *1000');
        axis tight; axis xy;
        grid on;
        %bda_formatFigure(gcf, [], 8);
    end
    %% 
end

function makeClim_symmetric()
    clim_old = get(gca, 'clim');
    set(gca, 'clim', [-1, 1] * max(abs(clim_old)));
end

function stringCell = permuteStringOptions(options, primary)
    if isempty(primary)
        stringCell = options;
        return
    end
    idx = find(strcmp(options, primary), 1);
    stringCell = [options(idx), options([1:idx-1 idx+1:end])];
end

function [ looe, Yhat, lambdaId, msePerLambda] = looRegression( X,  Y, lambdas) %#codegen
    % Multiple linear regression with leave-one-out cross-validation
    %
    % X - wx x n, matix of predictor windows, n >= d*w
    % Y - wy x n, matrix of target columns
    % lambdas - 1 x k matrix of regularization parameters to test
    %
    % The model fit is bX = Y. Add a row of ones to X to fit a model with intersect.
    %
    % Yhat - d x n, Yhat (leave one out)
    %
    % compare bda_looRegression.m
    
    X = X';
    d = size(Y, 1);
    dw = size(X, 2);
    n = size(X, 1);
    assert(n >= dw, 'n >= dw must hold.');
    
    isVerbose = n > 100000;
    
    if isVerbose
        fprintf('SVD...'); tic();
    end
    
    [U,S,~] = svd(X, 'econ');
    
    if isVerbose
        toc();
        fprintf('Eigendecomposition...'); tic();
    end
    
    [Q, D] = eig(S^2);            % note: (S^2 + yI)^-1 = Q (D + yI)^-1 Q^T
    
    if isVerbose
        toc();
    end
    
    I = eye(dw);
    looe = NaN(d, n, length(lambdas));
    
    if isVerbose
        fprintf('Prediction.linearRegression: Iterating over %i lambdas... ', numel(lambdas));
        tic();
    end
    
    for lambdaId = 1:length(lambdas)
        
        lambda = n * lambdas(lambdaId);
        
        M = Q * diag( 1./ (diag(D) + lambda) ) * Q';    % M = (S^2 + yI)^-1
        M = U * (M - I/lambda);

        % (n x w) * (w x d) [= (w x n) * (n x d)]  |  diag(M * U')' = sum(M .* U, 2)'
        looe(:, :, lambdaId) = bsxfun(@times,  (M * (U' * Y'))'...
            + Y/lambda, 1./( sum(M .* U, 2)' + 1/lambda));
        
        if isVerbose
            fprintf('.');
        end
        
    end
    
    if isVerbose
        toc();
    end
    
    msePerLambda = squeeze(sum(sum(looe.^2, 2), 1));
    [~, lambdaId] = min(msePerLambda);
    
    % looe is defined as looe = Y - Yhat
    looe = looe(:, :, lambdaId);
    Yhat = -looe + Y;
    
end

function [ nfolde, Yhat, msePerLambda, bestLambdaId, parts, bestBeta ] = nfoldRegression( X,  Y,...
        lambdas, cvFolds, useGPU) 
    %NPL_NFOLDREGRESSION Multiple linear regression and n-fold cross-validation 
    % 
    % dw - predictor size, d - target height, n - number of windows 
    % X - dw x n, matix of predictor windows, n >= dw
    % Y - d x n, matrix of target columns, must be mean subtracted
    % lambdas - 1 x k matrix of regularization parameters to test
    %
    % The model fit is bX = Y. Add a row of ones to X to fit a model with intersect.
    %
    % nfolde = Y - Yhat 
    % msePerLambda - mean squared cross validation error for each lambda
    % bestLambdaId - id of lambda that minimized the mse
    % parts - cell array
    % bestBeta - dw x d 
    % 
    % Author: Sepp Kollmorgen (skollmor@ini.phys.ethz.ch), Songbird-Lab @
    % INI @ ETHZ/UZH, 2014
    %
    eigThreshold = 50; % use eigendecomposition if #lambdas exceeds threshold
    
    if nargin < 5 || isempty(useGPU)
        useGPU = false;
    end
    
    d = size(Y, 1);
    dw = size(X, 1);
    n = size(X, 2);
    %assert(n >= dw, 'n >= dw must hold.');
    
    parts = disjointGroups(n, cvFolds);
    XX = zeros(dw, dw, cvFolds, class(X));
    YX = zeros(d, dw, cvFolds, class(X));
    nP = NaN(1, cvFolds);
    %Xp = NaN(dw, length(parts{1}));
    for partId = 1:length(parts)    % Takes up 70% of computation time (no gpu)
                                    % parfor and spmd do not help
%         if useGPU
%             Xp = gpuArray(X(:, parts{partId}));
%             Yp = gpuArray(Y(:, parts{partId}));
%             XX(:, :, partId) = gather(Xp * Xp');
%             YX(:, :, partId) = gather(Yp * Xp');
%         else
            Xp = X(:, parts{partId});
            Yp = Y(:, parts{partId});
            XX(:, :, partId) = Xp * Xp';
            YX(:, :, partId) = Yp * Xp';
%        end
        nP(partId) = length(parts{partId});
        %XX(:, :, partId) = X(:, parts{partId}) * X(:, parts{partId})';
        %YX(:, :, partId) = Y(:, parts{partId}) * X(:, parts{partId})';
    end
    
    if useGPU   
        I = gpuArray(eye(dw));
    else
        I = eye(dw);
    end
    
    nfolde = zeros(d, n, length(lambdas), class(X));
    for foldId = 1:cvFolds
        outFold = setdiff(1:cvFolds, foldId);
        if useGPU
            XXof = gpuArray(sum(XX(:, :, outFold), 3));
            YXof = gpuArray(sum(YX(:, :, outFold), 3));
        else
            XXof = sum(XX(:, :, outFold), 3);
            YXof = sum(YX(:, :, outFold), 3);
        end         
        nPof = sum(nP(outFold));
        if length(lambdas) > eigThreshold  % eigendecomposition is only worthwhile if we compute many lambdas
            XXof = (XXof + XXof') / 2;     % ensure perfect symetry
            [Q, D] = eig(XXof);            % note: (XXof + yI)^-1 = Q (D + yI)^-1 Q^T    %23s (wnd: 20)
            diagD = diag(D)';
            for lambdaId = 1:length(lambdas)
                lambda = nPof * lambdas(lambdaId);
                if useGPU
                    beta = gather(bsxfun(@times, Q, 1./(diagD + lambda)) * Q' * YXof'); %21s        
                else
                    beta = bsxfun(@times, Q, 1./(diagD + lambda)) * Q' * YXof';         %69s (wnd: 20, 20 lambdas)
                end
                %beta = (YXof * (Q * bsxfun(@times, Q, 1./(diag(D)' + lambda))'))';      
                %beta = Q * diag(1./(diag(D) + lambda)) * Q' * YXof';                   
                nfolde(:, parts{foldId}, lambdaId) = Y(:, parts{foldId}) - beta' * X(:, parts{foldId});
            end
        else
            if useGPU 
%                 Xp = gpuArray(X(:, parts{foldId})); %21.25s, wnd 20
%                 Yp = gpuArray(Y(:, parts{foldId}));
                Xp = X(:, parts{foldId});             %2s
                Yp = Y(:, parts{foldId});
            else
                Xp = X(:, parts{foldId});
                Yp = Y(:, parts{foldId});
            end
            for lambdaId = 1:length(lambdas)
                lambda = nPof * lambdas(lambdaId);
                if useGPU
                    beta = gather((XXof + lambda*I)\YXof');                 % 26s (wnd: 20, 20 lambdas)
                    nfolde(:, parts{foldId}, lambdaId) = Yp - beta' * Xp;   % 19s (wnd: 20, 20 lambdas)
%                     beta = (XXof + lambda*I)\YXof';                       % 26s (wnd: 20, 20 lambdas)
%                     nfolde(:, parts{foldId}, lambdaId) = gather(Yp - beta' * Xp);
                else
                    beta = (XXof + lambda*I)\YXof';             % 45s (wnd: 20, 20 lambdas)
                    nfolde(:, parts{foldId}, lambdaId) = Yp - beta' * Xp;
                end
            end
        end
    end
    msePerLambda = squeeze(sum(sum(nfolde.^2, 2), 1)); % / (size(nfolde, 1)*size(nfolde, 2));
    [~, bestLambdaId] = min(msePerLambda);
    nfolde = nfolde(:, :, bestLambdaId);
    Yhat = Y - nfolde;
    if nargout >= 5
        if useGPU
            XXof = gpuArray(sum(XX, 3));
            YXof = gpuArray(sum(YX, 3));
            lambda = sum(nP) * lambdas(bestLambdaId);
            bestBeta = gather((XXof + lambda*I)\YXof');
        else
            XXof = sum(XX, 3);
            YXof = sum(YX, 3);
            lambda = sum(nP) * lambdas(bestLambdaId);
            bestBeta = (XXof + lambda*I)\YXof';
        end
    end
end


% creates disjoint groups of the indices 1:nItems such that
% groups have either k = floor(n/nGroups) or k+1 elements,
% maximimizing number of groups with k+1 elements
function groups = disjointGroups(nItems, nGroups)
    assert(nGroups <= nItems);
    n = nItems;
    rp = randperm(n);
    grs = floor(n/nGroups);
    groups = cell(1, nGroups);
    phaseII = false;
    for k = 1:nGroups
        groups{k} = rp(1:grs);
        rp(1:grs) = [];
        % generate groups of size grs until remaining groups can be
        % size grs+1
        if ~phaseII && (nGroups-k)*(grs+1) <= length(rp)
            grs = grs + 1;
            phaseII = true;
        end
    end
    assert(length(rp) == 0); %#ok<ISMT>
    %groups{k} = [groups{k}, rp];
end



