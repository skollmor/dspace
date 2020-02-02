function [ titleStr, settings, results ] = collapseSources( dataview, settings )
    % This functions summarizes one or multiple datasources as a new 'collapsed' 
    % datasource. It bins all datapoints according to a number of binning variables 
    % and then computes summary statistics  over all datapoints in each bin. In batch 
    % mode this function can accumulate summaries for all selected sources in a 
    % single summary datasource.
    %
    % Only data inside the current point-filter is considered.
    %
    % Bins are defined through all combinations of the values of the <b>binning-variables</b>. 
    % Within each bin, data is accumulated by computing mean, median, variance, 
    % 5thPercentile, 95thPercentile, nPts, nNaNs for each <b>target-variable</b> over all 
    % datapoints falling into each bin. 
    %
    % Accumulation is done seperately for each combination of the values
    % given by the <b>split-variables</b>. This allows for each split to be mean
    % subtracted and/or normalized (the mean is the average over all
    % (accumulated) bins for this split). 
    % <h4>Treatment of NaNs</h4>
    % NaNs in binning and splitting variables are treated like normal values. 
    % In particular all NaNs are treated as identical.
    % Target variables and coordinates are accumulated ignoring NaNs.
    % <h4>Output Datasource</h4>
    % Results are stored in a new datasource on the collection level with the name provided. 
    % In batch processing mode this collapsed-source is filled step-by-step with
    % results from all selected sources in the current level.
    %
    % The results-datasource contains all split and bin variables as well
    % as the various accumulations of the target variable.
    %
    % It also contains a variable sourceIdx indicating from which datasource the summarized 
    % data originates.
    % <h4>Example</h4> 
    % Assume a number of datasources where datapoints are measurements of 
    % beak-size of birds of varying species. Let's say these datasources 
    % have the variables
    %
    % beaksize, birdweight, birdspecies, ...
    %
    % and that there are multiple sources since sets of measurements were 
    % taken by multiple experimenters.
    %
    % We might be interested in how beaksize changes as a function of birdweight.
    %
    % The BinningTool can answer this question but we need to
    % accumulate across datasources first with birdweight as binning
    % variable and beaksize as target variable.
    %
    % Additionally we can remove effects of mean and std. deviations within
    % species by selecting birdspecies as a split variable.
    %
    % See also dspace_data.DataCollection
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

    
    titleStr = 'Essentials/Collapse Source(s)';
        
     if nargin == 0
        % Function was called with 0 inputs: 
        % -- Only need to define the title (which we did already above)   
        return
    elseif nargin == 1 || (nargin == 2 && isempty(settings))
        % Function was called with 1 input or 2 inputs where the second is empty:
        % -- Only define default settings --
        dsource = dataview.dataSource;
        
        pf = dataview.getPointFilter();
        np = sum(pf);
        featureIdentifiers = ['---' dsource.getCoordinateIdentifiers()];
        varNames = sort(dataview.getPropertyNames());
        settings = {'Description', sprintf('Collapse source(s) (%i points in current filter).',...
            np),...
            'WindowWidth', 600, 'ControlWidth', 350,...
            'separator', 'Binning Variables',...
            {'Binning-variables', 'binVars'}, dspace.app.StringList(varNames),...
            {'Split-variables', 'splitVars'}, dspace.app.StringList(varNames),...
            'separator', 'Processing',...
            {'Subtract mean for each split', 'meanSubtract'}, true,...
            {'Z-score each split', 'zscore'}, true,...
            {'Compute percentiles', 'doPrctiles'}, false,...
            {'Discard empty bins', 'discardEmptyBins'}, true,...
            'separator', 'Targets',...
            {'Target-variables', 'targetVars'}, dspace.app.StringList(varNames),...
            {'Target-features', 'targetFeatures'}, dspace.app.StringList(featureIdentifiers),...
            'separator', 'Output Datasource',...
            {'Name for summary datasource', 'rtSourceName'}, 'Summary',...
            {'Level for summary datasource', 'rtLevelName'}, 'Collapsed'};
        
        return;
     end
    
    % Function was called with 2 arguments.
    %% -- Perform computations and create module function outputs --
    dsource = dataview.dataSource;
    pf = dataview.getPointFilter();
       
    % Fetch partial collapsed source
    cSourceName = settings.rtSourceName;
    cLevelName = settings.rtLevelName;
    collapsedSource = dsource.parentCollection.fetchSource(cSourceName, cLevelName);
    levelname = dsource.parentCollection.getLevel(dsource);
    sourceId =  dsource.parentCollection.getIndexInLevel(dsource, levelname);
     
    if isempty(collapsedSource) 
        newlyCreated = true;
        collapsedSource = dspace_data.TableDataSource(cSourceName);
    else
        if settings.runAll && settings.runAll_currentSourceCount == 1
            % If the provided source is the first source to be processed in batch mode, 
            % we need to erase old collapsed-source
            fprintf('collapseSources: Clearing existing source %s on level %s...\n', collapsedSource.getName(), cLevelName);
            collapsedSource.P = table();
            collapsedSource.Pdef = {};
        end
        newlyCreated = false;
    end
    
    if collapsedSource.getNumberOfPoints() > 0
        if ismember('SQidx', collapsedSource.P.Properties.VariableNames)
            collapsedSource.P.SQidx = [];
        end
        collapsedSource.P.idx = [];
    end
    
    if ismember('split_idx_global', collapsedSource.P.Properties.VariableNames)
        max_element_id = max(collapsedSource.P.split_idx_global);
    else
        max_element_id = 0; 
    end
    
    splitVariables = settings.splitVars.strings; %{};
    splitLevels = cell(1, numel(splitVariables));
    for k = 1:numel(splitVariables)
        if any(isnan(dsource.P.(splitVariables{k})(pf)))
            fprintf('dspacefcns.Essentials.collapseSources: Warning: %i pts have NaN values for split variable %s.\n',...
                sum(isnan(dsource.P.(splitVariables{k})(pf))), splitVariables{k});
        end
        % Exclude NaNs
        pf2 = pf & ~isnan(dsource.P.(splitVariables{k}));
        splitLevels{k} = unique(dsource.P.(splitVariables{k})(pf2))';
        
        if any(isnan(dsource.P.(splitVariables{k})(pf)))
            splitLevels{k}(end+1) = NaN;
        end
        
        if ~isempty(dsource.Pdef) && isfield(dsource.Pdef, (splitVariables{k}))
            collapsedSource.Pdef.(splitVariables{k}) = dsource.Pdef.(splitVariables{k});
        end
    end
        
    binVariables = settings.binVars.strings;
    binLevels = cell(1, numel(binVariables));
    for k = 1:numel(binVariables)
        if any(isnan(dsource.P.(binVariables{k})(pf)))
            fprintf('dspacefcns.Essentials.collapseSources: Warning: %i pts have NaN values for bin variable %s.\n',...
                sum(isnan(dsource.P.(splitVariables{k})(pf))), binVariables{k});
        end
        % Exclude NaNs
        pf2 = pf & ~isnan(dsource.P.(binVariables{k}));
        binLevels{k} = unique(dsource.P.(binVariables{k})(pf2))';
        
        if any(isnan(dsource.P.(binVariables{k})(pf)))
            binLevels{k}(end+1) = NaN;
        end
        
        if ~isempty(dsource.Pdef) && isfield(dsource.Pdef, (binVariables{k}))
            collapsedSource.Pdef.(binVariables{k}) = dsource.Pdef.(binVariables{k});
        end
    end
      
    targetVariables = settings.targetVars.strings;
        
    if isempty(splitLevels)
        splits = NaN;
    else
        splits = combvec(splitLevels{:});
    end
    
    accTable = table();
    fprintf('dspacefcns.Essentials.collapseSources: Processing %i splits... ', size(splits, 2)); tic();
    
    for splitId = 1:size(splits, 2)
        pfsplit = pf;
        if ~isempty(splitLevels)
            for kk = 1:numel(splitVariables)
                if ~isnan(splits(kk, splitId))
                    pfsplit = pfsplit & dsource.P.(splitVariables{kk}) == splits(kk, splitId);
                else
                    pfsplit = pfsplit & isnan(dsource.P.(splitVariables{kk}));
                end
            end
        end
        
        subTable = collapseSelection(dsource, pfsplit, binVariables, binLevels, targetVariables,...
            settings.doPrctiles);
        
        if settings.meanSubtract || settings.zscore
            if settings.meanSubtract
                transf = 'meanSubtract';
            elseif settings.zscore
                transf = 'zscore';
            end
            % subtract the mean over all bins of each split
            for jj = 1:numel(targetVariables)
                subTable.(sprintf('mean_%s', targetVariables{jj})) = ...
                    transform(subTable.(sprintf('mean_%s', targetVariables{jj})), transf);
                
                subTable.(sprintf('median_%s', targetVariables{jj})) =...
                    transform(subTable.(sprintf('median_%s', targetVariables{jj})), transf);
                
                subTable.(sprintf('var_%s', targetVariables{jj})) =...
                    transform(subTable.(sprintf('var_%s', targetVariables{jj})), transf);
                
                if settings.doPrctiles
                    subTable.(sprintf('percentile5th_%s', targetVariables{jj})) =...
                        transform(subTable.(sprintf('percentile5th_%s', targetVariables{jj})), transf);
                
                    subTable.(sprintf('percentile95th_%s', targetVariables{jj})) =...
                        transform(subTable.(sprintf('percentile95th_%s', targetVariables{jj})), transf);
                end
            end
        end
        
        n = size(subTable, 1);
        for kk = 1:numel(splitVariables)
            subTable.(splitVariables{kk}) = repmat(splits(kk, splitId), n, 1);
        end
        subTable.split_idx_global = repmat(splitId, n, 1);        
        accTable = [accTable ; subTable];
        if size(splits, 2) < 15 || mod(splitId, floor(size(splits, 2)/20)) == 1
            fprintf('.');
        end
    end
    toc(); %fprintf('\n');
    
    accTable.split_idx_global = accTable.split_idx_global + max_element_id;
    accTable.source_idx = repmat(sourceId, size(accTable, 1), 1);
    
    collapsedSource.P = [collapsedSource.P; accTable];
   
    results = [];
    results.settings = settings;
    
    collapsedSource.P.idx = (1:collapsedSource.getNumberOfPoints())';
    
    %     if numel(binVariables) == 1
    %         settings = [];
    %         settings.sequenceVariable = 'idx';
    %         settings.condition = 'P.split_idx_global(sources) == P.split_idx_global(targets)';
    %         settings.k = 1;
    %         settings.varstem = 'SQ';
    %         view = Dataview.getConfiguredDefaultView(collapsedSource);
    %         [~, ~, results] = dspacefcns.createSequenceVariable(view, settings);
    %     end
    
    %sort columns
    collapsedSource.P = collapsedSource.P(:, sort(collapsedSource.P.Properties.VariableNames));

    if settings.discardEmptyBins
        not_empty = collapsedSource.P.nPts > 0;
        if any(collapsedSource.P.nPts == 0)
            fprintf('Discarding %i bins because nPts == 0.\n', sum(collapsedSource.P.nPts == 0));
        end
        collapsedSource.reindexDatasource(find(not_empty)); %#ok<FNDSB>
    end
    
    if newlyCreated
        dsource.parentCollection.insertSource(collapsedSource, cLevelName);
    end
    
