function [ titlestr, settings, results] = computeMixingMatrix( dataview, settings )
    % Computes and plots a mixing matrix based on a (k-NN) graph and a level 
    % and target variable. Both level and target variable should be categorical.
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


    titlestr = 'Essentials/Graphs/Compute Mixing Matrix';
    if nargin == 0   
        return;
    end
    
    np = dataview.getNumberOfPoints();
    pf = dataview.getPointFilter();
    dsource = dataview.dataSource;
    groupNames = dsource.getGraphNames();
    varNames = dsource.getPropertyNames();
    
    if nargin < 2 || isempty(settings)
        settings = {'Description', sprintf('Compute mixing matrix (%i/%i points in selection).', sum(pf), np),...
            'WindowWidth', 700, 'ControlWidth', 350,...
            'separator', 'Mixing Matrix',...
            {'Binning Labels (x)', 'levelVar'}, permuteStringOptions(varNames, dataview.Chart1name),...
            {'Neighborhood Labels (y)', 'targetVar'}, permuteStringOptions(varNames, dataview.SelectionName),...
            {'Graph', 'lg'}, groupNames,...
            {'Truncate Connected-Node-Set to k Elements', 'lgTruncate_k'}, 0,...
            'separator', 'Various',...
            {'Use log_2 scale', 'log2scale'}, true,...
            {'Scale Mixing Matrix', 'divideByNH'}, true,...
            {'Scaling Type', 'nhType'}, {'Outer-Product', 'Permutation'},...
            {'Min. Bin Size', 'minLevelSize'}, 100,...
            'separator', 'Multi-Dimensional Scaling',...
            {'Use multi-dimensional scaling', 'mdScale'}, false,...
            {'Align MD-scale dimensions to the change over levels', 'alignMdScale'}, true,....
            {'Estimate exponent', 'mdScaleExp'}, false};
        return;
    end
    
    %% Prepare variables
    binName = settings.levelVar;
    binVar = dataview.getPropertyValues(settings.levelVar);
    nnLabelsName = settings.targetVar;
    nnLabelsVar = dataview.getPropertyValues(settings.targetVar);
    graph = dsource.G(settings.lg);
    
    if ~(isfield(settings, 'doPlot') && ~settings.doPlot)
        h = dspace.app.waitbar_dspace(0.25, strrep(titlestr, '_', ' '), 'Color', [1,1,1], 'Name', 'Processing');
    end
    
    if ~graph.isInitialized()
        graph.initialize(dsource);
    end
         
    NNids = graph.getConnectedNodes(find(pf));
    if isfield(settings, 'lgTruncate_k') && settings.lgTruncate_k > 0
        NNids = NNids(:, 1:settings.lgTruncate_k);
    end
   
    LGnans = sum(isnan(NNids), 2);
    if sum(LGnans) > 0
        fprintf('%i Neighborhoods contain NaN ids. (avg #NaNs: %.2f)\n', sum(LGnans > 0),...
            mean(LGnans(LGnans > 0)));
    end
    
    if ~isfield(settings, 'alignMdScale')
        settings.alignMdScale = false;
    end
    
    if ~isfield(settings, 'mdScaleExp')
        settings.mdScaleExp = false;
    end
    
    isIntegerLevels = all(round(binVar(pf)) == binVar(pf));
    if isfield(settings, 'forceLevels')
        levels = settings.forceLevels;
    elseif isIntegerLevels
        levels =  min(binVar(pf)):max(binVar(pf));
    else
        levels = unique(binVar(pf));
    end
    
    if ~isfield(settings, 'forceLevels')
        assert(numel(levels) < 1000, 'Too many levels (the level variable must be categorical).');
    end
    
    isIntTarget = all(round(nnLabelsVar(pf)) == nnLabelsVar(pf));
    if isfield(settings, 'forceTargets')
        targetBins = settings.forceTargets;
    elseif isIntTarget
        targetBins = min(nnLabelsVar(pf)):max(nnLabelsVar(pf));
    else
        targetBins = linspace(min(nnLabelsVar(pf)), max(nnLabelsVar(pf)), 100);
    end
    
    pfIds = find(pf);
    
    fprintf('Computing mixing matrix. nPts: %i; LGsize: %i...\n', sum(pf), size(NNids, 2));
    
    %% Compute Mixing Matrix
    switch settings.nhType
        case 'Permutation'
            permutation = 1:numel(pfIds);
            [Hcounts, levelSizes] = mixingMatrix(NNids, LGnans, levels, targetBins, binVar, nnLabelsVar,...
                pf, pfIds, permutation, settings.minLevelSize, settings.subtractTarget);
            
            NHsamples = 100; minLevelSize = settings.minLevelSize;
            NHcounts = NaN(size(Hcounts, 1), size(Hcounts, 2), NHsamples);
            parfor j = 1:NHsamples
                permutation = randperm(numel(pfIds));
                [NHcounts(:, :, j), ~] = mixingMatrix(NNids, LGnans, levels, targetBins, binVar,...
                    nnLabelsVar, pf, pfIds, permutation, minLevelSize, settings.subtractTarget); %#ok<PFBNS>
            end
            
            NH = mean(NHcounts, 3);
            
        case 'Quasi-Analytical'
            [Hcounts, ~, NH, levelSizes] = mixingMatrix_outerproductNH(NNids, LGnans, levels, targetBins, binVar,...
                nnLabelsVar, pf, pfIds, settings.minLevelSize, graph, settings.subtractTarget);
    end
    
    
    
    Hcounts(levelSizes < settings.minLevelSize, :) = NaN;
    
    HcountRatio = Hcounts./NH;
    
    if settings.divideByNH
        Hplot = HcountRatio;
    else
        Hplot = Hcounts;
    end
    
    if settings.log2scale
        Hplot = log2(Hplot);
    end
    
    titlestr = sprintf('LGs: %s (%i levels); NH type: %s.', graph.getName(), numel(levels), settings.nhType);
    figureName = sprintf('Mixing Matrix for %s', dsource.getName());
    
    %% Plot
    if ~(isfield(settings, 'doPlot') && ~settings.doPlot)
        f = bda_figure(figureName, [1, 5], 1);
        f(1, 1, '', 1, 4);
        imagesc([min(levels), max(levels)], [min(targetBins), max(targetBins)], Hplot); axis xy; axis tight;
        
        ylabel([nnLabelsName ' (Target)'], 'interpreter', 'none');
        title(titlestr, 'interpreter', 'none', 'fontsize', 7);
        colormap(parula(1000));
        cbar =  colorbar('Position', [0.91, 0.4, 0.025, 0.5]);
        if settings.divideByNH
            if settings.log2scale
                ylabel(cbar, 'log2(#H/#NH)', 'interpreter', 'none');
            else
                ylabel(cbar, '#H/#NH', 'interpreter', 'none');
            end
        else
            if settings.log2scale
                ylabel(cbar, 'log2(#H)', 'interpreter', 'none');
            else
                ylabel(cbar, '#H', 'interpreter', 'none');
            end
        end
        clims = get(gca, 'clim');
        set(gca, 'clim', max(abs(clims))*[-1, 1]);
        ax(1) = gca;
        f(1, 5, '', 1, 1);
        title(sprintf('n=%i', sum(levelSizes)));
        bar(levels, levelSizes);
        xlim([min(levels), max(levels)]);
        ax(2) = gca;
        linkaxes(ax, 'x');
        xlabel([binName ' (Levels)'], 'interpreter', 'none');
        bda_formatFigure(gcf, 1, 8);
    else
        ax = [];
    end
    if ~(isfield(settings, 'doPlot') && ~settings.doPlot)
        close(h);
    end
    %% MD Scale
    figureName = sprintf('MdScale of Mixing Matrix for %s', dsource.getName());
    if settings.mdScale
        dissimilarity = -Hplot;
        dissimilarity = dissimilarity - min(dissimilarity(:));
        for k = 1:size(dissimilarity, 1)
            dissimilarity(k, k) = 0;
        end
        dissimilarity(isinf(dissimilarity(:))) = nanmax(dissimilarity(~isinf(dissimilarity(:))));
