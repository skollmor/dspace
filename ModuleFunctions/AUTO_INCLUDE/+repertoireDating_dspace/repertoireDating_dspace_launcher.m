function [ titleStr, settings, results ] = repertoireDating_dspace_launcher( dataview, settings )
    % This function computes/plots repertoire dating statistics and mixing matrices.
    % This function can launch the following repertoire dating functions:
    % 
    % 
    % <a href="matlab:doc('repertoireDating.renditionPercentiles')">repertoireDating.renditionPercentiles</a>
    %
    % <a href="matlab:doc('repertoireDating.percentiles')">repertoireDating.percentiles</a>
    %
    % <a href="matlab:doc('repertoireDating.plotPercentiles')">repertoireDating.plotPercentiles</a>
    %
    % <a href="matlab:doc('repertoireDating.mixingMatrix')">repertoireDating.mixingMatrix</a>
    %
    % <a href="matlab:doc('repertoireDating.stratifiedMixingMatrices')">repertoireDating.stratifiedMixingMatrices</a>
    %
    % <a href="matlab:doc('repertoireDating.visualizeStratifiedMixingMatrix')">repertoireDating.visualizeStratifiedMixingMatrix</a>
    %
    %
    % See also repertoireDating.mixingMatrix, repertoireDating.percentiles, repertoireDating.renditionPercentiles, repertoireDating.stratifiedMixingMatrices, repertoireDating.visualizeStratifiedMixingMatrix.
    %
    %
    %
    % 
    % ---
    % Copyright (C) 2020 University Zurich, Sepp Kollmorgen
    % 
    % Reference (please cite):
    % Kollmorgen, S., Hahnloser, R.H.R. & Mante, V. Nearest neighbours reveal
    % fast and slow components of motor learning. Nature 577, 526-530 (2020).
    % https://doi.org/10.1038/s41586-019-1892-x
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
    %
    % Repertoire-Dating on Github: <a href="matlab:web('https://github.com/skollmor/repertoireDating', '-browser')">https://github.com/skollmor/repertoireDating</a>
    % Dataspace on Github: <a href="matlab:web('https://github.com/skollmor/dspace', '-browser')">https://github.com/skollmor/dspace</a>


    titleStr = 'Essentials/Graphs/Repertoire Dating Analyses';
    
    if nargin == 0, return, end
    
    source = dataview.getDatasource();
    labelNames = source.getPropertyNames();
    pf = dataview.getPointFilter();
    np = source.N;
    graphNames = source.getGraphNames();  
    featureNames = source.getFeatureNames();
    
    defaultSettings = {'Description' , sprintf('Repertoire Dating & Mixing Matrices (%i/%i Pts in Filter).', sum(pf), np),...
            'WindowWidth', 700, 'ControlWidth', 400,...
            'separator', 'Graph & Labels',...
            {'Graph (for 1-3)', 'graphName'}, graphNames,...
            {'Features (for 4)', 'featureName'}, featureNames,...
            {'Epoch Label', 'epochName'}, labelNames,...
            {'SubEpoch Label', 'subEpochName'}, labelNames,...           
            'separator', 'Analyses to Compute',...
            {'1 - Repertoire Time', 'doRepTime'}, false,...
            {'2 - Percentiles', 'doPercentiles'}, false,...
            {'3 - Mixing Matrix', 'doMixing'}, false,...
            {'4 (& 1) - Stratified Mixing Matrix', 'doStratifiedMixing'}, false,...
            {'2 & 4 - Epochs to Consider', 'epochsForAvg'}, '16:25'};
    
    if nargin < 2 || isempty(settings)
        settings = defaultSettings;
        return;
    end
    
    graph = source.G(settings.graphName);
    selection = find(pf);
    
    if settings.doRepTime || settings.doPercentiles || settings.doMixing || settings.doStratifiedMixing
        
        if ~graph.isInitialized()
            fprintf('Initializing Graph...\n');
            graph.initialize(source);
        end
            
        % The element itself is not part of the connected node list for k-NN graphs
        fprintf('Querrying graph...\n');
        % connectedIds refers to the entire dataset (all datapoints in source)
        NNids = graph.getConnectedNodes(selection); %#ok<FNDSB>
        fprintf('done.\n');
        epoch = source.L.(settings.epochName);
        subEpoch = source.L.(settings.subEpochName);
        
        results = [];
        if settings.doRepTime || settings.doStratifiedMixing
            repTime = repertoireDating.renditionPercentiles(NNids, epoch, 'valid', pf, 'percentiles', 50);
            results.repTime = repTime;
        end
        
        if settings.doPercentiles
            fprintf('Computing percentiles... ');
            uEpochSelection = eval(settings.epochsForAvg);
            [RPD, RPD_epoch, RPD_subEpoch] = repertoireDating.percentiles(NNids, epoch, subEpoch, 'valid', pf);
            repertoireDating.plotPercentiles(RPD, RPD_epoch, RPD_subEpoch, uEpochSelection);
            fprintf('done.\n');
            results.percentiles = RPD;
            results.epochs = RPD_epoch;
            results.supEpoch = RPD_subEpoch;
        end
        
        if settings.doMixing
            fprintf('Computing Mixing Matrix... ');
            results.MM = repertoireDating.mixingMatrix(NNids, epoch, 'valid', pf, 'doPlot', true);
            fprintf('done.\n');
        end
        
        if settings.doStratifiedMixing
            fprintf('Computing stratified mixing matrices...\n');
            uEpochSelection = eval(settings.epochsForAvg);
            features = source.F(settings.featureName);
            %data = features.getMatrix(1:np);
            data_ = features.getMatrix(selection);
            epoch_ = epoch(selection);
            subEpoch_ = subEpoch(selection);
            repTime_ = repTime; % already partial
            % RP is the repertoire time (50th percentile)
            % stratMM = repertoireDating.stratifiedMixingMatrices(data, epoch,...
            %    subEpoch, repTime, 'valid', pf, 'uEpochs', uEpochSelection);
            stratMM = repertoireDating.stratifiedMixingMatrices(data_, epoch_,...
                subEpoch_, repTime_, 'uEpochs', uEpochSelection);
            % Avg the stratified mixing matrices
            C = arrayfun(@(i) stratMM.allMMs{i}.log2CountRatio, 1:numel(stratMM.allMMs), 'uni', false);
            avgStratMM = nanmean(cat(3, C{:}), 3);
            % Visualize through MDS
            repertoireDating.visualizeStratifiedMixingMatrix(avgStratMM, stratMM);
            
            results.stratMM = stratMM;
            results.avgStratMM = avgStratMM;
            fprintf('Stratified mixing matrices done.\n');
            
        end
        
    end
   
end