end

function subTable = collapseSelection(source, pf, binVariables, binLevels, targetVariables, doPercentiles)
    
    bins = combvec(binLevels{:});
    %allVarNames = {};
    allVarNames = binVariables; 
    allVarTypes = {};
    for jj = 1:numel(targetVariables)
        if doPercentiles
            allVarNames(end+1:end+7) = {sprintf('mean_%s', targetVariables{jj}),...
                sprintf('median_%s', targetVariables{jj}),...
                sprintf('var_%s', targetVariables{jj}),...
                sprintf('percentile5th_%s', targetVariables{jj}),....
                sprintf('percentile95th_%s', targetVariables{jj}),...
                sprintf('nNaNs_%s', targetVariables{jj})};
            allVarTypes(end+1:end+6) = {'double'};
        else
            allVarNames(end+1:end+4) = {sprintf('mean_%s', targetVariables{jj}),...
                sprintf('median_%s', targetVariables{jj}),...
                sprintf('var_%s', targetVariables{jj}),...
                sprintf('nNaNs_%s', targetVariables{jj})};
            allVarTypes(end+1:end+5) = {'double'};
        end
    end
    
    allVarNames{end+1} = 'nPts';
    allVarTypes{end+1} = 'double';
    
    %subTable = table('size', [numel(bins), numel(allVarNames)], 'VariableNames',...
    %     allVarNames, 'variableTypes', allVarTypes);
    %subTable(1:numel(bins), 1:numel(allVarNames)) = {NaN};
    subTable = array2table(NaN(size(bins, 2), numel(allVarNames)));
    subTable.Properties.VariableNames = allVarNames;
    
    % Circumvent slowdown due to custody monitoring of repeated access to
    % the same variables
    all_targ_vals = cell(1, numel(targetVariables));
    for jj = 1:numel(targetVariables)
        all_targ_vals{jj} = source.P.(targetVariables{jj});
    end
    
    for binId = 1:size(bins, 2)
        
        pfbin = pf;
        for kk = 1:numel(binVariables)
            subTable.(binVariables{kk})(binId) = bins(kk, binId);
            if ~isnan(bins(kk, binId))
                pfbin = pfbin & source.P.(binVariables{kk}) == bins(kk, binId);
            else
                pfbin = pfbin & isnan(source.P.(binVariables{kk}));
            end
        end
        pfbin = find(pfbin);
        for jj = 1:numel(targetVariables)
            targ_vals = all_targ_vals{jj}(pfbin);
            subTable.(sprintf('mean_%s', targetVariables{jj}))(binId) = nanmean(targ_vals);
            subTable.(sprintf('median_%s', targetVariables{jj}))(binId) = nanmedian(targ_vals);
            subTable.(sprintf('var_%s', targetVariables{jj}))(binId) = nanvar(targ_vals);
            if doPercentiles
                subTable.(sprintf('percentile5th_%s', targetVariables{jj}))(binId) = prctile(targ_vals, 5);
                subTable.(sprintf('percentile95th_%s', targetVariables{jj}))(binId) = prctile(targ_vals, 95);
            end
            subTable.(sprintf('nNaNs_%s', targetVariables{jj}))(binId) = sum(isnan(targ_vals));
        end
        subTable.nPts(binId) = numel(pfbin);
        
    end
    
end

function x = transform(x, transf)
    xnn = x(~isnan(x));
    switch transf
        case 'meanSubtract'
            x = x - mean(xnn(:));
        case 'zscore'
            xvar = var(xnn);
            x = (x - mean(xnn))/sqrt(xvar);
    end       
end
   