%         dissimilarity_x = dissimilarity ./ repmat(sum(dissimilarity, 1), size(dissimilarity, 1), 1);
%         dissimilarity_y = dissimilarity ./ repmat(sum(dissimilarity, 2), 1, size(dissimilarity, 2));
%         dissimilarity = dissimilarity_x + dissimilarity_y' + dissimilarity_x' + dissimilarity_y;
        dissimilarity =  dissimilarity +  dissimilarity';
        opts = statset('MaxIter', 1000);
        [Y, stress, disparities] = mdscale(dissimilarity, 2, 'criterion', 'sstress', 'Options', opts);
        
        if settings.alignMdScale
            dY = Y(end, :) - Y(1, :);
            dYP = [-dY(2), dY(1)];
            dY = dY/norm(dY);
            dYP = dYP/norm(dYP);
            Tr = [dY; dYP];
            Y_transformed = Y * Tr';
        else
            Y_transformed = Y;
        end
        
        if ~(isfield(settings, 'doPlot') && ~settings.doPlot)
            yrange = [min(Y(:, 1)) max(Y(:, 1))];
            f = bda_figure(figureName, [2, 2], 1);
            f(1,1,'');
            imagesc(dissimilarity);
            axis tight;
            
            
            colorbar('Position', [0.47, 0.8, 0.025, 0.1]);
            titlestr = sprintf('LGs: %s (%i levels); NH type: %s.', graph.getName(), numel(levels), settings.nhType);
            f(1,2,'');
            scatter(Y_transformed(:, 1), Y_transformed(:, 2), 40, levels, 'filled');
            if size(Y_transformed, 1) < 35
                for j = 1:size(Y, 1)
                    text(Y_transformed(j, 1)+diff(yrange)/20, Y_transformed(j, 2), num2str(levels(j)));
                end
            end
            plot(Y_transformed(:, 1), Y_transformed(:, 2), ':k');
            xlabel('mdsX'); ylabel('mdsY');
            title(sprintf('MD-Scale; Stress=%f', stress));
            
            xlims = get(gca, 'xlim');
            ylims = get(gca, 'ylim');
            ml = [-1, 1] * max(abs([xlims, ylims]));
            xlim(ml);
            ylim(ml);
            
            f(2, 1, '');
            ldDist = squareform(pdist(Y));
            [dum,ord] = sortrows([disparities(:) dissimilarity(:)]);
            plot(dissimilarity(:),ldDist(:),'bo', ...
                dissimilarity(ord),disparities(ord),'r.-');
            xlabel('HD Dissimilarity')
            ylabel('LD Distance/Disparity')
            plot(dissimilarity(:), disparities(:), '+k');
            legend({'LD Distances' 'Disparity', 'Disparity'}, 'Location','NorthWest');
            f(2, 2, '');
            plot(Hplot(:), ldDist(:), '.k');
            if settings.divideByNH
                if settings.log2scale
                    xlabel('log2(#H/#NH)', 'interpreter', 'none');
                else
                    xlabel('#H/#NH', 'interpreter', 'none');
                end
            else
                if settings.log2scale
                    xlabel('log2(#H)', 'interpreter', 'none');
                else
                    xlabel('#H', 'interpreter', 'none');
                end
            end
            ylabel('LD Distance');
            bda_formatFigure(gcf, 1, 8);
            set(gcf, 'Position', [16   251   699   627]);
        end
    end
    
    results = [];
    results.Hcounts = Hcounts;
    results.NHcounts = NH;
    results.HcountRatio = HcountRatio;
    results.HcountRatio_log2 = log2(HcountRatio);
    results.levelSizes = levelSizes;
    results.levels = levels;
    results.targets = targetBins;
    results.settings = settings;
    results.axis = ax;
    if settings.mdScale
        results.MDS.Y = Y;
        results.MDS.Y_transformed = Y_transformed;
        results.MDS.dissimilarityMatrix = dissimilarity;
        results.MDS.stress = stress;
        results.MDS.disparities = disparities;
    end
end


function [Hcounts, levelSizes] = mixingMatrix(LGids, LGnans, levels, targetBins, levelvar,...
        targetvar, pf, pfIds, permutation, minLevelSize, subtractTarget)
    
    % use the same permutation for target and level variable
    levelvar(pfIds) = levelvar(pfIds(permutation));
    targetvar(pfIds) = targetvar(pfIds(permutation));
    
    levelSizes = NaN(1, numel(levels));
    
    Hcounts = NaN(numel(targetBins), numel(levels));
    
    for k = 1:numel(levels)
        validIds = levelvar(pf) == levels(k) & LGnans == 0;
        levelSizes(k) = sum(validIds);
        
        if sum(validIds) < minLevelSize
            Hcounts(:, k) = NaN(numel(targetBins), 1);
            continue;
        end
        
        % LG members indices (elements of A) are global (no point filter)
        A = LGids(validIds, :);
        
        if subtractTarget
            if size(A, 1) == 1
                A = reshape(targetvar(A), 1, []);
                A = A - repmat(targetvar(pfIds(validIds)), 1, size(A, 2));
            else
                A = targetvar(A) - repmat(targetvar(pfIds(validIds)), 1, size(A, 2));
            end
        else
            A = targetvar(A);
        end
        
        A = A(:);
        Hcounts(:, k) = histc(A, targetBins);
        
    end
end

function [Hcounts, NHcounts, NH, levelSizes] = mixingMatrix_outerproductNH(LGids, LGnans, levels, targetBins, levelvar,...
        targetvar, pf, pfIds, minLevelSize, lg, subtractTarget)
    
    Hcounts = NaN(numel(targetBins), numel(levels));
    NHcounts = NaN(numel(targetBins), numel(levels));
    NH = NaN(numel(targetBins), numel(levels));
    levelSizes = NaN(numel(levels), 1);
    lgSize = size(LGids, 2);
    
    % parfor
    for k = 1:numel(levels) % (k = 1:numel(levels), 4)
        
        validIds = levelvar(pf) == levels(k) & LGnans == 0;
        levelSizes(k) = sum(validIds);
        
        if sum(validIds) < minLevelSize
            Hcounts(:, k) = NaN(numel(targetBins), 1);
            NHcounts(:, k) = NaN(numel(targetBins), 1);
            NH(:, k) = NaN(numel(targetBins), 1);
            continue;
        end
        
        % LG members indices (elements of A) are global (no point filter)
        A = LGids(validIds, :);
        
        if subtractTarget
            if size(A, 1) == 1
                A = reshape(targetvar(A), 1, []);
                A = A - repmat(targetvar(pfIds(validIds)), 1, size(A, 2));
            else
                A = targetvar(A) - repmat(targetvar(pfIds(validIds)), 1, size(A, 2));
            end
        else
            A = targetvar(A);
        end
        
        A = A(:);
        Hcounts(:, k) = histc(A, targetBins);
        
        if ~subtractTarget
            % Null hypothesis assumes point positions are randomized (when conditioned LGs
            % are used, each level has potentially a different candidate set)
            [NH_, W_] = lg.getWeightedJointDomain(pfIds(validIds));
            D = targetvar(NH_);
            % compute weighted histogram using weights W (how often each
            % target value occurs if only lg domains but no distances are
            % considered)
            [~, bin] = histc(D, targetBins);
            wh = zeros(1, numel(targetBins));
            % an error here, might indicate a faulty (too large) local group domain
            for r = 1:length(W_)
                wh(bin(r)) = wh(bin(r)) + W_(r);
            end
            % This is the "marginal" for this level (when conditioned LGs
            % are used, each level has potentially a different candidate set)
            NHcounts(:, k) = wh;
            NH(:, k) = lgSize/sum(wh) * levelSizes(k) * NHcounts(:, k);
        else
            % level and target variable might not be independent
            lgcTargets = targetvar(pfIds(validIds));
            fTargetBins = min(targetvar(pfIds)):max(targetvar(pfIds));
            [lgc_hist, ~] = histc(lgcTargets, fTargetBins);
            
            % under the permutation null hypothesis an lg center may have any
            % point as lg member (except itself)
            members_hist = histc(targetvar(pfIds), fTargetBins);
            % assuming target bins for the difference are explicitly
            % provided
            difference_hist = zeros(size(targetBins));
            for deltaIdx = 1:numel(targetBins)
                delta = targetBins(deltaIdx);
                
                if delta < 0
                    difference_hist(deltaIdx) = lgSize/numel(pfIds) * sum(members_hist(1:end+delta).*lgc_hist(-delta+1:end));
                else
                    difference_hist(deltaIdx) = lgSize/numel(pfIds) * sum(members_hist(delta+1:end).*lgc_hist(1:end-delta));
                end
            end
            NH(:, k) = difference_hist;
            NHcounts(:, k) = NaN;
        end
        
    end
end


function stringCell = permuteStringOptions(options, primary)
    if isempty(primary)
        stringCell = options;
        return
    end
    idx = find(strcmp(options, primary), 1);
    stringCell = [options(idx), options([1:idx-1 idx+1:end])];
end

